import Foundation
import Supabase

// A Codable struct to represent the user's preferences data in Supabase.
struct HomeyUserPreferences: Codable {
    var userId: UUID
    var workFromHome: Bool
    var hasPets: Bool
    var walkability: Double
    var safetyRating: Double
    var selectedStyles: [String]
    var maxRent: Double
    var moveInDate: Date
    var aiQuestionAnswers: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case workFromHome = "work_from_home"
        case hasPets = "has_pets"
        case walkability
        case safetyRating = "safety_rating"
        case selectedStyles = "selected_styles"
        case maxRent = "max_rent"
        case moveInDate = "move_in_date"
        case aiQuestionAnswers = "ai_question_answers"
    }
}

// A Codable struct for the limited data shared with real estate agents
struct HomeyAgentViewableClientData: Codable {
    var userId: UUID
    var firstName: String
    var lastName: String
    var clientType: String  // "renter", "buyer", "seller"
    var budget: Double
    var neighborhoodPreference: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case clientType = "client_type"
        case budget
        case neighborhoodPreference = "neighborhood_preference"
    }
}

// A Codable struct to represent the agent's preferences data in Supabase.
struct HomeyAgentPreferences: Codable {
    var agentId: UUID
    var clientPreferencesVisible: Bool
    var defaultNotificationSettings: [String: Bool]
    var customMessages: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case agentId = "agent_id"
        case clientPreferencesVisible = "client_preferences_visible"
        case defaultNotificationSettings = "default_notification_settings"
        case customMessages = "custom_messages"
    }
}

// Add this protocol for real-time updates
protocol PreferencesObserver: AnyObject {
    func preferencesDidUpdate(_ preferences: HomeyUserPreferences)
    func clientPreferencesDidUpdate(_ preferences: HomeyUserPreferences, for clientId: UUID)
    // Add a new method for agent-viewable client data updates
    func agentViewableClientDataDidUpdate(_ clientData: HomeyAgentViewableClientData, for clientId: UUID)
}

class PreferencesService {
    static let shared = PreferencesService()
    
    private var supabase: SupabaseClient? {
        do {
            let authManager = try RealSupabaseAuthManager()
            return authManager.client
        } catch {
            print("Error initializing Supabase client: \(error)")
            return nil
        }
    }
    
    // Real-time observers
    private var observers: [PreferencesObserver] = []
    private var userPreferencesChannel: RealtimeChannelV2?
    private var agentPreferencesChannel: RealtimeChannelV2?
    // Add a new channel for agent-viewable client data
    private var agentViewableClientDataChannel: RealtimeChannelV2?
    
    private init() {}
    
    // MARK: - Observer Management
    
    func addObserver(_ observer: PreferencesObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: PreferencesObserver) {
        observers.removeAll { $0 === observer }
    }
    
    // MARK: - User Preferences
    
    func fetchPreferences(for userId: UUID) async throws -> HomeyUserPreferences? {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }
        
