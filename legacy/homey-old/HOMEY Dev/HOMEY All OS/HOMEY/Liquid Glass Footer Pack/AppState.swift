import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var selectedHomey: HomeyKind = .charlie
    @Published var askHomey: HomeyKind? = nil

    @Published var pendingURL: String? = nil
    @Published var intentGoToMatches: Bool = false
    @Published var intentOpenListingId: UUID? = nil
    @Published var pendingInbox: Bool = false

    init() {}
}
