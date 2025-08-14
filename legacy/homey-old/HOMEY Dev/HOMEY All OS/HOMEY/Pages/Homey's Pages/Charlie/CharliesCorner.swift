import SwiftUI

struct CharliesCorner: View {
    @EnvironmentObject private var edu: EducationCenterStore

    var openChat: () -> Void
    var stations: [String] = []
    var currentIndex: Int = 0
    var openEducation: () -> Void = {}

    var sections: [EducationCenterSectionView] = []
    var onSectionTap: (EducationCenterSectionView) -> Void = { _ in }

    private var clampedIndex: Int {
        guard !stations.isEmpty else { return 0 }
        return min(max(0, currentIndex), stations.count - 1)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Charlie’s Corner")
                    .font(.title.bold())
                    .padding(.horizontal, 12)

                if !stations.isEmpty {
                    SubwayProgressView(stations: stations, currentIndex: clampedIndex)
                        .padding(.horizontal, 12)
                }

                if !sections.isEmpty {
                    CCGlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Education Center", systemImage: "book.fill")
                                .font(.headline)
                            Text("Short lessons, real approvals. No fluff.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            EducationCenterSectionList(sections: sections, tap: onSectionTap)
                        }
                    }
                    .padding(.horizontal, 12)
                } else {
                    CCGlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Education Center", systemImage: "book.fill")
                                .font(.headline)
                            Text("Short lessons, real approvals. No fluff.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Browse Modules") { openEducation() }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.horizontal, 12)
                }

                CCGlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Chat with Charlie", systemImage: "message.fill")
                            .font(.headline)
                        Text("Got a board interview? Bring your chaos. We’ll tidy it up.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Open Chat") { openChat() }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 16)
        }
    }
}

// Rename to avoid colliding with your existing GlassCard
struct CCGlassCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
    }
}
