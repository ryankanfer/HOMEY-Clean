//
//  AppSessionManager.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI
#if canImport(Supabase)
    import Supabase
#endif
import Foundation

// Import managers and services used in this file
// OnboardingStateManager is defined in Core/Managers/OnboardingStateManager.swift
// InteractionLogger is defined in Intelligence/Services/InteractionLogger.swift

@MainActor
final class AppSessionManager: ObservableObject {
    static let shared = AppSessionManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var userRole: String = "client"
    @Published var clientSegment: String?
    @Published var currentJourneyStage: JourneyStage = .exploring
    @Published var userProfile: UserProfile?

    #if canImport(Supabase)
        private let client: SupabaseClient
        var supabaseClient: SupabaseClient { client }
        private var authListenerTask: Task<Void, Never>?
        private var tokenRefreshTimer: Timer?
        private var realtime: RealtimeSubscriptions?
    #endif
    private let profiles: ProfilesProviding
    private let profileManager: UserProfileManager
    
    // Track if profile hydration is in progress to prevent duplicate calls
    private var isHydratingProfile = false

    #if canImport(Supabase)
    private init(client: SupabaseClient? = nil, profiles: ProfilesProviding? = nil) {
        if let providedClient = client {
            self.client = providedClient
            self.profiles = profiles ?? RealSupabaseProfilesService(client: self.client)
        } else {
            // Read Supabase credentials from Info.plist
            guard let supabaseURLString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
                  let supabaseURL = URL(string: supabaseURLString),
                  let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
                  !supabaseURLString.isEmpty, !supabaseKey.isEmpty
            else {
                #if DEBUG
                print("==================================================================================")
                print("⚠️ SUPABASE CREDENTIALS NOT FOUND in Info.plist.")
                print("⚠️ The app will run in offline mode. Please ensure SUPABASE_URL and")
                print("⚠️ SUPABASE_ANON_KEY are set correctly in your target's Info.plist.")
                print("==================================================================================")
                #endif
                
                // Initialize with a dummy client to prevent crashes
                self.client = SupabaseClient(supabaseURL: URL(string: "https://invalid.supabase.co")!, supabaseKey: "invalid_key")
                self.profiles = profiles ?? FakeProfilesService()
                self.profileManager = UserProfileManager(client: self.client)
                // Don't start listeners for the dummy client
                return
            }
            
            print("✅ Supabase credentials loaded successfully.")
            self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
            self.profiles = profiles ?? RealSupabaseProfilesService(client: self.client)
        }

        self.profileManager = UserProfileManager(client: self.client)
        startAuthListener()
        self.realtime = RealtimeSubscriptions(client: self.client)
    }
    #else
        private init(profiles: ProfilesProviding = FakeProfilesService()) {
            self.profiles = profiles
            self.profileManager = UserProfileManager()
        }
    #endif

    #if canImport(Supabase)
    deinit {
        authListenerTask?.cancel()
        tokenRefreshTimer?.invalidate()
        Task { @MainActor in
            realtime?.unsubscribeAll()
            realtime = nil
        }
    }
    #endif
}

