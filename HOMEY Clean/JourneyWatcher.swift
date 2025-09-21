import SwiftUI

@MainActor
struct JourneyWatcher: ViewModifier {
    @EnvironmentObject private var session: AppSessionManager
    @Environment(\.scenePhase) private var scenePhase
    @State private var backgroundTime: Date?

    func body(content: Content) -> some View {
        content
            .task {
                await session.restoreIfPossible()
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    handleAppBecameActive()
                case .background:
                    handleAppWentToBackground()
                case .inactive:
                    // App is transitioning, no action needed
                    break
                @unknown default:
                    break
                }
            }
    }
    
    private func handleAppBecameActive() {
        Task {
            // Always try to restore session when app becomes active
            await session.restoreIfPossible()
            
            // If app was in background for more than 5 minutes, refresh session
            if let backgroundTime = backgroundTime {
                let timeInBackground = Date().timeIntervalSince(backgroundTime)
                if timeInBackground > 300 { // 5 minutes
                    print("[JourneyWatcher] App was in background for \(timeInBackground) seconds, refreshing session")
                    await session.restoreIfPossible()
                }
            }
            
            backgroundTime = nil
        }
    }
    
    private func handleAppWentToBackground() {
        backgroundTime = Date()
        print("[JourneyWatcher] App went to background at \(backgroundTime!)")
    }
}

extension View {
    func journeyWatched() -> some View {
        modifier(JourneyWatcher())
    }
}
