import Foundation
import SwiftUI

enum StreetEasyMarketType { case rentals, sales }

struct StreetEasyLinkBuilder {
    // MARK: - Public API
    static func makeURL(market: StreetEasyMarketType, filters: MatchmakerFilters) -> URL? {
        let base = basePath(for: market)
        let areaSlug = neighborhoodSlug(from: filters.neighborhoods.first)
        let facets = facets(from: filters)
        let urlString = facets.isEmpty ? "\(base)/\(areaSlug)" : "\(base)/\(areaSlug)/\(facets.joined(separator: "|"))"
        return URL(string: urlString)
    }

    static func makeURL(market: StreetEasyMarketType, filters: SearchFilters) -> URL? {
        let base = basePath(for: market)
        let areaSlug = neighborhoodSlug(from: filters.neighborhoods.first)
        let facets = facets(from: filters)
        let urlString = facets.isEmpty ? "\(base)/\(areaSlug)" : "\(base)/\(areaSlug)/\(facets.joined(separator: "|"))"
        return URL(string: urlString)
    }

    // MARK: - Builders
    private static func basePath(for market: StreetEasyMarketType) -> String {
        switch market {
        case .rentals: return "https://streeteasy.com/for-rent"
        case .sales: return "https://streeteasy.com/for-sale"
        }
    }

    private static func neighborhoodSlug(from name: String?) -> String {
        guard let name = name, !name.isEmpty else { return "nyc" }
        // Basic slug: lowercased, spaces -> hyphens, remove punctuation
        let lower = name.lowercased()
        let trimmed = lower.replacingOccurrences(of: "'", with: "")
        let spaced = trimmed.replacingOccurrences(of: " ", with: "-")
        return spaced
    }

    private static func facets(from filters: MatchmakerFilters) -> [String] {
        var facets: [String] = []

        if let range = filters.priceRange {
            let min = Int(range.lowerBound)
            let max = Int(range.upperBound)
            facets.append("price:\(min)-\(max)")
        }

        if let beds = filters.minBedrooms {
            facets.append("beds:\(beds)-")
        }

        if let baths = filters.minBathrooms {
            facets.append("baths:\(baths)-")
        }

        // Amenities mapping — initial subset, can be expanded/verified by inspecting StreetEasy URLs
        let amenityMap: [String: String] = [
            "Doorman": "doorman",
            "Elevator": "elevator",
            "Gym": "gym",
            "Laundry": "laundry",
            "Parking": "parking",
            "Balcony": "balcony",
            "Dishwasher": "dishwasher",
            "AC": "air_conditioning",
            "Air Conditioning": "air_conditioning"
        ]

        var amenityFacetValues: [String] = []
        var discreteFacets: [String] = []

        for amenity in filters.mustHaveAmenities {
            if amenity == "Pet Friendly" {
                // Simplified assumption: prefer dogs. Could branch on user profile for dogs/cats.
                discreteFacets.append("dogs:1")
                continue
            }
            if let val = amenityMap[amenity] {
                amenityFacetValues.append(val)
            }
        }

        if !amenityFacetValues.isEmpty {
            facets.append("amenities:\(amenityFacetValues.joined(separator: ","))")
        }
        facets.append(contentsOf: discreteFacets)

        return facets
    }

    private static func facets(from filters: SearchFilters) -> [String] {
        var facets: [String] = []

        if let range = filters.priceRange {
            let min = Int(range.lowerBound)
            let max = Int(range.upperBound)
            facets.append("price:\(min)-\(max)")
        }

        if let beds = filters.minBedrooms {
            facets.append("beds:\(beds)-")
        }

        if let baths = filters.minBathrooms {
            facets.append("baths:\(baths)-")
        }

        let amenityMap: [String: String] = [
            "Doorman": "doorman",
            "Elevator": "elevator",
            "Gym": "gym",
            "Laundry": "laundry",
            "Parking": "parking",
            "Balcony": "balcony",
            "Dishwasher": "dishwasher",
            "AC": "air_conditioning",
            "Air Conditioning": "air_conditioning"
        ]

        var amenityFacetValues: [String] = []
        var discreteFacets: [String] = []

        for amenity in filters.amenities {
            if amenity == "Pet Friendly" {
                discreteFacets.append("dogs:1")
                continue
            }
            if let val = amenityMap[amenity] {
                amenityFacetValues.append(val)
            }
        }

        if !amenityFacetValues.isEmpty {
            facets.append("amenities:\(amenityFacetValues.joined(separator: ","))")
        }
        facets.append(contentsOf: discreteFacets)

        return facets
    }
}