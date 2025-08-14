import SwiftUI

public struct AdminDashboardView: View {
    private let logger: JourneyLogging?

    @State private var selectedRole = "admin"
    @State private var navigationTag: String?

    public init(logger: JourneyLogging? = nil) {
        self.logger = logger
    }

    // Static metrics
    private let cards: [MetricCard] = [
        .init(title: "Total Agents", value: "24"),
        .init(title: "Active Listings", value: "17"),
        .init(title: "Sales (Month)", value: "11"),
        .init(title: "Urgent Flags", value: "3")
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // TODO: Add AvatarStrip when available

                    Picker("Mode", selection: $selectedRole) {
                        Text("Admin").tag("admin")
                        Text("Agent").tag("agent")
                        Text("Client").tag("client")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedRole) { role in
                        switch role {
                        case "agent", "client":
                            navigationTag = role
                        default:
                            navigationTag = nil
                        }
                    }

                    // Metric grid
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(cards) { card in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(card.title).font(.subheadline).foregroundColor(.secondary)
                                Text(card.value).font(.title).bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }

                    SectionCard(title: "Quick Actions", subtitle: "Common tasks") {
                        PlaceholderRow(label: "Invite / Onboard Agent")
                        PlaceholderRow(label: "Generate Report")
                    }

                    SectionCard(title: "Recent Activity", subtitle: "Last 24h") {
                        PlaceholderRow(label: "Paige Turner added 3 clients")
                        PlaceholderRow(label: "Scout Finch updated a listing")
                        PlaceholderRow(label: "Drew Carter flagged a message")
                    }
                }
                .padding()
            }
            .navigationTitle("Admin Dashboard")

            NavigationLink("", tag: "agent", selection: $navigationTag) {
                AgentDashboardView(logger: logger)
            }
            NavigationLink("", tag: "client", selection: $navigationTag) {
                ClientDashboardView(logger: logger)
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
}

// MARK: - Reused bits

private struct SectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title3).bold()
                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
            }
            content
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct PlaceholderRow: View {
    let label: String
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2).frame(width: 10, height: 10)
            Text(label)
            Spacer()
            Text("—").foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    AdminDashboardView(logger: NoopJourneyLogger())
}

