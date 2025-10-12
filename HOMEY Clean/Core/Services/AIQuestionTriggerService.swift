import Foundation
import Combine

// MARK: - Question Trigger Rules
struct QuestionTriggerRule: Codable {
    let id: String
    let questionId: String
    let eventType: BehavioralEventType
    let condition: TriggerCondition
    let priority: Int // Higher priority = triggered sooner
    let cooldownPeriod: TimeInterval // Minimum time between triggers for same question
}

enum TriggerCondition: Codable {
    case countGreaterThan(Int)
    case countLessThan(Int)
    case containsValue(String)
    // Note: Removed custom case as it can't be Codable
    
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    enum ConditionType: String, Codable {
        case countGreaterThan, countLessThan, containsValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ConditionType.self, forKey: .type)
        
        switch type {
        case .countGreaterThan:
            let value = try container.decode(Int.self, forKey: .value)
            self = .countGreaterThan(value)
        case .countLessThan:
            let value = try container.decode(Int.self, forKey: .value)
            self = .countLessThan(value)
        case .containsValue:
            let value = try container.decode(String.self, forKey: .value)
            self = .containsValue(value)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .countGreaterThan(let value):
            try container.encode(ConditionType.countGreaterThan, forKey: .type)
            try container.encode(value, forKey: .value)
        case .countLessThan(let value):
            try container.encode(ConditionType.countLessThan, forKey: .type)
            try container.encode(value, forKey: .value)
        case .containsValue(let value):
            try container.encode(ConditionType.containsValue, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

extension TriggerCondition: Equatable {
    static func == (lhs: TriggerCondition, rhs: TriggerCondition) -> Bool {
        switch (lhs, rhs) {
        case (.countGreaterThan(let l), .countGreaterThan(let r)):
            return l == r
        case (.countLessThan(let l), .countLessThan(let r)):
            return l == r
        case (.containsValue(let l), .containsValue(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - Triggered Question Model
struct TriggeredQuestion: Identifiable, Codable {
    let id = UUID()
    let questionId: String
    let triggeredAt: Date
    let priority: Int
    var isAnswered: Bool = false
}

// MARK: - AI Question Trigger Service
class AIQuestionTriggerService: ObservableObject {
    static let shared = AIQuestionTriggerService()
    
    @Published var triggeredQuestions: [TriggeredQuestion] = []
    
    private let trackingService = BehavioralTrackingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Define trigger rules for our AI questions
    private let triggerRules: [QuestionTriggerRule] = [
        QuestionTriggerRule(
            id: "rule_1",
            questionId: "ai_q_1",
            eventType: .searchPerformed,
            condition: .countGreaterThan(3),
            priority: 10,
            cooldownPeriod: 86400 // 24 hours
        ),
        QuestionTriggerRule(
            id: "rule_2",
            questionId: "ai_q_2",
            eventType: .listingSaved,
            condition: .countGreaterThan(5),
            priority: 8,
            cooldownPeriod: 86400 // 24 hours
        ),
        QuestionTriggerRule(
            id: "rule_3",
            questionId: "ai_q_3",
            eventType: .listingViewed,
            condition: .countGreaterThan(10),
            priority: 7,
            cooldownPeriod: 86400 // 24 hours
        ),
        QuestionTriggerRule(
            id: "rule_4",
            questionId: "ai_q_4",
            eventType: .listingViewed,
            condition: .containsValue("pet-friendly"),
            priority: 9,
            cooldownPeriod: 86400 // 24 hours
        )
    ]
    
    private init() {
        // In a real implementation, we would load saved triggered questions from storage
        loadTriggeredQuestions()
    }
    
    // Evaluate rules based on a new behavioral event
    func evaluateRules(for event: BehavioralEvent) {
        let matchingRules = triggerRules.filter { rule in
            // Check if event type matches
            guard rule.eventType == event.eventType else { return false }
            
            // Check if rule condition is met
            return evaluateCondition(rule.condition, with: event)
        }
        
        // Create triggered questions for matching rules
        let newTriggeredQuestions = matchingRules.map { rule in
            TriggeredQuestion(
                questionId: rule.questionId,
                triggeredAt: Date(),
                priority: rule.priority
            )
        }
        
        // Add new triggered questions, avoiding duplicates
        for newQuestion in newTriggeredQuestions {
            if !triggeredQuestions.contains(where: { $0.questionId == newQuestion.questionId }) {
                triggeredQuestions.append(newQuestion)
            }
        }
        
        // Sort by priority (highest first)
        triggeredQuestions.sort { $0.priority > $1.priority }
        
        // Save updated triggered questions
        saveTriggeredQuestions()
    }
    
    // Evaluate a condition against an event
    private func evaluateCondition(_ condition: TriggerCondition, with event: BehavioralEvent) -> Bool {
        switch condition {
        case .countGreaterThan(let count):
            // This would typically check against historical data
            // For demo purposes, we'll just return true for some cases
            return event.metadata["count"]?.value as? Int ?? 0 > count
        case .countLessThan(let count):
            return event.metadata["count"]?.value as? Int ?? 0 < count
        case .containsValue(let value):
            // Check if any metadata value contains the specified value
            for (_, metadataValue) in event.metadata {
                if let stringValue = metadataValue.value as? String,
                   stringValue.contains(value) {
                    return true
                }
            }
            return false
        }
    }
    
    // Get triggered questions that haven't been answered yet
    func getUnansweredQuestions() -> [TriggeredQuestion] {
        return triggeredQuestions.filter { !$0.isAnswered }
    }
    
    // Mark a question as answered
    func markQuestionAsAnswered(_ questionId: String) {
        if let index = triggeredQuestions.firstIndex(where: { $0.questionId == questionId }) {
            triggeredQuestions[index].isAnswered = true
            saveTriggeredQuestions()
        }
    }
    
    // Load triggered questions from storage (simplified implementation)
    private func loadTriggeredQuestions() {
        // In a real app, this would load from UserDefaults, Core Data, or a database
        // For now, we'll start with an empty array
        triggeredQuestions = []
    }
    
    // Save triggered questions to storage (simplified implementation)
    private func saveTriggeredQuestions() {
        // In a real app, this would save to UserDefaults, Core Data, or a database
        // For now, we'll just keep them in memory
    }
}
