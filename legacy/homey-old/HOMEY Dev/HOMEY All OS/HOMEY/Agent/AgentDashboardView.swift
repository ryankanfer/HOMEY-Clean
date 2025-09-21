import SwiftUI

struct AgentDashboardView: View {
    @EnvironmentObject var session: SessionManager
    @State private var navPath: [Route] = []
    @State private var showSettings = false

    // Put declarations here, not inside the body closure
    enum Route: Hashable { case placeholder }

    var body: some View {
        ZStack {
            GlassKit.Background() // full-screen backdrop

            NavigationStack(path: $navPath) {
                ScrollView {
                    VStack(spacing: 16) {
                        HeroHeader(
                            name: "Agent",
                            subtitle: "Your pipeline, tasks, and client updates."
                        )

                        // Use the namespaced card
                        GlassKit.Card { Text("Today’s Tasks").frame(maxWidth: .infinity, alignment: .leading) }
                        GlassKit.Card { Text("Active Clients").frame(maxWidth: .infinity, alignment: .leading) }
                        GlassKit.Card { Text("Upcoming Tours").frame(maxWidth: .infinity, alignment: .leading) }

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showSettings = true } label: { Image(systemName: "gearshape") }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }
}
