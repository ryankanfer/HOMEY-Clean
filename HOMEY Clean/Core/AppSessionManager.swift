import Foundation
import Combine
#if canImport(Supabase)
import Supabase
#endif

@MainActor
final class AppSessionManager: ObservableObject {

    // MARK: - Public state you can bind UI to
    @Published var userRole: String = "client"         // "client" | "agent" | "admin"
    @Published var clientSegment: String? = nil        // "renter"|"buyer"|"seller"|"landlord" (for clients)
    @Published var isAuthenticated: Bool = false

    // MARK: - Internals
    #if canImport(Supabase)
    let client: SupabaseClient
    #endif
    let profiles: ProfilesProviding

    // MARK: - Error mapping just for sign-in UI
    enum SignInError: LocalizedError {
        case invalidCredentials
        case emailNotConfirmed
        case network
        case unknown(String)

        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Incorrect email or password."
            case .emailNotConfirmed:
                return "Please confirm your email to sign in."
            case .network:
                return "Can’t reach the server. Try again."
            case .unknown(let m):
                return m
            }
        }
    }

    // MARK: - Init
    #if canImport(Supabase)
    init(client: SupabaseClient,
         profiles: ProfilesProviding? = nil) {
        // Use the provided client for both auth and profile lookups unless
        // a different `ProfilesProviding` is explicitly supplied.
        self.client = client
        self.profiles = profiles ?? RealSupabaseProfilesService(client: client)
    }
    
    /// Convenience initializer for previews or tests where a real
    /// `SupabaseClient` isn’t necessary. Supplies a dummy client and
    /// a fake profile service.
    convenience init() {
        let url = URL(string: "https://example.com")!
        let client = SupabaseClient(supabaseURL: url, supabaseKey: "demo-key")
        self.init(client: client, profiles: FakeProfilesService())
    }
    #else
    init(profiles: ProfilesProviding = FakeProfilesService()) {
        self.profiles = profiles
    }
    #endif
}

// MARK: - Public API
extension AppSessionManager {
    /// Sign in with friendly errors
    func signIn(email: String, password: String) async throws {
        #if canImport(Supabase)
        do {
            // NOTE: you previously had this working, keeping the same call shape.
            _ = try await client.auth.signIn(email: email, password: password)

            isAuthenticated = client.auth.currentSession != nil
            if let session = client.auth.currentSession {
                await hydrateFrom(session)
            } else {
                isAuthenticated = false
            }
        } catch {
            let msg = (error as NSError).localizedDescription.lowercased()
            if msg.contains("invalid login") || msg.contains("invalid credentials") {
                throw SignInError.invalidCredentials
            } else if msg.contains("not confirmed") || msg.contains("confirm") {
                throw SignInError.emailNotConfirmed
            } else if msg.contains("network") || msg.contains("timed out") {
                throw SignInError.network
            } else {
                throw SignInError.unknown((error as NSError).localizedDescription)
            }
        }
        #else
        isAuthenticated = true
        #endif
    }

    /// Resend email confirmation
    func resendConfirmation(email: String) async throws {
        #if canImport(Supabase)
        try await client.auth.resend(email: email, type: .signup, emailRedirectTo: nil)
        #endif
    }

    /// Start password reset flow (sends email with link to your `reset.html`)
    func resetPassword(email: String, redirectTo: URL) async throws {
        #if canImport(Supabase)
        try await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo)
        #endif
    }

    /// Try to restore or refresh a session on launch/foreground
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

    /// Public wrapper to "refresh" the auth/session state on demand.
    /// Internally maps to `restoreIfPossible()` so the UI can call a simple name.
    func refreshSession() async {
        await restoreIfPossible()
    }

    /// Sign out fully and clear local state
    func signOut() async {
        #if canImport(Supabase)
        _ = try? await client.auth.signOut()
        #endif
        await signOutLocalOnly()
    }
}

// MARK: - Private helpers
extension AppSessionManager {
    private func hydrateFrom(_ session: Session) async {
        // role + client segment from DB
        let uid = session.user.id
        if let info = try? await profiles.fetchProfile(for: uid) {
            self.userRole = info.role
            self.clientSegment = info.clientSegment
        } else {
            // default on failure; you can retry in background
            self.userRole = "client"
            self.clientSegment = nil
        }
    }

    private func signOutLocalOnly() async {
        self.isAuthenticated = false
        self.userRole = "client"
        self.clientSegment = nil
    }
}
