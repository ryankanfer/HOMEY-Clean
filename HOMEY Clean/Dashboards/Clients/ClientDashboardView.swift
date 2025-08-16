import SwiftUI

public struct ClientDashboardView: View {
    // Swap to your real logger type later; keep the optional so stubs are harmless.
    private let logger: JourneyLogging?
    @EnvironmentObject private var flags: FeatureFlags
    
    public init(logger: JourneyLogging? = nil) {
        self.logger = logger
    }
    
    public var body: some View {
        if flags.useLegacyClientTabs {
            LegacyClientDashboardTabs()
        } else {
            CleanClientDashboardTabs(logger: logger)
        }
    }
}

// MARK: - Clean tabs wrapper
private struct CleanClientDashboardTabs: View {
    let logger: JourneyLogging?
    var body: some View {
        TabView {
            CleanClientHome(logger: logger)
                .tabItem { Label("Home", systemImage: "house") }
        }
    }
}

/// Extracted from the previous inline ScrollView content so we can mount it in a TabView
private struct CleanClientHome: View {
    let logger: JourneyLogging?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome")
                        .font(.largeTitle).bold()
                    Text("Let's make your home journey smooth and successful.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                SectionCard(title: "Charlie", subtitle: "Education & prep") {
                    PlaceholderRow(label: "Education Center")
                    PlaceholderRow(label: "Chat with Charlie")
                }

                SectionCard(title: "Paige", subtitle: "Paperwork & tasks") {
                    PlaceholderRow(label: "Document readiness")
                    PlaceholderRow(label: "Smart upload")
                    PlaceholderRow(label: "Documents")
                }

                SectionCard(title: "Scout", subtitle: "Search & shortlists") {
                    PlaceholderRow(label: "Search homes")
                    PlaceholderRow(label: "Closing Time game")
                    PlaceholderRow(label: "View matches")
                }

                SectionCard(title: "Isla", subtitle: "Neighborhood stats") {
                    PlaceholderRow(label: "Area vs baseline metrics")
                    PlaceholderRow(label: "More insights")
                }

                SectionCard(title: "Viza", subtitle: "Design & vibes") {
                    PlaceholderRow(label: "Design inspiration")
                    PlaceholderRow(label: "Chat with Viza")
                    PlaceholderRow(label: "Upload photo")
                }

                SectionCard(title: "Drew", subtitle: "Trusted pros") {
                    PlaceholderRow(label: "Lenders")
                    PlaceholderRow(label: "Inspectors")
                    PlaceholderRow(label: "Movers")
                }
            }
            .padding()
        }
        .onAppear {
            logger?.log("Viewed Dashboard: Client", metadata: ["screen": "client"]) }
    }
}

// MARK: - Legacy tabs wrapper
private struct LegacyClientDashboardTabs: View {
    var body: some View {
        #if LEGACY_CLIENT_VIEWS
        TabView {
            // Legacy home screen
            ClientHomeView()
                .tabItem { Label("Home", systemImage: "house") }

            // Legacy live content (if you had a feed/updates surface)
            ClientLiveContent()
                .tabItem { Label("Live", systemImage: "sparkles") }
        }
        #else
        // Fallback placeholder when legacy views are not yet in the target
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Legacy client views not in target")
                .font(.headline)
            Text("Add ClientHomeView.swift and ClientLiveContent.swift to the app target or build with -D LEGACY_CLIENT_VIEWS once they’re included.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        #endif
    }
}

// MARK: - Preview

