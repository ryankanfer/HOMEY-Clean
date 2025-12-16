import SwiftUI

final class AppRouter: ObservableObject {
    private let analytics: Analytics

    @Published var route: AppRoute? {
        didSet {
            analytics.track(.routeNavigated(route: route.map { String(describing: $0) }))
        }
    }

    init(analytics: Analytics = DefaultAnalytics.shared) {
        self.analytics = analytics
    }
}