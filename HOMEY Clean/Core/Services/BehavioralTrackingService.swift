import Foundation
import Combine

// MARK: - Behavioral Event Types
enum BehavioralEventType: String, Codable, CaseIterable {
    case searchPerformed = "search_performed"
    case listingSaved = "listing_saved"
    case listingViewed = "listing_viewed"
    case documentUploaded = "document_uploaded"
    case profileUpdated = "profile_updated"
    case preferenceChanged = "preference_changed"
    case mapInteraction = "map_interaction"
    case aiQuestionAnswered = "ai_question_answered"
}

// MARK: - Behavioral Event Model
struct BehavioralEvent: Codable, Identifiable {
    let id = UUID()
    let userId: UUID
    let eventType: BehavioralEventType
    let timestamp: Date
    let metadata: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case id, userId, eventType, timestamp, metadata
    }
}

// MARK: - AnyCodable Helper
struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value.mapValues { $0.value }
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value.map { $0.value }
        } else if container.decodeNil() {
            self.value = ()
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Int8:
            try container.encode(value)
        case let value as Int16:
            try container.encode(value)
        case let value as Int32:
            try container.encode(value)
        case let value as Int64:
            try container.encode(value)
        case let value as UInt:
            try container.encode(value)
        case let value as UInt8:
            try container.encode(value)
        case let value as UInt16:
            try container.encode(value)
        case let value as UInt32:
            try container.encode(value)
        case let value as UInt64:
            try container.encode(value)
        case let value as Float:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as String:
            try container.encode(value)
        case let value as [Any?]:
            try container.encode(value.map { AnyCodable($0) })
        case let value as [String: Any?]:
            try container.encode(value.mapValues { AnyCodable($0) })
        case let value as [AnyCodable]:
            try container.encode(value)
        case let value as [String: AnyCodable]:
            try container.encode(value)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
}

// MARK: - Behavioral Tracking Service
class BehavioralTrackingService {
    static let shared = BehavioralTrackingService()
    
    private var eventBuffer: [BehavioralEvent] = []
    private let bufferSize = 10
    private let queue = DispatchQueue(label: "BehavioralTrackingQueue", qos: .background)
    
    private init() {}
    
    // Track a behavioral event
    func trackEvent(
        userId: UUID,
        eventType: BehavioralEventType,
        metadata: [String: Any] = [:]
    ) {
        let event = BehavioralEvent(
            userId: userId,
            eventType: eventType,
            timestamp: Date(),
            metadata: metadata.mapValues { AnyCodable($0) }
        )
        
        queue.async {
            self.eventBuffer.append(event)
            
            // When buffer reaches capacity, process events
            if self.eventBuffer.count >= self.bufferSize {
                self.processEvents()
            }
        }
    }
    
    // Process buffered events (in a real app, this would send to backend)
    private func processEvents() {
        let eventsToProcess = eventBuffer
        eventBuffer.removeAll()
        
        // In a real implementation, we would send these events to a backend service
        // For now, we'll just print them for demonstration
        for event in eventsToProcess {
            print("Processing event: \(event.eventType.rawValue) for user \(event.userId)")
        }
    }
    
    // Get recent events for a user (for rule evaluation)
    func getRecentEvents(for userId: UUID, eventType: BehavioralEventType?, limit: Int = 50) -> [BehavioralEvent] {
        // In a real implementation, this would query a local database or backend
        // For now, we'll return an empty array as we're not persisting events
        return []
    }
    
    // Force process any remaining events
    func flush() {
        queue.async {
            if !self.eventBuffer.isEmpty {
                self.processEvents()
            }
        }
    }
}