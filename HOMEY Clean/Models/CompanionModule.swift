import Foundation

public enum CompanionModule: String, CaseIterable, Hashable {
    case charlie
    case scout
    case paige
    case drew
}

public extension CompanionModule {
    var title: String {
        switch self {
        case .charlie: return "Charlie"
        case .scout: return "Scout"
        case .paige: return "Paige"
        case .drew: return "Drew"
        }
    }

    var systemIcon: String {
        switch self {
        case .charlie: return "person.crop.circle.badge.checkmark"
        case .scout: return "binoculars.fill"
        case .paige: return "doc.text.fill"
        case .drew: return "wrench.and.screwdriver.fill"
        }
    }
}
