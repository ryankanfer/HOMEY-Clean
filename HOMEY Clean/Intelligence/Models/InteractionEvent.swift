import Foundation
import SwiftUI

public enum InteractionType: String, Codable {
    case searchPerformed
    case propertyViewed
    case propertySaved
    case propertyUnsaved
    case documentUploaded
    case documentProcessed
    case documentStatusChanged
    case documentDeleted
    case journeyStageChanged
    case favoriteToggled
    case messageSent
    case messageReceived
    case tabSwitched
    case pageViewed
    case filterApplied
    case error
    case custom
    case tourScheduled
}

/// Lightweight AnyCodable for event payloads
public struct InteractionAnyCodable: Codable, Hashable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let dict = try? container.decode([String: InteractionAnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([InteractionAnyCodable].self) {
            value = array.map { $0.value }
        } else {
            value = NSNull()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { InteractionAnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { InteractionAnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }

    public static func == (lhs: InteractionAnyCodable, rhs: InteractionAnyCodable) -> Bool {
        String(describing: lhs.value) == String(describing: rhs.value)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }
}

public struct InteractionEvent: Identifiable, Codable, Hashable {
    public let id: UUID
    public let type: InteractionType
    public let occurredAt: Date
    public let page: AppPage?
    public let userId: UUID?
    public let sessionId: String
    public let metadata: [String: InteractionAnyCodable]

    public init(
        id: UUID = UUID(),
        type: InteractionType,
        occurredAt: Date = Date(),
        page: AppPage? = nil,
        userId: UUID?,
        sessionId: String,
        metadata: [String: InteractionAnyCodable] = [:]
    ) {
        self.id = id
        self.type = type
        self.occurredAt = occurredAt
        self.page = page
        self.userId = userId
        self.sessionId = sessionId
        self.metadata = metadata
    }
}

// Convenience factories
public extension InteractionEvent {
    static func search(query: String, filters: [String: InteractionAnyCodable], page: AppPage?, userId: UUID?, sessionId: String) -> InteractionEvent {
        InteractionEvent(
            type: .searchPerformed,
            page: page,
            userId: userId,
            sessionId: sessionId,
            metadata: [
                "query": .init(query),
                "filters": .init(filters.mapValues { $0.value })
            ]
        )
    }

    static func propertyView(listingId: String, source: String, page: AppPage?, userId: UUID?, sessionId: String) -> InteractionEvent {
        InteractionEvent(
            type: .propertyViewed,
            page: page,
            userId: userId,
            sessionId: sessionId,
            metadata: [
                "listing_id": .init(listingId),
                "source": .init(source)
            ]
        )
    }

    static func propertySave(listingId: String, saved: Bool, page: AppPage?, userId: UUID?, sessionId: String) -> InteractionEvent {
        InteractionEvent(
            type: saved ? .propertySaved : .propertyUnsaved,
            page: page,
            userId: userId,
            sessionId: sessionId,
            metadata: [
                "listing_id": .init(listingId),
                "action": .init(saved ? "save" : "unsave")
            ]
        )
    }

    static func docUpload(name: String, type: String, page: AppPage?, userId: UUID?, sessionId: String) -> InteractionEvent {
        InteractionEvent(
            type: .documentUploaded,
            page: page,
            userId: userId,
            sessionId: sessionId,
            metadata: [
                "name": .init(name),
                "type": .init(type)
            ]
        )
    }

    static func journeyStageChange(from: JourneyStage, to: JourneyStage, page: AppPage?, userId: UUID?, sessionId: String) -> InteractionEvent {
        InteractionEvent(
            type: .journeyStageChanged,
            page: page,
            userId: userId,
            sessionId: sessionId,
            metadata: [
                "from": .init(from.rawValue),
                "to": .init(to.rawValue)
            ]
        )
    }

    static func tourScheduled(listingId: String?, page: AppPage?, userId: UUID?, sessionId: String) -> InteractionEvent {
        var md: [String: InteractionAnyCodable] = ["event": .init("tour_scheduled")]
        if let lid = listingId { md["listing_id"] = .init(lid) }
        return InteractionEvent(
            type: .tourScheduled,
            page: page,
            userId: userId,
            sessionId: sessionId,
            metadata: md
        )
    }
}