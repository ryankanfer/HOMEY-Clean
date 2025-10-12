import SwiftUI

@main
struct HOMEYCleanApp: App {
    @StateObject private var session = AppSessionManager.shared
    @StateObject private var flags = FeatureFlags.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var userProfileManager = UserProfileManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(flags)
                .environmentObject(themeManager)
                .environmentObject(userProfileManager)
                .tint(Theme.primaryAction)
                .dynamicTypeSize(.medium...(.accessibility1))
                .task {
                    // Add a timeout to prevent hanging during session restoration
                    let timeoutTask = Task {
                        try await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds
                        print("[App] Session restoration timeout - proceeding anyway")
                    }
                    
                    await session.restoreIfPossible()
                    
                    // Cancel the timeout since session restoration completed
                    timeoutTask.cancel()
                }
        }
    }
}