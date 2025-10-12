import SwiftUI
import Combine

struct CinematicHomeyLandingView: View {
    @Binding var selectedTab: Int
    @Binding var showLeftDrawer: Bool
    @Binding var showRightDrawer: Bool

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // UI State
    @State private var animateIn = false
    @State private var searchQuery: String = ""
    @State private var showGhostTab = false
    @FocusState private var isSearchFocused: Bool

    private var actionItems: [ActionItem] {
        AppPage.allCases
            .filter { $0.isMajorTab && $0 != .homey }
            .map { page in
                ActionItem(
                    title: page.displayName.uppercased(),
                    action: { routeTo(page) }
                )
            }
    }

    var body: some View {
        ZStack {
            LightParticleBackground()
                .ignoresSafeArea()
            
            SilhouetteBand()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .opacity(0.8)
                .ignoresSafeArea()

            // Main Content VStack
            VStack(spacing: 0) {
                topBar
                    .padding(.top, 8)
                    .opacity(animateIn ? 1 : 0)

                if showGhostTab {
                    GhostMenuBar(items: actionItems)
                        .transition(.opacity.combined(with: .offset(y: -10)))
                }
                
                Spacer()

                header
                    .scaleEffect(showGhostTab ? 0.9 : 1.0)
                    .opacity(showGhostTab ? 0.8 : 1.0)
                    .padding(.bottom, 20)
                
                LiquidGlassSearchBar(
                    placeholder: "Search for anything...",
                    text: $searchQuery,
                    isFocused: $isSearchFocused,
                    onSubmit: { handleHomeQuery($0) }
                )
                .padding(.horizontal)
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showGhostTab)
        }
        .onAppear {
            if reduceMotion {
                animateIn = true
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    animateIn = true
                }
            }
        }
        .onChange(of: isSearchFocused) { _, isFocused in
            showGhostTab = isFocused
        }
    }

    private var header: some View {
        Text("H O M E Y")
            .font(.system(size: 48, weight: .thin))
            .kerning(10)
            .foregroundStyle(Color.gray.opacity(0.8))
            .minimumScaleFactor(0.8)
            .animation(.spring(response: 0.5, dampingFraction: 0.9).delay(0.1), value: animateIn)
    }

    private var topBar: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                    showLeftDrawer = true
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            }
            .buttonStyle(.plain)

            Spacer()
            
            ZStack(alignment: .topTrailing) {
                Button {
                    // Navigate directly to the full profile view
                    router.route = .profile
                } label: {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .background(.regularMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
                
                Text("65")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .offset(x: 4, y: -4)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.9).delay(0.2), value: animateIn)
    }

    private func handleHomeQuery(_ raw: String) {
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { router.route = .search; return }
        router.route = .search
    }
    
    private func routeTo(_ page: AppPage) {
        if let route = page.route {
            router.route = route
        }
    }
}

// MARK: - UI Components

private struct GhostMenuBar: View {
    let items: [ActionItem]
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(items) { item in
                Button(action: item.action) {
                    Text(item.title)
                        .font(.system(size: 10, weight: .medium))
                        .kerning(1.2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundColor(.black.opacity(0.7))
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

private struct LiquidGlassSearchBar: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSubmit: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray.opacity(0.9))
                .padding(.leading, 20)

            TextField(placeholder, text: $text)
                .submitLabel(.search)
                .onSubmit { onSubmit(text) }
                .focused(isFocused)
                .font(.system(size: 18, weight: .light))
                .kerning(1.1)
                .foregroundStyle(Color.black.opacity(0.8))
                .tint(Theme.primaryAction)
                .padding(.vertical, 20)
                .padding(.leading, 8)
                .padding(.trailing, 20)
        }
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
    }
}

private struct SilhouetteBand: View {
    private let assetName = "silhouette_group"
    var height: CGFloat = 260

    var body: some View {
        ZStack {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipped()
            } else {
                // Helpful placeholder if asset is missing or name is wrong
                LinearGradient(colors: [.clear, .black.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                    .frame(height: height)
                    .overlay(
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Missing asset: \(assetName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 8),
                        alignment: .bottom
                    )
            }
        }
        .mask(
            LinearGradient(
                colors: [.black.opacity(0), .black, .black],
                startPoint: .top,
                endPoint: .init(x: 0.5, y: 0.4)
            )
        )
        .allowsHitTesting(false)
    }
}

private struct ActionItem: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> Void
}

// MARK: - Unchanged Components (LightParticleBackground, KeyboardResponder, etc.)
private struct LightParticleBackground: View {
    var body: some View {
        ZStack {
            Color(white: 0.985).ignoresSafeArea()
            
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    context.blendMode = .normal
                    for i in 0..<30 {
                        let seed = Double(i) * 1.234
                        let randomX = fract(sin(seed * 12.98) * 43758.54); let randomY = fract(cos(seed * 78.23) * 12345.67)
                        let randomDuration = 8.0 + (fract(sin(seed * 56.43) * 9876.54)) * 10.0
                        let randomDelay = (fract(cos(seed * 34.12) * 5432.10)) * 5.0
                        let time = t + randomDelay; let progress = (time / randomDuration).truncatingRemainder(dividingBy: 1.0)
                        let x = randomX * size.width; let y = randomY * size.height
                        let opacity = sin(progress * .pi) * 0.3; let scale = 0.5 + (sin(progress * .pi) * 0.5)
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 3 * scale, height: 3 * scale)), with: .color(Color.gray.opacity(opacity)))
                    }
                }
            }
        }
    }
    @inline(__always) private func fract(_ x: Double) -> Double { x - floor(x) }
}
final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0; private var cancellable: AnyCancellable?
    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).map { $0.keyboardHeight }
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in CGFloat(0) }
        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide).debounce(for: .seconds(0.1), scheduler: RunLoop.main).assign(to: \.currentHeight, on: self)
    }
}
extension Notification { var keyboardHeight: CGFloat { (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 } }

// MARK: - Previews and Helpers
#if DEBUG
struct CinematicHomeyLandingView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var selectedTab = 0
        @State private var showLeftDrawer = false
        @State private var showRightDrawer = false
        @StateObject private var router = AppRouter()
        @StateObject private var themeManager = ThemeManager()
        var body: some View {
            CinematicHomeyLandingView(selectedTab: $selectedTab, showLeftDrawer: $showLeftDrawer, showRightDrawer: $showRightDrawer)
                .environmentObject(router).environmentObject(themeManager)
        }
    }
    static var previews: some View { Wrapper() }
}
#endif
private extension AppPage {
    var isMajorTab: Bool {
        switch self {
        case .discover, .insights, .directory, .documents, .vision: return true
        default: return false
        }
    }
    var route: AppRoute? {
        switch self {
        case .discover: return .discover; case .insights: return .insights; case .directory: return .directory; case .documents: return .documents
        case .vision: return .vision; case .matchmaker: return .matchmaker; case .profile: return .profile; case .settings: return .settings
        default: return nil
        }
    }
}
