import SwiftUI

enum HomeyKind: String, CaseIterable, Identifiable {
    case charlie, paige, scout, isla, viza, drew

    var id: String { rawValue }
    var displayTitle: String { rawValue.capitalized }

    /// Placeholder image for each homey.
    var image: Image {
        switch self {
        case .charlie: return Image(systemName: "person.circle")
        case .paige:   return Image(systemName: "person.circle.fill")
        case .scout:   return Image(systemName: "person.2.circle")
        case .isla:    return Image(systemName: "person.2.circle.fill")
        case .viza:    return Image(systemName: "person.crop.square")
        case .drew:    return Image(systemName: "person.crop.square.fill")
        }
    }
}

extension HomeyKind {
    static let allHomeys: [HomeyKind] = [.charlie, .paige, .scout, .isla, .viza, .drew]
}
