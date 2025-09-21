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
                .tint(Theme.dynamicPrimary())
                .dynamicTypeSize(.medium...(.accessibility1))
                .themeAware()
                .task {
                    await session.restoreIfPossible()
                }
        }
    }
}