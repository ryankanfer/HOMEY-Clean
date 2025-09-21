import Foundation
import SwiftUI
#if canImport(Supabase)
    import Supabase
#endif

// MARK: - Events Manager
@MainActor
class EventsManager: ObservableObject {
    static let shared = EventsManager()
    
    private let eventsRepository: EventsRepository
    private let userBehaviorTracker: UserBehaviorTracker
    
    init(eventsRepository: EventsRepository? = nil,
         userBehaviorTracker: UserBehaviorTracker? = nil) {
        self.userBehaviorTracker = userBehaviorTracker ?? UserBehaviorTracker()
        if let repository = eventsRepository {
            self.eventsRepository = repository
        } else {
            // Create EventsRepository without accessing main actor-isolated properties
            let supabaseURL = URL(string: "https://mzqswvyfnblghgvcgxpw.supabase.co")!
            let supabaseKey = """
            eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.\
            0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0
            """
            let client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
            self.eventsRepository = EventsRepository(client: client)
        }
    }
    
    // MARK: - Event Recording
    func recordEvent(_ event: HomeyEvent) {
        Task {
            await eventsRepository.recordEvent(event)
            updateBehaviorTracking(event)
        }
    }
    
    // MARK: - Behavior Tracking Updates
    private func updateBehaviorTracking(_ event: HomeyEvent) {
        switch event {
        case .listingView:
            userBehaviorTracker.recordPropertyView()
            
        case .searchQuery(let query, let filters):
            if let area = filters["neighborhood"] as? String {
                let bedrooms = filters["bedrooms"] as? String
                let petFriendly = filters["pet_friendly"] as? Bool ?? false
                userBehaviorTracker.recordSearch(area: area, bedrooms: bedrooms, petFriendly: petFriendly)
            }
            
        case .listingSave:
            userBehaviorTracker.recordSave()
            
        default:
            break
        }
    }
    
    // MARK: - Convenience Methods for Common Events
    
    // Document Events
    func recordDocumentUpload(filename: String, type: String) {
        recordEvent(.documentUpload(filename: filename, type: type))
    }
    
    func recordDocumentProcessed(id: UUID, type: String, extractedFields: Int) {
        recordEvent(.documentProcessed(id: id, type: type, extractedFields: extractedFields))
    }
    
    func recordDocumentStatusChange(id: UUID, status: String) {
        recordEvent(.documentStatusChanged(id: id, status: status))
    }
    
    // Search Events
    func recordSearch(query: String, filters: [String: Any] = [:]) {
        recordEvent(.searchQuery(query: query, filters: filters))
    }
    
    func recordPropertyView(propertyId: String, source: String = "search") {
        recordEvent(.listingView(listingId: propertyId, source: source))
    }
    
    func recordPropertySave(propertyId: String, action: String = "save") {
        recordEvent(.listingSave(listingId: propertyId, action: action))
    }
    
    func recordTourRequest(propertyId: String, requestedDate: Date? = nil) {
        recordEvent(.tourRequest(listingId: propertyId, requestedDate: requestedDate))
    }
    
    // Matchmaker Events
    func recordMatchmakerSwipe(propertyId: String, direction: String) {
        recordEvent(.matchmakerSwipe(listingId: propertyId, direction: direction))
    }
    
    func recordMatchmakerSave(propertyId: String) {
        recordEvent(.matchmakerSave(listingId: propertyId))
    }
    
    func recordMatchmakerTourRequest(propertyId: String) {
        recordEvent(.matchmakerTourRequest(listingId: propertyId))
    }
    
    // Profile Events
    func recordProfileView() {
        recordEvent(.profileView)
    }
    
    func recordProgressUpdate(stage: String, progress: Double) {
        recordEvent(.progressUpdate(stage: stage, progress: progress))
    }
    
    func recordNextStepView(step: String) {
        recordEvent(.nextStepView(step: step))
    }
    
    // Onboarding Events
    func recordOnboardingStart() {
        recordEvent(.onboardingStart)
    }
    
    func recordOnboardingAnswer(promptId: String, responses: [String: String], context: [String: Any]) {
        recordEvent(.onboardingAnswer(question: promptId, answer: ["responses": responses, "context": context]))
    }
    
    func recordOnboardingComplete() {
        recordEvent(.onboardingComplete)
    }
    
    func recordContinuousOnboardingTrigger(context: String) {
        recordEvent(.continuousOnboardingTrigger(context: context))
    }
    
    // Agent Events
    func recordAgentAssignment(agentId: UUID) {
        recordEvent(.agentAssignment(agentId: agentId))
    }
    
    func recordAgentMessage(agentId: UUID, messageType: String) {
        recordEvent(.agentMessage(agentId: agentId, messageType: messageType))
    }
    
    func recordAgentInteraction(agentId: UUID, interactionType: String) {
        recordEvent(.agentInteraction(agentId: agentId, interactionType: interactionType))
    }
    
    // Navigation Events
    func recordTabSwitch(from: String, to: String) {
        recordEvent(.tabSwitch(from: from, to: to))
    }
    
    func recordDrawerOpen(source: String) {
        recordEvent(.drawerOpen(source: source))
    }
    
    func recordDrawerItemTap(item: String) {
        recordEvent(.drawerItemTap(item: item))
    }
}
