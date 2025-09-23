import Foundation
#if canImport(Supabase)
import Supabase
#endif

public struct RecommendationSummary: Codable {
    public let userId: UUID
    public let currentStage: JourneyStage
    public let inferredStage: JourneyStage
    public let confidence: Double
    public let reasons: [String: Double]
    public let preferences: PreferencesSnapshot
    public let counters: Counters
    public let updatedAt: Date

    public struct PreferencesSnapshot: Codable {
        public let budgetMin: Double?
        public let budgetMax: Double?
        public let propertyTypes: [String]
        public let neighborhoods: [String]
        public let bedrooms: Int?
        public let bathrooms: Double?
    }

    public struct Counters: Codable {
        public let searches24: Int
        public let views24: Int
        public let saves24: Int
    }
}

public actor RecommendationEngineWriter {
    public static let shared = RecommendationEngineWriter()

    public func write(summary: RecommendationSummary) async {
        #if canImport(Supabase)
        let client = await MainActor.run { AppSessionManager.shared.supabaseClient }
        struct Row: Encodable {
            let user_id: UUID
            let journey_stage: String
            let inferred_stage: String
            let confidence: Double
            let summary_json: Data
            let updated_at: String
        }
        do {
            let data = try JSONEncoder().encode(summary)
            let row = Row(
                user_id: summary.userId,
                journey_stage: summary.currentStage.rawValue,
                inferred_stage: summary.inferredStage.rawValue,
                confidence: summary.confidence,
                summary_json: data,
                updated_at: ISO8601DateFormatter().string(from: summary.updatedAt)
            )
            _ = try await client
                .from("recommendation_engine")
                .upsert(row, onConflict: "user_id")
                .execute()
        } catch {
            #if DEBUG
            print("RecommendationEngineWriter upsert failed: \(error.localizedDescription)")
            #endif
        }
        #endif
    }
}