extension AppSessionManager {
    enum SignInError: LocalizedError {
        case invalidCredentials, emailNotConfirmed, network, unknown(String)
        var errorDescription: String? {
            switch self {
            case .invalidCredentials: return "Email or password is incorrect."
            case .emailNotConfirmed: return "Please confirm your email before signing in."
            case .network: return "Network issue. Try again."
            case let .unknown(m): return m
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        // TEMPORARY: Enable demo mode for test+demo@homey.app
        if email.lowercased() == "test+demo@homey.app" {
            // Demo user setup
            await MainActor.run {
                isAuthenticated = true
                userRole = "client"
                clientSegment = "buyer"
                currentJourneyStage = .exploring
            }
            
            // Create a demo user profile
            let demoProfile = UserProfile(
                id: UUID(),
                email: email.lowercased(),
                fullName: "Demo User",
                role: "client",
                clientSegment: "buyer",
                journeyStage: .exploring,
                preferences: UserPreferences(),
                journeyState: JourneyState(),
                onboardingCompleted: false
            )
            await MainActor.run {
                userProfile = demoProfile
            }
            Task { await UserProfileManager.shared.hydrateOnboardingLifestyleFromBackend() }
            return
        }
        
        #if canImport(Supabase)
            do {
                _ = try await client.auth.signIn(email: email, password: password)
                let session = client.auth.currentSession
                await MainActor.run {
                    isAuthenticated = (session != nil)
                }
                if let session {
                    await hydrateFrom(session)
                    startTokenRefreshTimer(for: session)
                }
            } catch {
                let msg = (error as NSError).localizedDescription.lowercased()
                if msg.contains("invalid") || msg.contains("credential") { throw SignInError.invalidCredentials }
                if msg.contains("confirm") { throw SignInError.emailNotConfirmed }
                if msg.contains("network") || msg.contains("timed out") { throw SignInError.network }
                throw SignInError.unknown((error as NSError).localizedDescription)
            }
        #else
            await MainActor.run {
                isAuthenticated = true
            }
        #endif
    }

    func signUp(email: String, password: String, fullName: String) async throws {
        #if canImport(Supabase)
            do {
                var metadata: [String: AnyJSON] = ["full_name": .string(fullName)]
                
                _ = try await client.auth.signUp(
                    email: email,
                    password: password,
                    data: metadata
                )
                // Auth listener will handle session on verification.
            } catch {
                let msg = (error as NSError).localizedDescription.lowercased()
                if msg.contains("invalid") || msg.contains("credential") { throw SignInError.invalidCredentials }
                if msg.contains("confirm") { throw SignInError.emailNotConfirmed }
                if msg.contains("network") || msg.contains("timed out") { throw SignInError.network }
                throw SignInError.unknown((error as NSError).localizedDescription)
            }
        #else
            await MainActor.run {
                isAuthenticated = true
            }
        #endif
    }

    func resendConfirmation(email: String) async throws {
        #if canImport(Supabase)
            try await client.auth.resend(email: email, type: .signup)
        #endif
    }

    func resetPassword(email: String, redirectTo: URL) async throws {
        #if canImport(Supabase)
            try await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo)
        #endif
    }
    
    // MARK: - Magic Link Callback Handler
    func handleMagicLinkCallback(tokens: [String: String]) async {
        #if canImport(Supabase)
        #if DEBUG
        print("[AppSessionManager] Processing magic link callback with tokens: \(tokens.keys.joined(separator: ", "))")
        print("[AppSessionManager] Token values: \(tokens)")
        #endif
        
        do {
            // Direct tokens (final redirect) path
            if let accessToken = tokens["access_token"],
               let refreshToken = tokens["refresh_token"] {
                #if DEBUG
                print("[AppSessionManager] Found access/refresh tokens, setting session directly")
                #endif
                
                let session = try await client.auth.setSession(
                    accessToken: accessToken,
                    refreshToken: refreshToken
                )
                
                #if DEBUG
                print("[AppSessionManager] Successfully set session from magic link")
                #endif
                
                await MainActor.run {
                    isAuthenticated = true
                    #if DEBUG
                    print("[AppSessionManager] Set isAuthenticated = true on main thread")
                    #endif
                }
                await hydrateFrom(session)
                return
            }
            
            // PKCE intermediate path
            if let pkceToken = tokens["token"],
               let type = tokens["type"],
               ["magiclink", "signup"].contains(type.lowercased()) {
                #if DEBUG
                print("[AppSessionManager] Found PKCE token (\(type)), attempting to resolve session via Supabase")
                #endif
                
                if let current = client.auth.currentSession {
                    await MainActor.run {
                        isAuthenticated = true
                        #if DEBUG
                        print("[AppSessionManager] Set isAuthenticated = true from current session on main thread")
                        #endif
                    }
                    await hydrateFrom(current)
                    return
                }
                
                let session = try await client.auth.session
                await MainActor.run {
                    isAuthenticated = true
                    #if DEBUG
                    print("[AppSessionManager] Set isAuthenticated = true from refreshed session on main thread")
                    #endif
                }
                await hydrateFrom(session)
                return
            }
            
            #if DEBUG
            print("[AppSessionManager] No recognized tokens; attempting restoreIfPossible()")
            #endif
            await restoreIfPossible()
            
        } catch {
            #if DEBUG
            print("[AppSessionManager] Error processing magic link callback: \(error)")
            #endif
            await restoreIfPossible()
        }
        #endif
    }

