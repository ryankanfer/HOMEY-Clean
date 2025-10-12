import Foundation

extension AppPage {
    var displayName: String {
        switch self {
        case .homey:
            return "Homey"
        case .settings:
            return "Settings"
        case .profile:
            return "Profile"
        case .notifications:
            return "Notifications"
        case .discover:
            return "Discover"
        case .insights:
            return "Insights"
        case .matchmaker:
            return "Matchmaker"
        case .documents:
            return "Documents"
        case .directory:
            return "Directory"
        case .vision:
            return "Vision"
        }
    }
}