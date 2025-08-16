import SwiftUI

public struct ScoutDashboardView: View {
    public init() {}
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Scout").font(.title2.bold())
                Text("Search & shortlists").foregroundStyle(.secondary)
                // Drop legacy Scout UI here
                Label("Search homes", systemImage: "magnifyingglass")
                Label("Closing Time game", systemImage: "gamecontroller.fill")
                Label("View matches", systemImage: "list.bullet")
            }
            .padding()
        }
    }
}