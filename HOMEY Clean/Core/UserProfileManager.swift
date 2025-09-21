//
//  UserProfileManager.swift
//  HOMEY Clean
//
//  Enhanced user profile and journey state management
//

import SwiftUI
import Foundation
#if canImport(Supabase)
    import Supabase
#endif

// HomepageCustomization model is defined in the same project

// MARK: - Enhanced User Profile Models

public struct UserProfile: Codable {
    public let id: UUID
    public let email: String
    public var fullName: String?
    public var role: String
    public var clientSegment: String?
    public var journeyStage: JourneyStage
    public var preferences: UserPreferences
    public var journeyState: JourneyState
    public var onboardingCompleted: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public var currentGoals: [String] {
        return Array(journeyState.currentGoals)
    }
    
    public init(
        id: UUID,
        email: String,
        fullName: String? = nil,
        role: String = "client",
        clientSegment: String? = nil,
        journeyStage: JourneyStage = .exploring,
        preferences: UserPreferences = UserPreferences(),
        journeyState: JourneyState = JourneyState(),
        onboardingCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.role = role
        self.clientSegment = clientSegment
        self.journeyStage = journeyStage
        self.preferences = preferences
        self.journeyState = journeyState
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct UserPreferences: Codable {
    public var pushNotifications: Bool = true
    public var emailSummaries: Bool = true
    public var guidedTours: Bool = true
    public var advancedFeatures: Bool = false
    public var darkMode: Bool = false
    public var preferredCommunicationTime: String = "morning" // morning, afternoon, evening
    public var marketingConsent: Bool = false
    public var savedNeighborhoods: [String] = []
    public var homepageCustomization: HomepageCustomization = HomepageCustomization.defaultCustomization
    
    public static let shared = UserPreferences()
    
    public init(
        pushNotifications: Bool = true,
        emailSummaries: Bool = true,
        guidedTours: Bool = true,
        advancedFeatures: Bool = false,
        darkMode: Bool = false,
        preferredCommunicationTime: String = "morning",
        marketingConsent: Bool = false,
        savedNeighborhoods: [String] = [],
        homepageCustomization: HomepageCustomization = HomepageCustomization.defaultCustomization
    ) {
        self.pushNotifications = pushNotifications
        self.emailSummaries = emailSummaries
        self.guidedTours = guidedTours
        self.advancedFeatures = advancedFeatures
        self.darkMode = darkMode
        self.preferredCommunicationTime = preferredCommunicationTime
        self.marketingConsent = marketingConsent
        self.savedNeighborhoods = savedNeighborhoods
        self.homepageCustomization = homepageCustomization
    }
}

public struct JourneyState: Codable {
    public var currentGoals: [String] = []
    public var completedMilestones: [String] = []
    public var savedProperties: [String] = []
    public var viewedProperties: [String] = []
    public var scheduledTours: [String] = []
    public var activeSearchCriteria: SearchCriteria?
    public var lastActivityDate: Date = Date()
    public var sessionCount: Int = 0
    public var totalTimeSpent: TimeInterval = 0
    public var progressMetrics: [String: Double] = [:]
    public var activities: [JourneyActivity] = []
    public var stageHistory: [JourneyStageTransition] = []
    
    public init(
        currentGoals: [String] = [],
        completedMilestones: [String] = [],
        savedProperties: [String] = [],
        viewedProperties: [String] = [],
        scheduledTours: [String] = [],
        activeSearchCriteria: SearchCriteria? = nil,
        lastActivityDate: Date = Date(),
        sessionCount: Int = 0,
        totalTimeSpent: TimeInterval = 0,
        progressMetrics: [String: Double] = [:]
    ) {
        self.currentGoals = currentGoals
        self.completedMilestones = completedMilestones
        self.savedProperties = savedProperties
        self.viewedProperties = viewedProperties
        self.scheduledTours = scheduledTours
        self.activeSearchCriteria = activeSearchCriteria
        self.lastActivityDate = lastActivityDate
        self.sessionCount = sessionCount
        self.totalTimeSpent = totalTimeSpent
        self.progressMetrics = progressMetrics
    }
    
    public mutating func recordActivity() {
        lastActivityDate = Date()
        sessionCount += 1
    }
    
    public mutating func addGoal(_ goal: String) {
        if !currentGoals.contains(goal) {
            currentGoals.append(goal)
        }
    }
    
    public mutating func completeGoal(_ goal: String) {
        currentGoals.removeAll { $0 == goal }
        if !completedMilestones.contains(goal) {
            completedMilestones.append(goal)
        }
    }
    
    public mutating func saveProperty(_ propertyId: String) {
        if !savedProperties.contains(propertyId) {
            savedProperties.append(propertyId)
        }
    }
    
    public mutating func viewProperty(_ propertyId: String) {
        if !viewedProperties.contains(propertyId) {
            viewedProperties.append(propertyId)
        }
    }
}

public struct SearchCriteria: Codable {
    public var minPrice: Double?
    public var maxPrice: Double?
    public var bedrooms: Int?
    public var bathrooms: Int?
    public var propertyType: String?
    public var neighborhoods: [String] = []
    public var amenities: [String] = []
    
    public init(
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        bedrooms: Int? = nil,
        bathrooms: Int? = nil,
        propertyType: String? = nil,
        neighborhoods: [String] = [],
        amenities: [String] = []
    ) {
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.propertyType = propertyType
        self.neighborhoods = neighborhoods
        self.amenities = amenities
    }
}

// MARK: - Journey Activity

public struct JourneyActivity: Codable {
    public let id: String
    public let type: String
    public let timestamp: Date
    public let metadata: [String: String] // Simplified for Codable compliance
    
    public init(id: String, type: String, timestamp: Date, metadata: [String: Any] = [:]) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        // Convert Any values to String for Codable compliance
        self.metadata = metadata.compactMapValues { "\($0)" }
    }
}

// MARK: - Journey Stage Transition

public struct JourneyStageTransition: Codable {
    public let fromStage: JourneyStage
    public let toStage: JourneyStage
    public let timestamp: Date
    public let trigger: String
    
