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
                    SplashBackground(mode: currentSplashMode())
                        .ignoresSafeArea()
                    LaunchView()
                        .transition(.opacity)
                        .allowsHitTesting(true)
                }
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

private struct SplashBackground: View {
    let mode: SplashMode

    var body: some View {
        LinearGradient(colors: colors(for: mode), startPoint: .top, endPoint: .bottom)
            .overlay(
                RadialGradient(colors: vignette(for: mode), center: .center, startRadius: 280, endRadius: 900)
                    .blendMode(.multiply)
            )
    }

    private func colors(for mode: SplashMode) -> [Color] {
        switch mode {
        case .sunrise:
            return [
                Color(red: 0.99, green: 0.67, blue: 0.47), // warm peach
                Color(red: 0.99, green: 0.80, blue: 0.62), // soft apricot
                Color(red: 0.88, green: 0.93, blue: 0.97)  // misty bottom
            ]
        case .day:
            return [
                Color(red: 0.16, green: 0.42, blue: 0.66),
                Color(red: 0.34, green: 0.71, blue: 0.86),
                Color(red: 0.88, green: 0.93, blue: 0.97)
            ]
        case .sunset:
            return [
                Color(red: 0.84, green: 0.38, blue: 0.52), // rose
                Color(red: 0.98, green: 0.66, blue: 0.35), // tangerine
                Color(red: 0.98, green: 0.84, blue: 0.64)  // golden haze
            ]
        case .night:
            return [
                Color(red: 0.04, green: 0.10, blue: 0.18), // deep navy
                Color(red: 0.06, green: 0.14, blue: 0.24), // midnight
                Color(red: 0.10, green: 0.18, blue: 0.28)  // steel blue
            ]
        }
    }

    private func vignette(for mode: SplashMode) -> [Color] {
        switch mode {
        case .sunrise:
            return [Color.black.opacity(0.0), Color.black.opacity(0.18)]
        case .day:
            return [Color.black.opacity(0.0), Color.black.opacity(0.22)]
        case .sunset:
            return [Color.black.opacity(0.0), Color.black.opacity(0.20)]
        case .night:
            return [Color.black.opacity(0.05), Color.black.opacity(0.28)]
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
                    showSecond = true
                }
            }
            .allowsHitTesting(false)
    }
}
