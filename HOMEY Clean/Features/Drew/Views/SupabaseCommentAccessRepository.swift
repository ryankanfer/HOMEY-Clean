//  SupabaseCommentAccessRepository.swift
//  HOMEY Clean
//
//  Helper to manage comment access rows in Supabase.
//  NOTE ON RLS:
//  With the policy "Insert own access" (auth.uid() = user_id), only the AGENT can insert
//  their own access row from the client app. If you want the CLIENT to grant access to an
//  agent automatically, you should:
//   - Use a server-side function (Postgres SECURITY DEFINER) or
//   - Call a trusted server (using the service role key) to perform the insert on behalf of the client.
//
//  The methods below provide both patterns:
//   - grantAccessForCurrentUser(targetId:) — for agents to self-grant access
//   - grantAccessForAgent(targetId:agentUserId:) — will only succeed if your RLS allows it
//     (e.g., via a custom policy or if called from a trusted environment)

import Foundation
import Supabase

final class SupabaseCommentAccessRepository {
    static let shared = SupabaseCommentAccessRepository()
    private init() {}

    private var client: SupabaseClient { SupabaseClientProvider.client }

    struct AccessRow: Codable, Identifiable {
        let id: UUID
        let target_id: String
        let user_id: UUID
        let created_at: Date
    }
    
    private struct InsertAccessPayload: Encodable {
        let target_id: String
        let user_id: String
    }

    // MARK: - Agent self-grant
    // Allows the CURRENT authenticated user (agent) to grant themselves access to a target.
    func grantAccessForCurrentUser(targetId: String) async {
        do {
            let session = try await client.auth.session
            let userId = session.user.id
            let payload = InsertAccessPayload(
                target_id: targetId,
                user_id: userId.uuidString
            )
            _ = try await client
                .from("comment_access")
                .insert(payload)
                .execute()
        } catch {
            print("Supabase grantAccessForCurrentUser error:", error)
        }
    }

    // MARK: - Client grants agent (requires permissive RLS or server-side function)
    func grantAccessForAgent(targetId: String, agentUserId: UUID) async {
        do {
            let payload = InsertAccessPayload(
                target_id: targetId,
                user_id: agentUserId.uuidString
            )
            _ = try await client
                .from("comment_access")
                .insert(payload)
                .execute()
        } catch {
            print("Supabase grantAccessForAgent error:", error)
        }
    }

    // MARK: - Revoke access
    func revokeAccessForCurrentUser(targetId: String) async {
        do {
            let session = try await client.auth.session
            let userId = session.user.id
            _ = try await client
                .from("comment_access")
                .delete()
                .eq("target_id", value: targetId)
                .eq("user_id", value: userId.uuidString)
                .execute()
        } catch {
            print("Supabase revokeAccessForCurrentUser error:", error)
        }
    }

    func revokeAccessForAgent(targetId: String, agentUserId: UUID) async {
        do {
            _ = try await client
                .from("comment_access")
                .delete()
                .eq("target_id", value: targetId)
                .eq("user_id", value: agentUserId.uuidString)
                .execute()
        } catch {
            print("Supabase revokeAccessForAgent error:", error)
        }
    }

    // MARK: - Queries
    func listAgentsForTarget(targetId: String) async -> [UUID] {
        do {
            let response: PostgrestResponse<[AccessRow]> = try await client
                .from("comment_access")
                .select()
                .eq("target_id", value: targetId)
                .execute()
            let rows = response.value
            return rows.map { $0.user_id }
        } catch {
            print("Supabase listAgentsForTarget error:", error)
            return []
        }
    }

    func listTargetsForCurrentUser() async -> [String] {
        do {
            let session = try await client.auth.session
            let userId = session.user.id
            let response: PostgrestResponse<[AccessRow]> = try await client
                .from("comment_access")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
            let rows = response.value
            return rows.map { $0.target_id }
        } catch {
            print("Supabase listTargetsForCurrentUser error:", error)
            return []
        }
    }
}

