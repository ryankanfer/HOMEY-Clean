import Foundation
import Supabase

// Repository for creating and tracking client→agent invitation links
// Backed by the `client_agent_links` table and the RPC `accept_client_invite` (server-side).
// This helper only covers the client-side creation and polling for acceptance.

struct ClientAgentLink: Codable, Identifiable {
    let id: UUID
    let code: String
    let client_user_id: UUID
    let agent_user_id: UUID?
    let status: String
    let created_at: Date
    let expires_at: Date
}

final class ClientAgentLinkRepository {
    static let shared = ClientAgentLinkRepository()
    private init() {}

    private var client: SupabaseClient { SupabaseClientProvider.client }

    // MARK: - Create invite
    func createInvite(codeLength: Int = 8) async throws -> ClientAgentLink {
        let user = try await client.auth.user()
        let code = Self.makeCode(length: codeLength)

        struct InsertPayload: Encodable {
            let code: String
            let client_user_id: String
        }

        let response: PostgrestResponse<ClientAgentLink> = try await client
            .from("client_agent_links")
            .insert(InsertPayload(code: code, client_user_id: user.id.uuidString))
            .select("*")
            .single()
            .execute()

        return response.value
    }

    // MARK: - Fetch by code
    func fetch(code: String) async throws -> ClientAgentLink? {
        let response: PostgrestResponse<[ClientAgentLink]> = try await client
            .from("client_agent_links")
            .select("*")
            .eq("code", value: code)
            .limit(1)
            .execute()
        return response.value.first
    }

    // MARK: - Wait/poll for acceptance
    // Polls until status == "accepted" or timeout.
    func waitForAcceptance(code: String, timeout: TimeInterval = 300, interval: TimeInterval = 2) async throws -> ClientAgentLink? {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            if let link = try await fetch(code: code), link.status.lowercased() == "accepted" {
                return link
            }
            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        return nil
    }

    // MARK: - Share URL for QR / deep link
    func shareURL(for code: String) -> URL {
        // Replace with your deployed universal link domain if different
        return URL(string: "https://homey.app/invite/\(code)")!
    }

    // MARK: - Helpers
    private static func makeCode(length: Int) -> String {
        // URL/QR friendly: lowercase letters + digits (no ambiguous chars)
        let alphabet = Array("abcdefghjkmnpqrstuvwxyz23456789")
        var rng = SystemRandomNumberGenerator()
        return String((0..<length).map { _ in alphabet.randomElement(using: &rng)! })
    }
}
