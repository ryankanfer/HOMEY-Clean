import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSessionManager
    @AppStorage("hasSeenCharlieOnboarding") private var hasSeenCharlieOnboarding = false
    @State private var showCharlie = false
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                LaunchView()
                    .task {
                        try? await Task.sleep(nanoseconds: 1_200_000_000)
                        showSplash = false
                    }
            } else if session.isAuthenticated {
                switch session.userRole {
                case "admin":
                    AdminDashboardView()
                case "agent":
                    AgentDashboardView()
                default:
                    ClientDashboardView()
                }
            } else {
                AuthGate()
            }
        }
        // One-time Charlie onboarding after first auth
        .sheet(isPresented: $showCharlie) {
            CharlieOnboardingView {
                hasSeenCharlieOnboarding = true
                showCharlie = false
            }
            .environmentObject(session)
        }
        .task(id: session.isAuthenticated) {
            if session.isAuthenticated, !hasSeenCharlieOnboarding {
                if showSplash { try? await Task.sleep(nanoseconds: 800_000_000) }
                showCharlie = true
            }
        }
        .journeyWatched()
    }
}

// MARK: - Logged-in shell placeholders (retain for reference)
private struct AuthenticatedHome: View {
    @EnvironmentObject private var session: AppSessionManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("HOMEY").font(.largeTitle.bold())
                    RoleSelectionView()
                    Divider()
                    Group {
                        Text("Current role: \(session.userRole.capitalized)")
                        if session.userRole == "client" {
                            Text("Client segment: \(session.clientSegment?.capitalized ?? "—")")
                        }
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)

                    Group {
                        switch session.userRole {
                        case "agent": AgentArea()
                        case "admin": AdminArea()
                        default:       ClientArea()
                        }
                    }
                    .padding(.top, 8)

                    Button("Sign Out") { Task { await session.signOut() } }
                        .buttonStyle(.bordered)
                        .padding(.top, 16)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

private struct ClientArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Client Area").font(.title3.weight(.semibold))
            Text("Drop ClientDashboardView here.").foregroundStyle(.secondary)
        }
    }
}

private struct AgentArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Agent Area").font(.title3.weight(.semibold))
            Text("Drop AgentDashboardView here.").foregroundStyle(.secondary)
        }
    }
}

private struct AdminArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Admin Area").font(.title3.weight(.semibold))
            Text("Drop AdminDashboardView here.").foregroundStyle(.secondary)
        }
    }
}
