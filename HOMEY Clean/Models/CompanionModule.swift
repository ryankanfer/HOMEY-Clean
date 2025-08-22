import Foundation

public enum CompanionModule: String, CaseIterable, Hashable {
    case charlie
    case scout
    case isla
    case paige
    case drew
    case viza
}

public extension CompanionModule {
    var title: String {
        switch self {
        case .charlie: return "Charlie"
        case .scout: return "Scout"
        case .isla: return "Isla"
        case .paige: return "Paige"
        case .drew: return "Drew"
        case .viza: return "Viza"
        }
    }

    var systemIcon: String {
        switch self {
        case .charlie: return "person.crop.circle.badge.checkmark"
        case .scout: return "binoculars.fill"
        case .isla: return "chart.line.uptrend.xyaxis"
        case .paige: return "doc.text.fill"
        case .drew: return "wrench.and.screwdriver.fill"
        case .viza: return "photo.on.rectangle.angled"
        }
    }
}
