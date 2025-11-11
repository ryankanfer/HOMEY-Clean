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
//  - Optionally shows a welcome view until dismissed (persisted with a key)
//  - Then reveals the provided `content`.
public struct LaunchGate<Content: View, Welcome: View>: View {
    private let content: Content
    private let welcome: Welcome?
    private let minDisplay: TimeInterval
    private let showSplashPerProcess: Bool
    private let welcomeKey: String?
    private let forceShowWelcome: Bool
    private let awaitUserUnlock: Bool

    @State private var showingSplash = true
    @State private var showingWelcome = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        minDisplay: TimeInterval = 2.0,
        showSplashPerProcess: Bool = true,
        welcomeKey: String? = nil,
        forceShowWelcome: Bool = false,
        awaitUserUnlock: Bool = false,
        @ViewBuilder welcome: () -> Welcome,
        @ViewBuilder content: () -> Content
    ) {
        self.minDisplay = minDisplay
        self.showSplashPerProcess = showSplashPerProcess
        self.welcomeKey = welcomeKey
        self.forceShowWelcome = forceShowWelcome
        self.awaitUserUnlock = awaitUserUnlock
        self.welcome = welcome()
        self.content = content()
    }

    public init(
        minDisplay: TimeInterval = 2.0,
        showSplashPerProcess: Bool = true,
        forceShowWelcome: Bool = false,
        awaitUserUnlock: Bool = false,
        @ViewBuilder content: () -> Content
    ) where Welcome == EmptyView {
        self.minDisplay = minDisplay
        self.showSplashPerProcess = showSplashPerProcess
        welcomeKey = nil
        self.forceShowWelcome = forceShowWelcome
        self.awaitUserUnlock = awaitUserUnlock
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
                    SplashBackground(mode: currentSplashMode())
                        .ignoresSafeArea()
                    LaunchView(onFinished: {
                        Task { @MainActor in
                            withAnimation(self.reduceMotion ? .none : .easeOut(duration: 0.25)) {
                                self.showingSplash = false
                                self.evaluateWelcome()
                            }
                        }
                    })
                        .transition(.opacity)
                }
                .ignoresSafeArea()
                .zIndex(1)
            } else if showingWelcome, let welcomeKey, let welcome {
                welcome
                    .environment(\.dismissWelcome) {
                        Task { @MainActor in
                            UserDefaults.standard.set(true, forKey: welcomeKey)
                            withAnimation(self.reduceMotion ? .none : .easeOut(duration: 0.25)) {
                                self.showingWelcome = false
                            }
                        }
                    }
                    .transition(.opacity)
                    .ignoresSafeArea()
                    .zIndex(1)
            }
        }
        .task { await start() }
    }

    private func start() async {
        // This task should only run once to dismiss the splash.
        guard showingSplash else { return }

        // If awaiting user unlock, do not auto-dismiss; the LaunchView will call back.
        if awaitUserUnlock {
            return
        }

        let shouldShowSplash: Bool = {
            if !showSplashPerProcess { return true }
            if LaunchGateProcessState.splashShown { return false }
            return true
        }()

        if shouldShowSplash {
            LaunchGateProcessState.splashShown = true
            let delay = max(0, minDisplay)
            // Use modern async sleep, which is more reliable in SwiftUI tasks.
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            withAnimation(self.reduceMotion ? .none : .easeOut(duration: 0.25)) {
                self.showingSplash = false
                self.evaluateWelcome()
            }
        } else {
            // If splash isn't needed, immediately transition.
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

private enum SplashMode: String {
    case sunrise
    case day
    case sunset
    case night
}

private func currentSplashMode(date: Date = Date()) -> SplashMode {
    let hour = Calendar.current.component(.hour, from: date)
    switch hour {
    case 5..<8: return .sunrise
    case 8..<17: return .day
    case 17..<20: return .sunset
    default: return .night
    }
}

// Theme-aligned splash background
private struct SplashBackground: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let mode: SplashMode

    var body: some View {
        // Use the same hero gradient as Homey so splash matches the app instantly.
        LinearGradient(colors: [Theme.background, Theme.surface], startPoint: .top, endPoint: .bottom)
            .overlay(Color.clear.opacity(0.25))
            .overlay(
                // Subtle vignette tuned by mode to keep text readable on top of any time-of-day gradient.
                RadialGradient(
                    colors: vignetteColors(for: mode),
                    center: .center,
                    startRadius: 280,
                    endRadius: 900
                )
                .blendMode(.multiply)
            )
    }

    private func vignetteColors(for mode: SplashMode) -> [Color] {
        // Slightly stronger vignette at night/sunset; lighter during day/sunrise.
        switch mode {
        case .sunrise:
            return [Color.black.opacity(0.02), Color.black.opacity(0.18)]
        case .day:
            return [Color.black.opacity(0.02), Color.black.opacity(0.20)]
        case .sunset:
            return [Color.black.opacity(0.04), Color.black.opacity(0.24)]
        case .night:
            return [Color.black.opacity(0.06), Color.black.opacity(0.28)]
        }
    }
}

private struct SplashPhrasesView: View {
    @State private var showFirst = false
    @State private var showSecond = false

    var body: some View {
        ZStack { }
            .padding(.horizontal, 24)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.clear)
            .onAppear {
                showFirst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    Task { @MainActor in
                        showSecond = true
                    }
                }
            }
            .allowsHitTesting(false)
    }
}