        let response: [HomeyUserPreferences] = try await supabase.database
            .from("user_preferences")
            .select()
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }
    
    func updatePreferences(_ preferences: HomeyUserPreferences) async throws {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }
        
        try await supabase.database
            .from("user_preferences")
            .upsert(preferences)
            .execute()
        
        // Manually notify observers since real-time is disabled for now
        notifyPreferencesUpdated(preferences)
    }
    
    // MARK: - Agent Preferences
    
    func fetchAgentPreferences(for agentId: UUID) async throws -> HomeyAgentPreferences? {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }

        let response: [HomeyAgentPreferences] = try await supabase.database
            .from("agent_preferences")
            .select()
            .eq("agent_id", value: agentId)
            .limit(1)
            .execute()
            .value
            
        return response.first
    }
    
    func updateAgentPreferences(_ preferences: HomeyAgentPreferences) async throws {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }
        
        try await supabase.database
            .from("agent_preferences")
            .upsert(preferences)
            .execute()
    }
    
    // MARK: - Agent-Client Relationship Methods
    
    func fetchClients(for agentId: UUID) async throws -> [UUID] {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }
        
        struct ClientLink: Codable {
            let clientId: UUID
            enum CodingKeys: String, CodingKey { case clientId = "client_id" }
        }
        
        let response: [ClientLink] = try await supabase.database
            .from("agent_client_links")
            .select("client_id")
            .eq("agent_id", value: agentId)
            .execute()
            .value
        
        return response.map { $0.clientId }
    }

    // Modified method to update client preferences and also update agent-viewable data
    func updateClientPreferences(_ preferences: HomeyUserPreferences, agentId: UUID) async throws {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }
        
        let clientIds = try await fetchClients(for: agentId)
        guard clientIds.contains(preferences.userId) else {
            throw PreferencesError.accessDenied
        }
        
        // Update the full preferences (for the client)
        try await updatePreferences(preferences)
        
        // Update the limited data that agents can see
        // Note: This would need to be populated with actual client data from other sources
        // For now, I'm creating a placeholder that shows how it would work
        let agentViewableData = HomeyAgentViewableClientData(
            userId: preferences.userId,
            firstName: "Client",  // This would come from user profile data
            lastName: "Name",     // This would come from user profile data
            clientType: "renter", // This would come from user profile data
            budget: preferences.maxRent,
            neighborhoodPreference: preferences.selectedStyles.joined(separator: ", ") // Simplified mapping
        )
        
        try await updateAgentViewableClientData(agentViewableData)
        
        // Notify observers
        notifyClientPreferencesUpdated(preferences, for: agentId)
        notifyAgentViewableClientDataUpdated(agentViewableData, for: agentId)
    }
    
    // MARK: - Agent-Viewable Client Data Methods
    
    func fetchAgentViewableClientData(for userId: UUID) async throws -> HomeyAgentViewableClientData? {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }
        
        let response: [HomeyAgentViewableClientData] = try await supabase.database
            .from("agent_viewable_client_data")
            .select()
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }
    
    func updateAgentViewableClientData(_ clientData: HomeyAgentViewableClientData) async throws {
        guard let supabase = self.supabase else { throw PreferencesError.supabaseNotInitialized }
        
        try await supabase.database
            .from("agent_viewable_client_data")
            .upsert(clientData)
            .execute()
    }
    
    // MARK: - Real-time Updates
    
    func subscribeToUserPreferences(for userId: UUID) {
        guard let supabase = self.supabase else {
            print("Supabase not initialized, skipping subscription.")
            return
        }
        
        if let existingChannel = userPreferencesChannel {
            Task {
                await supabase.removeChannel(existingChannel)
            }
        }
        
        let channel: RealtimeChannelV2 = supabase.channel("public:user_preferences")
        self.userPreferencesChannel = channel

        channel.onPostgresChange(AnyAction.self, schema: "public", table: "user_preferences") { [weak self] (action: AnyAction) in
            guard let self = self else { return }
            do {
                let record: [String: Any]
                switch action {
                case .insert(let insertAction):
                    record = insertAction.record
                case .update(let updateAction):
                    record = updateAction.record
                default:
                    return
                }
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: record),
                   let preferences = try? JSONDecoder().decode(HomeyUserPreferences.self, from: jsonData) {
                    if preferences.userId == userId {
                        self.notifyPreferencesUpdated(preferences)
                    }
                }
            } catch {
                print("Failed to decode user preferences: \(error)")
            }
        }
        
        Task {
            do {
                try await channel.subscribe()
                print("Successfully subscribed to user preferences for user \(userId)")
            } catch {
                print("Failed to subscribe to user preferences: \(error)")
            }
        }
    }

    func subscribeToAgentClientPreferences(for agentId: UUID) {
        // This method is now deprecated since we're using agent-viewable client data
        // Keeping it for backward compatibility but it doesn't do anything now
        print("Agent client preferences subscription is deprecated. Use subscribeToAgentViewableClientData instead.")
    }
    
    // MARK: - Real-time Updates for Agent-Viewable Data
    
    func subscribeToAgentViewableClientData(for agentId: UUID) {
        guard let supabase = self.supabase else {
            print("Supabase not initialized, skipping agent subscription.")
            return
        }
        
        Task {
            do {
                let clientIds = try await fetchClients(for: agentId)
                guard !clientIds.isEmpty else {
                    print("Agent \(agentId) has no clients, skipping real-time subscription.")
                    return
                }
                
                if let existingChannel = agentViewableClientDataChannel {
                    await supabase.removeChannel(existingChannel)
                }
                
                let channel: RealtimeChannelV2 = supabase.channel("public:agent_viewable_client_data")
                self.agentViewableClientDataChannel = channel
                
                channel.onPostgresChange(AnyAction.self, schema: "public", table: "agent_viewable_client_data") { [weak self] (action: AnyAction) in
                    guard let self = self else { return }
                    do {
                        let record: [String: Any]
                        switch action {
                        case .insert(let insertAction):
                            record = insertAction.record
                        case .update(let updateAction):
                            record = updateAction.record
                        default:
                            return
                        }
                        
                        if let jsonData = try? JSONSerialization.data(withJSONObject: record),
                           let clientData = try? JSONDecoder().decode(HomeyAgentViewableClientData.self, from: jsonData) {
                            if clientIds.contains(clientData.userId) {
                                self.notifyAgentViewableClientDataUpdated(clientData, for: clientData.userId)
                            }
                        }
                    } catch {
                        print("Failed to decode agent-viewable client data: \(error)")
                    }
                }
                
                try await channel.subscribe()
                print("Successfully subscribed to agent-viewable client data for agent \(agentId)")
            } catch {
                print("Failed to subscribe to agent-viewable client data for agent: \(error)")
            }
        }
    }
    
    // MARK: - Notification Methods
    
    private func notifyPreferencesUpdated(_ preferences: HomeyUserPreferences) {
        DispatchQueue.main.async {
            for observer in self.observers {
                observer.preferencesDidUpdate(preferences)
            }
        }
    }
    
    private func notifyClientPreferencesUpdated(_ preferences: HomeyUserPreferences, for clientId: UUID) {
        DispatchQueue.main.async {
            for observer in self.observers {
                observer.clientPreferencesDidUpdate(preferences, for: clientId)
            }
        }
    }
    
    // New notification method for agent-viewable client data
    private func notifyAgentViewableClientDataUpdated(_ clientData: HomeyAgentViewableClientData, for clientId: UUID) {
        DispatchQueue.main.async {
            for observer in self.observers {
                observer.agentViewableClientDataDidUpdate(clientData, for: clientId)
            }
        }
    }
}

enum PreferencesError: Error, LocalizedError {
    case supabaseNotInitialized
    case fetchFailed(Error)
    case updateFailed(Error)
    case accessDenied
    
    var errorDescription: String? {
        switch self {
        case .supabaseNotInitialized:
            return "Supabase client not initialized"
        case .fetchFailed(let error):
            return "Failed to fetch preferences: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update preferences: \(error.localizedDescription)"
        case .accessDenied:
            return "Access denied: You don't have permission to access these preferences"
        }
    }
}