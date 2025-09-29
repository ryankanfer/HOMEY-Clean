import Foundation
import Supabase

// MARK: - Events Repository
class EventsRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    @MainActor
    convenience init() {
        self.init(client: AppSessionManager.shared.supabaseClient)
    }

    func recordEvent(_ event: HomeyEvent) async {
        do {
            let eventData = EventRecord(
                id: UUID(),
                userId: getCurrentUserId(),
                eventType: event.type,
                eventData: event.data,
                timestamp: Date(),
                sessionId: getSessionId()
            )
            
            try await client
                .from("events")
                .insert(eventData)
                .execute()
            
            // Also update user behavior patterns for HOMEY Brain
            await updateBehaviorPatterns(event)
            
        } catch {
            print("Failed to record event: \(error)")
        }
    }
    
    func getEvents(for userId: UUID, limit: Int = 100) async throws -> [EventRecord] {
        let response: [EventRecord] = try await client
            .from("events")
            .select()
            .eq("user_id", value: userId)
            .order("timestamp", ascending: false)
            .limit(limit)
            .execute()
            .value
        
        return response
    }
    
    func getEventsByType(_ type: String, for userId: UUID) async throws -> [EventRecord] {
        let response: [EventRecord] = try await client
            .from("events")
            .select()
            .eq("user_id", value: userId)
            .eq("event_type", value: type)
            .order("timestamp", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    private func getCurrentUserId() -> UUID {
        // TODO: Get from session manager
        return UUID() // Mock for now
    }
    
    private func getSessionId() -> String {
        // TODO: Get from session manager
        return UUID().uuidString
    }
    
    private func updateBehaviorPatterns(_ event: HomeyEvent) async {
        // Update user behavior patterns for HOMEY Brain personalization
        switch event {
        case .documentUpload, .documentProcessed:
            await updateDocumentBehavior(event)
        case .searchQuery, .listingView, .listingSave:
            await updateSearchBehavior(event)
        case .onboardingAnswer:
            await updatePreferences(event)
        case .agentInteraction:
            await updateAgentPreferences(event)
        default:
            break
        }
    }
    
    private func updateDocumentBehavior(_ event: HomeyEvent) async {
        // Track document upload patterns for Next Step suggestions
        print("Updating document behavior patterns for event: \(event.type)")
    }
    
    private func updateSearchBehavior(_ event: HomeyEvent) async {
        // Track search patterns to improve recommendations
        print("Updating search behavior patterns for event: \(event.type)")
    }
    
    private func updatePreferences(_ event: HomeyEvent) async {
        // Update user preferences based on onboarding answers
        print("Updating preferences from event: \(event.type)")
    }
    
    private func updateAgentPreferences(_ event: HomeyEvent) async {
        // Track agent interaction preferences
        print("Updating agent preferences from event: \(event.type)")
    }
}

// MARK: - Event Models
struct EventRecord: Codable {
    let id: UUID
    let userId: UUID
    let eventType: String
    let eventData: [String: Any]
    let timestamp: Date
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventType = "event_type"
        case eventData = "event_data"
        case timestamp
        case sessionId = "session_id"
    }
    
    init(id: UUID, userId: UUID, eventType: String, eventData: [String: Any], timestamp: Date, sessionId: String) {
        self.id = id
        self.userId = userId
        self.eventType = eventType
        self.eventData = eventData
        self.timestamp = timestamp
        self.sessionId = sessionId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        eventType = try container.decode(String.self, forKey: .eventType)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        
        // Handle eventData as JSON
        if let jsonData = try? container.decode(Data.self, forKey: .eventData),
           let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            eventData = dict
        } else {
            eventData = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(sessionId, forKey: .sessionId)
        
        // Encode eventData as JSON
        let jsonData = try JSONSerialization.data(withJSONObject: eventData)
        try container.encode(jsonData, forKey: .eventData)
    }
}

// MARK: - HOMEY Events
enum HomeyEvent {
    // Document events
    case documentUpload(filename: String, type: String)
    case documentProcessed(id: UUID, type: String, extractedFields: Int)
    case documentStatusChanged(id: UUID, status: String)
    case documentDeleted(id: UUID)
    case documentUploadError(filename: String, error: String)
    
    // Search events
    case searchQuery(query: String, filters: [String: Any])
    case listingView(listingId: String, source: String)
    case listingSave(listingId: String, action: String) // save/unsave
    case listingShare(listingId: String, recipient: String)
    case tourRequest(listingId: String, requestedDate: Date?)
    
    // Matchmaker events
    case matchmakerSwipe(listingId: String, direction: String) // left/right
    case matchmakerSave(listingId: String)
    case matchmakerTourRequest(listingId: String)
    
    // Profile events
    case profileView
    case progressUpdate(stage: String, progress: Double)
    case nextStepView(step: String)
    
    // Onboarding events
    case onboardingStart
    case onboardingAnswer(question: String, answer: Any)
    case onboardingComplete
    case continuousOnboardingTrigger(context: String)
    
    // Agent events
    case agentAssignment(agentId: UUID)
    case agentMessage(agentId: UUID, messageType: String)
    case agentInteraction(agentId: UUID, interactionType: String)
    
    // Navigation events
    case tabSwitch(from: String, to: String)
    