    func restoreIfPossible() async {
        print("[AppSessionManager] Starting session restoration...")
        
        do {
            // Add timeout to prevent hanging during session restoration
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                throw CancellationError()
            }
            
            let restoreTask = Task {
                print("[AppSessionManager] Attempting to restore session from Supabase...")
                let session = try await client.auth.session
                print("[AppSessionManager] Session restored successfully for user: \(session.user.id)")
                
                await MainActor.run {
                    isAuthenticated = true
                }
                
                print("[AppSessionManager] Starting profile hydration...")
                await hydrateFrom(session)
                print("[AppSessionManager] Profile hydration completed")
            }
            
            // Race between timeout and session restoration
            _ = try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await timeoutTask.value }
                group.addTask { try await restoreTask.value }
                
                // Wait for first to complete
                try await group.next()
                
                // Cancel remaining tasks
                group.cancelAll()
            }
            
        } catch {
            print("[AppSessionManager] Session restoration failed: \(error.localizedDescription)")
            
            if error is CancellationError {
                print("[AppSessionManager] Session restoration timed out - proceeding with unauthenticated state")
                await MainActor.run {
                    isAuthenticated = false
                }
                // Additional debugging to ensure state is properly updated
                print("[AppSessionManager] isAuthenticated set to false after timeout")
                return
            }
            
            if let authError = error as? AuthError {
                switch authError {
                case .sessionMissing:
                    print("[AppSessionManager] No session found - user needs to sign in")
                    await signOut()
                default:
                    print("[AppSessionManager] Auth error: \(authError.localizedDescription)")
                    await signOut()
                }
            } else {
                print("[AppSessionManager] Unexpected error during session restoration: \(error)")
                await signOut()
            }
        }
    }
    
    #if canImport(Supabase)
    private func checkExistingSession() async {
        // Check for existing session on app startup
        if let session = client.auth.currentSession {
            await MainActor.run {
                isAuthenticated = true
            }
            await hydrateFrom(session)
        } else {
            // Try to restore session from stored tokens
            await restoreIfPossible()
        }
    }
    #endif
    
    #if canImport(Supabase)
    private func startTokenRefreshTimer(for session: Session) {
        // Invalidate existing timer
        tokenRefreshTimer?.invalidate()
        
        // Calculate when to refresh (5 minutes before expiry)
        let expiresAt = Date(timeIntervalSince1970: TimeInterval(session.expiresAt))
        let refreshTime = expiresAt.addingTimeInterval(-300) // 5 minutes before expiry
        let timeUntilRefresh = refreshTime.timeIntervalSinceNow
        
        print("🔄 Token expires at: \(expiresAt)")
        print("🔄 Will refresh in: \(timeUntilRefresh) seconds")
        
        // Only set timer if refresh time is in the future
        guard timeUntilRefresh > 0 else {
            print("⚠️ Token already expired or expires soon, refreshing immediately")
            Task {
                await refreshTokenIfNeeded()
            }
            return
        }
        
        // Set timer to refresh token
        tokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: timeUntilRefresh, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshTokenIfNeeded()
            }
        }
    }
    
    private func refreshTokenIfNeeded() async {
        guard client.auth.currentSession != nil else {
            print("❌ No session to refresh")
            return
        }
        
        do {
            print("🔄 Refreshing token...")
            let refreshedSession = try await client.auth.refreshSession()
            print("✅ Token refreshed successfully")
            
            // Start new timer for the refreshed session
            startTokenRefreshTimer(for: refreshedSession)
        } catch {
            print("❌ Token refresh failed: \(error.localizedDescription)")
            
            // Check if it's a network error
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("network") || errorMessage.contains("internet") || errorMessage.contains("connection") {
                print("🌐 Network error during refresh, will retry later")
                // Schedule retry in 5 minutes
                tokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
                    Task { @MainActor in
                        await self?.refreshTokenIfNeeded()
                    }
                }
            } else {
                // Non-network error, sign out
                await signOutLocalOnly()
            }
        }
    }

    private func startRealtimeSubscriptions() {
        guard let realtime else { return }
        // Avoid duplicate subscriptions by clearing any existing first
        realtime.unsubscribeAll()
        realtime.subscribeOnboardingProfiles { payload in
            print("Onboarding profile changed: \(payload)")
        }
        realtime.subscribeDocuments { payload in
            print("Document changed: \(payload)")
        }
        realtime.subscribeShowingRequests { payload in
            print("Showing request changed: \(payload)")
        }
        realtime.subscribeMessages { payload in
            print("Message changed: \(payload)")
        }
    }
    #endif

    func signOut() async {
        #if canImport(Supabase)
            _ = try? await client.auth.signOut()
        #endif
        await signOutLocalOnly()
    }
}

