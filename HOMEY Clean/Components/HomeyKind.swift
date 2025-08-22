//
//  HomeyKind.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import Foundation
import SwiftUI

public enum HomeyKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case charlie, paige, scout, isla, viza, drew

    // Identifiable
    public var id: String { rawValue }

    // Display helpers
    public var displayTitle: String { rawValue.capitalized }

    public init?(fromFooterTitle t: String) {
        switch t.lowercased() {
        case "charlie": self = .charlie
        case "paige": self = .paige
        case "scout": self = .scout
        case "isla": self = .isla
        case "viza": self = .viza
        case "drew": self = .drew
        default: return nil
        }
    }
}

// MARK: - Default Homey sets (used by AvatarStrip, dashboards, etc.)

public extension HomeyKind {
    static let allHomeys: [HomeyKind] = [.charlie, .paige, .scout, .isla, .viza, .drew]
    static let adminDefault: [HomeyKind] = [.charlie, .paige, .scout, .isla, .viza, .drew]
    static let agentDefault: [HomeyKind] = [.charlie, .paige, .drew, .scout, .isla, .viza]
    static let clientDefault: [HomeyKind] = [.charlie, .scout, .paige, .isla, .viza, .drew]

    var displayName: String { displayTitle }

    /// Asset names in your catalog (edit to your actual names)
    var assetName: String {
        switch self {
        case .charlie: return "charlieAvatar"
        case .paige: return "paigeAvatar"
        case .scout: return "scoutAvatar"
        case .isla: return "islaAvatar"
        case .viza: return "vizaAvatar"
        case .drew: return "drewAvatar"
        }
    }

    /// Short blurb for the intro carousel
    var blurb: String {
        switch self {
        case .charlie: return "Your savvy deal sherpa and voice of reason."
        case .paige: return "Documents tamed. Deadlines met. Chaos avoided."
        case .scout: return "Finds listings you’ll actually want to see."
        case .isla: return "Neighborhood intel without the fluff."
        case .viza: return "Visuals, AR, and vibe checks before you tour."
        case .drew: return "Keeps your team aligned and moving."
        }
    }

    /// Role titles for each HomeyKind
    var role: String {
        switch self {
        case .charlie: return "CONCIERGE"
        case .paige: return "PAPERWORK STYLIST"
        case .scout: return "SEARCH PRO"
        case .isla: return "DESIGN STYLIST"
        case .viza: return "CONNECTOR"
        case .drew: return "TEAM LEADER"
        }
    }

    /// Emoji representation for each HomeyKind
    var emoji: String {
        switch self {
        case .charlie: return "🏠"
        case .paige: return "📋"
        case .scout: return "🔍"
        case .isla: return "🎨"
        case .viza: return "📱"
        case .drew: return "👥"
        }
    }
}
