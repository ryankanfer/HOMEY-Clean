//
//  SupabaseAuthManager.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/13/25.
//

import Foundation
#if canImport(Supabase)
    import Supabase
#endif

public enum RealAuthConfigError: Error, LocalizedError {
    case missingURL
    case invalidURL
    case missingKey

    public var errorDescription: String? {
        switch self {
        case .missingURL: return "Missing SUPABASE_URL in Info.plist."
        case .invalidURL: return "SUPABASE_URL is not a valid URL."
        case .missingKey: return "Missing SUPABASE_ANON_KEY in Info.plist."
        }
    }
}

/// Production Auth manager backed by Supabase.
/// Reads SUPABASE_URL and SUPABASE_ANON_KEY from Info.plist.
/// Conforms to AuthProviding.
public final class RealSupabaseAuthManager: AuthProviding {
    #if canImport(Supabase)
        public let client: SupabaseClient
    #endif

    public init() throws {
        let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        guard let rawURL = urlString, !rawURL.isEmpty else { throw RealAuthConfigError.missingURL }
        // Remove trailing slash if present
        let cleanURLString = rawURL.hasSuffix("/") ? String(rawURL.dropLast()) : rawURL
        guard let url = URL(string: cleanURLString) else { throw RealAuthConfigError.invalidURL }

        let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        guard let anonKey = key, !anonKey.isEmpty else { throw RealAuthConfigError.missingKey }

        #if canImport(Supabase)
            let storage = KeychainLocalStorage()
            let options = SupabaseClientOptions(
                auth: .init(
                    storage: storage,
                    autoRefreshToken: true
                )
            )
            client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey, options: options)
        #endif
    }

    public func signIn(email: String, password: String) async throws -> AuthUser {
        #if canImport(Supabase)
            _ = try await client.auth.signIn(email: email, password: password)
            let user = try await client.auth.user()
            return AuthUser(id: user.id, email: user.email ?? email)
        #else
            throw AuthError.notImplemented
        #endif
    }

    public func signUp(
        fullName: String,
        email: String,
        password: String,
        referralCode: String?
    ) async throws -> AuthUser {
        #if canImport(Supabase)
            var metadata: [String: AnyJSON] = ["full_name": .string(fullName)]
            if let ref = referralCode, !ref.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                metadata["referral_code"] = .string(ref)
            }
            _ = try await client.auth.signUp(
                email: email,
                password: password,
                data: metadata
            )
            let user = try await client.auth.user()
            return AuthUser(id: user.id, email: user.email ?? email)
        #else
            throw AuthError.notImplemented
        #endif
    }

    public func signOut() async throws {
        #if canImport(Supabase)
            try await client.auth.signOut()
        #endif
    }

    public func currentUser() async -> AuthUser? {
        #if canImport(Supabase)
            if let session = client.auth.currentSession {
                let u = session.user
                return AuthUser(id: u.id, email: u.email ?? "")
            }
            do {
                let u = try await client.auth.user()
                return AuthUser(id: u.id, email: u.email ?? "")
            } catch {
                return nil
            }
        #else
            return nil
        #endif
    }
}