    public init(fromStage: JourneyStage, toStage: JourneyStage, timestamp: Date, trigger: String) {
        self.fromStage = fromStage
        self.toStage = toStage
        self.timestamp = timestamp
        self.trigger = trigger
    }
}

// MARK: - User Profile Manager

@MainActor
public final class UserProfileManager: ObservableObject {
    public static let shared: UserProfileManager = {
        #if canImport(Supabase)
            let supabaseURL = URL(string: "https://mzqswvyfnblghgvcgxpw.supabase.co")!
            let supabaseKey = """
            eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.\
            0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0
            """
            return UserProfileManager(client: SupabaseClient(
                supabaseURL: supabaseURL,
                supabaseKey: supabaseKey
            ))
        #else
            return UserProfileManager()
        #endif
    }()
    
    @Published public var currentProfile: UserProfile?
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    
    #if canImport(Supabase)
        private let client: SupabaseClient
    #endif
    
    private let cacheKey = "cached_user_profile"
    private let preferencesKey = "user_preferences"
    private let journeyStateKey = "journey_state"
    
    #if canImport(Supabase)
        public init(client: SupabaseClient) {
            self.client = client
            loadCachedProfile()
        }
    #else
        public init() {
            loadCachedProfile()
        }
    #endif
    
    // MARK: - Profile Management
    
