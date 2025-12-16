import Foundation
#if canImport(Supabase)
import Supabase
#endif

/// Service responsible for saving and fetching StreetEasy listing links in Supabase.
final class SavedListingsService {
    static let shared = SavedListingsService()

    #if canImport(Supabase)
    private var supabase: Any?
    #endif

    private init() {
        #if canImport(Supabase)
        // Lazily initialize Supabase client using Env helpers
        guard let url = URL(string: Env.projectURL), !Env.anonKey.isEmpty else {
            return
        }
        self.supabase = SupabaseClient(supabaseURL: url, supabaseKey: Env.anonKey)
        #endif
    }

    // MARK: - Save

    /// Saves a listing link into Supabase. If an Edge Function `saveListing` exists, it will be preferred.
    func saveListing(url: URL, title: String?, userID: UUID) async throws {
        #if canImport(Supabase)
        guard let supabase = self.supabase as? SupabaseClient else {
            throw NSError(domain: "SavedListingsServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }

        // Attempt to call edge function first (if configured); fall back to direct insert.
        // Edge Function path: /functions/v1/saveListing
        do {
            struct Payload: Codable { let url: String; let title: String?; let user_id: UUID }
            let payload = Payload(url: url.absoluteString, title: title, user_id: userID)
            // Use FunctionInvokeOptions per supabase-swift 2.x API; decode a generic dictionary.
            let options = FunctionInvokeOptions(headers: [:], body: payload)
            let _: [String: String] = try await supabase.functions.invoke("saveListing", options: options, decoder: JSONDecoder())
            return
        } catch {
            // Fall back to direct insert into saved_listings table
            struct Record: Codable {
                let user_id: UUID
                let url: String
                let title: String?
            }
            let record = Record(user_id: userID, url: url.absoluteString, title: title)
            try await supabase.database
                .from("saved_listings")
                .insert(record)
                .execute()
        }
        #else
        throw NSError(
            domain: "SavedListingsServiceError",
            code: -2,
            userInfo: [
                NSLocalizedDescriptionKey: "Supabase SDK not available in this target. Add and link the Supabase package to use SavedListingsService."
            ]
        )
        #endif
    }

    // MARK: - Fetch

    func fetchSavedListings(for userID: UUID) async throws -> [SavedListingLink] {
        #if canImport(Supabase)
        guard let supabase = self.supabase as? SupabaseClient else {
            throw NSError(domain: "SavedListingsServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }

        let response: [SavedListingLink] = try await supabase.database
            .from("saved_listings")
            .select()
            .eq("user_id", value: userID)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
        #else
        throw NSError(
            domain: "SavedListingsServiceError",
            code: -2,
            userInfo: [
                NSLocalizedDescriptionKey: "Supabase SDK not available in this target. Add and link the Supabase package to use SavedListingsService."
            ]
        )
        #endif
    }
}