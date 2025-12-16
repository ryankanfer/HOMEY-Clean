import Foundation
import SwiftUI
import CoreLocation

struct PropertyListing: Identifiable, Hashable, Codable {
    let id: String
    let address: String
    let neighborhood: String
    let price: Double
    let bedrooms: Int
    let bathrooms: Double
    let squareFootage: Int?
    let propertyType: PropertyType
    let amenities: [String]
    let images: [String]
    let thumbnailURL: String
    let coordinates: PropertyCoordinate
    let listingDate: Date
    let description: String
    let contactInfo: ContactInfo
    var isSaved: Bool = false
    let availableDate: Date?
    let isNewListing: Bool
    
    var imageURLs: [String] {
        return images
    }
    
    // MARK: - Computed Properties
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$0"
    }
    
    var pricePerSqFt: Double? {
        guard let sqft = squareFootage, sqft > 0 else { return nil }
        return price / Double(sqft)
    }
    
    var formattedPricePerSqFt: String? {
        guard let pricePerSqFt = pricePerSqFt else { return nil }
        return String(format: "$%.0f/sqft", pricePerSqFt)
    }
    
    var bedroomText: String {
        switch bedrooms {
        case 0: return "Studio"
        case 1: return "1 Bed"
        default: return "\(bedrooms) Beds"
        }
    }
    
    var bathroomText: String {
        if bathrooms == floor(bathrooms) {
            return "\(Int(bathrooms)) Bath\(bathrooms == 1 ? "" : "s")"
        } else {
            return "\(bathrooms) Baths"
        }
    }
    
    var primaryImage: String {
        return images.first ?? "placeholder_property"
    }
    
    var imageURL: String? {
        return images.first
    }
    
    // MARK: - Filter Matching
    
    func matchesFilter(_ filter: ScoutFilter) -> Bool {
        switch filter {
        case .price:
            // For now, assume any price is valid - in real app, would check against user's price range
            return true
        case .beds:
            return bedrooms > 0
        case .pets:
            return amenities.contains { $0.lowercased().contains("pet") }
        case .doorman:
            return amenities.contains { $0.lowercased().contains("doorman") || $0.lowercased().contains("concierge") }
        case .amenities:
            return !amenities.isEmpty
        case .parking:
            return amenities.contains { $0.lowercased().contains("parking") || $0.lowercased().contains("garage") }
        case .laundry:
            return amenities.contains { $0.lowercased().contains("laundry") || $0.lowercased().contains("washer") }
        case .outdoor:
            return amenities.contains { amenity in
                let lower = amenity.lowercased()
                return lower.contains("balcony") || lower.contains("terrace") || lower.contains("patio") || lower.contains("garden")
            }
        }
    }
    
    // MARK: - Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PropertyListing, rhs: PropertyListing) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Supporting Types

enum PropertyType: String, CaseIterable, Codable {
    case apartment = "apartment"
    case condo = "condo"
    case townhouse = "townhouse"
    case house = "house"
    case studio = "studio"
    case loft = "loft"
    
    var displayName: String {
        switch self {
        case .apartment: return "Apartment"
        case .condo: return "Condo"
        case .townhouse: return "Townhouse"
        case .house: return "House"
        case .studio: return "Studio"
        case .loft: return "Loft"
        }
    }
}

struct ContactInfo: Codable {
    let agentName: String
    let agentPhone: String
    let agentEmail: String
    let brokerageName: String
    let brokeragePhone: String?
}

struct PropertyCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Sample Data

