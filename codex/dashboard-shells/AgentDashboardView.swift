import SwiftUI

public struct AgentDashboardView: View {
    private let logger: JourneyLogging?

    public init(logger: JourneyLogging? = nil) {
        self.logger = logger
    }

    @State private var navPath: [Route] = []
    @State private var showSettings = false

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
                        HeroHeader(title: "Agent",
                                   subtitle: "Your pipeline, tasks, and client updates.")

                        GlassCard {
                            SectionCard(title: "Today's Tasks") {
                                PlaceholderRow(label: "Check listings")
                            }
                        }

                        GlassCard {
                            SectionCard(title: "Active Clients") {
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

                        GlassCard {
                            SectionCard(title: "Upcoming Tours") {
                                PlaceholderRow(label: "None scheduled")
                            }
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            Text("Settings")
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

private struct HeroHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.largeTitle).bold()
            if let s = subtitle {
                Text(s).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GlassBackground: View {
    var body: some View {
        Color(.systemBackground).ignoresSafeArea()
    }
}

private struct GlassCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) { content() }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
        .padding()
    }
}

private struct PlaceholderRow: View {
    let label: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    AgentDashboardView(logger: NoopJourneyLogger())
}
