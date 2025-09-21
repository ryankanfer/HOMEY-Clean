import Foundation
import SwiftUI

// MARK: - Lens Model

struct Lens: Identifiable, Codable, Hashable {
    let id: UUID
    let type: LensType
    let name: String
    let icon: String
    let isActive: Bool
    let weight: Double // For overlay composition
    let filterCriteria: FilterCriteria?

    init(type: LensType, isActive: Bool = false, weight: Double = 1.0) {
        id = UUID()
        self.type = type
        name = type.displayName
        icon = type.icon
        self.isActive = isActive
        self.weight = weight
        filterCriteria = type.defaultCriteria
    }
}

// MARK: - Lens Types

enum LensType: String, Codable, CaseIterable {
    case price
    case bedrooms
    case bathrooms
    case petFriendly = "pet_friendly"
    case elevator
    case doorman
    case washerDryer = "washer_dryer"
    case outdoor
    case newToMarket = "new_to_market"
    case openHouse = "open_house"
    case sunHours = "sun_hours"
    case schools
    case transit
    case vibe
    case noise

    var displayName: String {
        switch self {
        case .price: return "Price"
        case .bedrooms: return "Bedrooms"
        case .bathrooms: return "Bathrooms"
        case .petFriendly: return "Pet Friendly"
        case .elevator: return "Elevator"
        case .doorman: return "Doorman"
        case .washerDryer: return "Washer/Dryer"
        case .outdoor: return "Outdoor"
        case .newToMarket: return "New to Market"
        case .openHouse: return "Open House"
        case .sunHours: return "Sun Hours"
        case .schools: return "Schools"
        case .transit: return "Transit"
        case .vibe: return "Vibe"
        case .noise: return "Noise"
        }
    }

    var icon: String {
        switch self {
        case .price: return "dollarsign.circle.fill"
        case .bedrooms: return "bed.double.fill"
        case .bathrooms: return "bathtub.fill"
        case .petFriendly: return "pawprint.fill"
        case .elevator: return "arrow.up.arrow.down"
        case .doorman: return "person.fill"
        case .washerDryer: return "washer.fill"
        case .outdoor: return "leaf.fill"
        case .newToMarket: return "sparkles"
        case .openHouse: return "house.fill"
        case .sunHours: return "sun.max.fill"
        case .schools: return "graduationcap.fill"
        case .transit: return "tram.fill"
        case .vibe: return "waveform"
        case .noise: return "speaker.wave.3.fill"
        }
    }

    var color: Color {
        switch self {
        case .price: return .green
        case .bedrooms, .bathrooms: return .blue
        case .petFriendly: return .orange
        case .elevator, .doorman, .washerDryer: return .purple
        case .outdoor: return .mint
        case .newToMarket: return .yellow
        case .openHouse: return .red
        case .sunHours: return .orange
        case .schools: return .indigo
        case .transit: return .cyan
        case .vibe: return .pink
        case .noise: return .gray
        }
    }

    var defaultCriteria: FilterCriteria? {
        switch self {
        case .price:
            return .priceRange(min: 0, max: 10000)
        case .bedrooms:
            return .bedroomCount(min: 1, max: 4)
        case .bathrooms:
            return .bathroomCount(min: 1.0, max: 3.0)
        case .sunHours:
            return .sunHours(min: 4)
        case .schools:
            return .schoolRating(min: 7.0)
        case .transit:
            return .transitScore(min: 70)
        default:
            return .boolean(true)
        }
    }

    var hasOverlay: Bool {
        switch self {
        case .schools, .transit, .vibe, .sunHours:
            return true
        default:
            return false
        }
    }
}

// MARK: - Filter Criteria

enum FilterCriteria: Codable, Hashable {
    case priceRange(min: Int, max: Int)
    case bedroomCount(min: Int, max: Int)
    case bathroomCount(min: Double, max: Double)
    case sunHours(min: Int)
    case schoolRating(min: Double)
    case transitScore(min: Int)
    case boolean(Bool)

    func matches(listing: Listing) -> Bool {
        switch self {
        case let .priceRange(min, max):
            return listing.price >= min && listing.price <= max
        case let .bedroomCount(min, max):
            return listing.bedrooms >= min && listing.bedrooms <= max
        case let .bathroomCount(min, max):
            return listing.bathrooms >= min && listing.bathrooms <= max
        case let .sunHours(min):
            return (listing.sunHours ?? 0) >= min
        case let .schoolRating(min):
            return (listing.schoolRating ?? 0) >= min
        case let .transitScore(min):
            return (listing.transitScore ?? 0) >= min
        case let .boolean(required):
            return required // For feature-based filters, handled elsewhere
        }
    }
}

// MARK: - Lens Size

enum LensSize: String, CaseIterable {
    case small = "S"
    case medium = "M"
    case large = "L"

    var radius: CGFloat {
        switch self {
        case .small: return 80
        case .medium: return 120
        case .large: return 160
        }
    }

    var maskImageName: String {
        switch self {
        case .small: return "lens_mask_s"
        case .medium: return "lens_mask_m"
        case .large: return "lens_mask_l"
        }
    }
}

// MARK: - Sample Data

extension Lens {
    static let defaultLenses: [Lens] = [
        Lens(type: .price),
        Lens(type: .bedrooms),
        Lens(type: .bathrooms),
        Lens(type: .petFriendly),
        Lens(type: .elevator),
        Lens(type: .doorman),
        Lens(type: .washerDryer),
        Lens(type: .outdoor),
        Lens(type: .newToMarket),
        Lens(type: .openHouse),
        Lens(type: .sunHours),
        Lens(type: .schools),
        Lens(type: .transit),
        Lens(type: .vibe),
        Lens(type: .noise)
    ]

    static let quickFilters: [Lens] = [
        Lens(type: .price, isActive: true),
        Lens(type: .bedrooms, isActive: true),
        Lens(type: .bathrooms, isActive: true),
        Lens(type: .petFriendly)
    ]
}
