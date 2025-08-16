//
//  AuthManager.swift
//  HOMEY Clean
//
//  Start with a protocol + fake implementation so we can swap in Supabase later.
//

import Foundation

public struct AuthUser: Sendable, Equatable {
    public let id: UUID
    public let email: String
    public init(id: UUID, email: String) {
        self.id = id
        self.email = email
    }
}

public protocol AuthProviding: Sendable {
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(fullName: String, email: String, password: String, referralCode: String?) async throws -> AuthUser
    func signOut() async throws
    func currentUser() async -> AuthUser?
}

public enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case notImplemented
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password."
        case .notImplemented: return "Not implemented yet."
        case .unknown: return "Something went wrong."
        }
    }
}

// MARK: - FakeAuthManager for steps 8–12
public actor FakeAuthManager: AuthProviding {
    private var user: AuthUser?

    public init() {}

    public func signIn(email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2s for vibes
        guard email.contains("@"), password.count >= 4 else { throw AuthError.invalidCredentials }
        let u = AuthUser(id: UUID(), email: email.lowercased())
        self.user = u
        return u
    }

    public func signUp(fullName: String, email: String, password: String, referralCode: String?) async throws -> AuthUser {
        try await signIn(email: email, password: password)
    }

    public func signOut() async throws {
        self.user = nil
    }

    public func currentUser() async -> AuthUser? {
        self.user
    }
}

// MARK: - Placeholder for Supabase (step 13+)
// Implement a RealSupabaseAuthManager conforming to AuthProviding in step 13.
