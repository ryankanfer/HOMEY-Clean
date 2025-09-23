import Foundation
#if canImport(Supabase)
import Supabase
#endif

public struct SuggestionMetric: Codable {
    public let suggestionId: UUID
    public let type: SuggestionType
    public let page: AppPage?
    public let action: String // impression|click
    public let timestamp: Date
}

public struct AdoptionMetric: Codable {
    public let page: AppPage
    public let action: String // viewed|engaged
    public let timestamp: Date
}

public actor MetricsTracker {
    public static let shared = MetricsTracker()

    private var buffer: [String: Int] = [:]
    private let storageKey = "metrics.buffer.v1"

    private func key(_ metric: SuggestionMetric) -> String {
        "sug#\(metric.suggestionId.uuidString)#\(metric.action)"
    }

    private func key(_ metric: AdoptionMetric) -> String {
        "adopt#\(metric.page.rawValue)#\(metric.action)"
    }

    public func trackSuggestionImpression(_ suggestion: Suggestion) async {
        let m = SuggestionMetric(suggestionId: suggestion.id, type: suggestion.type, page: suggestion.page, action: "impression", timestamp: .now)
        buffer[key(m), default: 0] += 1
        await flushIfNeeded()
    }

    public func trackSuggestionClick(_ suggestion: Suggestion) async {
        let m = SuggestionMetric(suggestionId: suggestion.id, type: suggestion.type, page: suggestion.page, action: "click", timestamp: .now)
        buffer[key(m), default: 0] += 1
        await flushIfNeeded()
    }

    public func trackPageAdoption(_ page: AppPage, action: String = "viewed") async {
        let m = AdoptionMetric(page: page, action: action, timestamp: .now)
        buffer[key(m), default: 0] += 1
        await flushIfNeeded()
    }

    public func trackChecklistCompletion(id: String) async {
        buffer["checklist#\(id)#completed", default: 0] += 1
        await flushIfNeeded()
    }

    public func trackSupportEventReduced() async {
        buffer["support#reduced", default: 0] += 1
        await flushIfNeeded()
    }

    private func flushIfNeeded() async {
        if buffer.values.reduce(0, +) < 10 { return }
        await flush()
    }

    public func flush() async {
        let payload = buffer
        buffer.removeAll()

        #if canImport(Supabase)
        let allowed = await GovernanceCenter.shared.privacy.trackingEnabled
        if !allowed { return }
        let client = await MainActor.run { AppSessionManager.shared.supabaseClient }

        struct Row: Encodable {
            let bucket: String
            let count: Int
            let user_id: UUID?
            let created_at: String
        }

        let uid = await InteractionLogger.shared.currentUserId()
        let rows: [Row] = payload.map { (k, v) in
            Row(bucket: k, count: v, user_id: uid, created_at: ISO8601DateFormatter().string(from: Date()))
        }

        do {
            _ = try await client.from("intelligence_metrics").insert(rows).execute()
        } catch {
            #if DEBUG
            print("Metrics flush failed: \(error.localizedDescription)")
            #endif
        }
        #endif
    }
}