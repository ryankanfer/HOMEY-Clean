import Foundation

struct SearchFilters {
    var priceRange: ClosedRange<Double>?
    var minBedrooms: Int?
    var minBathrooms: Int?
    var neighborhoods: [String] = []
    var amenities: [String] = []

    mutating func clearAll() {
        priceRange = nil
        minBedrooms = nil
        minBathrooms = nil
        neighborhoods.removeAll()
        amenities.removeAll()
    }
}