    public func loadProfile(for userId: UUID) async {
        isLoading = true
        error = nil
        
        do {
            #if canImport(Supabase)
                let profile = try await fetchProfileFromSupabase(userId: userId)
                await MainActor.run {
                    self.currentProfile = profile
                    self.cacheProfile(profile)
                    self.isLoading = false
                }
            #else
                // Fallback for development
                let profile = createMockProfile(userId: userId)
                currentProfile = profile
                cacheProfile(profile)
                isLoading = false
            #endif
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    public func updateProfile(_ profile: UserProfile) async {
        isLoading = true
        error = nil
        
        do {
            #if canImport(Supabase)
                let updatedProfile = try await updateProfileInSupabase(profile)
                await MainActor.run {
                    self.currentProfile = updatedProfile
                    self.cacheProfile(updatedProfile)
                    self.isLoading = false
                }
            #else
                // Fallback for development
                var updatedProfile = profile
                updatedProfile.updatedAt = Date()
                currentProfile = updatedProfile
                cacheProfile(updatedProfile)
                isLoading = false
            #endif
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    public func updateJourneyStage(_ stage: JourneyStage) async {
        guard var profile = currentProfile else { return }
        profile.journeyStage = stage
        profile.journeyState.recordActivity()
        await updateProfile(profile)
    }
    
    public func updatePreferences(_ preferences: UserPreferences) async {
        guard var profile = currentProfile else { return }
        profile.preferences = preferences
        await updateProfile(profile)
    }
    
    public func recordJourneyActivity(_ activity: String, metadata: [String: Any] = [:]) async {
        guard var profile = currentProfile else { return }
        profile.journeyState.recordActivity()
        
        // Update progress metrics based on activity
        switch activity {
        case "property_viewed":
            if let propertyId = metadata["propertyId"] as? String {
                profile.journeyState.viewProperty(propertyId)
            }
        case "property_saved":
            if let propertyId = metadata["propertyId"] as? String {
                profile.journeyState.saveProperty(propertyId)
            }
        case "goal_completed":
            if let goal = metadata["goal"] as? String {
                profile.journeyState.completeGoal(goal)
            }
        default:
            break
        }
        
        await updateProfile(profile)
    }
    
    // MARK: - Contextual Authentication Helpers
    
    public func shouldShowOnboarding() -> Bool {
        return currentProfile?.onboardingCompleted != true
    }
    
    public func getContextualGreeting() -> String {
        guard let profile = currentProfile else { return "Welcome to HOMEY" }
        
        let timeOfDay = getTimeOfDay()
        let name = profile.fullName?.components(separatedBy: " ").first ?? "there"
        
        switch profile.journeyStage {
        case .exploring:
            return "Good \(timeOfDay), \(name)! Ready to explore some options?"
        case .researching:
            return "Good \(timeOfDay), \(name)! Let's dive deeper into your research."
        case .viewing:
            return "Good \(timeOfDay), \(name)! Any exciting properties to view today?"
        case .negotiating:
            return "Good \(timeOfDay), \(name)! How are those negotiations going?"
        case .closing:
            return "Good \(timeOfDay), \(name)! Almost there - let's get you to closing!"
        case .settled:
            return "Good \(timeOfDay), \(name)! How's life in your new home?"
        }
    }
    
    public func getRecommendedActions() -> [String] {
        guard let profile = currentProfile else { return [] }
        
        switch profile.journeyStage {
        case .exploring:
            return ["Set your budget", "Explore neighborhoods", "Get pre-approved"]
        case .researching:
            return ["Compare market trends", "Research schools", "Check commute times"]
        case .viewing:
            return ["Schedule tours", "Prepare viewing checklist", "Research comparable sales"]
        case .negotiating:
            return ["Review offer strategy", "Get inspection scheduled", "Finalize financing"]
        case .closing:
            return ["Review closing documents", "Schedule final walkthrough", "Prepare for move"]
        case .settled:
            return ["Set up utilities", "Find local services", "Explore your neighborhood"]
        }
    }
    
    // MARK: - Private Methods
    
    private func getTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default: return "night"
        }
    }
    
    private func loadCachedProfile() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            currentProfile = profile
        }
    }
    
    private func cacheProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    private func createMockProfile(userId: UUID) -> UserProfile {
        return UserProfile(
            id: userId,
            email: "user@example.com",
            fullName: "Demo User",
            role: "client",
            clientSegment: "buyer",
            journeyStage: .exploring,
            preferences: UserPreferences(),
            journeyState: JourneyState(),
            onboardingCompleted: false
        )
    }
    
    // MARK: - Additional Contextual Methods
    
    /// Record journey activity for analytics and personalization
    public func recordActivity(_ activity: String, metadata: [String: Any] = [:]) async {
        guard var profile = currentProfile else { return }
        
        profile.journeyState.recordActivity()
        
        // Update progress metrics based on activity type
        switch activity {
        case "property_viewed":
            if let propertyId = metadata["propertyId"] as? String {
                profile.journeyState.viewProperty(propertyId)
            }
        case "property_saved":
            if let propertyId = metadata["propertyId"] as? String {
                profile.journeyState.saveProperty(propertyId)
            }
        case "goal_completed":
            if let goal = metadata["goal"] as? String {
                profile.journeyState.completeGoal(goal)
            }
        default:
            break
        }
        
        await updateProfile(profile)
    }
    
    /// Get progress percentage for current journey stage
    public func getJourneyProgress() -> Double {
        guard let profile = currentProfile else { return 0.0 }
        
        let totalMilestones = profile.journeyState.currentGoals.count + profile.journeyState.completedMilestones.count
        guard totalMilestones > 0 else { return 0.0 }
        
        return Double(profile.journeyState.completedMilestones.count) / Double(totalMilestones)
    }
    
