import Foundation
import CoreLocation

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

struct PropertySearchParams: Codable {
    let location: LocationData?
    let neighborhood: String?
    let priceRange: ScoutPriceRange?
    let bedrooms: Int?
    let amenities: [String]?
    let query: String?
    let limit: Int
    let offset: Int
    
    init(
        location: CLLocation? = nil,
        neighborhood: String? = nil,
        filters: Set<ScoutFilter>? = nil,
        query: String? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) {
        self.location = location.map { LocationData(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
        self.neighborhood = neighborhood
        self.priceRange = nil // Will be extracted from filters if needed
        self.bedrooms = nil // Will be extracted from filters if needed
        self.amenities = nil // Will be extracted from filters if needed
        self.query = query
        self.limit = limit
        self.offset = offset
    }
}

// MARK: - Supporting Types

struct ScoutPriceRange: Codable {
    let min: Double?
    let max: Double?
    
    init(min: Double? = nil, max: Double? = nil) {
        self.min = min
        self.max = max
    }
}