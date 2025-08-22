import SwiftUI

@MainActor
struct JourneyWatcher: ViewModifier {
    @EnvironmentObject private var session: AppSessionManager
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .task {
                await session.restoreIfPossible()
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    Task { await session.restoreIfPossible() }
                }
            }
    }
}

extension View {
    func journeyWatched() -> some View {
        modifier(JourneyWatcher())
    }
}