    /// Check if user has completed specific milestone
    public func hasCompletedMilestone(_ milestone: String) -> Bool {
        return currentProfile?.journeyState.completedMilestones.contains(milestone) ?? false
    }
    
    /// Add a goal to the current goals if not already present
    public func addGoal(_ goal: String) async {
        guard var profile = currentProfile else { return }
        profile.journeyState.addGoal(goal)
        await updateProfile(profile)
    }
    
    /// Complete a goal and move it to completed milestones
    public func completeGoal(_ goal: String) async {
        guard var profile = currentProfile else { return }
        profile.journeyState.completeGoal(goal)
        await updateProfile(profile)
    }
    
    /// Get user's saved properties count
    public func getSavedPropertiesCount() -> Int {
        return currentProfile?.journeyState.savedProperties.count ?? 0
    }
    
    /// Get user's viewed properties count
    public func getViewedPropertiesCount() -> Int {
        return currentProfile?.journeyState.viewedProperties.count ?? 0
    }
    
    #if canImport(Supabase)
    private func fetchProfileFromSupabase(userId: UUID) async throws -> UserProfile {
        struct ProfileRow: Decodable {
            let id: UUID
            let email: String
            let full_name: String?
            let role: String?
            let client_segment: String?
            let journey_stage: String?
            let preferences: Data?
            let journey_state: Data?
            let onboarding_completed: Bool?
            let created_at: String
            let updated_at: String
        }
        
        let response: PostgrestResponse<ProfileRow> = try await client
            .from("profiles")
            .select("id, email, full_name, role, client_segment, journey_stage, preferences, journey_state, onboarding_completed, created_at, updated_at")
            .eq("id", value: userId)
            .single()
            .execute()
        
        let row = response.value
        
        let preferences: UserPreferences
        if let prefData = row.preferences {
            preferences = (try? JSONDecoder().decode(UserPreferences.self, from: prefData)) ?? UserPreferences()
        } else {
            preferences = UserPreferences()
        }
        
        let journeyState: JourneyState
        if let stateData = row.journey_state {
            journeyState = (try? JSONDecoder().decode(JourneyState.self, from: stateData)) ?? JourneyState()
        } else {
            journeyState = JourneyState()
        }
        
        let journeyStage = JourneyStage(rawValue: row.journey_stage ?? "exploring") ?? .exploring
        
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = dateFormatter.date(from: row.created_at) ?? Date()
        let updatedAt = dateFormatter.date(from: row.updated_at) ?? Date()
        
        return UserProfile(
            id: row.id,
            email: row.email,
            fullName: row.full_name,
            role: row.role ?? "client",
            clientSegment: row.client_segment,
            journeyStage: journeyStage,
            preferences: preferences,
            journeyState: journeyState,
            onboardingCompleted: row.onboarding_completed ?? false,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private func updateProfileInSupabase(_ profile: UserProfile) async throws -> UserProfile {
        let preferencesData = try JSONEncoder().encode(profile.preferences)
        let journeyStateData = try JSONEncoder().encode(profile.journeyState)
        
        struct UpdateData: Encodable {
            let full_name: String?
            let role: String
            let client_segment: String?
            let journey_stage: String
            let preferences: Data
            let journey_state: Data
            let onboarding_completed: Bool
            let updated_at: String
        }
        
        let updateData = UpdateData(
            full_name: profile.fullName,
            role: profile.role,
            client_segment: profile.clientSegment,
            journey_stage: profile.journeyStage.rawValue,
            preferences: preferencesData,
            journey_state: journeyStateData,
            onboarding_completed: profile.onboardingCompleted,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        
        try await client
            .from("profiles")
            .update(updateData)
            .eq("id", value: profile.id)
            .execute()
        
        var updatedProfile = profile
        updatedProfile.updatedAt = Date()
        return updatedProfile
    }
    #endif
}

// MARK: - Environment Key

struct UserProfileManagerKey: EnvironmentKey {
    static let defaultValue: UserProfileManager? = nil
}

extension EnvironmentValues {
    var userProfileManager: UserProfileManager? {
        get { self[UserProfileManagerKey.self] }
        set { self[UserProfileManagerKey.self] = newValue }
    }
}