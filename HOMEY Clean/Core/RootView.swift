import Foundation
import Supabase
import SwiftUI

private struct ProfileRole: Decodable { let role: String }

struct RootView: View {
    @EnvironmentObject private var session: AppSessionManager
    @AppStorage("hasSeenCharlieOnboarding") private var hasSeenCharlieOnboarding = false
    @State private var showCharlie = false
    @State private var resolvedRole: String?
    #if DEBUG
    @AppStorage("dev_show_admin_tabs") private var devShowAdminTabs = false
    #endif
    @AppStorage("use_signature_scene") private var useSignatureScene = true
    @StateObject private var companion = CompanionStore()

    private let projectURL: URL
    private let supabaseAnonKey: String

    init() {
        let rawURL = (Bundle.main.infoDictionary?["SUPABASE_URL"
        ] as? String) ?? "https://mzqswvyfnblghgvcgxpw.supabase.co/"
        let url = URL(string: rawURL)!
        let key = (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? ""
        projectURL = url
        supabaseAnonKey = key
        // client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }

    private func loadRole() async {
        do {
            let client = session.supabaseClient
            let sessionObj = try await client.auth.session
            let uid = sessionObj.user.id
            let resp: PostgrestResponse<[ProfileRole]> = try await client
                .from("profiles")
                .select("role")
                .eq("id", value: uid)
                .execute()
            if let first = resp.value.first {
                resolvedRole = first.role
            } else {
                resolvedRole = session.userRole
            }
        } catch {
            resolvedRole = session.userRole
        }
    }

    var body: some View {
        LaunchGate(
            minDisplay: 2.2,
            showSplashPerProcess: true
        ) {
            appShell
                .environmentObject(companion)
        }
    }

    private var appShell: some View {
        ZStack {
            AnimatedLuxeBackground()
            content
        }
        .sheet(isPresented: $showCharlie) {
            ComprehensiveOnboardingFlow {
                hasSeenCharlieOnboarding = true
                showCharlie = false
            }
            .environmentObject(session)
        }
        .task {
            if !session.isAuthenticated {
                await session.restoreIfPossible()
            }
        }
        .task(id: session.isAuthenticated) {
            if session.isAuthenticated {
                await loadRole()
                if !hasSeenCharlieOnboarding { showCharlie = true }
            } else {
                resolvedRole = nil
            }
        }
        .tint(Theme.primary)
        .journeyWatched()
    }

    @ViewBuilder
    private var content: some View {
        if session.isAuthenticated {
            let currentRole: String = {
                #if DEBUG
                if devShowAdminTabs {
                    return "admin"
                }
                #endif
                return resolvedRole ?? session.userRole
            }()

            switch currentRole {
            case "admin":
                TabView {
                    AdminDashboardView(client: session.supabaseClient, projectURL: projectURL)
                        .tabItem { Label("Admin", systemImage: "person.crop.square") }
                    AgentDashboardView(client: session.supabaseClient, projectURL: projectURL)
                        .tabItem { Label("Agent", systemImage: "person.2") }
                    TRAEDemoView()
                        .tabItem { Label("TRAE Demo", systemImage: "sparkles") }
                    ComprehensiveSettingsView()
                        .tabItem { Label("Settings", systemImage: "gearshape") }
                }
            case "agent":
                NavigationStack {
                    AgentDashboardView(client: session.supabaseClient, projectURL: projectURL)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink(destination: ComprehensiveSettingsView()) {
                                    Image(systemName: "gearshape")
                                }
                            }
                        }
                }
            default:
                ClientTabView(projectURL: projectURL)
                    .environmentObject(session)
            }
        } else {
            AuthGate()
        }
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
                    if session.userRole == "admin" {
                        RoleSelectionView()
                    }
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
                        default: ClientArea()
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
            Text("Clients use Signature Screens for all interactions.").foregroundStyle(.secondary)
        }
    }
}

private struct AgentArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Agent Area").font(.title3.weight(.semibold))
            Text("Drop AgentDashboardView here.").foregroundStyle(.secondary)
            NavigationLink("Journey") { Text("Open Agent → Events in the Agent tab") }
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