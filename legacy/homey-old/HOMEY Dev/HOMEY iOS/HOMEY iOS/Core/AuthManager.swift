//
//  AuthManager.swift
//  HOMIE
//

import Foundation
import Combine
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    // MARK: - Supabase Client (single source of truth)
    // TODO: move keys to secure storage for prod.
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://fafbjfajmmsjftiivhil.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhZmJqZmFqbW1zamZ0aWl2aGlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxODg4MjEsImV4cCI6MjA2Nzc2NDgyMX0.S9P5wgPZGBop-0E55VMD1mhfIe2PnJfq28nt8UMLjCM"
    )

    private init() {}

    // MARK: - Auth
    func signUp(email: String, password: String, referralCode: String?) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
        if let code = referralCode?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty {
            _ = try await client.database
                .rpc("claim_referral_code", params: ["p_code": code] as [String: String])
                .execute()
        }
    }

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async { try? await client.auth.signOut() }

    var currentSession: Session? {
        get async { try? await client.auth.session }
    }

    func claimReferralCode(_ code: String) async throws {
        let c = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !c.isEmpty else { return }
        _ = try await client.database
            .rpc("claim_referral_code", params: ["p_code": c] as [String: String])
            .execute()
    }
}
