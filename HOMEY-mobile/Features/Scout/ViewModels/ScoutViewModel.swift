import Foundation
import SwiftUI
import Combine
import CoreLocation
import Observation

@Observable
class ScoutViewModel {
    // MARK: - Properties
    
    private(set) var allListings: [PropertyListing] = []
    private(set) var visibleListings: [PropertyListing] = []
    private(set) var shortlistedProperties: [PropertyListing] = []
    private(set) var neighborhoodData: NeighborhoodData?
    
    var timeOfDay: ScoutTimeOfDay = .day
    var currentNeighborhood: String = "Flatiron"
    var currentLocation: CLLocation?
    var isLoading = false
    var errorMessage: String?
    
    // Lens properties
    var lensPosition: CGPoint = CGPoint(x: 200, y: 200)
    var lensSize: LensSize = .medium
    var isDragging: Bool = false
    var activeLenses: [Lens] = []
    var priceRange: ClosedRange<Double> = 1000...5000
   var listings: [PropertyListing] = []
    var selectedListing: PropertyListing?
    var isShowingPeekCard: Bool = false
    var selectedBedrooms: Int = 0
    var selectedBathrooms: Int = 0
    var shortlist: [PropertyListing] = []
    
    // Filter state
    private var activeFilters: Set<ScoutFilter> = []
    var searchQuery: String = "" {
        didSet {
            searchListings(query: searchQuery)
        }
    }
    private var currentSearchQuery: String = ""
    
    // Services
    private let dataService: ScoutDataServiceProtocol
    private let locationManager: LocationManagerProtocol
    
    // Publishers
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(dataService: ScoutDataServiceProtocol = ScoutDataService.shared,
         locationManager: LocationManagerProtocol = LocationManager.shared) {
        self.dataService = dataService
        self.locationManager = locationManager
        setupLocationUpdates()
        loadShortlistedProperties()
    }
    
    // MARK: - Data Loading
    
