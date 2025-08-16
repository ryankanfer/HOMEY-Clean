import SwiftUI

public struct AgentDashboardView: View {
    private let logger: JourneyLogging?

    public init(logger: JourneyLogging? = nil) {
        self.logger = logger
    }

    @State private var navPath: [Route] = []
    @State private var showSettings = false
    @State private var isRefreshing = false

    enum Route: Hashable { case placeholder }

    private let clients: [AgentClientRowModel] = [
        .init(name: "Alex Rivera", stage: "Interview Scheduled"),
        .init(name: "Jamie Lin", stage: "Application Submitted"),
        .init(name: "Morgan Patel", stage: "Board Approval")
    ]

    public var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack(path: $navPath) {
                ScrollView {
                    VStack(spacing: 16) {
                        HeroHeader(
                            name: "Agent",
                            subtitle: "Your pipeline, tasks, and client updates."
                        )

                        GlassCard(
                            padding: 16,
                            cornerRadius: 12,
                            background: AnyShapeStyle(Color(.secondarySystemBackground)),
                            fillWidth: true,
                            alignment: .leading
                        ) {
                            SectionCard(
                                title: "Today's Tasks",
                                subtitle: "\(Date.now.formatted(.dateTime.weekday().month().day()))"
                            ) {
                                PlaceholderRow(label: "Check listings")
                                PlaceholderRow(label: "Follow up on board package")
                            }
                        }

                        GlassCard(
                            padding: 16,
                            cornerRadius: 12,
                            background: AnyShapeStyle(Color(.secondarySystemBackground)),
                            fillWidth: true,
                            alignment: .leading
                        ) {
                            SectionCard(title: "Active Clients", subtitle: "\(clients.count) total") {
                                ForEach(clients) { client in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(client.name).bold()
                                        Text(client.stage)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    if client.id != clients.last?.id { Divider() }
                                }
                            }
                        }

                        GlassCard(
                            padding: 16,
                            cornerRadius: 12,
                            background: AnyShapeStyle(Color(.secondarySystemBackground)),
                            fillWidth: true,
                            alignment: .leading
                        ) {
                            SectionCard(title: "Upcoming Tours", subtitle: "") {
                                PlaceholderRow(label: "None scheduled")
                            }
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .refreshable {
                    // wire real refresh later
                    try? await Task.sleep(nanoseconds: 350_000_000)
                }
                .navigationTitle("Agent")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                Form {
                    Section("Preferences") {
                        Toggle("Show beta widgets", isOn: .constant(false))
                    }
                }
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showSettings = false }
                    }
                }
            }
        }
        .onAppear {
            logger?.log("Viewed Dashboard: Agent", metadata: ["screen": "agent"])
        }
    }
}

// MARK: - Models & stubs

private struct AgentClientRowModel: Identifiable {
    let id = UUID()
    let name: String
    let stage: String
}

private struct GlassBackground: View {
    var body: some View {
        Theme.background.ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview("Agent Dashboard") {
    AgentDashboardView(logger: nil)
}
