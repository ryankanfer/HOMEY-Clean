import SwiftUI

private struct DismissWelcomeActionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var dismissWelcome: () -> Void {
        get { self[DismissWelcomeActionKey.self] }
        set { self[DismissWelcomeActionKey.self] = newValue }
    }
}

// Per-process splash flag holder (must not live on a generic type).
private enum LaunchGateProcessState {
    static var splashShown = false
}

/// A unified gate that:
/// - Shows a splash (per cold process, not persisted)
/// - Optionally shows a welcome view until dismissed (persisted with a key)
/// - Then reveals the provided `content`.
public struct LaunchGate<Content: View, Welcome: View>: View {
    private let content: Content
    private let welcome: Welcome?
    private let minDisplay: TimeInterval
    private let showSplashPerProcess: Bool
    private let welcomeKey: String?
    private let forceShowWelcome: Bool

    @State private var showingSplash = true
    @State private var showingWelcome = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        minDisplay: TimeInterval = 2.0,
        showSplashPerProcess: Bool = true,
        welcomeKey: String? = nil,
        forceShowWelcome: Bool = false,
        @ViewBuilder welcome: () -> Welcome,
        @ViewBuilder content: () -> Content
    ) {
        self.minDisplay = minDisplay
        self.showSplashPerProcess = showSplashPerProcess
        self.welcomeKey = welcomeKey
        self.forceShowWelcome = forceShowWelcome
        self.welcome = welcome()
        self.content = content()
    }

    public init(
        minDisplay: TimeInterval = 2.0,
        showSplashPerProcess: Bool = true,
        forceShowWelcome: Bool = false,
        @ViewBuilder content: () -> Content
    ) where Welcome == EmptyView {
        self.minDisplay = minDisplay
        self.showSplashPerProcess = showSplashPerProcess
        welcomeKey = nil
        self.forceShowWelcome = forceShowWelcome
        welcome = nil
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
                .opacity((showingSplash || showingWelcome) ? 0 : 1)
                .accessibilityHidden(showingSplash || showingWelcome)

            if showingSplash {
                ZStack {
                    LaunchView()
                        .ignoresSafeArea()
                    SplashPhrasesView()
                        .ignoresSafeArea()
                }
                .transition(.opacity)
                .allowsHitTesting(true)
                .ignoresSafeArea()
                .zIndex(1)
            } else if showingWelcome, let welcomeKey, let welcome {
                welcome
                    .environment(\.dismissWelcome) {
                        UserDefaults.standard.set(true, forKey: welcomeKey)
                        withAnimation(self.reduceMotion ? .none : .easeOut(duration: 0.25)) {
                            self.showingWelcome = false
                        }
                    }
                    .transition(.opacity)
                    .allowsHitTesting(true)
                    .ignoresSafeArea()
                    .zIndex(1)
            }
        }
        .onAppear(perform: start)
    }

    private func start() {
        let shouldShowSplash: Bool = {
            if !showSplashPerProcess { return true }
            if LaunchGateProcessState.splashShown { return false }
            return true
        }()

        if shouldShowSplash {
            LaunchGateProcessState.splashShown = true
            let delay = max(0, minDisplay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(self.reduceMotion ? .none : .easeOut(duration: 0.25)) {
                    self.showingSplash = false
                    self.evaluateWelcome()
                }
            }
        } else {
            showingSplash = false
            evaluateWelcome()
        }
    }

    private func evaluateWelcome() {
        guard let key = welcomeKey else {
            // If no key is provided, only show when explicitly forced and a welcome exists.
            showingWelcome = forceShowWelcome && (welcome != nil)
            return
        }
        let hasSeen = UserDefaults.standard.bool(forKey: key)
        showingWelcome = forceShowWelcome || !hasSeen
    }
}

private struct SplashPhrasesView: View {
    @State private var showFirst = false
    @State private var showSecond = false

    var body: some View {
        VStack(spacing: 6) {
            Text("in your pocket.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .opacity(showFirst ? 1 : 0)
                .animation(.easeInOut(duration: 1.2), value: showFirst)

            Text("on your side.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.95))
                .opacity(showSecond ? 1 : 0)
                .animation(.easeInOut(duration: 1.2), value: showSecond)
        }
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.clear)
        .onAppear {
            showFirst = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSecond = true
            }
        }
        .allowsHitTesting(false)
    }
}