    func loadInitialData() {
        isLoading = true
        errorMessage = nil
        
        let searchParams = PropertySearchParams(
            location: currentLocation,
            neighborhood: currentNeighborhood,
            filters: activeFilters,
            query: currentSearchQuery
        )
        
        dataService.fetchPropertyListings(params: searchParams)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.allListings = response.listings
                    self?.applyCurrentFilters()
                }
            )
            .store(in: &cancellables)
        
        // Load neighborhood data if location is available
        if let location = currentLocation {
            loadNeighborhoodData(for: location)
        }
    }
    
    private func loadNeighborhoodData(for location: CLLocation) {
        dataService.getNeighborhoodData(for: location.coordinate)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load neighborhood data: \(error)")
                    }
                },
                receiveValue: { [weak self] data in
                    self?.neighborhoodData = data
                    self?.currentNeighborhood = data.name
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadShortlistedProperties() {
        dataService.getShortlistedProperties()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load shortlisted properties: \(error)")
                    }
                },
                receiveValue: { [weak self] properties in
                    self?.shortlistedProperties = properties
                }
            )
            .store(in: &cancellables)
        //         receiveCompletion: { completion in
        //             self.isLoading = false
        //             if case .failure(let error) = completion {
        //                 self.errorMessage = error.localizedDescription
        //             }
        //         },
        //         receiveValue: { listings in
        //             self.allListings = listings
        //             self.applyCurrentFilters()
        //         }
        //     )
        //     .store(in: &cancellables)
    }
    
    // MARK: - Filter Management
    
    func applyFilters(_ filters: Set<ScoutFilter>) {
        activeFilters = filters
        applyCurrentFilters()
    }
    
    private func applyCurrentFilters() {
        visibleListings = allListings.filter { listing in
            // If no filters active, show all
            if activeFilters.isEmpty {
                return true
            }
            
            // Check each active filter
            for filter in activeFilters {
                if !listing.matchesFilter(filter) {
                    return false
                }
            }
            
            return true
        }
    }
    
    // MARK: - Shortlist Management
    
    func addToShortlist(_ listing: PropertyListing) {
        guard !shortlistedProperties.contains(where: { $0.id == listing.id }) else { return }
        
        dataService.addToShortlist(listing.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to add to shortlist: \(error)")
                    }
                },
                receiveValue: { [weak self] _ in
                    var updatedListing = listing
                    updatedListing.isSaved = true
                    
                    self?.shortlistedProperties.append(updatedListing)
                    self?.updateListingInArrays(updatedListing)
                    self?.checkProgressionMilestones()
                }
            )
            .store(in: &cancellables)
    }
    
    func removeFromShortlist(_ listing: PropertyListing) {
        dataService.removeFromShortlist(listing.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to remove from shortlist: \(error)")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.shortlistedProperties.removeAll { $0.id == listing.id }
                    
                    var updatedListing = listing
                    updatedListing.isSaved = false
                    self?.updateListingInArrays(updatedListing)
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateListingInArrays(_ listing: PropertyListing) {
        // Update in allListings
        if let index = allListings.firstIndex(where: { $0.id == listing.id }) {
            allListings[index] = listing
        }
        
        // Update in visibleListings
        if let index = visibleListings.firstIndex(where: { $0.id == listing.id }) {
            visibleListings[index] = listing
        }
    }
    
    // MARK: - Time of Day
    
    // MARK: - Location Updates
    
    private func setupLocationUpdates() {
        // Listen for location updates
        locationManager.currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                if let coordinate = coordinate {
                    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    self?.currentLocation = location
                    self?.loadNeighborhoodData(for: location)
                } else {
                    self?.currentLocation = nil
                }
            }
            .store(in: &cancellables)
        
        // Listen for authorization status changes
        locationManager.authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.locationManager.startLocationUpdates()
                case .denied, .restricted:
                    self?.errorMessage = "Location access is required for Scout to work properly."
                case .notDetermined:
                    self?.locationManager.requestLocationPermission()
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Progression System
    
    private func checkProgressionMilestones() {
        let savedCount = shortlistedProperties.count
        
        switch savedCount {
        case 1:
            showProgressionEvent(.trailStarted)
        case 10:
            showProgressionEvent(.neighborhoodUnlocked)
        case 25:
            showProgressionEvent(.expertStatus)
        default:
            break
        }
    }
    
    private func showProgressionEvent(_ event: ProgressionEventType) {
        // TODO: Show progression event UI
        print("Progression event: \(event)")
    }
    
    // MARK: - Search
    
    func searchListings(query: String) {
        currentSearchQuery = query
        
        if query.isEmpty {
            applyCurrentFilters()
        } else {
            isLoading = true
            
            let searchParams = PropertySearchParams(
                location: currentLocation,
                neighborhood: currentNeighborhood,
                filters: activeFilters,
                query: query
            )
            
            dataService.searchProperties(params: searchParams)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    },
                    receiveValue: { [weak self] response in
                        self?.allListings = response.listings
                        self?.applyCurrentFilters()
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    func refreshData() {
        loadInitialData()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Lens Methods
    
    func setLensSize(_ size: LensSize) {
        lensSize = size
    }
    
    func trackLensInteraction(at position: CGPoint, zoomLevel: Double) {
        // Track lens interaction for analytics
        // TODO: Implement analytics tracking
    }
    
    func toggleTimeOfDay() {
        timeOfDay = timeOfDay == .day ? .dusk : .day
    }
    
    func toggleLens(_ lens: Lens) {
        if let index = activeLenses.firstIndex(where: { $0.id == lens.id }) {
            activeLenses.remove(at: index)
        } else {
            activeLenses.append(lens)
        }
    }
    
    func resetFilters() {
        activeFilters.removeAll()
        activeLenses.removeAll()
        priceRange = 1000...5000
        selectedBedrooms = 0
        selectedBathrooms = 0
        applyCurrentFilters()
    }
    
    func setBedroomFilter(_ filter: String) {
        switch filter {
        case "Any":
            selectedBedrooms = 0
        case "1+":
            selectedBedrooms = 1
        case "2+":
            selectedBedrooms = 2
        case "3+":
            selectedBedrooms = 3
        case "4+":
            selectedBedrooms = 4
        default:
            selectedBedrooms = 0
        }
    }
    
    func setBathroomFilter(_ filter: String) {
        switch filter {
        case "Any":
            selectedBathrooms = 0
        case "1+":
            selectedBathrooms = 1
        case "2+":
            selectedBathrooms = 2
        case "3+":
            selectedBathrooms = 3
        default:
            selectedBathrooms = 0
        }
    }
    
    // MARK: - Trail and Peek Card Methods
    
    func startTrail() {
        // TODO: Implement trail starting logic
        // This could involve navigation to a trail view or starting a guided tour
        print("Starting trail with \(shortlistedProperties.count) properties")
    }
    
    func showPeekCard(for listing: PropertyListing) {
        selectedListing = listing
        isShowingPeekCard = true
    }
    
    func shareProperty(_ listing: PropertyListing) {
        // TODO: Implement property sharing logic
        // This could involve system share sheet or custom sharing
        print("Sharing property: \(listing.address)")
    }
    
    // MARK: - Swipe Actions
    
    func likeProperty(_ property: PropertyListing) {
        // Add to shortlist if not already there
        if !shortlistedProperties.contains(where: { $0.id == property.id }) {
            addToShortlist(property)
        }
        
        // Track user preference for learning
        trackUserPreference(property: property, liked: true)
        
        print("Liked property: \(property.address)")
    }
    
    func dislikeProperty(_ property: PropertyListing) {
        // Remove from shortlist if it's there
        if shortlistedProperties.contains(where: { $0.id == property.id }) {
            removeFromShortlist(property)
        }
        
        // Track user preference for learning
        trackUserPreference(property: property, liked: false)
        
        print("Disliked property: \(property.address)")
    }
    
    func loadMoreListings() {
        // Load more listings when running low
        guard !isLoading else { return }
        
        isLoading = true
        
        let params = PropertySearchParams(
            location: currentLocation,
            neighborhood: currentNeighborhood,
            filters: activeFilters,
            query: currentSearchQuery
        )
        
        dataService.searchProperties(params: params)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    // Append new listings, avoiding duplicates
                    let uniqueNewListings = response.listings.filter { newListing in
                        !(self?.listings.contains { $0.id == newListing.id } ?? false)
                    }
                    
                    self?.listings.append(contentsOf: uniqueNewListings)
                }
            )
            .store(in: &cancellables)
    }
    
    private func trackUserPreference(property: PropertyListing, liked: Bool) {
        // This could be used to improve recommendations
        // For now, just log the preference
        let preference = [
            "propertyId": property.id,
            "liked": liked,
            "price": property.price,
            "bedrooms": property.bedrooms,
            "bathrooms": property.bathrooms,
            "neighborhood": property.neighborhood,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]
        
        // TODO: Send to analytics/ML service
        print("User preference tracked: \(preference)")
    }
}

// MARK: - Supporting Types

enum ScoutFilter: String, CaseIterable, Hashable {
    case price = "price"
    case beds = "beds"
    case pets = "pets"
    case doorman = "doorman"
    case amenities = "amenities"
    case parking = "parking"
    case laundry = "laundry"
    case outdoor = "outdoor"
    
    var displayName: String {
        switch self {
        case .price: return "Price"
        case .beds: return "Beds"
        case .pets: return "Pet Friendly"
        case .doorman: return "Doorman"
        case .amenities: return "Amenities"
        case .parking: return "Parking"
        case .laundry: return "Laundry"
        case .outdoor: return "Outdoor"
        }
    }
    
    var iconName: String {
        switch self {
        case .price: return "dollarsign.circle"
        case .beds: return "bed.double"
        case .pets: return "pawprint"
        case .doorman: return "person.badge.key"
        case .amenities: return "star.circle"
        case .parking: return "car"
        case .laundry: return "washer"
        case .outdoor: return "tree"
        }
    }
    
    static var primaryFilters: [ScoutFilter] {
        [.price, .beds, .pets, .doorman]
    }
    
    static var secondaryFilters: [ScoutFilter] {
        [.amenities, .parking, .laundry, .outdoor]
    }
}

enum ProgressionEventType {
    case trailStarted
    case neighborhoodUnlocked
    case expertStatus
    
    var title: String {
        switch self {
        case .trailStarted: return "Trail Started!"
        case .neighborhoodUnlocked: return "Neighborhood Unlocked!"
        case .expertStatus: return "Scout Expert!"
        }
    }
    
    var message: String {
        switch self {
        case .trailStarted: return "You've saved your first property. Keep exploring!"
        case .neighborhoodUnlocked: return "You've explored 10 properties in this area."
        case .expertStatus: return "You're now a Scout expert with 25+ saved properties!"
        }
    }
}

// MARK: - Helper Extensions

extension PropertySearchParams {
    init(location: CLLocation?, neighborhood: String, filters: Set<ScoutFilter>, query: String) {
        self.location = location.map { LocationData(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
        self.neighborhood = neighborhood
        self.priceRange = nil // Will be set based on filters
        self.bedrooms = nil // Will be set based on filters
        self.amenities = Array(filters.map { $0.rawValue })
        self.query = query.isEmpty ? nil : query
        self.limit = 50
        self.offset = 0
    }
}
