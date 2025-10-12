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
    @StateObject private var router = AppRouter()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var quickDrawerVM = RightQuickViewDrawerViewModel()
    @State private var selectedTab = 0 // Start with HOMEY (primary tab)
    @State private var showLeftDrawer = false
    @State private var showRightDrawer = false
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
        HapticsManager.shared.impact(.light)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Dynamic gradient background based on current page
                ThemedBackground(page: currentPage)
                    .ignoresSafeArea()
                
                // Main tab content - Only HOMEY tab
                CinematicHomeyLandingView(selectedTab: $selectedTab, showLeftDrawer: $showLeftDrawer, showRightDrawer: $showRightDrawer)
                    .tint(Theme.primaryAction)
                    .environmentObject(router)
                    .environmentObject(themeManager)
                    .leftEdgeSwipe(isDrawerPresented: $showLeftDrawer)
                    .onAppear {
                        selectedTab = 0
                    }
                    .onChange(of: router.route) { newRoute in
                        if let route = newRoute {
                            switch route {
                            case .insights: path.append(.insights)
                            case .directory: path.append(.directory)
                            case .vision: path.append(.vision)
                            case .settings: path.append(.settings)
                            case .matchmaker: path.append(.matchmaker)
                            case .profile: path.append(.profile)
                            case .documents: path.append(.documents)
                            case .arFeatures: path.append(.arFeatures)
                            case .helpSupport: path.append(.helpSupport)
                            case .education: path.append(.education)
                            case .search: path.append(.search)
                            case .discover: path.append(.discover)
                            case .settingsDetail(let subroute): path.append(.settingsDetail(subroute))
                            }
                            router.route = nil
                        }
                    }
                
                // Left navigation drawer
                LeftNavigationDrawer(isPresented: $showLeftDrawer)
                    .environmentObject(router)

                // Right Simplified Profile Drawer
                RightDrawerView(isPresented: $showRightDrawer) {
                    SimplifiedProfileView(closeDrawerAction: {
                        showRightDrawer = false
                    })
                    .environmentObject(router)
                    .environmentObject(session)
                }
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
                    MatchmakerView()
                        .environmentObject(themeManager)
                case .search:
                    SearchPageView()
                        .environmentObject(themeManager)
                case .discover:
                    SearchPageView()
                        .environmentObject(themeManager)
                        .navigationTitle("Discover")
                        .navigationBarTitleDisplayMode(.large)
                case .settings:
                    ComprehensiveSettingsView()
                        .environmentObject(themeManager)
                case .profile:
                    ProfileTabView()
                        .environmentObject(themeManager)
                        .environmentObject(session)
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
                    ComingSoonView(
                        featureTitle: "Education Center",
                        subtitle: "Learn about the home buying process"
                    )
                    .environmentObject(themeManager)
                case .settingsDetail(let subroute):
                    switch subroute {
                    case .appearanceTheme:
                        ThemeSelectionView()
                    case .accessibility:
                        AccessibilitySettingsView()
                    case .notifications:
                        QuietHoursView()
                    case .privacySecurity:
                        ConnectedDevicesView()
                    case .integrations:
                        CalendarSyncView()
                    case .personalizationTabOrder:
                        TabOrderCustomizationView()
                    case .personalizationQuickActions:
                        QuickActionsView()
                    case .helpSupport:
                        FAQView()
                    case .about:
                        AboutView()
                    }
                }
            }
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 24)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 8)
                            .onEnded { value in
                                if value.translation.width < -40 { // Leftward drag
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                        showRightDrawer = true
                                    }
                                }
                            }
                    )
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
    case search
    case discover
    case settings
    case profile
    case arFeatures
    case helpSupport
    case education
    case settingsDetail(SettingsRoute)
}