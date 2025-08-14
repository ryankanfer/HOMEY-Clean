import SwiftUI

public struct ClientDashboardView: View {
    // Swap to your real logger type later; keep the optional so stubs are harmless.
    private let logger: JourneyLogging?
    
    public init(logger: JourneyLogging? = nil) {
        self.logger = logger
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // TODO: Add GradientBackground when available
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome")
                        .font(.largeTitle).bold()
                    Text("Let\u2019s make your home journey smooth and successful.")
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
            logger?.log("Viewed Dashboard: Client", metadata: ["screen": "client"])
        }
    }
}

// MARK: - Helpers

private struct SectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.title3).bold()
                    Text(subtitle).font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
            }
            content
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct PlaceholderRow: View {
    let label: String
    var body: some View {
        HStack {
            Circle().frame(width: 10, height: 10)
            Text(label)
            Spacer()
            Text("—").foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    ClientDashboardView(logger: NoopJourneyLogger())
}
