import Supabase
import SwiftUI

@MainActor
final class AdminLoginViewModel: ObservableObject {
    // form state
    @Published var email: String = ""
    @Published var password: String = ""

    // ui state
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isLoggedIn: Bool = false

    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    func signIn() async {
        guard !isLoading else { return }
        error = nil
        isLoading = true
        defer { isLoading = false }

        do {
            // SDK in your project supports this signature
            let auth = try await supabase.auth.signIn(email: email, password: password)
            let userId = auth.user.id

            // Admin check WITHOUT RPC — query admins table
            struct AdminRow: Decodable { let user_id: UUID }

            let rows: [AdminRow] = try await supabase
                .from("admins")
                .select("user_id")
                .eq("user_id", value: userId)
                .limit(1)
                .execute()
                .value // property, not a function

            let isAdmin = !rows.isEmpty

            if isAdmin {
                isLoggedIn = true
            } else {
                try? await supabase.auth.signOut()
                error = "Unauthorized: Admin access required."
            }
        } catch {
            self.error = "Login failed: \(error.localizedDescription)"
        }
    }
}
