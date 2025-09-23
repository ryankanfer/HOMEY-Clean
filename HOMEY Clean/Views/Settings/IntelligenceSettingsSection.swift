import SwiftUI

struct IntelligenceSettingsSection: View {
    @State private var trackingEnabled = true
    @State private var personalizedEnabled = true
    @State private var caps: [AppPage: Int] = [
        .homey: 3, .discover: 3, .insights: 3, .directory: 2, .vision: 2, .documents: 3
    ]
    @State private var previewSuggestions: [Suggestion] = []
    @State private var loadingPreview = false

    private let pages: [AppPage] = [.homey, .discover, .insights, .directory, .vision, .documents]

    var body: some View {
        Section(header: Text("Intelligence")) {
            // Privacy
            Toggle("Enable tracking", isOn: $trackingEnabled)
            Toggle("Personalized suggestions", isOn: $personalizedEnabled)

            // Per-surface caps
            VStack(alignment: .leading, spacing: 10) {
                Text("Per-surface caps")
                    .font(.subheadline.weight(.semibold))
                ForEach(pages, id: \.self) { page in
                    HStack {
                        Text(page.displayName)
                        Spacer()
                        Stepper(value: Binding(
                            get: { caps[page] ?? 3 },
                            set: { caps[page] = max(0, min(6, $0)) }
                        ), in: 0...6) {
                            Text("\(caps[page] ?? 3)")
                                .frame(width: 28)
                        }
                    }
                }
            }

            // Snooze controls
            HStack {
                Button("Snooze all on Discover (24h)") {
                    Task { await GovernanceCenter.shared.snoozeAll(on: .discover, for: 24 * 3600) }
                }
                Spacer()
                Button("Clear snoozes") {
                    Task { await GovernanceCenter.shared.clearSnoozes() }
                }
            }

            // Save
            Button("Save Intelligence Settings") {
                Task {
                    await GovernanceCenter.shared.setPrivacy(.init(
                        trackingEnabled: trackingEnabled,
                        personalizedSuggestionsEnabled: personalizedEnabled
                    ))
                    for (page, cap) in caps {
                        await GovernanceCenter.shared.setCap(for: page, count: cap)
                    }
                }
            }

            // Preview (local)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Preview Suggestions (Discover)")
                        .font(.subheadline.weight(.semibold))
                    if loadingPreview {
                        ProgressView().scaleEffect(0.8)
                    }
                }
                if previewSuggestions.isEmpty && !loadingPreview {
                    Text("No suggestions to preview. Try searching, saving, or uploading a doc.")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(previewSuggestions) { s in
                        HStack {
                            Image(systemName: s.icon)
                                .frame(width: 18)
                            Text(s.title)
                                .font(.caption)
                            Spacer()
                            Text(s.type.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                HStack {
                    Button("Refresh Preview") {
                        Task {
                            loadingPreview = true
                            let resp = await IntelligenceAPI.shared.suggestions(for: .discover)
                            previewSuggestions = resp.suggestions
                            loadingPreview = false
                        }
                    }
                    Spacer()
                    Button("Context Snapshot") {
                        Task {
                            _ = await IntelligenceAPI.shared.context()
                        }
                    }
                }
            }
        }
        .task {
            let privacy = await GovernanceCenter.shared.privacy
            trackingEnabled = privacy.trackingEnabled
            personalizedEnabled = privacy.personalizedSuggestionsEnabled
            // hydrate caps
            for p in pages {
                caps[p] = await GovernanceCenter.shared.cap(for: p)
            }
        }
    }
}