// MARK: - New extension for onboarding lifestyle answers

extension AppSessionManager {
    /// Single-source accessor for onboarding lifestyle answers so views that only
    /// hold the session can read them without importing UserProfileManager.
    var onboardingLifestyle: [String: String] {
        UserProfileManager.shared.onboardingLifestyle
    }
}

extension AppSessionManager {
    #if canImport(Supabase)
        private func hydrateFrom(_ session: Session) async {
            // Prevent duplicate hydration calls
            guard !isHydratingProfile else {
                print("[AppSessionManager] Profile hydration already in progress, skipping duplicate call")
                return
            }
            
            isHydratingProfile = true
            defer { 
                Task { @MainActor in
                    self.isHydratingProfile = false
                }
            }
            
            let uid: UUID = session.user.id
            let userEmail = session.user.email ?? "unknown"
            
            print("[AppSessionManager] Hydrating profile for user: \(uid) (\(userEmail))")
            
            do {
                // Add timeout to prevent hanging during profile fetch
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 8_000_000_000) // 8 seconds
                    throw CancellationError()
                }
                
                let profileTask = Task {
                    // Load comprehensive user profile using ProfilesRepository
                    let profilesRepository = ProfilesRepository()
                    let profileRecord = try await profilesRepository.fetchProfile(for: uid)
                    
                    print("[AppSessionManager] ProfileRecord loaded successfully: role=\(profileRecord.role), segment=\(profileRecord.clientSegment ?? "none")")
                    
                    // Update session state from ProfileRecord
                    await MainActor.run {
                        userRole = profileRecord.role
                        clientSegment = profileRecord.clientSegment
                    }
                    
                    // Load or create UserProfile for journey management
                    await profileManager.loadProfile(for: uid)
                    
                    if let profile = profileManager.currentProfile {
                        print("[AppSessionManager] UserProfile loaded successfully: stage=\(profile.journeyStage)")
                        await MainActor.run {
                            currentJourneyStage = profile.journeyStage
                            userProfile = profile
                        }
                    } else {
                        // Create UserProfile from ProfileRecord if not exists
                        let newUserProfile = profileRecord.toUserProfile()
                        await MainActor.run {
                            userProfile = newUserProfile
                            currentJourneyStage = newUserProfile.journeyStage
                        }
                        print("[AppSessionManager] Created UserProfile from ProfileRecord")
                    }

                    await MainActor.run {
                        CrossScreenContext.shared.hydrateFromProfileIfAvailable()
                    }

                    Task { await UserProfileManager.shared.hydrateOnboardingLifestyleFromBackend() }
                    
                    // Start realtime subscriptions after hydration
                    startRealtimeSubscriptions()
                }
                
                // Race between timeout and profile hydration
                _ = try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask { try await timeoutTask.value }
                    group.addTask { try await profileTask.value }
                    
                    // Wait for first to complete
                    try await group.next()
                    
