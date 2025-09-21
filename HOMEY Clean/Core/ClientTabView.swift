//
//  ClientTabView.swift
//  HOMEY Clean
//
//  Redesigned client navigation with left drawer and simplified tabs
//

import SwiftUI

// Import extracted components
// Note: These files contain the extracted components from ClientTabView.swift

struct ClientTabView: View {
    @EnvironmentObject private var session: AppSessionManager
    @StateObject private var router = DrawerRouter()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = 0 // Start with HOMEY (primary tab)
    @State private var showLeftDrawer = false
    @State private var showAllDrawer = false
    @State private var dragOffset: CGFloat = 0
    @State private var path: [AppRoute] = []
    
    // Dynamic second tab state
    @State private var secondTabType: SecondTabType = .search
    @State private var showTabOptions = false
    @State private var carouselIndex: Int = 0
    
    private let projectURL: URL
    
    init(projectURL: URL) {
        self.projectURL = projectURL
    }
    
    private let pinnedSecondTabKey = "PinnedSecondTabType"

    private func loadPinnedSecondTab() {
        if let raw = UserDefaults.standard.string(forKey: pinnedSecondTabKey),
           let saved = SecondTabType(rawValue: raw) {
            secondTabType = saved
        }
    }

    private func savePinnedSecondTab(_ type: SecondTabType) {
        UserDefaults.standard.set(type.rawValue, forKey: pinnedSecondTabKey)
    }

    private var carouselOrder: [SecondTabType] { SecondTabType.allCases }

    private func cycleSecondTab() {
        guard let currentIndex = carouselOrder.firstIndex(of: secondTabType) else { return }
        let nextIndex = (currentIndex + 1) % carouselOrder.count
        let next = carouselOrder[nextIndex]
        secondTabType = next
        savePinnedSecondTab(next)
        selectedTab = 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Dynamic gradient background based on current page
                AnimatedGradientBackground(for: currentPage)
                    .environmentObject(themeManager)
                    .ignoresSafeArea()
                
                // Main tab content - Only HOMEY tab
                TabView(selection: $selectedTab) {
                    // Tab 0: HOMEY (only tab)
                    HomeyLandingViewWithProfile(selectedTab: $selectedTab, showLeftDrawer: $showLeftDrawer)
                        .tabItem {
                            Label("HOMEY", systemImage: "house.fill")
                        }
                        .tag(0)
                }
                .tint(Theme.primary)
                .environmentObject(router)
                .environmentObject(themeManager)
                .leftEdgeSwipe(isDrawerPresented: $showLeftDrawer)
                .onChange(of: selectedTab) { _, newTab in
                    // Update theme based on selected tab
                    themeManager.setCurrentPage(.homey)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToTab"))) { notification in
                    if let tabIndex = notification.object as? Int, tabIndex == 0 {
                        selectedTab = tabIndex
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToFullPage"))) { notification in
                    if let destination = notification.object as? String {
                        switch destination {
                        case "insights":
                            path.append(.insights)
                        case "directory":
                            path.append(.directory)
                        case "vision":
                            path.append(.vision)
                        case "documents":
                            path.append(.documents)
                        case "matchmaker":
                            path.append(.matchmaker)
                        case "education":
                            path.append(.education)
                        default:
                            break
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToDiscover"))) { _ in
                    // Navigate to discover/search functionality
                    path.append(.discover)
                }
                .onChange(of: router.route) { _, newRoute in
                    // Handle drawer route changes
                    if let route = newRoute {
                        switch route {
                        case .insights:
                            path.append(.insights)
                        case .directory:
                            path.append(.directory)
                        case .vision:
                            path.append(.vision)
                        case .settings:
                            path.append(.settings)
                        case .matchmaker:
                            path.append(.matchmaker)
                        case .profile:
                            path.append(.profile)
                        case .documents:
                            path.append(.documents)
                        case .arFeatures:
                            path.append(.arFeatures)
                        }
                        // Reset the route after handling
                        router.route = nil
                    }
                }
                .onAppear {
                    // Initialize with HOMEY tab
                    selectedTab = 0
                }
                
                // Left navigation drawer
                LeftNavigationDrawer(isPresented: $showLeftDrawer)
                    .environmentObject(router)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .insights:
                    InsightsTabView()
                        .environmentObject(themeManager)
                case .directory:
                    DirectoryTabView()
                        .environmentObject(themeManager)
                        .navigationTitle("Directory")
                        .navigationBarTitleDisplayMode(.large)
                case .vision:
                    VisionTabView()
                        .environmentObject(themeManager)
                        .navigationTitle("Vision")
                        .navigationBarTitleDisplayMode(.large)
                case .documents:
                    DocumentsTabView()
                case .matchmaker:
                    MatchmakerPlaceholderView()
                case .discover:
                    SearchTabView()
                        .environmentObject(themeManager)
                case .settings:
                    ComprehensiveSettingsView()
                        .environmentObject(themeManager)
                case .profile:
                    ProfileTabView()
                        .environmentObject(themeManager)
                case .arFeatures:
                    ARFeaturesPlaceholderView()
                        .environmentObject(themeManager)
                case .helpSupport:
                    ComingSoonView(
                        featureTitle: "Help & Support",
                        subtitle: "Support center and help resources coming soon"
                    )
                    .environmentObject(themeManager)
                case .education:
                    EducationCenterView()
                        .environmentObject(themeManager)
                        .navigationTitle("Education")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
        }
        .environmentObject(router)
        .environmentObject(themeManager)
    }
    
    // Computed property to map selected tab to AppPage
    private var currentPage: AppPage {
        switch selectedTab {
        case 0: return .homey
        case 1: 
            switch secondTabType {
            case .search: return .discover
            case .map: return .discover
            case .filters: return .discover
            }
        default: return .homey
        }
    }
    
    // Dynamic second tab content
    @ViewBuilder
    private var dynamicSecondTabContent: some View {
        switch secondTabType {
        case .search:
            SearchTabViewSimple()
        case .map:
            SearchTabViewSimple()
        case .filters:
            SearchTabViewSimple()
        }
    }
}

// DrawerMenuItem moved to DrawerComponents.swift to avoid duplication

// MARK: - Placeholder Views (to be implemented)

struct ProfileViewPlaceholder: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.largeTitle.bold())
            
            Text("Liquid Glass progress bar and profile content coming soon")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// SearchView moved to SearchComponents.swift to avoid duplication

enum AppRoute: Hashable {
    case insights
    case directory
    case vision
    case documents
    case matchmaker
    case discover
    case settings
    case profile
    case arFeatures
    case helpSupport
    case education
}