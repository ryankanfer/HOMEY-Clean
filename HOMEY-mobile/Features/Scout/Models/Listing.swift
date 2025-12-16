import Foundation
import SwiftUI

// MARK: - Listing Model

struct Listing: Identifiable, Codable, Hashable {
    let id: UUID
    let address: String
    let neighborhood: String
    let price: Int
    let bedrooms: Int
    let bathrooms: Double
    let squareFootage: Int?
    let listingType: ListingType
    let coordinates: Coordinates
    let imageURLs: [String]
    let thumbnailURL: String
    let features: [ListingFeature]
    let monthlyFees: MonthlyFees?
    let sunHours: Int?
    let noiseLevel: NoiseLevel?
    let walkScore: Int?
    let transitScore: Int?
    let schoolRating: Double?
    let isNewToMarket: Bool
    let hasOpenHouse: Bool
    let isFeatured: Bool
    let listingDate: Date
    let lastUpdated: Date

    // Computed properties
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }

    var bedroomBathroomText: String {
        let bedText = bedrooms == 1 ? "1 bed" : "\(bedrooms) beds"
        let bathText = bathrooms == 1.0 ? "1 bath" : "\(bathrooms) baths"
        return "\(bedText) • \(bathText)"
    }

    var monthlyTotal: Int? {
        guard let fees = monthlyFees else { return nil }
        return fees.hoa + fees.maintenance + fees.taxes + fees.insurance
    }
}

// MARK: - Supporting Types

enum ListingType: String, Codable, CaseIterable {
    case sale
    case rental

    var displayName: String {
        switch self {
        case .sale: return "For Sale"
        case .rental: return "For Rent"
        }
    }
}

struct Coordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

enum ListingFeature: String, Codable, CaseIterable {
    case petFriendly = "pet_friendly"
    case elevator
    case doorman
    case washerDryer = "washer_dryer"
    case outdoor
    case parking
    case gym
    case rooftop
    case storage
    case dishwasher
    case inUnitLaundry = "in_unit_laundry"
    case patio
    case pool
    case rooftopAccess = "rooftop_access"

    var displayName: String {
        switch self {
        case .petFriendly: return "Pet Friendly"
        case .elevator: return "Elevator"
        case .doorman: return "Doorman"
        case .washerDryer: return "Washer/Dryer"
        case .outdoor: return "Outdoor Space"
        case .parking: return "Parking"
        case .gym: return "Gym"
        case .rooftop: return "Rooftop"
        case .storage: return "Storage"
        case .dishwasher: return "Dishwasher"
        case .inUnitLaundry: return "In-Unit Laundry"
        case .patio: return "Patio"
        case .pool: return "Pool"
        case .rooftopAccess: return "Rooftop Access"
        }
    }

    var icon: String {
        switch self {
        case .petFriendly: return "pawprint.fill"
        case .elevator: return "arrow.up.arrow.down"
        case .doorman: return "person.fill"
        case .washerDryer: return "washer.fill"
        case .outdoor: return "leaf.fill"
        case .parking: return "car.fill"
        case .gym: return "dumbbell.fill"
        case .rooftop: return "building.2.fill"
        case .storage: return "archivebox.fill"
        case .dishwasher: return "dishwasher.fill"
        case .inUnitLaundry: return "washer.fill"
        case .patio: return "leaf.circle.fill"
        case .pool: return "drop.fill"
        case .rooftopAccess: return "stairs"
        }
    }
}

struct MonthlyFees: Codable, Hashable {
    let hoa: Int
    let maintenance: Int
    let taxes: Int
    let insurance: Int

    var total: Int {
        return hoa + maintenance + taxes + insurance
    }
}

enum NoiseLevel: String, Codable, CaseIterable {
    case quiet
    case moderate
    case busy

    var displayName: String {
        switch self {
        case .quiet: return "Quiet"
        case .moderate: return "Moderate"
        case .busy: return "Busy"
        }
    }

    var color: Color {
        switch self {
        case .quiet: return .green
        case .moderate: return .orange
        case .busy: return .red
        }
    }
}

// MARK: - Sample Data

extension Listing {
    static let sampleListings: [Listing] = [
        Listing(
            id: UUID(),
            address: "245 E 25th St",
            neighborhood: "Flatiron",
            price: 5200,
            bedrooms: 2,
            bathrooms: 2.0,
            squareFootage: 1200,
            listingType: .rental,
            coordinates: Coordinates(latitude: 40.7398, longitude: -73.9857),
            imageURLs: ["listing1_1.jpg", "listing1_2.jpg"],
            thumbnailURL: "listing1_thumb.jpg",
            features: [.elevator, .washerDryer, .doorman],
            monthlyFees: MonthlyFees(hoa: 0, maintenance: 200, taxes: 150, insurance: 50),
            sunHours: 6,
            noiseLevel: .moderate,
            walkScore: 95,
            transitScore: 88,
            schoolRating: 8.5,
            isNewToMarket: true,
            hasOpenHouse: false,
            isFeatured: true,
            listingDate: Date().addingTimeInterval(-86400 * 3),
            lastUpdated: Date()
        ),
        Listing(
            id: UUID(),
            address: "123 W 14th St",
            neighborhood: "West Village",
            price: 4800,
            bedrooms: 1,
            bathrooms: 1.0,
            squareFootage: 800,
            listingType: .rental,
            coordinates: Coordinates(latitude: 40.7370, longitude: -74.0037),
            imageURLs: ["listing2_1.jpg", "listing2_2.jpg"],
            thumbnailURL: "listing2_thumb.jpg",
            features: [.petFriendly, .outdoor, .dishwasher],
            monthlyFees: nil,
            sunHours: 4,
            noiseLevel: .quiet,
            walkScore: 92,
            transitScore: 75,
            schoolRating: 9.0,
            isNewToMarket: false,
            hasOpenHouse: true,
            isFeatured: false,
            listingDate: Date().addingTimeInterval(-86400 * 14),
            lastUpdated: Date().addingTimeInterval(-86400)
        )
    ]
}