    // Onboarding map interactions
    case subwayMapExpanded
    case subwayMapCollapsed
    case stationClicked(stationId: String)
    
    // Market insights events
    case marketInsightsView(area: String)
    case vendorSuggestionsView
    case drawerOpen(source: String) // swipe/button
    case drawerItemTap(item: String)
    
    // Additional matchmaker events
    case applyMatchmakerFilters(filters: [String: Any])
    case saveProperty(propertyId: String)
    case requestTour(propertyId: String)
    
    var type: String {
        switch self {
        case .documentUpload: return "document_upload"
        case .documentProcessed: return "document_processed"
        case .documentStatusChanged: return "document_status_changed"
        case .documentDeleted: return "document_deleted"
        case .documentUploadError: return "document_upload_error"
        case .searchQuery: return "search_query"
        case .listingView: return "listing_view"
        case .listingSave: return "listing_save"
        case .listingShare: return "listing_share"
        case .tourRequest: return "tour_request"
        case .matchmakerSwipe: return "matchmaker_swipe"
        case .matchmakerSave: return "matchmaker_save"
        case .matchmakerTourRequest: return "matchmaker_tour_request"
        case .profileView: return "profile_view"
        case .progressUpdate: return "progress_update"
        case .nextStepView: return "next_step_view"
        case .onboardingStart: return "onboarding_start"
        case .onboardingAnswer: return "onboarding_answer"
        case .onboardingComplete: return "onboarding_complete"
        case .continuousOnboardingTrigger: return "continuous_onboarding_trigger"
        case .agentAssignment: return "agent_assignment"
        case .agentMessage: return "agent_message"
        case .agentInteraction: return "agent_interaction"
        case .tabSwitch: return "tab_switch"
        case .subwayMapExpanded: return "subway_map_expanded"
        case .subwayMapCollapsed: return "subway_map_collapsed"
        case .stationClicked: return "station_clicked"
        case .marketInsightsView: return "market_insights_view"
        case .vendorSuggestionsView: return "vendor_suggestions_view"
        case .drawerOpen: return "drawer_open"
        case .drawerItemTap: return "drawer_item_tap"
        case .applyMatchmakerFilters: return "apply_matchmaker_filters"
        case .saveProperty: return "save_property"
        case .requestTour: return "request_tour"
        }
    }
    
    var data: [String: Any] {
        switch self {
        case .documentUpload(let filename, let type):
            return ["filename": filename, "type": type]
        case .documentProcessed(let id, let type, let extractedFields):
            return ["id": id.uuidString, "type": type, "extracted_fields": extractedFields]
        case .documentStatusChanged(let id, let status):
            return ["id": id.uuidString, "status": status]
        case .documentDeleted(let id):
            return ["id": id.uuidString]
        case .documentUploadError(let filename, let error):
            return ["filename": filename, "error": error]
        case .searchQuery(let query, let filters):
            return ["query": query, "filters": filters]
        case .listingView(let listingId, let source):
            return ["listing_id": listingId, "source": source]
        case .listingSave(let listingId, let action):
            return ["listing_id": listingId, "action": action]
        case .listingShare(let listingId, let recipient):
            return ["listing_id": listingId, "recipient": recipient]
        case .tourRequest(let listingId, let requestedDate):
            var data: [String: Any] = ["listing_id": listingId]
            if let date = requestedDate {
                data["requested_date"] = date.timeIntervalSince1970
            }
            return data
        case .matchmakerSwipe(let listingId, let direction):
            return ["listing_id": listingId, "direction": direction]
        case .matchmakerSave(let listingId):
            return ["listing_id": listingId]
        case .matchmakerTourRequest(let listingId):
            return ["listing_id": listingId]
        case .profileView:
            return [:]
        case .progressUpdate(let stage, let progress):
            return ["stage": stage, "progress": progress]
        case .nextStepView(let step):
            return ["step": step]
        case .onboardingStart:
            return [:]
        case .onboardingAnswer(let question, let answer):
            return ["question": question, "answer": answer]
        case .onboardingComplete:
            return [:]
        case .continuousOnboardingTrigger(let context):
            return ["context": context]
        case .agentAssignment(let agentId):
            return ["agent_id": agentId.uuidString]
        case .agentMessage(let agentId, let messageType):
            return ["agent_id": agentId.uuidString, "message_type": messageType]
        case .agentInteraction(let agentId, let interactionType):
            return ["agent_id": agentId.uuidString, "interaction_type": interactionType]
        case .tabSwitch(let from, let to):
            return ["from": from, "to": to]
        case .subwayMapExpanded:
            return [:]
        case .subwayMapCollapsed:
            return [:]
        case .stationClicked(let stationId):
            return ["station_id": stationId]
        case .marketInsightsView(let area):
            return ["area": area]
        case .vendorSuggestionsView:
            return [:]
        case .drawerOpen(let source):
            return ["source": source]
        case .drawerItemTap(let item):
            return ["item": item]
        case .applyMatchmakerFilters(let filters):
            return ["filters": filters]
        case .saveProperty(let propertyId):
            return ["property_id": propertyId]
        case .requestTour(let propertyId):
            return ["property_id": propertyId]
        }
    }
}