                    // Cancel remaining tasks
                    group.cancelAll()
                }
                
            } catch {
                print("[AppSessionManager] Profile fetch failed: \(error.localizedDescription)")
                
                if error is CancellationError {
                    print("[AppSessionManager] Profile hydration timed out - using fallback values")
                    // Use email-based role detection as fallback for timeout
                    let role: String
                    let segment: String?
                    if userEmail.contains("admin") || userEmail == "control.homie@gmail.com" {
                        role = "admin"; segment = nil
                    } else if userEmail.contains("agent") {
                        role = "agent"; segment = nil
                    } else {
                        role = "client"; segment = "buyer"
                    }
                    
                    await MainActor.run {
                        userRole = role
                        clientSegment = segment
                        currentJourneyStage = .exploring
                        userProfile = nil
                    }
                    
                    print("[AppSessionManager] Timeout fallback role assignment: \(userRole)")
                    return
                }
                
                // Check if this is an RLS policy error
                let errorMsg = error.localizedDescription.lowercased()
                if errorMsg.contains("infinite recursion") || errorMsg.contains("rls") || errorMsg.contains("policy") {
                    print("[AppSessionManager] RLS policy error detected - using email-based role detection")
                    
                    // Use email-based role detection as fallback
                    let role: String
                    let segment: String?
                    if userEmail.contains("admin") || userEmail == "control.homie@gmail.com" {
                        role = "admin"; segment = nil
                    } else if userEmail.contains("agent") {
                        role = "agent"; segment = nil
                    } else {
                        role = "client"; segment = "buyer"
                    }
                    
                    await MainActor.run {
                        userRole = role
                        clientSegment = segment
                    }
                    
                    print("[AppSessionManager] Fallback role assignment: \(userRole)")
                } else {
                    // Fallback to default values if profile fetch fails
                    await MainActor.run {
                        userRole = "client"
                        clientSegment = nil
                    }
                }
                
                await MainActor.run {
                    currentJourneyStage = .exploring
                    userProfile = nil
                }
            }
        }
    #endif

    private func signOutLocalOnly() async {
        await MainActor.run {
            isAuthenticated = false
            userRole = "client"
            clientSegment = nil
            currentJourneyStage = .exploring
            userProfile = nil
        }
        
        #if canImport(Supabase)
        // Stop the token refresh timer when signing out
        tokenRefreshTimer?.invalidate()
        tokenRefreshTimer = nil
        
        // Stop realtime subscriptions when signing out
        Task { @MainActor in
            realtime?.unsubscribeAll()
        }
        #endif
    }
}

// MARK: - Contextual Authentication Extensions

extension AppSessionManager {
    /// Get contextual greeting based on user's journey stage and time of day
    func getContextualGreeting() -> String {
        return profileManager.getContextualGreeting()
    }
    
    /// Get recommended actions based on current journey stage
    func getRecommendedActions() -> [String] {
        return profileManager.getRecommendedActions()
    }
    
    /// Check if user should see onboarding flow
    func shouldShowOnboarding() async -> Bool {
        // Check both profile manager and onboarding state manager
        let profileNeedsOnboarding = profileManager.shouldShowOnboarding()
        let onboardingRequired = await MainActor.run {
            OnboardingStateManager.shared.isOnboardingRequired
        }
        return profileNeedsOnboarding || onboardingRequired
    }
    
    /// Update user's journey stage
    func updateJourneyStage(_ stage: JourneyStage) async {
        let previous = currentJourneyStage
        await MainActor.run {
            currentJourneyStage = stage
        }
        await profileManager.updateJourneyStage(stage)
        if let updatedProfile = profileManager.currentProfile {
            await MainActor.run {
                userProfile = updatedProfile
            }
        }
        Task {
            await InteractionLogger.shared.captureJourneyStageChange(from: previous, to: stage, page: .homey)
        }
    }
    
    /// Record journey activity for analytics and personalization
    func recordJourneyActivity(_ activity: String, metadata: [String: Any] = [:]) async {
        await profileManager.recordJourneyActivity(activity, metadata: metadata)
        if let updatedProfile = profileManager.currentProfile {
            await MainActor.run {
                userProfile = updatedProfile
            }
        }
    }
    
    /// Update user preferences
    func updateUserPreferences(_ preferences: UserPreferences) async {
        await profileManager.updatePreferences(preferences)
        if let updatedProfile = profileManager.currentProfile {
            await MainActor.run {
                userProfile = updatedProfile
            }
        }
    }
    
    /// Complete onboarding process
    func completeOnboarding(with profile: UserProfile) async {
        var updatedProfile = profile
        updatedProfile.onboardingCompleted = true
        await profileManager.updateProfile(updatedProfile)
        
        if let finalProfile = profileManager.currentProfile {
            await MainActor.run {
                userProfile = finalProfile
                userRole = finalProfile.role
                clientSegment = finalProfile.clientSegment
                currentJourneyStage = finalProfile.journeyStage
            }
        }
        
        // Notify onboarding state manager of completion
        await MainActor.run {
            OnboardingStateManager.shared.forceCompleteOnboarding()
        }
    }
    
