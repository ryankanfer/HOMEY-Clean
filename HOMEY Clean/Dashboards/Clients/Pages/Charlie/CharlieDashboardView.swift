import SwiftUI

public struct CharlieDashboardView: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var showOnboarding = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Charlie").font(.title2.bold())
                Text("Concierge & onboarding").foregroundStyle(.secondary)

                // Replace this with legacy Charlie UI later
                Group {
                    Label("Education Center", systemImage: "book.closed.fill")
                    Label("Chat with Charlie", systemImage: "message.fill")
                }
                .font(.callout)

                Button("Start Onboarding") { showOnboarding = true }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .sheet(isPresented: $showOnboarding) {
            CharlieOnboardingView {
                // Optional: mark seen, refresh, etc.
            }
            .environmentObject(session)
        }
    }
}