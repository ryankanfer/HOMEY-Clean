import Foundation

public struct StageInference: Codable {
    public let recommended: JourneyStage
    public let confidence: Double
    public let reasons: [String: Double]
    public let evaluatedAt: Date

    public init(recommended: JourneyStage, confidence: Double, reasons: [String: Double], evaluatedAt: Date = .now) {
        self.recommended = recommended
        self.confidence = confidence
        self.reasons = reasons
        self.evaluatedAt = evaluatedAt
    }
}

public enum StageDetector {
    public static func inferStage(recent events: [InteractionEvent], context: UserContext, state: CrossScreenState) -> StageInference {
        let now = Date()
        // Windows
        let last24h = events.filter { now.timeIntervalSince($0.occurredAt) <= 24 * 3600 }
        let last7d = events.filter { now.timeIntervalSince($0.occurredAt) <= 7 * 24 * 3600 }
        let last14d = events.filter { now.timeIntervalSince($0.occurredAt) <= 14 * 24 * 3600 }

        // Counts
        let searches24 = last24h.filter { $0.type == .searchPerformed }.count
        let views24 = last24h.filter { $0.type == .propertyViewed }.count
        let saves24 = last24h.filter { $0.type == .propertySaved }.count

        // Per-listing saves and views (7d window)
        var savesByListing: [String: Int] = [:]
        var viewsByListing: [String: Int] = [:]
        for e in last7d {
            if e.type == .propertySaved, let id = e.metadata["listing_id"]?.value as? String {
                savesByListing[id, default: 0] += 1
            }
            if e.type == .propertyViewed, let id = e.metadata["listing_id"]?.value as? String {
                viewsByListing[id, default: 0] += 1
            }
        }
        let repeatedListingSaves = savesByListing.values.max() ?? 0
        let repeatedListingViews = viewsByListing.values.max() ?? 0

        // Document signals (14d window)
        var uploadedDocTypes: Set<String> = []
        for e in last14d where e.type == .documentUploaded {
            if let t = e.metadata["type"]?.value as? String { uploadedDocTypes.insert(t) }
        }

        // Heuristics
        var recommended = context.journeyStage
        var reasons: [String: Double] = [:]

        // Actively searching => researching
        if searches24 >= 3 || views24 >= 6 || saves24 >= 3 {
            recommended = .researching
            let strength = min(1.0, (Double(searches24) / 5.0) + (Double(views24) / 12.0) + (Double(saves24) / 6.0))
            reasons["actively_searching"] = strength
        }

        // Found properties => viewing (tours scheduled or repeated saves/views for one listing)
        // We infer tours via custom/tourScheduled metadata or repeated saves+views
        let toursScheduled = last14d.contains { e in
            if e.type == .custom, let eventName = e.metadata["event"]?.value as? String {
                return eventName == "tour_scheduled"
            }
            if e.type == .tabSwitched, let to = e.metadata["to"]?.value as? String {
                return to == "tours"
            }
            return false
        }
        if toursScheduled || (repeatedListingSaves >= 2 && repeatedListingViews >= 2) {
            recommended = .viewing
            let strength = toursScheduled ? 1.0 : min(1.0, Double(repeatedListingSaves + repeatedListingViews) / 6.0)
            reasons["found_properties"] = strength
        }

        // In contract => closing (contracts/board-package uploads)
        let inContractDocs: Set<String> = ["Board Form", "Offer Letter", "contract", "purchaseAgreement"]
        if !uploadedDocTypes.isDisjoint(with: inContractDocs) {
            recommended = .closing
            reasons["in_contract_docs"] = 1.0
        }

        // Negotiating hint: offer letter without board form
        if uploadedDocTypes.contains("Offer Letter") && !uploadedDocTypes.contains("Board Form") {
            recommended = .negotiating
            reasons["offer_letter"] = 0.8
        }

        // Confidence
        let confidence = min(1.0, reasons.values.reduce(0, +))

        return StageInference(recommended: recommended, confidence: confidence, reasons: reasons)
    }
}