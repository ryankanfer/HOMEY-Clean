import SwiftUI

struct ClientDashboardView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var taste: TasteStore
    @StateObject private var journey = JourneyWatcher.shared

    @State private var navPath: [Route] = []
    @State private var showSettings = false
    @Namespace private var avatarNS

    // Single source of truth for which HOMEY is selected
    private var selectedHomey: HomeyKind { appState.selectedHomey }

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                let currentTheme = theme(for: selectedHomey)
                GradientBackground(theme: currentTheme)

                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        HeroHeader(
                            name: "Welcome",
                            subtitle: "Let’s make your home journey smooth and successful."
                        )

                        homeyContent
                            .padding(.bottom, 90)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .scrollContentBackground(.hidden)
            }
            .tint(theme(for: selectedHomey).accent)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.selectedHomey = .charlie
                    } label: {
                        Label("HOMEY", systemImage: "house.fill")
                            .font(.headline)
                            .labelStyle(.titleAndIcon)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { /* notifications */ } label: {
                        Image(systemName: "bell")
                    }
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    Menu {
                        Button(role: .destructive) {
                            Task { await session.logout() }
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .matches:
                    MatchesView()
                case .listing(let id):
                    ListingDetailView(listingId: id)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        // MARK: Lifecycle
        .task(id: session.userId) {
            if let uid = session.userId {
                await journey.start(userId: uid)   // call your JourneyWatcher API
            }
        }
        .onDisappear {
            Task { await journey.stop() }
        }
        // MARK: Intents / deep links
        .onChange(of: appState.intentGoToMatches) { go in
            guard go else { return }
            navPath.append(.matches)
            appState.intentGoToMatches = false
            appState.selectedHomey = .scout
        }
        .onChange(of: appState.intentOpenListingId) { id in
            guard let id else { return }
            navPath.append(.listing(id))
            appState.intentOpenListingId = nil
        }
    }

    // MARK: - View switching
    @ViewBuilder
    private var homeyContent: some View {
        switch selectedHomey {
        case .charlie:
            CharliesCorner(openChat: { /* open chat */ })

        case .paige:
            PaigesPlace(
                openChat: { openChat(with: .paige) },
                openDocuments: { /* nav to docs */ }
            )

        case .scout:
            ScoutView(
                openMatches: { navPath.append(.matches) },
                openChat: { openChat(with: .scout) }
            )

        case .isla:
            IslasInsights(
                areaName: "Upper West Side",
                areaValues: .init(medianRent: "$4,500", daysOnMarket: "28", pricePerSqft: "$7.50"),
                baselineName: "Manhattan",
                baselineValues: .init(medianRent: "$4,250", daysOnMarket: "42", pricePerSqft: "$6.85"),
                openInsights: { /* route */ },
                openChat: { openChat(with: .isla) }
            )

        case .viza:
            VizasVision(
                openChat: { openChat(with: .viza) },
                showAR: { /* present AR/Camera */ },
                uploadPhoto: { /* picker */ }
            )

        case .drew:
            DrewsDirectory(openChat: { openChat(with: .drew) })
        }
    }

    // MARK: - Helpers
    private func openChat(with h: HomeyKind) {
        appState.askHomey = h   // delegate to RootView sheet
    }

    private func mapJourneyToIndex(_ step: Any?) -> Int {
        guard let s = journey.journey?.currentStep else { return 0 }
        let key = String(describing: s).lowercased()
        if key.contains("pre") { return 1 }
        if key.contains("search") { return 2 }
        if key.contains("offer") { return 3 }
        if key.contains("board") || key.contains("loan") { return 4 }
        if key.contains("closing") { return 5 }
        return 0
    }

    enum Route: Hashable {
        case matches
        case listing(UUID)
    }
}