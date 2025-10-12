//
//  ProfilesRepository.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 1/25/25.
//

import Foundation
import SwiftUI
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
    let firstName: String?
    let lastName: String?
    let agentId: UUID?
    
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
        case firstName = "first_name"
        case lastName = "last_name"
        case agentId = "agent_id"
    }
}

struct ProfileUpdateRequest: Codable {
    let fullName: String?
    let phoneNumber: String?
    let preferredComms: String?
    let workingWithAgent: Bool?
    let clientSegment: String?
    let firstName: String?
    let lastName: String?
    // Optional extended fields (Continue Onboarding)
    let occupation: String?
    let income: Double?
    let liquidAssets: Double?
    let reasonForPurchase: String?
    let employmentType: String?
    let pets: Bool?
    let needsElevator: Bool?
    let preferredNeighborhood: String?
    let bedrooms: Int?
    let bathrooms: Int?
    let propertyTenure: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case preferredComms = "preferred_comms"
        case workingWithAgent = "working_with_agent"
        case clientSegment = "client_segment"
        case firstName = "first_name"
        case lastName = "last_name"
        case occupation
        case income
        case liquidAssets = "liquid_assets"
        case reasonForPurchase = "reason_for_purchase"
        case employmentType = "employment_type"
        case pets
        case needsElevator = "needs_elevator"
        case preferredNeighborhood = "preferred_neighborhood"
        case bedrooms
        case bathrooms
        case propertyTenure = "property_tenure"
    }
}

