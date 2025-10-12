import SwiftUI

public struct SuggestionCardView: View {
    let suggestion: Suggestion
    public var onTap: (() -> Void)?

    public init(suggestion: Suggestion, onTap: (() -> Void)? = nil) {
        self.suggestion = suggestion
        self.onTap = onTap
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: suggestion.icon)
                .font(.title3)
                .foregroundStyle(Theme.primaryAction)

            VStack(alignment: .leading, spacing: 6) {
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)

                Text(suggestion.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)

                HStack(spacing: 10) {
                    Button(suggestion.actionText) {
                        onTap?()
                        Task {
                            await MetricsTracker.shared.trackSuggestionClick(suggestion)
                            let uid = await InteractionLogger.shared.currentUserId()
                            let sid = await InteractionLogger.shared.makeSessionId()
                            await InteractionLogger.shared.log(
                                InteractionEvent(
                                    type: .custom,
                                    page: suggestion.page,
                                    userId: uid,
                                    sessionId: sid,
                                    metadata: [
                                        "event": .init("suggestion_tapped"),
                                        "suggestion_id": .init(suggestion.id.uuidString),
                                        "type": .init(suggestion.type.rawValue),
                                        "title": .init(suggestion.title)
                                    ]
                                )
                            )
                        }
                    }
                    .font(.callout.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Theme.primaryAction.opacity(0.1))
                    .clipShape(Capsule())

                    Menu {
                        Button("Snooze this type for 1 day") {
                            Task { await GovernanceCenter.shared.snooze(type: suggestion.type, for: 24 * 3600) }
                        }
                        Button("Snooze this type for 1 week") {
                            Task { await GovernanceCenter.shared.snooze(type: suggestion.type, for: 7 * 24 * 3600) }
                        }
                        if let p = suggestion.page {
                            Button("Snooze all on this page today") {
                                Task { await GovernanceCenter.shared.snoozeAll(on: p, for: 24 * 3600) }
                            }
                        }
                        Button("Clear snoozes") {
                            Task { await GovernanceCenter.shared.clearSnoozes() }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.callout.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.primaryAction.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Theme.primaryAction.opacity(0.1), radius: 6, x: 0, y: 3)
        .onAppear {
            Task { await MetricsTracker.shared.trackSuggestionImpression(suggestion) }
        }
    }
}

public struct SuggestionListView: View {
    public let page: AppPage?
    @State private var items: [Suggestion] = []
    @State private var isLoading = true
    @Environment(\.suggestionEngine) private var suggestionEngine

    public init(page: AppPage?) {
        self.page = page
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !items.isEmpty {
                ForEach(items) { s in
                    SuggestionCardView(suggestion: s)
                }
            }
        }
        .task {
            isLoading = true
            items = await suggestionEngine.suggestions(for: page)
            isLoading = false
        }
    }
}

public struct SuggestionInlinePlacement: View {
    public let page: AppPage?
    @State private var items: [Suggestion] = []
    @Environment(\.suggestionEngine) private var suggestionEngine

    public init(page: AppPage?) {
        self.page = page
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !items.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items) { s in
                            SuggestionCardView(suggestion: s)
                                .frame(width: 280)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .task {
            items = await suggestionEngine.suggestions(for: page)
        }
        .onAppear {
            Task {
                if let page { await MetricsTracker.shared.trackPageAdoption(page) }
            }
        }
    }
}