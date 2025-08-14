import Foundation
import Combine

@MainActor
final class SessionManager: ObservableObject {
    // Dependencies
    private let auth: AuthProviding
    private let profiles: ProfilesProviding

    // State
    @Published var isLoggedIn: Bool = false
    @Published var email: String? = nil
    @Published var userId: UUID? = nil
    @Published var userRole: String? = "client"          // "admin" | "agent" | "client"
    @Published var clientSegment: String? = nil          // renter|buyer|seller|landlord when role == client

    // Derived
    var effectiveRole: String { (userRole ?? "client").lowercased() }

    init(auth: AuthProviding, profiles: ProfilesProviding) {
        self.auth = auth
        self.profiles = profiles
    }

    // Boot
    func restore() async {
        if let user = await auth.currentUser() {
            self.isLoggedIn = true
            self.email = user.email
            self.userId = user.id
            await refreshProfile()
        } else {
            reset()
        }
    }

    // Actions
    func signIn(email: String, password: String) async throws {
        let user = try await auth.signIn(email: email, password: password)
        self.isLoggedIn = true
        self.email = user.email
        self.userId = user.id
        await refreshProfile()
    }

    func signUp(fullName: String, email: String, password: String, referralCode: String?) async throws {
        let user = try await auth.signUp(fullName: fullName, email: email, password: password, referralCode: referralCode)
        self.isLoggedIn = true
        self.email = user.email
        self.userId = user.id
        await refreshProfile()
    }

    func signOut() async {
        try? await auth.signOut()
        reset()
    }

    // MARK: - Helpers
    private func refreshProfile() async {
        guard let uid = userId else { return }
        do {
            let info = try await profiles.fetchProfile(for: uid)
            self.userRole = info.role
            self.clientSegment = info.clientSegment
        } catch {
            // Default safely. UI can still function.
            self.userRole = "client"
            self.clientSegment = nil
            #if DEBUG
            print("[SessionManager] Failed to fetch profile:", error.localizedDescription)
            #endif
        }
    }

    private func reset() {
        self.isLoggedIn = false
        self.email = nil
        self.userId = nil
        self.userRole = "client"
        self.clientSegment = nil
    }
}
