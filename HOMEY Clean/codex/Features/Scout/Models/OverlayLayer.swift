import Foundation
import SwiftUI

// MARK: - Overlay Layer Model

struct OverlayLayer: Identifiable, Codable, Hashable {
    let id: UUID
    let type: OverlayType
    let name: String
    let imageName: String
    let alpha: Double
    let blendMode: BlendMode
    let isVisible: Bool
    let weight: Double // For composition priority
    let animationDuration: Double?

    init(type: OverlayType, alpha: Double = 0.7, isVisible: Bool = false, weight: Double = 1.0) {
        id = UUID()
        self.type = type
        name = type.displayName
        imageName = type.imageName
        self.alpha = alpha
        blendMode = type.defaultBlendMode
        self.isVisible = isVisible
        self.weight = weight
        animationDuration = type.animationDuration
    }
}

// MARK: - Overlay Types

enum OverlayType: String, Codable, CaseIterable {
    case schools
    case transit
    case vibe
    case sunPathDay = "sun_path_day"
    case sunPathDusk = "sun_path_dusk"
    case noise
    case walkability
    case safety
    case nightlife
    case restaurants

    var displayName: String {
        switch self {
        case .schools: return "Schools"
        case .transit: return "Transit"
        case .vibe: return "Neighborhood Vibe"
        case .sunPathDay: return "Sun Path (Day)"
        case .sunPathDusk: return "Sun Path (Dusk)"
        case .noise: return "Noise Levels"
        case .walkability: return "Walkability"
        case .safety: return "Safety"
        case .nightlife: return "Nightlife"
        case .restaurants: return "Restaurants"
        }
    }

    var imageName: String {
        switch self {
        case .schools: return "schools_overlay"
        case .transit: return "transit_overlay"
        case .vibe: return "vibe_overlay"
        case .sunPathDay: return "sun_path_day"
        case .sunPathDusk: return "sun_path_dusk"
        case .noise: return "noise_grain"
        case .walkability: return "walkability_overlay"
        case .safety: return "safety_overlay"
        case .nightlife: return "nightlife_overlay"
        case .restaurants: return "restaurants_overlay"
        }
    }

    var defaultBlendMode: BlendMode {
        switch self {
        case .schools, .transit, .restaurants: return .multiply
        case .vibe, .nightlife: return .overlay
        case .sunPathDay, .sunPathDusk: return .softLight
        case .noise: return .multiply
        case .walkability, .safety: return .normal
        }
    }

    var color: Color {
        switch self {
        case .schools: return .blue
        case .transit: return .green
        case .vibe: return .purple
        case .sunPathDay: return .orange
        case .sunPathDusk: return .indigo
        case .noise: return .red
        case .walkability: return .mint
        case .safety: return .cyan
        case .nightlife: return .pink
        case .restaurants: return .yellow
        }
    }

    var icon: String {
        switch self {
        case .schools: return "graduationcap.fill"
        case .transit: return "tram.fill"
        case .vibe: return "waveform"
        case .sunPathDay: return "sun.max.fill"
        case .sunPathDusk: return "moon.fill"
        case .noise: return "speaker.wave.3.fill"
        case .walkability: return "figure.walk"
        case .safety: return "shield.fill"
        case .nightlife: return "music.note"
        case .restaurants: return "fork.knife"
        }
    }

    var animationDuration: Double? {
        switch self {
        case .sunPathDay, .sunPathDusk: return 2.0
        case .vibe, .nightlife: return 1.5
        default: return nil
        }
    }

    var priority: Int {
        switch self {
        case .sunPathDay, .sunPathDusk: return 1 // Lowest priority (rendered first)
        case .noise: return 2
        case .vibe, .walkability, .safety: return 3
        case .schools, .transit, .restaurants, .nightlife: return 4 // Highest priority (rendered last)
        }
    }
}

// MARK: - Blend Mode

enum BlendMode: String, Codable, CaseIterable {
    case normal
    case multiply
    case overlay
    case softLight = "soft_light"
    case hardLight = "hard_light"
    case screen
    case colorDodge = "color_dodge"
    case colorBurn = "color_burn"

    var swiftUIBlendMode: SwiftUI.BlendMode {
        switch self {
        case .normal: return .normal
        case .multiply: return .multiply
        case .overlay: return .overlay
        case .softLight: return .softLight
        case .hardLight: return .hardLight
        case .screen: return .screen
        case .colorDodge: return .colorDodge
        case .colorBurn: return .colorBurn
        }
    }
}

// MARK: - Overlay Composition

struct OverlayComposition {
    let layers: [OverlayLayer]
    let totalAlpha: Double
    let renderOrder: [OverlayLayer]

    init(layers: [OverlayLayer]) {
        self.layers = layers.filter { $0.isVisible }
        totalAlpha = min(1.0, self.layers.reduce(0) { $0 + ($1.alpha * $1.weight) })
        renderOrder = self.layers.sorted { $0.type.priority < $1.type.priority }
    }

    var isEmpty: Bool {
        return layers.isEmpty
    }

    var activeLayerCount: Int {
        return layers.count
    }
}

// MARK: - Time of Day

enum TimeOfDay: String, CaseIterable {
    case day
    case dusk

    var displayName: String {
        switch self {
        case .day: return "Day"
        case .dusk: return "Dusk"
        }
    }

    var panoramaImageName: String {
        switch self {
        case .day: return "city_pano_day"
        case .dusk: return "city_pano_dusk"
        }
    }

    var sunPathOverlay: OverlayType {
        switch self {
        case .day: return .sunPathDay
        case .dusk: return .sunPathDusk
        }
    }

    var ambientColor: Color {
        switch self {
        case .day: return Color.white.opacity(0.1)
        case .dusk: return Color.blue.opacity(0.2)
        }
    }
}

// MARK: - Sample Data

extension OverlayLayer {
    static let defaultOverlays: [OverlayLayer] = [
        OverlayLayer(type: .schools, alpha: 0.6),
        OverlayLayer(type: .transit, alpha: 0.7),
        OverlayLayer(type: .vibe, alpha: 0.5),
        OverlayLayer(type: .sunPathDay, alpha: 0.4),
        OverlayLayer(type: .sunPathDusk, alpha: 0.4),
        OverlayLayer(type: .noise, alpha: 0.3),
        OverlayLayer(type: .walkability, alpha: 0.6),
        OverlayLayer(type: .safety, alpha: 0.5),
        OverlayLayer(type: .nightlife, alpha: 0.6),
        OverlayLayer(type: .restaurants, alpha: 0.7)
    ]

    static func overlaysForTimeOfDay(_ timeOfDay: TimeOfDay) -> [OverlayLayer] {
        var overlays = defaultOverlays.filter {
            $0.type != .sunPathDay && $0.type != .sunPathDusk
        }
        overlays.append(OverlayLayer(type: timeOfDay.sunPathOverlay, alpha: 0.4))
        return overlays
    }
}
