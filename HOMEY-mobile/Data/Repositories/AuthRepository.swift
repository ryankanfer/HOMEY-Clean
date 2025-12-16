//
//  AuthRepository.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 1/25/25.
//

import Foundation
import Supabase

// MARK: - Auth Repository
class AuthRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    @MainActor
    convenience init() {
        self.init(client: AppSessionManager.shared.supabaseClient)
    }

    // MARK: - Authentication Methods
    
    func signIn(email: String, password: String) async throws -> AuthUser {
        let response = try await client.auth.signIn(email: email, password: password)
        let user = try await client.auth.user()
        return AuthUser(id: user.id, email: user.email ?? email)
    }
    
    func signUp(fullName: String, email: String, password: String, referralCode: String? = nil) async throws -> AuthUser {
        var metadata: [String: AnyJSON] = ["full_name": .string(fullName)]
        if let ref = referralCode, !ref.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata["referral_code"] = .string(ref)
        }
        
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: metadata
        )
        let user = try await client.auth.user()
        return AuthUser(id: user.id, email: user.email ?? email)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() async throws -> AuthUser? {
        do {
            let user = try await client.auth.user()
            return AuthUser(id: user.id, email: user.email ?? "")
        } catch {
            return nil
        }
    }
    
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    func updatePassword(newPassword: String) async throws {
        try await client.auth.update(user: UserAttributes(password: newPassword))
    }
    
    func refreshSession() async throws {
        try await client.auth.refreshSession()
    }
    
    // MARK: - Session Management
    
    func getSession() async throws -> Session? {
        return try await client.auth.session
    }
    
    func isAuthenticated() async -> Bool {
        do {
            _ = try await client.auth.user()
            return true
        } catch {
            return false
        }
    }
}