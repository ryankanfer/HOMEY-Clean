//
//  AppSessionManager.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI
#if canImport(Supabase)
    import Supabase
#endif

@MainActor
final class AppSessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userRole: String = "client"
    @Published var clientSegment: String?

    #if canImport(Supabase)
        private let client: SupabaseClient
        /// Read-only accessor for the Supabase client (keeps the stored property private).
        var supabaseClient: SupabaseClient { client }
    #endif
    private let profiles: ProfilesProviding

    #if canImport(Supabase)
        init(client: SupabaseClient, profiles: ProfilesProviding? = nil) {
            self.client = client
            self.profiles = profiles ?? RealSupabaseProfilesService(client: client)
        }
    #else
        init(profiles: ProfilesProviding = FakeProfilesService()) {
            self.profiles = profiles
        }
    #endif
}

extension AppSessionManager {
    enum SignInError: LocalizedError {
        case invalidCredentials, emailNotConfirmed, network, unknown(String)
        var errorDescription: String? {
            switch self {
            case .invalidCredentials: return "Email or password is incorrect."
            case .emailNotConfirmed: return "Please confirm your email before signing in."
            case .network: return "Network issue. Try again."
            case let .unknown(m): return m
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        #if canImport(Supabase)
            do {
                _ = try await client.auth.signIn(email: email, password: password)
                isAuthenticated = client.auth.currentSession != nil
                if let session = client.auth.currentSession { await hydrateFrom(session) }
            } catch {
                let msg = (error as NSError).localizedDescription.lowercased()
                if msg.contains("invalid") || msg.contains("credential") { throw SignInError.invalidCredentials }
                if msg.contains("confirm") { throw SignInError.emailNotConfirmed }
                if msg.contains("network") || msg.contains("timed out") { throw SignInError.network }
                throw SignInError.unknown((error as NSError).localizedDescription)
            }
        #else
            isAuthenticated = true
        #endif
    }

    func resendConfirmation(email: String) async throws {
        #if canImport(Supabase)
            try await client.auth.resend(email: email, type: .signup)
        #endif
    }

    func resetPassword(email: String, redirectTo: URL) async throws {
        #if canImport(Supabase)
            try await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo)
        #endif
    }

    func restoreIfPossible() async {
        #if canImport(Supabase)
            if let existing = client.auth.currentSession {
                isAuthenticated = true
                await hydrateFrom(existing)
                return
            }
            do {
                _ = try await client.auth.refreshSession()
                if let session = client.auth.currentSession {
                    isAuthenticated = true
                    await hydrateFrom(session)
                } else {
                    await signOutLocalOnly()
                }
            } catch {
                await signOutLocalOnly()
            }
        #endif
    }

    func signOut() async {
        #if canImport(Supabase)
            _ = try? await client.auth.signOut()
        #endif
        await signOutLocalOnly()
    }
}

extension AppSessionManager {
    #if canImport(Supabase)
        private func hydrateFrom(_ session: Session) async {
            let uid: UUID = session.user.id
            if let info = try? await profiles.fetchProfile(for: uid) {
                userRole = info.role
                clientSegment = info.clientSegment
            } else {
                userRole = "client"
                clientSegment = nil
            }
        }
    #endif

    private func signOutLocalOnly() async {
        isAuthenticated = false
        userRole = "client"
        clientSegment = nil
    }
}
