import SwiftUI

struct AdminRoleTabs: View {
    @EnvironmentObject var session: SessionManager
    var body: some View {
        Picker("Mode", selection: Binding(
            get: { session.effectiveRole },
            set: { session.setActiveRole($0) }
        )) {
            Text("Admin").tag("admin")
            Text("Agent").tag("agent")
            Text("Client").tag("client")
        }
        .pickerStyle(.segmented)
    }
}

struct AdminDashboardView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var appState: AppState

    @State private var chatAssistant: HomeyKind? = nil
    @State private var showInviteCodes = false

    @State private var totalAgents = 24
    @State private var activeListings = 17
    @State private var salesThisMonth = 11
    @State private var urgentFlags = 3

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    AvatarStrip(
                        homeys: HomeyKind.adminDefault,

                        // If AvatarStrip expects Binding<HomeyKind?>
                        selected: Binding<HomeyKind?>(
                            get: { appState.selectedHomey },
                            set: { appState.selectedHomey = $0 ?? .charlie }
                        ),

                        onLongPress: { homey in
                            chatAssistant = homey
                        }
                    )

                    VStack(spacing: 18) { AdminRoleTabs() }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        KPI("Total Agents", value: totalAgents, tint: .blue)
                        KPI("Active Listings", value: activeListings, tint: .purple)
                            .onTapGesture { /* push listings or show sheet */ }
                        KPI("Sales (Month)", value: salesThisMonth, tint: .green)
                        KPI("Urgent Flags", value: urgentFlags, tint: .red)
                    }
                    .padding(.horizontal)

                    SectionHeader("Quick Actions")
                    CardButton(title: "Invite / Onboard Agent", system: "person.badge.plus") { showInviteCodes = true }
                    CardButton(title: "Generate Report", system: "doc.text.magnifyingglass") {}

                    SectionHeader("Recent Activity")
                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            ActivityRow(symbol: "bolt.fill", text: "Paige Turner added 3 clients")
                            Divider()
                            ActivityRow(symbol: "house", text: "Scout Finch updated a listing")
                            Divider()
                            ActivityRow(symbol: "flag.fill", text: "Drew Carter flagged a message")
                        }
                    }
                }
                .padding(.vertical, 14)
            }
            .navigationTitle("Admin Dashboard")
            .toolbar {
                AdminRoleSwitcher()
                ToolbarItem(placement: .topBarTrailing) {
                    BButton(role: .destructive) {
                        Task { await session.logout() }
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .sheet(item: $chatAssistant) { ChatView(homey: $0) }
            .sheet(isPresented: $showInviteCodes) { AdminInviteCodesView() }
        }
    }
}