extension PropertyListing {
    static let sampleListings: [PropertyListing] = [
        PropertyListing(
            id: "1",
            address: "123 Broadway, Apt 4B",
            neighborhood: "Flatiron",
            price: 4500,
            bedrooms: 1,
            bathrooms: 1.0,
            squareFootage: 650,
            propertyType: .apartment,
            amenities: ["Doorman", "Gym", "Rooftop", "Pet Friendly", "Laundry"],
            images: ["property_1", "property_1_2", "property_1_3"],
            thumbnailURL: "property_1",
            coordinates: PropertyCoordinate(latitude: 40.7410, longitude: -73.9896),
            listingDate: Date().addingTimeInterval(-86400 * 3),
            description: "Stunning one-bedroom apartment in the heart of Flatiron with floor-to-ceiling windows and modern finishes. " +
                        "This bright and airy unit features hardwood floors, stainless steel appliances, and an in-unit washer/dryer.",
            contactInfo: ContactInfo(
                agentName: "Sarah Johnson",
                agentPhone: "(555) 123-4567",
                agentEmail: "sarah@realestate.com",
                brokerageName: "Manhattan Realty Group",
                brokeragePhone: "(555) 123-4500"
            ),
            availableDate: Date().addingTimeInterval(86400 * 7),
            isNewListing: true
        ),
        PropertyListing(
            id: "2",
            address: "456 Park Avenue, Unit 12A",
            neighborhood: "Midtown East",
            price: 6800,
            bedrooms: 2,
            bathrooms: 2.0,
            squareFootage: 950,
            propertyType: .condo,
            amenities: ["Concierge", "Pool", "Parking", "Balcony", "Gym"],
            images: ["property_2", "property_2_2"],
            thumbnailURL: "property_2",
            coordinates: PropertyCoordinate(latitude: 40.7549, longitude: -73.9707),
            listingDate: Date().addingTimeInterval(-86400 * 1),
            description: "Luxurious two-bedroom condo with stunning city views and premium amenities. Features include marble countertops, custom closets, and a private balcony overlooking the city.",
            contactInfo: ContactInfo(
                agentName: "Michael Chen",
                agentPhone: "(555) 987-6543",
                agentEmail: "mchen@luxurynyc.com",
                brokerageName: "Luxury NYC Properties",
                brokeragePhone: "(555) 987-6500"
            ),
            availableDate: Date().addingTimeInterval(86400 * 14),
            isNewListing: false
        ),
        PropertyListing(
            id: "3",
            address: "789 Greenwich Street, Apt 8C",
            neighborhood: "Tribeca",
            price: 8200,
            bedrooms: 2,
            bathrooms: 2.5,
            squareFootage: 1100,
            propertyType: .loft,
            amenities: ["Doorman", "Terrace", "Parking", "Pet Friendly", "Washer/Dryer"],
            images: ["property_3"],
            thumbnailURL: "property_3",
            coordinates: PropertyCoordinate(latitude: 40.7195, longitude: -74.0089),
            listingDate: Date().addingTimeInterval(-86400 * 7),
            description: "Converted loft in historic Tribeca building with soaring ceilings and exposed brick. This unique space combines industrial charm with modern luxury.",
            contactInfo: ContactInfo(
                agentName: "Emma Rodriguez",
                agentPhone: "(555) 456-7890",
                agentEmail: "emma@tribecaliving.com",
                brokerageName: "Tribeca Living Realty",
                brokeragePhone: nil
            ),
            availableDate: Date().addingTimeInterval(86400 * 30),
            isNewListing: false
        ),
        PropertyListing(
            id: "4",
            address: "321 East 23rd Street, Studio 5F",
            neighborhood: "Gramercy",
            price: 3200,
            bedrooms: 0,
            bathrooms: 1.0,
            squareFootage: 450,
            propertyType: .studio,
            amenities: ["Laundry", "Gym", "Pet Friendly"],
            images: ["property_4", "property_4_2"],
            thumbnailURL: "property_4",
            coordinates: PropertyCoordinate(latitude: 40.7390, longitude: -73.9845),
            listingDate: Date().addingTimeInterval(-86400 * 2),
            description: "Cozy studio apartment in pre-war Gramercy building. Perfect for young professionals with efficient layout and great natural light.",
            contactInfo: ContactInfo(
                agentName: "David Park",
                agentPhone: "(555) 234-5678",
                agentEmail: "dpark@gramercy.com",
                brokerageName: "Gramercy Properties",
                brokeragePhone: "(555) 234-5600"
            ),
            availableDate: Date().addingTimeInterval(86400 * 3),
            isNewListing: true
        ),
        PropertyListing(
            id: "5",
            address: "567 West Village Lane, Apt 3A",
            neighborhood: "West Village",
            price: 5900,
            bedrooms: 1,
            bathrooms: 1.0,
            squareFootage: 750,
            propertyType: .apartment,
            amenities: ["Garden", "Parking", "Laundry", "Pet Friendly"],
            images: ["property_5"],
            thumbnailURL: "property_5",
            coordinates: PropertyCoordinate(latitude: 40.7353, longitude: -74.0027),
            listingDate: Date().addingTimeInterval(-86400 * 5),
            description: "Charming one-bedroom in the heart of West Village with access to a private garden. This unit features original hardwood floors and updated kitchen.",
            contactInfo: ContactInfo(
                agentName: "Lisa Thompson",
                agentPhone: "(555) 345-6789",
                agentEmail: "lisa@villagelife.com",
                brokerageName: "Village Life Realty",
                brokeragePhone: "(555) 345-6700"
            ),
            availableDate: Date().addingTimeInterval(86400 * 10),
            isNewListing: false
        )
    ]
}