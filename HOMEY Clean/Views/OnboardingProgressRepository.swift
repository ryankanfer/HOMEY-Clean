import Foundation
#if canImport(Supabase)
import Supabase
#endif

/// Repository for onboarding progress persistence (basic_lifestyle + overall progress)
#if canImport(Supabase)
final class OnboardingProgressRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) { self.client = client }

    // Upsert basic lifestyle JSON for the current user
    func upsertBasicLifestyle(_ selections: [String: String]) async throws {
        struct UpdatePayload: Encodable {
            let user_id: UUID
            let basic_lifestyle: [String: String]
            let updated_at: String
        }
        let user = try await client.auth.user()
        let payload = UpdatePayload(
            user_id: user.id,
            basic_lifestyle: selections,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )

        // Try update, if not present then insert
        let updateResponse = try? await client
            .from("user_onboarding_progress")
            .update(payload)
            .eq("user_id", value: user.id)
            .select("*")
            .single()
            .execute()
        if updateResponse?.value != nil { return }

        struct InsertPayload: Encodable {
            let user_id: UUID
            let basic_lifestyle: [String: String]
            let overall_progress: Int
            let current_step: String
            let created_at: String
            let updated_at: String
        }
        let insert = InsertPayload(
            user_id: user.id,
            basic_lifestyle: selections,
            overall_progress: 0,
            current_step: "lifestyle",
            created_at: ISO8601DateFormatter().string(from: Date()),
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        _ = try await client
            .from("user_onboarding_progress")
            .insert(insert)
            .execute()
    }

    func fetchBasicLifestyleForCurrentUser() async throws -> [String: String]? {
        let user = try await client.auth.user()
        struct Row: Decodable { let basic_lifestyle: [String: String]? }
        let response: PostgrestResponse<Row> = try await client
            .from("user_onboarding_progress")
            .select("basic_lifestyle")
            .eq("user_id", value: user.id)
            .single()
            .execute()
        return response.value.basic_lifestyle
    }
}
#endif
