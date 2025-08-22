import Supabase
import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject private var flags: FeatureFlags
    private let logger: JourneyLogging?
    let client: SupabaseClient
    let projectURL: URL

    init(client: SupabaseClient, projectURL: URL, logger: JourneyLogging? = nil) {
        self.client = client
        self.projectURL = projectURL
        self.logger = logger
    }

    private enum Role {
        case admin
        case agent
        case client
    }

    @State private var selectedRole: Role = .admin

    // Dummy metrics
    private let cards: [MetricCard] = [
        .init(title: "Active Users", value: "1,284", footnote: "+6% WoW", trend: .up(6.0)),
        .init(title: "New Invites", value: "93", footnote: "Agents: 61 / Admins: 32", trend: .neutral),
        .init(title: "Journey Events", value: "42,713", footnote: "24h ingestion", trend: .up(12.5)),
        .init(title: "Errors", value: "0.12%", footnote: "p95 24h", trend: .down(0.03))
    ]

    var body: some View {
        ZStack {
            GradientBackground(theme: heroTheme(for: .drew))
            VStack(alignment: .leading, spacing: 16) {
                Picker("Mode", selection: $selectedRole) {
                    Text("Admin").tag(Role.admin)
                    Text("Agent").tag(Role.agent)
                    Text("Client").tag(Role.client)
                }
                .pickerStyle(.segmented)

                switch selectedRole {
                case .admin:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Admin").font(.largeTitle).bold()

                            // Metric grid
                            LazyVGrid(
                                columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2),
                                spacing: 12
                            ) {
                                ForEach(cards) { card in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(card.title).font(.subheadline).foregroundStyle(Theme.textMuted)
                                        Text(card.value).font(.title).bold()
                                        Text(card.footnote).font(.footnote).foregroundStyle(Theme.textMuted)
                                    }
                                    .padCard()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        .ultraThinMaterial,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    )
                                }
                            }

                            // Management panel placeholders
                            SectionCard(title: "Management", subtitle: "Controls & tools") {
                                PlaceholderRow(label: "Feature flags")
                                PlaceholderRow(label: "Moderation queue")
                                PlaceholderRow(label: "System health")
                            }
                            Text("Admin dashboard features coming soon")
                                .foregroundColor(Theme.textMuted)
                                .padding(.top, 8)
                        }
                    }
                case .agent:
                    AgentDashboardView(client: client, projectURL: projectURL)
                case .client:
                    ClientDashboardView(logger: logger)
                }
            }
            .padScreen()
        }
        .onAppear {
            logger?.log("Viewed Dashboard: Admin", metadata: ["screen": "admin"])
        }
    }
}

// MARK: - Preview
