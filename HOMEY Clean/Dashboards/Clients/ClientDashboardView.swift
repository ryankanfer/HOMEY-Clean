import SwiftUI

public struct ClientDashboardView: View {
    private let logger: JourneyLogging?
    @EnvironmentObject private var flags: FeatureFlags

    public init(logger: JourneyLogging? = nil) { self.logger = logger }

    public var body: some View {
        SwipeClientDashboard(logger: logger)
    }
}

// MARK: - Multi-homie swipeable dashboard using real dashboards
private struct SwipeClientDashboard: View {
    let logger: JourneyLogging?
    @State private var page = 0
    private let kinds: [HomeyKind] = [.charlie, .paige, .scout, .isla, .viza, .drew]
    private let titles = ["Charlie", "Paige", "Scout", "Isla", "Viza", "Drew"]

    var body: some View {
        VStack(spacing: 12) {
            // Header with current section title
            HStack {
                Text(titles[safe: page] ?? "Client")
                    .font(.largeTitle.bold())
                Spacer()
                BuildBadge()
            }
            .padding(.horizontal)

            // Use the dedicated dashboards instead of placeholder sections
            TabView(selection: $page) {
                CharlieDashboardView().tag(0)
                PaigeDashboardView().tag(1)
                ScoutDashboardView().tag(2)
                IslaDashboardView().tag(3)
                VizaDashboardView().tag(4)
                DrewDashboardView().tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .safeAreaInset(edge: .bottom) {
            ClientTabBar(
                items: kinds,
                selection: Binding(
                    get: { kinds[page] },
                    set: { new in
                        if let i = kinds.firstIndex(of: new) {
                            withAnimation(.spring()) { page = i }
                        }
                    }
                ),
                onPrimaryAction: { actionFor(kinds[page]) }
            )
            .background(.ultraThinMaterial)
        }
        .onAppear { logger?.log("Viewed Dashboard: Client", metadata: ["screen": "client"]) }
    }

    private func actionFor(_ kind: HomeyKind) {
        switch kind {
        case .charlie:
            // TODO: present Charlie chat
            logger?.log("CTA: Ask Charlie", metadata: ["screen": "client"]) 
        case .paige:
            // TODO: open documents
            logger?.log("CTA: Open Paige", metadata: ["screen": "client"]) 
        case .scout:
            // TODO: show filters/search
            logger?.log("CTA: Open Scout", metadata: ["screen": "client"]) 
        case .isla:
            // TODO: open neighborhood intel
            logger?.log("CTA: Open Isla", metadata: ["screen": "client"]) 
        case .viza:
            // TODO: open design tools
            logger?.log("CTA: Open Viza", metadata: ["screen": "client"]) 
        case .drew:
            // TODO: open vendor directory
            logger?.log("CTA: Open Drew", metadata: ["screen": "client"]) 
        }
    }
}

// MARK: - Safe index helper
private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}
