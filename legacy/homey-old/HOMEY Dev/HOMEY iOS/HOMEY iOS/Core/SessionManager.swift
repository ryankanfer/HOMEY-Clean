//
//  SessionManager.swift
//  HOMEY
//

import SwiftUI
import Combine
import Supabase

@MainActor
final class SessionManager: ObservableObject {

    // MARK: - Dependencies
    private let auth: AuthManager
    /// Single source of truth for Supabase client
    var client: SupabaseClient { auth.client }

    // MARK: - Published State
    @Published var isLoggedIn: Bool = false
    @Published var userRole: String? = nil        // "admin" | "agent" | "client"
    @Published var activeRole: String? = nil      // local override for admins
    @Published var email: String? = nil
    @Published var userId: UUID? = nil

    // MARK: - Derived
    var effectiveRole: String { (activeRole ?? userRole ?? "client").lowercased() }
    var isAdmin: Bool { effectiveRole == "admin" }

    // MARK: - Init
    init(auth: AuthManager = .shared) {
        self.auth = auth
    }

    // MARK: - Role setters
    func setRole(_ role: String?) {
        userRole = role
        if activeRole == nil { objectWillChange.send() }
    }
    func setActiveRole(_ role: String?) { activeRole = role }
    func clearActiveRole() { activeRole = nil }

    // MARK: - Auth passthroughs (adapt to your AuthManager API)
    func signIn(email: String, password: String) async throws {
        let user = try await auth.signIn(email: email, password: password)
        self.email = user.email
        self.userId = user.id
        self.isLoggedIn = true
        self.userRole = user.role
    }

    func signOut() async {
        do { try await auth.signOut() } catch {}
        self.isLoggedIn = false
        self.email = nil
        self.userId = nil
        self.activeRole = nil
    }
}
