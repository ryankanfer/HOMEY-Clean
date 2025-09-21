import Foundation
import Combine
import CoreLocation

// MARK: - Scout Data Service Protocol

protocol ScoutDataServiceProtocol {
    func fetchListings(for neighborhood: String, filters: Set<ScoutFilter>) -> AnyPublisher<[PropertyListing], ScoutError>
    func searchListings(query: String, location: CLLocationCoordinate2D?, radius: Double) -> AnyPublisher<[PropertyListing], ScoutError>
    func fetchPropertyListings(params: PropertySearchParams) -> AnyPublisher<PropertyListingsResponse, ScoutError>
    func searchProperties(params: PropertySearchParams) -> AnyPublisher<PropertyListingsResponse, ScoutError>
    func addToShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError>
    func saveToShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError>
    func removeFromShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError>
    func getShortlistedProperties() -> AnyPublisher<[PropertyListing], ScoutError>
    func getNeighborhoodData(for location: CLLocationCoordinate2D) -> AnyPublisher<NeighborhoodData, ScoutError>
}

// MARK: - Scout Data Service Implementation

class ScoutDataService: ScoutDataServiceProtocol {
    static let shared = ScoutDataService()
    
    private let apiClient: APIClient
    private let locationManager: LocationManager
    private let cacheManager: CacheManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: APIClient = .shared, 
         locationManager: LocationManager = .shared,
         cacheManager: CacheManager = .shared) {
        self.apiClient = apiClient
        self.locationManager = locationManager
        self.cacheManager = cacheManager
    }
    
    // MARK: - Property Listings
    
    func fetchListings(for neighborhood: String, filters: Set<ScoutFilter>) -> AnyPublisher<[PropertyListing], ScoutError> {
        let cacheKey = "listings_\(neighborhood)_\(filters.hashValue)"
        
        // Check cache first
        if let cachedListings: [PropertyListing] = cacheManager.get(cacheKey, type: [PropertyListing].self),
           !cacheManager.isExpired(cacheKey) {
            return Just(cachedListings)
                .setFailureType(to: ScoutError.self)
                .eraseToAnyPublisher()
        }
        
        // Build API request
        var parameters: [String: Any] = [
            "neighborhood": neighborhood,
            "limit": 50
        ]
        
        // Add filter parameters
        if !filters.isEmpty {
            parameters["filters"] = filters.map { $0.rawValue }
        }
        
        return apiClient.request(
            endpoint: "/api/v1/properties/search",
            method: .GET,
            parameters: parameters
        )
        .decode(type: PropertyListingsResponse.self, decoder: JSONDecoder())
        .map { response in
            // Cache the results
            self.cacheManager.set(response.listings, forKey: cacheKey, expiration: 300) // 5 minutes
            return response.listings
        }
        .mapError { error in
            if let apiError = error as? APIError {
                return ScoutError.apiError(apiError)
            }
            return ScoutError.networkError(error)
        }
        .eraseToAnyPublisher()
    }
    
    func searchListings(query: String, location: CLLocationCoordinate2D?, radius: Double = 2000) -> AnyPublisher<[PropertyListing], ScoutError> {
        var parameters: [String: Any] = [
            "query": query,
            "limit": 25
        ]
        
        if let location = location {
            parameters["lat"] = location.latitude
            parameters["lng"] = location.longitude
            parameters["radius"] = radius
        }
        
        return apiClient.request(
            endpoint: "/api/v1/properties/search",
            method: .GET,
            parameters: parameters
        )
        .decode(type: PropertyListingsResponse.self, decoder: JSONDecoder())
        .map { $0.listings }
        .mapError { error in
            if let apiError = error as? APIError {
                return ScoutError.apiError(apiError)
            }
            return ScoutError.networkError(error)
        }
        .eraseToAnyPublisher()
    }
    
    func fetchPropertyListings(params: PropertySearchParams) -> AnyPublisher<PropertyListingsResponse, ScoutError> {
        let neighborhood = params.neighborhood ?? "Unknown"
        let filters = Set<ScoutFilter>() // Convert from params if needed
        
        return fetchListings(for: neighborhood, filters: filters)
            .map { listings in
                PropertyListingsResponse(listings: listings, total: listings.count, hasMore: false)
            }
            .eraseToAnyPublisher()
    }
    
    func searchProperties(params: PropertySearchParams) -> AnyPublisher<PropertyListingsResponse, ScoutError> {
        let query = params.query ?? ""
        let location = params.location?.clLocation.coordinate
        
        return searchListings(query: query, location: location, radius: 2000)
            .map { listings in
                PropertyListingsResponse(listings: listings, total: listings.count, hasMore: false)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Shortlist Management
    
    func addToShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError> {
        return saveToShortlist(listingId)
    }
    
    func saveToShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError> {
        let parameters = ["listing_id": listingId]
        
        return apiClient.request(
            endpoint: "/api/v1/user/shortlist",
            method: .POST,
            parameters: parameters
        )
        .map { _ in () }
        .handleEvents(receiveOutput: { _ in
            // Invalidate shortlist cache
            self.cacheManager.remove("user_shortlist")
        })
        .mapError { error in
            if let apiError = error as? APIError {
                return ScoutError.apiError(apiError)
            }
            return ScoutError.networkError(error)
        }
        .eraseToAnyPublisher()
    }
    
    func removeFromShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError> {
        return apiClient.request(
            endpoint: "/api/v1/user/shortlist/\(listingId)",
            method: .DELETE
        )
        .map { _ in () }
        .handleEvents(receiveOutput: { _ in
            // Invalidate shortlist cache
            self.cacheManager.remove("user_shortlist")
        })
        .mapError { error in
            if let apiError = error as? APIError {
                return ScoutError.apiError(apiError)
            }
            return ScoutError.networkError(error)
        }
        .eraseToAnyPublisher()
    }
    
    func getShortlistedProperties() -> AnyPublisher<[PropertyListing], ScoutError> {
        let cacheKey = "user_shortlist"
        
        // Check cache first
        if let cachedShortlist: [PropertyListing] = cacheManager.get(cacheKey, type: [PropertyListing].self),
           !cacheManager.isExpired(cacheKey) {
            return Just(cachedShortlist)
                .setFailureType(to: ScoutError.self)
                .eraseToAnyPublisher()
        }
        
        return apiClient.request(
            endpoint: "/api/v1/user/shortlist",
            method: .GET
        )
        .decode(type: PropertyListingsResponse.self, decoder: JSONDecoder())
        .map { response in
            // Cache the results
            self.cacheManager.set(response.listings, forKey: cacheKey, expiration: 600) // 10 minutes
            return response.listings
        }
        .mapError { error in
            if let apiError = error as? APIError {
                return ScoutError.apiError(apiError)
            }
            return ScoutError.networkError(error)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Neighborhood Data
    
    func getNeighborhoodData(for location: CLLocationCoordinate2D) -> AnyPublisher<NeighborhoodData, ScoutError> {
        let cacheKey = "neighborhood_\(location.latitude)_\(location.longitude)"
        
        // Check cache first
        if let cachedData: NeighborhoodData = cacheManager.get(cacheKey, type: NeighborhoodData.self),
           !cacheManager.isExpired(cacheKey) {
            return Just(cachedData)
                .setFailureType(to: ScoutError.self)
                .eraseToAnyPublisher()
        }
        
        let parameters: [String: Any] = [
            "lat": location.latitude,
            "lng": location.longitude
        ]
        
        return apiClient.request(
            endpoint: "/api/v1/neighborhoods/lookup",
            method: .GET,
            parameters: parameters
        )
        .decode(type: NeighborhoodData.self, decoder: JSONDecoder())
        .map { data in
            // Cache the results
            self.cacheManager.set(data, forKey: cacheKey, expiration: 3600) // 1 hour
            return data
        }
        .mapError { error in
            if let apiError = error as? APIError {
                return ScoutError.apiError(apiError)
            }
            return ScoutError.networkError(error)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Supporting Types

struct PropertyListingsResponse: Codable {
    let listings: [PropertyListing]
    let total: Int
    let hasMore: Bool
}

struct NeighborhoodData: Codable {
    let name: String
    let averagePrice: Double
    let priceRange: ScoutPriceRange
    let demographics: Demographics
    let amenities: [String]
    let transitScore: Int
    let walkScore: Int
    let bikeScore: Int
}

// ScoutPriceRange is now defined in PropertySearchParams.swift

struct Demographics: Codable {
    let averageAge: Double
    let medianIncome: Double
    let populationDensity: Double
}

enum ScoutError: Error, LocalizedError {
    case networkError(Error)
    case apiError(APIError)
    case locationError(Error)
    case cacheError
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let apiError):
            return "API error: \(apiError.localizedDescription)"
        case .locationError(let error):
            return "Location error: \(error.localizedDescription)"
        case .cacheError:
            return "Cache error occurred"
        case .invalidData:
            return "Invalid data received"
        }
    }
}

// MARK: - Mock Implementation for Development

class MockScoutDataService: ScoutDataServiceProtocol {
    private let delay: TimeInterval
    
    init(delay: TimeInterval = 1.0) {
        self.delay = delay
    }
    
    func fetchListings(for neighborhood: String, filters: Set<ScoutFilter>) -> AnyPublisher<[PropertyListing], ScoutError> {
        let filteredListings = PropertyListing.sampleListings.filter { listing in
            // Filter by neighborhood
            guard listing.neighborhood.lowercased().contains(neighborhood.lowercased()) else {
                return false
            }
            
            // Apply filters
            if !filters.isEmpty {
                return filters.allSatisfy { listing.matchesFilter($0) }
            }
            
            return true
        }
        
        return Just(filteredListings)
            .setFailureType(to: ScoutError.self)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func searchListings(query: String, location: CLLocationCoordinate2D?, radius: Double) -> AnyPublisher<[PropertyListing], ScoutError> {
        let searchResults = PropertyListing.sampleListings.filter { listing in
            listing.address.localizedCaseInsensitiveContains(query) ||
            listing.neighborhood.localizedCaseInsensitiveContains(query) ||
            listing.description.localizedCaseInsensitiveContains(query)
        }
        
        return Just(searchResults)
            .setFailureType(to: ScoutError.self)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchPropertyListings(params: PropertySearchParams) -> AnyPublisher<PropertyListingsResponse, ScoutError> {
        let neighborhood = params.neighborhood ?? "Unknown"
        let filters = Set<ScoutFilter>() // Convert from params if needed
        
        return fetchListings(for: neighborhood, filters: filters)
            .map { listings in
                PropertyListingsResponse(listings: listings, total: listings.count, hasMore: false)
            }
            .eraseToAnyPublisher()
    }
    
    func searchProperties(params: PropertySearchParams) -> AnyPublisher<PropertyListingsResponse, ScoutError> {
        let query = params.query ?? ""
        let location = params.location?.clLocation.coordinate
        
        return searchListings(query: query, location: location, radius: 2000)
            .map { listings in
                PropertyListingsResponse(listings: listings, total: listings.count, hasMore: false)
            }
            .eraseToAnyPublisher()
    }
    
    func addToShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError> {
        return saveToShortlist(listingId)
    }
    
    func saveToShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError> {
        return Just(())
            .setFailureType(to: ScoutError.self)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func removeFromShortlist(_ listingId: String) -> AnyPublisher<Void, ScoutError> {
        return Just(())
            .setFailureType(to: ScoutError.self)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getShortlistedProperties() -> AnyPublisher<[PropertyListing], ScoutError> {
        return Just(Array(PropertyListing.sampleListings.prefix(2)))
            .setFailureType(to: ScoutError.self)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getNeighborhoodData(for location: CLLocationCoordinate2D) -> AnyPublisher<NeighborhoodData, ScoutError> {
        let mockData = NeighborhoodData(
            name: "Flatiron",
            averagePrice: 5200,
            priceRange: ScoutPriceRange(min: 3000, max: 8500),
            demographics: Demographics(
                averageAge: 32.5,
                medianIncome: 95000,
                populationDensity: 15000
            ),
            amenities: ["Restaurants", "Shopping", "Parks", "Transit"],
            transitScore: 95,
            walkScore: 88,
            bikeScore: 72
        )
        
        return Just(mockData)
            .setFailureType(to: ScoutError.self)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}