    /// Get user's progress in current journey stage
    func getJourneyProgress() -> Double {
        guard let profile = userProfile else { return 0.0 }
        
        let totalMilestones = profile.journeyStage.smartPicksItems.count
        let completedMilestones = profile.journeyState.completedMilestones.count
        
        return totalMilestones > 0 ? Double(completedMilestones) / Double(totalMilestones) : 0.0
    }
    
    /// Check if user has specific permissions based on role and journey stage
    func hasPermission(for feature: String) -> Bool {
        switch feature {
        case "admin_dashboard":
            return userRole == "admin"
        case "agent_tools":
            return userRole == "agent" || userRole == "admin"
        case "advanced_search":
            return userProfile?.preferences.advancedFeatures == true
        case "property_alerts":
            return currentJourneyStage == .researching || currentJourneyStage == .viewing
        case "negotiation_tools":
            return currentJourneyStage == .negotiating || currentJourneyStage == .closing
         default:
             return true
         }
     }
     
     /// Get contextual navigation items based on user state
     func getContextualNavigation() -> [NavigationItem] {
         var items: [NavigationItem] = []
         
         // Always show core features
         items.append(NavigationItem(title: "Home", icon: "house", destination: "home"))
         
         // Journey-specific items
         switch currentJourneyStage {
         case .exploring:
             items.append(NavigationItem(title: "Explore", icon: "map", destination: "explore"))
             items.append(NavigationItem(title: "Budget", icon: "dollarsign.circle", destination: "budget"))
         case .researching:
             items.append(NavigationItem(title: "Search", icon: "magnifyingglass", destination: "search"))
             items.append(NavigationItem(title: "Neighborhoods", icon: "building.2", destination: "neighborhoods"))
         case .viewing:
             items.append(NavigationItem(title: "Tours", icon: "calendar", destination: "tours"))
             items.append(NavigationItem(title: "Saved", icon: "heart", destination: "saved"))
         case .negotiating:
             items.append(NavigationItem(title: "Offers", icon: "doc.text", destination: "offers"))
             items.append(NavigationItem(title: "Financing", icon: "creditcard", destination: "financing"))
         case .closing:
             items.append(NavigationItem(title: "Checklist", icon: "checkmark.circle", destination: "checklist"))
             items.append(NavigationItem(title: "Documents", icon: "folder", destination: "documents"))
         case .settled:
             items.append(NavigationItem(title: "Home Care", icon: "wrench", destination: "homecare"))
             items.append(NavigationItem(title: "Community", icon: "person.3", destination: "community"))
         }
         
         // Role-specific items
         if userRole == "admin" {
             items.append(NavigationItem(title: "Admin", icon: "gear", destination: "admin"))
         }
         
         if userRole == "agent" || userRole == "admin" {
             items.append(NavigationItem(title: "Agent Tools", icon: "briefcase", destination: "agent"))
         }
         
         return items
     }
 }
 
 // MARK: - Navigation Item Model
 
 struct NavigationItem {
     let title: String
     let icon: String
     let destination: String
     let badge: String?
     
     init(title: String, icon: String, destination: String, badge: String? = nil) {
         self.title = title
         self.icon = icon
         self.destination = destination
         self.badge = badge
     }
 }

#if canImport(Supabase)
extension AppSessionManager {
    private func startAuthListener() {
        authListenerTask?.cancel()
        authListenerTask = Task { [weak self] in
            guard let self else { return }
            for await (event, session) in client.auth.authStateChanges {
                switch event {
                case .signedIn:
                    await MainActor.run { self.isAuthenticated = true }
                    if let session {
                        await hydrateFrom(session)
                    }
                case .signedOut:
                    await signOutLocalOnly()
                case .tokenRefreshed:
                    await MainActor.run { isAuthenticated = client.auth.currentSession != nil }
                    if let session {
                        await hydrateFrom(session)
                    }
                case .userUpdated:
                    if let session {
                        await hydrateFrom(session)
                    }
                default:
                    break
                }
            }
        }
    }
}
#endif

extension AppSessionManager {
    /// Returns a merged view of lifestyle signals (preferences preferred, then onboarding cache).
    func getMergedLifestyleSignals() async -> [String: String] {
        await UserProfileManager.shared.mergedLifestyleSignals()
    }
}