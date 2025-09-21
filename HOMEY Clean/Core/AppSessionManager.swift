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
    #endif
    private let profiles: ProfilesProviding
    private let profileManager: UserProfileManager

    #if canImport(Supabase)
        private init(client: SupabaseClient? = nil, profiles: ProfilesProviding? = nil) {
            if let client = client {
                self.client = client
            } else {
                // Default Supabase client initialization
                let supabaseURL = URL(string: "https://mzqswvyfnblghgvcgxpw.supabase.co")!
                let supabaseKey = """
                eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.\
                0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0
                """
                self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
            }
            self.profiles = profiles ?? RealSupabaseProfilesService(client: self.client)
            self.profileManager = UserProfileManager(client: self.client)
            startAuthListener()
            
            // Check for existing session on initialization
            Task { @MainActor in
                await checkExistingSession()
            }
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
            isAuthenticated = true
            userRole = "client"
            clientSegment = "buyer"
            currentJourneyStage = .exploring
            
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
            userProfile = demoProfile
            return
        }
        
        #if canImport(Supabase)
            do {
                _ = try await client.auth.signIn(email: email, password: password)
                isAuthenticated = client.auth.currentSession != nil
                if let session = client.auth.currentSession { 
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
            isAuthenticated = true
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

    func restoreIfPossible() async {
        #if canImport(Supabase)
            do {
                // Check if there's already a valid session
                if let session = client.auth.currentSession {
                    isAuthenticated = true
                    await hydrateFrom(session)
                    return
                }
                
                // Try to refresh the session
                let session = try await client.auth.session
                isAuthenticated = true
                await hydrateFrom(session)
            } catch {
                // Handle different error types
                if let authError = error as? AuthError {
                    switch authError {
                    case .sessionMissing:
                        // Session doesn't exist - user needs to sign in
                        await signOutLocalOnly()
                    default:
                        // Other auth errors - could be network issues
                        print("Auth error during restore: \(authError)")
                    }
                } else {
                    // Network or other errors - don't sign out, just log
                    print("Error restoring session: \(error)")
                }
            }
        #endif
    }
    
    #if canImport(Supabase)
    private func checkExistingSession() async {
        // Check for existing session on app startup
        if let session = client.auth.currentSession {
            isAuthenticated = true
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
    #endif

    func signOut() async {
        #if canImport(Supabase)
            _ = try? await client.auth.signOut()
        #endif
        await signOutLocalOnly()
    }
}

extension AppSessionManager {
    #if canImport(Supabase)
        private func hydrateFrom(_ session: Session) async {
            let uid: UUID = session.user.id
            let userEmail = session.user.email ?? "unknown"
            
            print("[AppSessionManager] Hydrating profile for user: \(uid) (\(userEmail))")
            
            do {
                // Load comprehensive user profile
                await profileManager.loadProfile(for: uid)
                
                if let profile = profileManager.currentProfile {
                    print("[AppSessionManager] Profile loaded successfully: role=\(profile.role), segment=\(profile.clientSegment ?? "none")")
                    userRole = profile.role
                    clientSegment = profile.clientSegment
                    currentJourneyStage = profile.journeyStage
                    userProfile = profile
                } else {
                    print("[AppSessionManager] ProfileManager returned nil, trying direct fetch...")
                    // Fallback to basic profile fetch
                    let info = try await profiles.fetchProfile(for: uid)
                    print("[AppSessionManager] Direct fetch successful: role=\(info.role), segment=\(info.clientSegment ?? "none")")
                    userRole = info.role
                    clientSegment = info.clientSegment
                }
            } catch {
                print("[AppSessionManager] Profile fetch failed: \(error.localizedDescription)")
                
                // Check if this is an RLS policy error
                let errorMsg = error.localizedDescription.lowercased()
                if errorMsg.contains("infinite recursion") || errorMsg.contains("rls") || errorMsg.contains("policy") {
                    print("[AppSessionManager] RLS policy error detected - using email-based role detection")
                    
                    // Use email-based role detection as fallback
                    if userEmail.contains("admin") || userEmail == "control.homie@gmail.com" {
                        userRole = "admin"
                        clientSegment = nil
                    } else if userEmail.contains("agent") {
                        userRole = "agent"
                        clientSegment = nil
                    } else {
                        userRole = "client"
                        clientSegment = "buyer" // Default segment
                    }
                    
                    print("[AppSessionManager] Fallback role assignment: \(userRole)")
                } else {
                    // Fallback to default values if profile fetch fails
                    userRole = "client"
                    clientSegment = nil
                }
                
                currentJourneyStage = .exploring
                userProfile = nil
            }
        }
    #endif

    private func signOutLocalOnly() async {
        isAuthenticated = false
        userRole = "client"
        clientSegment = nil
        currentJourneyStage = .exploring
        userProfile = nil
        
        #if canImport(Supabase)
        // Stop the token refresh timer when signing out
        tokenRefreshTimer?.invalidate()
        tokenRefreshTimer = nil
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
    func shouldShowOnboarding() -> Bool {
        return profileManager.shouldShowOnboarding()
    }
    
    /// Update user's journey stage
    func updateJourneyStage(_ stage: JourneyStage) async {
        currentJourneyStage = stage
        await profileManager.updateJourneyStage(stage)
        if let updatedProfile = profileManager.currentProfile {
            userProfile = updatedProfile
        }
    }
    
    /// Record journey activity for analytics and personalization
    func recordJourneyActivity(_ activity: String, metadata: [String: Any] = [:]) async {
        await profileManager.recordJourneyActivity(activity, metadata: metadata)
        if let updatedProfile = profileManager.currentProfile {
            userProfile = updatedProfile
        }
    }
    
    /// Update user preferences
    func updateUserPreferences(_ preferences: UserPreferences) async {
        await profileManager.updatePreferences(preferences)
        if let updatedProfile = profileManager.currentProfile {
            userProfile = updatedProfile
        }
    }
    
    /// Complete onboarding process
    func completeOnboarding(with profile: UserProfile) async {
        var updatedProfile = profile
        updatedProfile.onboardingCompleted = true
        await profileManager.updateProfile(updatedProfile)
        
        if let finalProfile = profileManager.currentProfile {
            userProfile = finalProfile
            userRole = finalProfile.role
            clientSegment = finalProfile.clientSegment
            currentJourneyStage = finalProfile.journeyStage
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
                    isAuthenticated = true
                    if let session {
                        await hydrateFrom(session)
                    }
                case .signedOut:
                    await signOutLocalOnly()
                case .tokenRefreshed:
                    isAuthenticated = client.auth.currentSession != nil
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