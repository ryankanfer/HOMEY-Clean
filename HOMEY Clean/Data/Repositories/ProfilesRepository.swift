//
//  ProfilesRepository.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 1/25/25.
//

import Foundation
import Supabase

// MARK: - Profile Models
struct ProfileRecord: Codable, Identifiable {
    let id: UUID
    let email: String?
    let fullName: String?
    let role: String
    let clientSegment: String?
    let createdAt: Date
    let updatedAt: Date
    let avatarUrl: String?
    let phoneNumber: String?
    let preferredComms: String?
    let workingWithAgent: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case role
        case clientSegment = "client_segment"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case avatarUrl = "avatar_url"
        case phoneNumber = "phone_number"
        case preferredComms = "preferred_comms"
        case workingWithAgent = "working_with_agent"
    }
}

struct ProfileUpdateRequest: Codable {
    let fullName: String?
    let phoneNumber: String?
    let preferredComms: String?
    let workingWithAgent: Bool?
    let clientSegment: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case preferredComms = "preferred_comms"
        case workingWithAgent = "working_with_agent"
        case clientSegment = "client_segment"
    }
}

// MARK: - Profiles Repository
class ProfilesRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    @MainActor
    convenience init() {
        self.init(client: AppSessionManager.shared.supabaseClient)
    }
    
    // MARK: - Profile Management
    
    func fetchProfile(for userId: UUID) async throws -> ProfileRecord {
        let response: PostgrestResponse<ProfileRecord> = try await client
            .from("profiles")
            .select("*")
            .eq("id", value: userId)
            .single()
            .execute()
        
        return response.value
    }
    
    func fetchCurrentUserProfile() async throws -> ProfileRecord {
        let user = try await client.auth.user()
        return try await fetchProfile(for: user.id)
    }
    
    func updateProfile(_ update: ProfileUpdateRequest) async throws -> ProfileRecord {
        let user = try await client.auth.user()
        
        let response: PostgrestResponse<ProfileRecord> = try await client
            .from("profiles")
            .update(update)
            .eq("id", value: user.id)
            .select("*")
            .single()
            .execute()
        
        return response.value
    }
    
    func createProfile(userId: UUID, email: String, fullName: String, role: String = "client") async throws -> ProfileRecord {
        struct CreateProfileRequest: Codable {
            let id: UUID
            let email: String
            let fullName: String
            let role: String
            
            enum CodingKeys: String, CodingKey {
                case id
                case email
                case fullName = "full_name"
                case role
            }
        }
        
        let request = CreateProfileRequest(
            id: userId,
            email: email,
            fullName: fullName,
            role: role
        )
        
        let response: PostgrestResponse<ProfileRecord> = try await client
            .from("profiles")
            .insert(request)
            .select("*")
            .single()
            .execute()
        
        return response.value
    }
    
    func updateAvatar(userId: UUID, avatarUrl: String) async throws {
        struct AvatarUpdate: Codable {
            let avatarUrl: String
            
            enum CodingKeys: String, CodingKey {
                case avatarUrl = "avatar_url"
            }
        }
        
        try await client
            .from("profiles")
            .update(AvatarUpdate(avatarUrl: avatarUrl))
            .eq("id", value: userId)
            .execute()
    }
    
    func deleteProfile(userId: UUID) async throws {
        try await client
            .from("profiles")
            .delete()
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Agent-specific methods
    
    func fetchClientProfiles() async throws -> [ProfileRecord] {
        let response: PostgrestResponse<[ProfileRecord]> = try await client
            .from("profiles")
            .select("*")
            .eq("role", value: "client")
            .execute()
        
        return response.value
    }
    
    func assignAgent(clientId: UUID, agentId: UUID) async throws {
        struct AgentAssignment: Codable {
            let agentId: UUID
            
            enum CodingKeys: String, CodingKey {
                case agentId = "agent_id"
            }
        }
        
        try await client
            .from("profiles")
            .update(AgentAssignment(agentId: agentId))
            .eq("id", value: clientId)
            .execute()
    }
}