// MARK: - ProfileRecord Extensions for UserProfile Compatibility
extension ProfileRecord {
    /// Convert ProfileRecord to UserProfile for compatibility with existing journey management
    func toUserProfile(
        journeyStage: JourneyStage = .exploring,
        preferences: UserPreferences = UserPreferences(),
        journeyState: JourneyState = JourneyState(),
        onboardingCompleted: Bool = false
    ) -> UserProfile {
        return UserProfile(
            id: self.id,
            email: self.email ?? "",
            fullName: self.fullName,
            role: self.role,
            clientSegment: self.clientSegment,
            journeyStage: journeyStage,
            preferences: preferences,
            journeyState: journeyState,
            onboardingCompleted: onboardingCompleted,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
    
    /// Create ProfileRecord from UserProfile for database operations
    static func from(userProfile: UserProfile) -> ProfileRecord {
        return ProfileRecord(
            id: userProfile.id,
            email: userProfile.email,
            fullName: userProfile.fullName,
            role: userProfile.role,
            clientSegment: userProfile.clientSegment,
            createdAt: userProfile.createdAt,
            updatedAt: userProfile.updatedAt,
            avatarUrl: nil, // Not available in UserProfile
            phoneNumber: nil, // Not available in UserProfile
            preferredComms: nil, // Not available in UserProfile
            workingWithAgent: nil, // Not available in UserProfile
            firstName: userProfile.fullName?.components(separatedBy: " ").first,
            lastName: userProfile.fullName?.components(separatedBy: " ").dropFirst().joined(separator: " "),
            agentId: nil // Not available in UserProfile
        )
    }
}

// MARK: - Profiles Repository
class ProfilesRepository: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    @MainActor
    convenience init() {
        self.init(client: AppSessionManager.shared.supabaseClient)
    }
    
    // MARK: - Agent-Client Relationship Management
    
    /// Fetch all clients assigned to the current agent
    func fetchClientProfiles() async throws -> [ProfileRecord] {
        let user = try await client.auth.user()
        
        // Query agent_client_links to get client IDs for this agent
        struct AgentClientLink: Codable {
            let clientId: UUID
            
            enum CodingKeys: String, CodingKey {
                case clientId = "client_id"
            }
        }
        
        let linksResponse: PostgrestResponse<[AgentClientLink]> = try await client
            .from("agent_client_links")
            .select("client_id")
            .eq("agent_id", value: user.id)
            .eq("status", value: "active")
            .execute()
        
        let clientIds = linksResponse.value.map { $0.clientId }
        
        guard !clientIds.isEmpty else {
            return []
        }
        
        // Fetch profiles for these client IDs
        let profilesResponse: PostgrestResponse<[ProfileRecord]> = try await client
            .from("profiles")
            .select("*")
            .in("id", values: clientIds)
            .execute()
        
        return profilesResponse.value
    }
    
    /// Fetch the assigned agent for the current client
    func fetchAssignedAgent() async throws -> ProfileRecord? {
        let user = try await client.auth.user()
        
        // Query agent_client_links to get agent ID for this client
        struct AgentClientLink: Codable {
            let agentId: UUID
            
            enum CodingKeys: String, CodingKey {
                case agentId = "agent_id"
            }
        }
        
        let linksResponse: PostgrestResponse<[AgentClientLink]> = try await client
            .from("agent_client_links")
            .select("agent_id")
            .eq("client_id", value: user.id)
            .eq("status", value: "active")
            .limit(1)
            .execute()
        
        guard let agentId = linksResponse.value.first?.agentId else {
            return nil
        }
        
        // Fetch the agent's profile
        return try await fetchProfile(for: agentId)
    }
    
    /// Create a new agent-client link
    func createAgentClientLink(agentId: UUID, clientId: UUID, invitedBy: UUID) async throws {
        struct CreateLinkRequest: Codable {
            let agentId: UUID
            let clientId: UUID
            let invitedBy: UUID
            let status: String
            let createdAt: Date
            
            enum CodingKeys: String, CodingKey {
                case agentId = "agent_id"
                case clientId = "client_id"
                case invitedBy = "invited_by"
                case status
                case createdAt = "created_at"
            }
        }
        
        let request = CreateLinkRequest(
            agentId: agentId,
            clientId: clientId,
            invitedBy: invitedBy,
            status: "active",
            createdAt: Date()
        )
        
        let _: PostgrestResponse<[CreateLinkRequest]> = try await client
            .from("agent_client_links")
            .insert(request)
            .execute()
    }
    
    /// Update agent-client link status
    func updateAgentClientLinkStatus(agentId: UUID, clientId: UUID, status: String) async throws {
        struct UpdateStatusRequest: Codable {
            let status: String
            let updatedAt: Date
            
            enum CodingKeys: String, CodingKey {
                case status
                case updatedAt = "updated_at"
            }
        }
        
        let request = UpdateStatusRequest(
            status: status,
            updatedAt: Date()
        )
        
        let _: PostgrestResponse<[UpdateStatusRequest]> = try await client
            .from("agent_client_links")
            .update(request)
            .eq("agent_id", value: agentId)
            .eq("client_id", value: clientId)
            .execute()
    }
    
    /// Check if current user has access to a specific client's data
    func hasAccessToClient(_ clientId: UUID) async throws -> Bool {
        let user = try await client.auth.user()
        
        // If user is the client themselves, they have access
        if user.id == clientId {
            return true
        }
        
        // Check if user is an agent with access to this client
        struct AgentClientLink: Codable {
            let clientId: UUID
            
            enum CodingKeys: String, CodingKey {
                case clientId = "client_id"
            }
        }
        
        let response: PostgrestResponse<[AgentClientLink]> = try await client
            .from("agent_client_links")
            .select("client_id")
            .eq("agent_id", value: user.id)
            .eq("client_id", value: clientId)
            .eq("status", value: "active")
            .execute()
        
        return !response.value.isEmpty
    }
    
    /// Check if current user has agent role and access permissions
    func hasAgentAccess() async throws -> Bool {
        let profile = try await fetchCurrentUserProfile()
        return profile.role == "agent"
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
            let firstName: String?
            let lastName: String?
            
            enum CodingKeys: String, CodingKey {
                case id
                case email
                case fullName = "full_name"
                case role
                case firstName = "first_name"
                case lastName = "last_name"
            }
        }
        
        let parts = fullName.split(separator: " ", maxSplits: 1).map(String.init)
        let req = CreateProfileRequest(
            id: userId,
            email: email,
            fullName: fullName,
            role: role,
            firstName: parts.first,
            lastName: parts.count > 1 ? parts.last : nil
        )
        
        let response: PostgrestResponse<ProfileRecord> = try await client
            .from("profiles")
            .insert(req)
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