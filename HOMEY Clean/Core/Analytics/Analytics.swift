import Foundation

public protocol Analytics {
    func track(_ event: AnalyticsEvent)
}

public enum AnalyticsEvent: Sendable {
    case routeNavigated(route: String?)
    case homepageCustomized(action: String?, layoutId: String?)
    case lessonStarted(id: String, title: String?)
    case documentUploaded(id: String, mimeType: String?, sizeBytes: Int?)
    case drawerOpened(snap: String, source: String?)
}

public extension AnalyticsEvent {
    var name: String {
        switch self {
        case .routeNavigated: return "RouteNavigated"
        case .homepageCustomized: return "HomepageCustomized"
        case .lessonStarted: return "LessonStarted"
        case .documentUploaded: return "DocumentUploaded"
        case .drawerOpened: return "DrawerOpened"
        }
    }

    var parameters: [String: String] {
        switch self {
        case let .routeNavigated(route):
            return [
                "route": route ?? "nil"
            ]
        case let .homepageCustomized(action, layoutId):
            return [
                "action": action ?? "nil",
                "layoutId": layoutId ?? "nil"
            ]
        case let .lessonStarted(id, title):
            return [
                "lessonId": id,
                "title": title ?? "nil"
            ]
        case let .documentUploaded(id, mimeType, sizeBytes):
            var params: [String: String] = ["documentId": id]
            if let mimeType { params["mimeType"] = mimeType }
            if let sizeBytes { params["sizeBytes"] = String(sizeBytes) }
            return params
        case let .drawerOpened(snap, source):
            return [
                "snap": snap,
                "source": source ?? "unknown"
            ]
        }
    }
}