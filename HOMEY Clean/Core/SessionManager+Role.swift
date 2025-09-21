import Foundation

extension AppSessionManager {
    #if DEBUG
    /// Switch the active role locally for debugging purposes only.
    /// This method is only available in DEBUG builds to prevent privilege escalation in Release.
    @MainActor
    func setActiveRole(_ role: String) {
        // Local role switching only allowed in DEBUG builds
        userRole = role
    }
    #endif
}
