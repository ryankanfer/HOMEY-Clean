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
                .foregroundStyle(Theme.dynamicPrimary())

            VStack(alignment: .leading, spacing: 6) {
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundStyle(Theme.dynamicText())

                Text(suggestion.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.dynamicTextSecondary())

                Button(suggestion.actionText) {
                    onTap?()
                }
                .font(.callout.weight(.semibold))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Theme.dynamicPrimary().opacity(0.1))
                .clipShape(Capsule())
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Theme.dynamicSurface(), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.dynamicPrimary().opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Theme.dynamicPrimary().opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

public struct SuggestionListView: View {
    public let page: AppPage?
    @State private var items: [Suggestion] = []
    @State private var isLoading = true

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
            items = await SuggestionEngine.shared.suggestions(for: page)
            isLoading = false
        }
    }
}

public struct SuggestionInlinePlacement: View {
    public let page: AppPage?
    @State private var items: [Suggestion] = []

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
            items = await SuggestionEngine.shared.suggestions(for: page)
        }
    }
}