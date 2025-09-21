import SwiftUI

// MARK: - Integration Helper

public struct SignatureSceneIntegration: View {
    @State private var selectedTab: NavigationTab = .journey
    @EnvironmentObject private var session: AppSessionManager

    public init() {}

    public var body: some View {
        NavigationDashboardView(selectedTab: $selectedTab)
            .environmentObject(session)
    }
}

// MARK: - Navigation Dashboard View

struct NavigationDashboardView: View {
    @Binding var selectedTab: NavigationTab
    @State private var previousTab: NavigationTab = .journey

    var body: some View {
        ZStack {
            // Main Content - Each dashboard handles its own scrolling
            Group {
                switch selectedTab {
                case .directory:
                    DrewDirectoryView()
                case .papers:
                    PaigeDashboard()
                case .journey:
                    JourneyEpisodeInterface()
                case .home:
                    SignatureSceneHomepage()
                case .search:
                    ScoutDashboardView()
                case .insights:
                    IslaDashboardView()
                case .vision:
                    VizaVisionView()
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 84) }

            // Custom Footer with All 7 Tabs - Fixed at bottom
            VStack {
                Spacer()
                CustomNavigationFooter(selectedTab: $selectedTab)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            previousTab = oldValue
        }
    }
}

// MARK: - Custom Navigation Footer

struct CustomNavigationFooter: View {
    @Binding var selectedTab: NavigationTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(NavigationTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.85))

                        Text(tab.title)
                            .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .medium))
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 72, alignment: .center)
        .background(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.92),
                            Color.black.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .bottom)
                .overlay(
                    // Subtle top divider only (no extra shading up)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 0.5),
                    alignment: .top
                )
        )
    }
}

// MARK: - Placeholder Dashboard View

struct PlaceholderDashboard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.white.opacity(0.8))

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }

            Text("Coming Soon")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Usage Examples

public enum SignatureSceneExamples {
    // Example 1: Direct usage in ContentView
    public static func replaceContentView() {
        // Replace your ContentView.swift with:
        /*
         import SwiftUI

         struct ContentView: View {
             var body: some View {
                 SignatureSceneHomepage()
                     .environmentObject(AppSessionManager())
             }
         }
         */
    }

    // Example 2: Integration with existing navigation
    public static func integrateWithNavigation() {
        // In your existing navigation structure:
        /*
         NavigationStack {
             SignatureSceneHomepage()
                 .navigationTitle("Home")
                 .navigationBarTitleDisplayMode(.inline)
         }
         */
    }

    // Example 3: Conditional rendering based on user preference
    public static func conditionalRendering() {
        // Check user preference and render accordingly:
        /*
         @AppStorage("useSignatureScene") private var useSignatureScene = true

         var body: some View {
             Group {
                 if useSignatureScene {
                     SignatureSceneHomepage()
                 } else {
                     ClientDashboardView()
                 }
             }
         }
         */
    }
}

// MARK: - Configuration Options

public struct SignatureSceneConfig {
    public var userName: String = "Alex"
    public var journeyStage: JourneyStage = .exploring
    public var enableAnimations: Bool = true
    public var enableCharacterReactions: Bool = true
    public var enableSmartPicks: Bool = true

    public init(
        userName: String = "Alex",
        journeyStage: JourneyStage = .exploring,
        enableAnimations: Bool = true,
        enableCharacterReactions: Bool = true,
        enableSmartPicks: Bool = true
    ) {
        self.userName = userName
        self.journeyStage = journeyStage
        self.enableAnimations = enableAnimations
        self.enableCharacterReactions = enableCharacterReactions
        self.enableSmartPicks = enableSmartPicks
    }
}

// MARK: - Enhanced Signature Scene with Configuration

public struct ConfigurableSignatureScene: View {
    let config: SignatureSceneConfig
    @EnvironmentObject private var session: AppSessionManager

    public init(config: SignatureSceneConfig) {
        self.config = config
    }

    public var body: some View {
        SignatureSceneHomepage()
            .environmentObject(session)
            .transaction { txn in
                if !config.enableAnimations {
                    txn.disablesAnimations = true
                }
            }
    }
}