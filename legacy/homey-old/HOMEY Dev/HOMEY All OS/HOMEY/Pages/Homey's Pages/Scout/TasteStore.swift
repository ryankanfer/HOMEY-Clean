import Combine
import Foundation
import os.log
import Supabase

@MainActor
final class TasteStore: ObservableObject {
    @Published var summary: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private let logger = Logger(subsystem: "com.homey.app", category: "TasteStore")

    func load(for userId: UUID, client: SupabaseClient) async {
        isLoading = true
        error = nil

        do {
            let resp = try await client
                .from("profiles")
                .select("taste_summary")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()

            struct Row: Decodable { let taste_summary: String? }
            let row = try JSONDecoder().decode(Row.self, from: resp.data)
            summary = row.taste_summary ?? ""
            logger.info("Successfully loaded taste summary for user: \(userId)")
        } catch {
            logger.error("Failed to load taste summary: \(error.localizedDescription)")
            self.error = error
            summary = ""
        }

        isLoading = false
    }
}
