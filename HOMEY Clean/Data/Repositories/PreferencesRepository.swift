//
//  PreferencesRepository.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 1/25/25.
//

import Foundation
import Supabase

// MARK: - Preferences Models
struct PreferencesRecord: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let budget: BudgetRange?
    let neighborhoods: [String]
    let bedrooms: Int?
    let bathrooms: Double?
    let pets: Bool?
    let timing: String?
    let propertyTypes: [String]
    let mustHaves: [String]
    let dealBreakers: [String]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case budget
        case neighborhoods
        case bedrooms
        case bathrooms
        case pets
        case timing
        case propertyTypes = "property_types"
        case mustHaves = "must_haves"
        case dealBreakers = "deal_breakers"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct BudgetRange: Codable {
    let min: Double
    let max: Double
    let type: String // "rent" or "purchase"
}

struct PreferencesUpdateRequest: Codable {
    let budget: BudgetRange?
    let neighborhoods: [String]?
    let bedrooms: Int?
    let bathrooms: Double?
    let pets: Bool?
    let timing: String?
    let propertyTypes: [String]?
    let mustHaves: [String]?
    let dealBreakers: [String]?
    
    enum CodingKeys: String, CodingKey {
        case budget
        case neighborhoods
        case bedrooms
        case bathrooms
        case pets
        case timing
        case propertyTypes = "property_types"
        case mustHaves = "must_haves"
        case dealBreakers = "deal_breakers"
    }
}

// MARK: - Preferences Repository
class PreferencesRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    @MainActor
    convenience init() {
        self.init(client: AppSessionManager.shared.supabaseClient)
    }
    
    // MARK: - Preferences Management
    
    func fetchPreferences(for userId: UUID) async throws -> PreferencesRecord? {
        let response: PostgrestResponse<[PreferencesRecord]> = try await client
            .from("preferences")
            .select("*")
            .eq("user_id", value: userId)
            .execute()
        
        return response.value.first
    }
    
    func fetchCurrentUserPreferences() async throws -> PreferencesRecord? {
        let user = try await client.auth.user()
        return try await fetchPreferences(for: user.id)
    }
    
    func updatePreferences(_ update: PreferencesUpdateRequest) async throws -> PreferencesRecord {
        let user = try await client.auth.user()
        
        // Check if preferences exist
        if let existing = try await fetchPreferences(for: user.id) {
            // Update existing preferences
            let response: PostgrestResponse<PreferencesRecord> = try await client
                .from("preferences")
                .update(update)
                .eq("user_id", value: user.id)
                .select("*")
                .single()
                .execute()
            
            return response.value
        } else {
            // Create new preferences
            return try await createPreferences(userId: user.id, preferences: update)
        }
    }
    
    func createPreferences(userId: UUID, preferences: PreferencesUpdateRequest) async throws -> PreferencesRecord {
        struct CreatePreferencesRequest: Codable {
            let id: UUID
            let userId: UUID
            let budget: BudgetRange?
            let neighborhoods: [String]
            let bedrooms: Int?
            let bathrooms: Double?
            let pets: Bool?
            let timing: String?
            let propertyTypes: [String]
            let mustHaves: [String]
            let dealBreakers: [String]
            
            enum CodingKeys: String, CodingKey {
                case id
                case userId = "user_id"
                case budget
                case neighborhoods
                case bedrooms
                case bathrooms
                case pets
                case timing
                case propertyTypes = "property_types"
                case mustHaves = "must_haves"
                case dealBreakers = "deal_breakers"
            }
        }
        
        let request = CreatePreferencesRequest(
            id: UUID(),
            userId: userId,
            budget: preferences.budget,
            neighborhoods: preferences.neighborhoods ?? [],
            bedrooms: preferences.bedrooms,
            bathrooms: preferences.bathrooms,
            pets: preferences.pets,
            timing: preferences.timing,
            propertyTypes: preferences.propertyTypes ?? [],
            mustHaves: preferences.mustHaves ?? [],
            dealBreakers: preferences.dealBreakers ?? []
        )
        
        let response: PostgrestResponse<PreferencesRecord> = try await client
            .from("preferences")
            .insert(request)
            .select("*")
            .single()
            .execute()
        
        return response.value
    }
    
    func updateBudget(userId: UUID, budget: BudgetRange) async throws {
        try await client
            .from("preferences")
            .update(["budget": budget])
            .eq("user_id", value: userId)
            .execute()
    }
    
    func addNeighborhood(userId: UUID, neighborhood: String) async throws {
        // First fetch current neighborhoods
        guard let current = try await fetchPreferences(for: userId) else { return }
        
        var neighborhoods = current.neighborhoods
        if !neighborhoods.contains(neighborhood) {
            neighborhoods.append(neighborhood)
            
            try await client
                .from("preferences")
                .update(["neighborhoods": neighborhoods])
                .eq("user_id", value: userId)
                .execute()
        }
    }
    
    func removeNeighborhood(userId: UUID, neighborhood: String) async throws {
        // First fetch current neighborhoods
        guard let current = try await fetchPreferences(for: userId) else { return }
        
        let neighborhoods = current.neighborhoods.filter { $0 != neighborhood }
        
        try await client
            .from("preferences")
            .update(["neighborhoods": neighborhoods])
            .eq("user_id", value: userId)
            .execute()
    }
    
    func updateTiming(userId: UUID, timing: String) async throws {
        try await client
            .from("preferences")
            .update(["timing": timing])
            .eq("user_id", value: userId)
            .execute()
    }
    
    func deletePreferences(userId: UUID) async throws {
        try await client
            .from("preferences")
            .delete()
            .eq("user_id", value: userId)
            .execute()
    }
}