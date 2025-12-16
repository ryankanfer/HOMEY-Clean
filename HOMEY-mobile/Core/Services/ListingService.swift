import Foundation
#if canImport(Supabase)
import Supabase
#endif

class ListingService {
    static let shared = ListingService()

    #if canImport(Supabase)
    private var supabase: SupabaseClient? {
        do {
            let authManager = try RealSupabaseAuthManager()
            return authManager.client
        } catch {
            print("Error initializing Supabase client: \(error)")
            return nil
        }
    }
    #else
    private var supabase: Any? { nil }
    #endif

    private init() {}

    // MARK: - Fetching Listings
    
    func fetchListings() async throws -> [Listing] {
        #if canImport(Supabase)
        guard let supabase = self.supabase as? SupabaseClient else {
            throw NSError(domain: "ListingServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }

        let response: [Listing] = try await supabase.database
            .from("listings")
            .select()
            .execute()
            .value
        
        return response
        #else
        throw NSError(domain: "ListingServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not available in this target. Add and link the Supabase package to use ListingService."])
        #endif
    }

    // MARK: - Saved Properties

    func fetchSavedPropertyIDs(for userID: UUID) async throws -> Set<UUID> {
        #if canImport(Supabase)
        guard let supabase = self.supabase as? SupabaseClient else {
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
        #else
        throw NSError(domain: "ListingServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not available in this target. Add and link the Supabase package to use ListingService."])
        #endif
    }

    func saveProperty(listingID: UUID, userID: UUID) async throws {
        #if canImport(Supabase)
        guard let supabase = self.supabase as? SupabaseClient else {
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
        #else
        throw NSError(domain: "ListingServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not available in this target. Add and link the Supabase package to use ListingService."])
        #endif
    }
    
    func unsaveProperty(listingID: UUID, userID: UUID) async throws {
        #if canImport(Supabase)
        guard let supabase = self.supabase as? SupabaseClient else {
            throw NSError(domain: "ListingServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not initialized"])
        }

        try await supabase.database
            .from("user_saved_properties")
            .delete()
            .eq("user_id", value: userID)
            .eq("listing_id", value: listingID)
            .execute()
        #else
        throw NSError(domain: "ListingServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not available in this target. Add and link the Supabase package to use ListingService."])
        #endif
    }
}
