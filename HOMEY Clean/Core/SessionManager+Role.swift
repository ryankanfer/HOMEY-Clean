import Foundation

extension AppSessionManager {
    /// Switch the active role locally, and optionally persist if needed.
    @MainActor
    func setActiveRole(_ role: String) {
        // If you keep roles in public.profiles, you can persist here later.
        self.userRole = role
    }
}
