import Foundation
import Combine

@MainActor
final class EducationCenterStore: ObservableObject {
    @Published var docs: [Doc] = []
    @Published var isLoading = false

    enum Quick { case search, upload, invite, tour, market }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // TODO: replace with your real fetch
        try? await Task.sleep(nanoseconds: 150_000_000)
        docs = [
            .init(title: "Welcome to HOMEY", subtitle: "Start here", url: nil),
            .init(title: "How co-ops work", subtitle: "Basics + board packages", url: nil),
            .init(title: "Board interview tips", subtitle: "Read this before you go", url: nil)
        ]
    }

    func open(_ doc: Doc) {
        // TODO: route to a detail screen or open URL
    }

    func quick(_ action: Quick) {
        // TODO: wire quick actions
    }
}

// Back-compat / namespaced model used across the app.
extension EducationCenterStore {
    struct Doc: Identifiable, Sendable {
        let id: UUID = .init()
        let title: String
        let subtitle: String?
        let url: URL?

        init(title: String, subtitle: String? = nil, url: URL? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.url = url
        }
    }
}
