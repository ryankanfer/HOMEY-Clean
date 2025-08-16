import SwiftUI

/// Wrap ANY existing root view so the launch plays once per cold start,
/// then gets out of the way forever until next relaunch.
public struct LaunchGate<Content: View>: View {
    private let content: Content
    private let minDisplay: TimeInterval
    @State private var showLaunch = true
    @State private var appearedAt = Date()
    @AppStorage("HOMEY_DidShowLaunchOnce") private var didShowLaunchOnce: Bool = false

    public init(minDisplay: TimeInterval = 1.4, @ViewBuilder content: () -> Content) {
        self.minDisplay = minDisplay
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
                .opacity(showLaunch ? 0 : 1)

            if showLaunch && !didShowLaunchOnce {
                LaunchView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            appearedAt = Date()
            if didShowLaunchOnce {
                // We already showed it this app run; skip immediately.
                showLaunch = false
            } else {
                // Ensure a minimum display time for the splash, then retire it.
                let delay = max(0, minDisplay)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showLaunch = false
                        didShowLaunchOnce = true
                    }
                }
            }
        }
    }
}