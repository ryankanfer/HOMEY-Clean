import SwiftUI

public struct AdminDashboardView: View {
    private let logger: JourneyLogging?

    public init(logger: JourneyLogging? = nil) {
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
        .init(title: "Active Users", value: "1,284", footnote: "+6% WoW"),
        .init(title: "New Invites", value: "93", footnote: "Agents: 61 / Admins: 32"),
        .init(title: "Journey Events", value: "42,713", footnote: "24h ingestion"),
        .init(title: "Errors", value: "0.12%", footnote: "p95 24h")
    ]

    public var body: some View {
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
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(cards) { card in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(card.title).font(.subheadline).foregroundStyle(Theme.textMuted)
                                    Text(card.value).font(.title).bold()
                                    Text(card.footnote).font(.footnote).foregroundStyle(Theme.textMuted)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }

                        // Management panel placeholders
                        SectionCard(title: "Management", subtitle: "Controls & tools") {
                            PlaceholderRow(label: "Feature flags")
                            PlaceholderRow(label: "Moderation queue")
                            PlaceholderRow(label: "System health")
                        }
                    }
                    .padding()
                }
            case .agent:
                AgentDashboardView(logger: logger) // TODO: replace with real Agent dashboard when available
            case .client:
                ClientDashboardView(logger: logger) // TODO: replace with real Client dashboard when available
            }
        }
        .onAppear {
            logger?.log("Viewed Dashboard: Admin", metadata: ["screen": "admin"])
        }
    }
}

// MARK: - Models

private struct MetricCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let footnote: String
}

// MARK: - Preview

#Preview {
    AdminDashboardView(logger: NoopJourneyLogger())
}
