import SwiftUI

public struct AgentDashboardView: View {
    @EnvironmentObject var session: SessionManager
    private let logger: JourneyLogging?

    public init(logger: JourneyLogging? = nil) {
        self.logger = logger
    }

    @State private var navPath: [Route] = []
    @State private var showSettings = false

    enum Route: Hashable { case placeholder }

    // Static placeholder data for now
    private let clients: [AgentClient] = [
        .init(fullName: "Ava Chen", journeyStage: "Application in review"),
        .init(fullName: "Marcus Lee", journeyStage: "Touring this week"),
        .init(fullName: "Noa Patel", journeyStage: "Offer sent"),
        .init(fullName: "Diego Rivera", journeyStage: "Board prep")
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

                        GlassCard {
                            Text("Today\u2019s Tasks")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active Clients")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ForEach(clients) { client in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(client.fullName).bold()
                                        Text(client.journeyStage)
                                            .font(.caption)
                                            .foregroundStyle(Theme.textMuted)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    if client.id != clients.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }

                        GlassCard {
                            Text("Upcoming Tours")
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            // TODO: Replace with SettingsView when available
            Text("Settings")
        }
        .onAppear {
            logger?.log("Viewed Dashboard: Agent", metadata: ["screen": "agent"])
        }
    }
}

// MARK: - Models & stubs

private struct AgentClient: Identifiable {
    let id = UUID()
    let fullName: String
    let journeyStage: String
}

private struct HeroHeader: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.largeTitle)
                .bold()
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GlassBackground: View {
    var body: some View {
        Theme.background
            .ignoresSafeArea()
    }
}

private struct GlassCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    AgentDashboardView(logger: NoopJourneyLogger())
        .environmentObject(SessionManager())
}
