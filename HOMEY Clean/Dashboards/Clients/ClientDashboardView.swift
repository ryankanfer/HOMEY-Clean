import SwiftUI

// Public entry
public struct ClientDashboardView: View {
    let logger: JourneyLogging?
    public init(logger: JourneyLogging? = nil) { self.logger = logger }
    public var body: some View { SwipeClientDashboard(logger: logger) }
}

// MARK: - Multi-homie swipeable dashboard using real dashboards

private struct SwipeClientDashboard: View {
    let logger: JourneyLogging?
    @EnvironmentObject private var session: AppSessionManager
    @State private var page = 0
    @State private var checklist: [[String: Any]] = []
    private let kinds: [HomeyKind] = [.charlie, .paige, .scout, .isla, .viza, .drew]
    private let titles = ["Charlie", "Paige", "Scout", "Isla", "Viza", "Drew"]

    private func loadCharlieChecklist() {
        Task {
            do {
                let items = try await CharlieAct.checklist(role: "client")
                checklist = items
                logger?.log("Fetched Charlie checklist", metadata: ["count": "\(items.count)"])
            } catch {
                logger?.log("Failed Charlie checklist", metadata: ["error": "\(error)"])
            }
        }
    }

    var body: some View {
        ZStack {
            RoomVibeBackground(kind: kinds[safe: page] ?? .charlie)

            VStack(spacing: 12) {
                // Header with current section title
                HStack {
                    Text(titles[safe: page] ?? "Client")
                        .font(.largeTitle.bold())
                    Spacer()
                    BuildBadge()
                    Button("Log out") {
                        Task {
                            do { try await session.signOut() } catch { print("Logout failed: \(error)") }
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }

                if !checklist.isEmpty && page == 0 {
                    Text("Checklist items: \(checklist.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                // Constrained pager: clamp to viewport width
                GeometryReader { proxy in
                    TabView(selection: $page) {
                        CharlieDashboardView().frame(width: proxy.size.width).tag(0)
                        PaigeDashboardView().frame(width: proxy.size.width).tag(1)
                        ScoutDashboardView().frame(width: proxy.size.width).tag(2)
                        IslaDashboardView().frame(width: proxy.size.width).tag(3)
                        VizaDashboardView().frame(width: proxy.size.width).tag(4)
                        DrewDashboardView().frame(width: proxy.size.width).tag(5)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(width: proxy.size.width)
                }
            }
            .padScreen()
        }
        .onAppear { loadCharlieChecklist() }
        .onChange(of: page) { newValue in if newValue == 0 { loadCharlieChecklist() } }
        .onAppear { logger?.log("Viewed Dashboard: Client", metadata: ["screen": "client"]) }
    }

    private func actionFor(_ kind: HomeyKind) {
        switch kind {
        case .charlie: logger?.log("CTA: Ask Charlie", metadata: ["screen": "client"])
        case .paige: logger?.log("CTA: Open Paige", metadata: ["screen": "client"])
        case .scout: logger?.log("CTA: Open Scout", metadata: ["screen": "client"])
        case .isla: logger?.log("CTA: Open Isla", metadata: ["screen": "client"])
        case .viza: logger?.log("CTA: Open Viza", metadata: ["screen": "client"])
        case .drew: logger?.log("CTA: Open Drew", metadata: ["screen": "client"])
        }
    }
}

// MARK: - Safe index helper

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}
