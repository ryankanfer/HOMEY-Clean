import Foundation
import Supabase

class ListingService {
    static let shared = ListingService()

    private var supabase: SupabaseClient? {
        do {
            let authManager = try RealSupabaseAuthManager()
            return authManager.client
        } catch {
            print("Error initializing Supabase client: \(error)")
            return nil
        }
    }

    private init() {}

    // MARK: - Fetching Listings
    
    func fetchListings() async throws -> [Listing] {
        guard let supabase = self.supabase else {
            throw NSError(domain: "ListingServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }

        let response: [Listing] = try await supabase.database
            .from("listings")
            .select()
            .execute()
            .value
        
        return response
    }

    // MARK: - Saved Properties

    func fetchSavedPropertyIDs(for userID: UUID) async throws -> Set<UUID> {
        guard let supabase = self.supabase else {
            throw NSError(domain: "ListingServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }
        
        struct SavedProperty: Codable {
            let listing_id: UUID
        }

        let response: [SavedProperty] = try await supabase.database
            .from("user_saved_properties")
            .select("listing_id")
            .eq("user_id", value: userID)
            .execute()
            .value
        
        return Set(response.map { $0.listing_id })
    }

    func saveProperty(listingID: UUID, userID: UUID) async throws {
        guard let supabase = self.supabase else {
            throw NSError(domain: "ListingServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }

        struct SavedProperty: Codable {
            let user_id: UUID
            let listing_id: UUID
        }
        
        let savedProperty = SavedProperty(user_id: userID, listing_id: listingID)

        try await supabase.database
            .from("user_saved_properties")
            .insert(savedProperty)
            .execute()
    }
    
    func unsaveProperty(listingID: UUID, userID: UUID) async throws {
        guard let supabase = self.supabase else {
            throw NSError(domain: "ListingServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }

        try await supabase.database
            .from("user_saved_properties")
            .delete()
            .eq("user_id", value: userID)
            .eq("listing_id", value: listingID)
            .execute()
    }
}