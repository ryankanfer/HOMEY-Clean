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
}

class PreferencesService {
    static let shared = PreferencesService()
    
    // Use the shared Supabase client from the auth manager
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
    private var userPreferencesChannel: RealtimeChannel?
    private var agentPreferencesChannel: RealtimeChannel?
    
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
        print("Fetching preferences for user \(userId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            let response: [HomeyUserPreferences] = try await supabase.database
                .from("user_preferences")
                .select()
                .eq("user_id", value: userId)
                .limit(1)
                .execute()
                .value
            
            return response.first
        } catch {
            print("Error fetching user preferences: \(error)")
            throw PreferencesError.fetchFailed(error)
        }
    }
    
    func updatePreferences(_ preferences: HomeyUserPreferences) async throws {
        print("Updating preferences for user \(preferences.userId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            // Use upsert to insert or update the preferences
            let response = try await supabase.database
                .from("user_preferences")
                .upsert(preferences)
                .execute()
            
            print("Successfully updated user preferences: \(response)")
        } catch {
            print("Error updating user preferences: \(error)")
            throw PreferencesError.updateFailed(error)
        }
    }
    
    // MARK: - Agent Preferences
    
    func fetchAgentPreferences(for agentId: UUID) async throws -> HomeyAgentPreferences? {
        print("Fetching preferences for agent \(agentId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            let response: [HomeyAgentPreferences] = try await supabase.database
                .from("agent_preferences")
                .select()
                .eq("agent_id", value: agentId)
                .limit(1)
                .execute()
                .value
            
            return response.first
        } catch {
            print("Error fetching agent preferences: \(error)")
            throw PreferencesError.fetchFailed(error)
        }
    }
    
    func updateAgentPreferences(_ preferences: HomeyAgentPreferences) async throws {
        print("Updating preferences for agent \(preferences.agentId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            // Use upsert to insert or update the preferences
            let response = try await supabase.database
                .from("agent_preferences")
                .upsert(preferences)
                .execute()
            
            print("Successfully updated agent preferences: \(response)")
        } catch {
            print("Error updating agent preferences: \(error)")
            throw PreferencesError.updateFailed(error)
        }
    }
    
    // MARK: - Agent-Client Relationship Methods
    
    /// Fetch all clients for a specific agent
    func fetchClients(for agentId: UUID) async throws -> [UUID] {
        print("Fetching clients for agent \(agentId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            // This assumes there's a table linking agents to clients
            // You might need to adjust this query based on your actual database schema
            struct ClientLink: Codable {
                let clientId: UUID
                
                enum CodingKeys: String, CodingKey {
                    case clientId = "client_id"
                }
            }
            
            let response: [ClientLink] = try await supabase.database
                .from("agent_client_links")
                .select("client_id")
                .eq("agent_id", value: agentId)
                .execute()
                .value
            
            return response.map { $0.clientId }
        } catch {
            print("Error fetching clients for agent: \(error)")
            throw PreferencesError.fetchFailed(error)
        }
    }
    
    /// Fetch preferences for all clients of a specific agent
    func fetchClientPreferences(for agentId: UUID) async throws -> [HomeyUserPreferences] {
        print("Fetching client preferences for agent \(agentId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            // First get all client IDs for this agent
            let clientIds = try await fetchClients(for: agentId)
            
            // Then fetch preferences for all those clients
            // Note: In a production environment, you might want to optimize this with a single query
            var preferences: [HomeyUserPreferences] = []
            
            for clientId in clientIds {
                if let clientPreference = try await fetchPreferences(for: clientId) {
                    preferences.append(clientPreference)
                }
            }
            
            return preferences
        } catch {
            print("Error fetching client preferences for agent: \(error)")
            throw PreferencesError.fetchFailed(error)
        }
    }
    
    /// Fetch preferences for a specific client (with access control)
    func fetchClientPreferences(for clientId: UUID, agentId: UUID) async throws -> HomeyUserPreferences? {
        print("Fetching preferences for client \(clientId) by agent \(agentId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            // First verify that this client belongs to this agent
            let clientIds = try await fetchClients(for: agentId)
            guard clientIds.contains(clientId) else {
                throw PreferencesError.accessDenied
            }
            
            // Then fetch the client's preferences
            return try await fetchPreferences(for: clientId)
        } catch {
            print("Error fetching client preferences: \(error)")
            throw PreferencesError.fetchFailed(error)
        }
    }
    
    /// Update preferences for a specific client (with access control)
    func updateClientPreferences(_ preferences: HomeyUserPreferences, agentId: UUID) async throws {
        print("Updating preferences for client \(preferences.userId) by agent \(agentId)...")
        
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        do {
            // First verify that this client belongs to this agent
            let clientIds = try await fetchClients(for: agentId)
            guard clientIds.contains(preferences.userId) else {
                throw PreferencesError.accessDenied
            }
            
            // Then update the client's preferences
            try await updatePreferences(preferences)
            
            // Notify observers
            notifyClientPreferencesUpdated(preferences, for: agentId)
        } catch {
            print("Error updating client preferences: \(error)")
            throw PreferencesError.updateFailed(error)
        }
    }
    
    // MARK: - Real-time Updates
    
    func subscribeToUserPreferences(for userId: UUID) async throws {
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        // Unsubscribe from previous channel if exists
        if let channel = userPreferencesChannel {
            await supabase.realtimeV2.removeChannel(channel)
        }
        
        // Create new channel for user preferences
        let channel = supabase.realtimeV2.channel("user_preferences_\(userId)")
        
        // Listen for changes
        channel.onPostgresAction(
            schema: "public",
            table: "user_preferences",
            filter: PostgresJoinFilter(column: "user_id", value: userId.uuidString)
        ) { [weak self] action in
            switch action {
            case .insert(let payload), .update(let payload):
                if let preferences = try? JSONDecoder().decode(HomeyUserPreferences.self, from: payload.record) {
                    self?.notifyPreferencesUpdated(preferences)
                }
            default:
                break
            }
        }
        
        userPreferencesChannel = channel
        try await channel.subscribe()
        print("Subscribed to real-time updates for user \(userId)")
    }
    
    func subscribeToAgentClientPreferences(for agentId: UUID) async throws {
        guard let supabase = self.supabase else {
            throw PreferencesError.supabaseNotInitialized
        }
        
        // Get client IDs for this agent
        let clientIds = try await fetchClients(for: agentId)
        
        // Unsubscribe from previous channel if exists
        if let channel = agentPreferencesChannel {
            await supabase.realtimeV2.removeChannel(channel)
        }
        
        // Create new channel for agent client preferences
        let channel = supabase.realtimeV2.channel("agent_client_preferences_\(agentId)")
        
        // Listen for changes to client preferences
        for clientId in clientIds {
            channel.onPostgresAction(
                schema: "public",
                table: "user_preferences",
                filter: PostgresJoinFilter(column: "user_id", value: clientId.uuidString)
            ) { [weak self] action in
                switch action {
                case .insert(let payload), .update(let payload):
                    if let preferences = try? JSONDecoder().decode(HomeyUserPreferences.self, from: payload.record) {
                        self?.notifyClientPreferencesUpdated(preferences, for: agentId)
                    }
                default:
                    break
                }
            }
        }
        
        agentPreferencesChannel = channel
        try await channel.subscribe()
        print("Subscribed to real-time updates for agent \(agentId)'s clients")
    }
    
    // MARK: - Notification Methods
    
    private func notifyPreferencesUpdated(_ preferences: HomeyUserPreferences) {
        DispatchQueue.main.async {
            for observer in self.observers {
                observer.preferencesDidUpdate(preferences)
            }
        }
    }
    
    private func notifyClientPreferencesUpdated(_ preferences: HomeyUserPreferences, for agentId: UUID) {
        DispatchQueue.main.async {
            for observer in self.observers {
                observer.clientPreferencesDidUpdate(preferences, for: preferences.userId)
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