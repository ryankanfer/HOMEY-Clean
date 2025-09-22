import Foundation

// MARK: - Search Record (renamed to avoid conflict with domain SearchCriteria)
public struct SearchRecord: Codable, Hashable {
    public let query: String
    public let filters: [String: InteractionAnyCodable]
    public let timestamp: Date

    public init(query: String, filters: [String: InteractionAnyCodable], timestamp: Date = .now) {
        self.query = query
        self.filters = filters
        self.timestamp = timestamp
    }
}

// MARK: - User Context

public enum BehaviorTag: String, Codable, Hashable {
    case prefersCondos
    case prefersHouses
    case petFriendly
    case priceSensitive
    case fastResponder
    case documentationFocused
    case neighborhoodExplorer
}

public struct PreferencesSummary: Codable, Hashable {
    public var budgetMin: Double?
    public var budgetMax: Double?
    public var propertyTypes: [String]
    public var neighborhoods: [String]
    public var bedrooms: Int?
    public var bathrooms: Double?

    public init(
        budgetMin: Double? = nil,
        budgetMax: Double? = nil,
        propertyTypes: [String] = [],
        neighborhoods: [String] = [],
        bedrooms: Int? = nil,
        bathrooms: Double? = nil
    ) {
        self.budgetMin = budgetMin
        self.budgetMax = budgetMax
        self.propertyTypes = propertyTypes
        self.neighborhoods = neighborhoods
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
    }
}

public struct UserContext: Codable, Hashable {
    public var journeyStage: JourneyStage
    public var preferences: PreferencesSummary
    public var inferredBehaviors: Set<BehaviorTag>
    public var recentWindowStart: Date

    public init(
        journeyStage: JourneyStage = .exploring,
        preferences: PreferencesSummary = PreferencesSummary(),
        inferredBehaviors: Set<BehaviorTag> = [],
        recentWindowStart: Date = Calendar.current.date(byAdding: .day, value: -14, to: .now) ?? .now
    ) {
        self.journeyStage = journeyStage
        self.preferences = preferences
        self.inferredBehaviors = inferredBehaviors
        self.recentWindowStart = recentWindowStart
    }
}

// MARK: - Cross Screen State

public struct CrossScreenState: Codable, Hashable {
    public var lastSearch: SearchRecord?
    public var lastViewedPropertyId: String?
    public var recentlyUploadedDocs: [DocumentType]
    public var lastMessageFromAgentAt: Date?

    public init(
        lastSearch: SearchRecord? = nil,
        lastViewedPropertyId: String? = nil,
        recentlyUploadedDocs: [DocumentType] = [],
        lastMessageFromAgentAt: Date? = nil
    ) {
        self.lastSearch = lastSearch
        self.lastViewedPropertyId = lastViewedPropertyId
        self.recentlyUploadedDocs = recentlyUploadedDocs
        self.lastMessageFromAgentAt = lastMessageFromAgentAt
    }
}

// MARK: - CrossScreenContext Store

@MainActor
public final class CrossScreenContext: ObservableObject {
    public static let shared = CrossScreenContext()

    @Published public private(set) var userContext: UserContext
    @Published public private(set) var state: CrossScreenState

    private let storageKey = "cross.screen.context.v1"

    private init(userContext: UserContext = UserContext(), state: CrossScreenState = CrossScreenState()) {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            self.userContext = decoded.userContext
            self.state = decoded.state
        } else {
            self.userContext = userContext
            self.state = state
        }
    }

    public func apply(_ event: InteractionEvent) {
        switch event.type {
        case .searchPerformed:
            if let query = event.metadata["query"]?.value as? String {
                var filters: [String: InteractionAnyCodable] = [:]
                if let fx = event.metadata["filters"]?.value as? [String: Any] {
                    filters = fx.mapValues { InteractionAnyCodable($0) }
                }
                state.lastSearch = SearchRecord(query: query, filters: filters, timestamp: event.occurredAt)
            }
        case .propertyViewed:
            if let pid = event.metadata["listing_id"]?.value as? String {
                state.lastViewedPropertyId = pid
            }
        case .propertySaved:
            if let _ = event.metadata["listing_id"]?.value as? String {
                userContext.inferredBehaviors.insert(.fastResponder)
            }
        case .documentUploaded:
            if let type = event.metadata["type"]?.value as? String,
               let docType = DocumentType(rawValue: type) {
                var docs = state.recentlyUploadedDocs
                docs.removeAll(where: { $0 == docType })
                docs.insert(docType, at: 0)
                state.recentlyUploadedDocs = Array(docs.prefix(10))
                userContext.inferredBehaviors.insert(.documentationFocused)
            }
        case .journeyStageChanged:
            if let to = event.metadata["to"]?.value as? String,
               let stage = JourneyStage(rawValue: to) {
                userContext.journeyStage = stage
            }
        case .messageReceived:
            state.lastMessageFromAgentAt = event.occurredAt
        default:
            break
        }

        persist()
    }

    public func hydrateFromProfileIfAvailable() {
        if let profile = AppSessionManager.shared.userProfile {
            var summary = PreferencesSummary()

            if let criteria = profile.journeyState.activeSearchCriteria {
                summary.budgetMin = criteria.minPrice
                summary.budgetMax = criteria.maxPrice
                if let beds = criteria.bedrooms { summary.bedrooms = beds }
                if let baths = criteria.bathrooms { summary.bathrooms = Double(baths) }
                summary.neighborhoods = criteria.neighborhoods
                if let type = criteria.propertyType {
                    summary.propertyTypes = [type]
                }
            }

            userContext.preferences = summary
            userContext.journeyStage = profile.journeyStage
            persist()
        }
    }

    private func persist() {
        let snap = Snapshot(userContext: userContext, state: state)
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private struct Snapshot: Codable {
        let userContext: UserContext
        let state: CrossScreenState
    }
}