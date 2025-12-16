import Foundation
import Supabase
import SwiftUI

private struct ProfileRole: Decodable { let role: String }

struct RootView: View {
    @EnvironmentObject private var session: AppSessionManager
    @ObservedObject private var onboardingManager = OnboardingStateManager.shared
    @State private var resolvedRole: String?
    @State private var showAuthSuccess = false
    @State private var showSuccessAnimation = false
    #if DEBUG
    @AppStorage("dev_show_admin_tabs") private var devShowAdminTabs = false
    #endif
    @AppStorage("use_signature_scene") private var useSignatureScene = true
    @StateObject private var companion = CompanionStore()

    private let projectURL: URL
    private let supabaseAnonKey: String

    init() {
        let rawURL = (Bundle.main.infoDictionary?["SUPABASE_URL"] as? String) ?? "https://mzqswvyfnblghgvcgxpw.supabase.co"
        let url = URL(string: rawURL)!
        let key = (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? ""
        projectURL = url
        supabaseAnonKey = key
    }
    
    // MARK: - Auth Callback Handler
    private func handleAuthCallback(tokens: [String: String]) async {
        #if DEBUG
        print("[RootView] Received auth callback with tokens: \(tokens.keys.joined(separator: ", "))")
        print("[RootView] Token values: \(tokens)")
        #endif
        
        // 1) Process session first (no UI mutations here)
        await AppSessionManager.shared.handleMagicLinkCallback(tokens: tokens)
        
        #if DEBUG
        print("[RootView] Auth callback processed, isAuthenticated: \(AppSessionManager.shared.isAuthenticated)")
        #endif
        
        // 2) Separate from current render pass
        await Task.yield()
        
        // 3) Apply UI changes on next runloop turn
        DispatchQueue.main.async {
            // Avoid re-triggering while already visible
            if !showSuccessAnimation {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSuccessAnimation = true
                }
            }
            // Hide animation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSuccessAnimation = false
                }
            }
        }
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
            let role = resp.value.first?.role ?? session.userRole
            // Defer to next runloop to avoid publishing during render
            DispatchQueue.main.async { resolvedRole = role }
        } catch {
            DispatchQueue.main.async { resolvedRole = session.userRole }
        }
    }

    var body: some View {
        LaunchGate(
            // REDUCE: Change from 8.0 to 2.0 seconds for faster debugging
            minDisplay: 2.0,
            showSplashPerProcess: true,
            awaitUserUnlock: true
        ) {
            appShell
                .environmentObject(companion)
        }
        .preferredColorScheme(.dark)
        .onOpenURL { url in
            // Defer deep link handling to avoid immediate state mutations during render
            DispatchQueue.main.async {
                DeepLinkManager.shared.handle(url)
            }
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            if let url = activity.webpageURL {
                DispatchQueue.main.async {
                    DeepLinkManager.shared.handle(url)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deepLinkRouted)) { note in
            guard let route = note.userInfo?[Notification.RouteKey] as? DeepLinkManager.Route else { return }
            switch route {
            case .authCallback(let tokens):
                // Defer the whole auth handling to next tick
                DispatchQueue.main.async {
                    Task { await handleAuthCallback(tokens: tokens) }
                }
            default:
                break
            }
        }
        .overlay(alignment: .top) {
            if showSuccessAnimation {
                AuthSuccessToast()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 12)
            }
        }
    }

    private var appShell: some View {
        ZStack {
            PaperBackground(tint: .black, intensity: 0.08, vignette: 0.35)
            
            // Show mandatory onboarding gate if user is authenticated but hasn't completed onboarding
            if session.isAuthenticated, onboardingManager.isBlockingAppAccess() {
                MandatoryOnboardingGate()
                    .environmentObject(onboardingManager)
            } else {
                content
            }
        }
        // React to auth changes, but defer UI changes to next tick
        .task(id: session.isAuthenticated) {
            print("[RootView] Authentication state changed - isAuthenticated: \(session.isAuthenticated)")
            if session.isAuthenticated {
                print("[RootView] Loading user role and initializing onboarding...")
                await loadRole()
                await onboardingManager.initializeOnboarding()
                print("[RootView] Role and onboarding initialization completed")
            } else {
                print("[RootView] User not authenticated - resetting state")
                DispatchQueue.main.async { resolvedRole = nil }
                // Only reset onboarding if the user explicitly signs out.
                // A session disappearing is not the same as signing out.
            }
        }
        .tint(Theme.primaryAction)
        .journeyWatched()
        .onAppear {
            print("[RootView] AppShell appeared")
        }
    }

    @ViewBuilder
    private var content: some View {
        // ViewBuilder expects SwiftUI views, not print statements
        
        if session.isAuthenticated {
            let currentRole: String = {
                #if DEBUG
                if devShowAdminTabs { return "admin" }
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

private struct AuthSuccessToast: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Signed in successfully")
                .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(radius: 8, y: 6)
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