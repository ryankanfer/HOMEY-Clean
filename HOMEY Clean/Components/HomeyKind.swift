import Foundation

// Top-level enum (not inside an extension)
enum HomeyKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case charlie, paige, scout, isla, viza, drew

    var id: String { rawValue }
    var displayTitle: String { rawValue.capitalized }

    init?(fromFooterTitle t: String) {
        switch t.lowercased() {
        case "charlie": self = .charlie
        case "paige":   self = .paige
        case "scout":   self = .scout
        case "isla":    self = .isla
        case "viza":    self = .viza
        case "drew":    self = .drew
        default:        return nil
        }
    }
}

// MARK: - Default Homey sets (used by AvatarStrip, dashboards, etc.)
extension HomeyKind {
    static let allHomeys: [HomeyKind]  = [.charlie, .paige, .scout, .isla, .viza, .drew]
    static let adminDefault: [HomeyKind]  = [.charlie, .paige, .scout, .isla, .viza, .drew]
    static let agentDefault: [HomeyKind]  = [.charlie, .paige, .drew, .scout, .isla, .viza]
    static let clientDefault: [HomeyKind] = [.charlie, .scout, .paige, .isla, .viza, .drew]
    
    var displayName: String { displayTitle }
    
    /// Asset names in your catalog (edit to your actual names)
       var assetName: String {
           switch self {
           case .charlie: return "charlieAvatar"
           case .paige:   return "paigeAvatar"
           case .scout:   return "scoutAvatar"
           case .isla:    return "islaAvatar"
           case .viza:    return "vizaAvatar"
           case .drew:    return "drewAvatar"
           }
       }

       /// Short blurb for the intro carousel
       var blurb: String {
           switch self {
           case .charlie: return "Your savvy deal sherpa and voice of reason."
           case .paige:   return "Documents tamed. Deadlines met. Chaos avoided."
           case .scout:   return "Finds listings you’ll actually want to see."
           case .isla:    return "Neighborhood intel without the fluff."
           case .viza:    return "Visuals, AR, and vibe checks before you tour."
           case .drew:    return "Keeps your team aligned and moving."
           }
       }
   }
