import SwiftUI
import Combine

@MainActor
class MatchmakerViewModel: ObservableObject {
    @Published var properties: [PropertyListing] = []
    @Published var filters = MatchmakerFilters()
    @Published var showFilters = false
    @Published var isLoading = false
    
    private let eventsRepository = EventsRepository()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadProperties()
    }
    
    // MARK: - Property Loading
    
    func loadProperties() {
        isLoading = true
        
        // Simulate API call with personalized recommendations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.properties = self.generatePersonalizedProperties()
            self.isLoading = false
        }
    }
    
    func loadMoreProperties() {
        // Load additional properties when running low
        let newProperties = generatePersonalizedProperties()
        properties.append(contentsOf: newProperties)
    }
    
    // MARK: - Swipe Actions
    
    func saveProperty(_ property: PropertyListing) {
        recordEvent(.saveProperty(propertyId: property.id))
        print("💖 Saved property: \(property.address)")
    }
    
    func passProperty(_ property: PropertyListing) {
        recordEvent(.listingSave(listingId: property.id, action: "pass"))
        print("❌ Passed on property: \(property.address)")
    }
    
    func requestTour(_ property: PropertyListing) {
        recordEvent(.requestTour(propertyId: property.id))
        print("📅 Requested tour for: \(property.address)")
    }
    
    // MARK: - Filters
    
    func applyFilters() {
        showFilters = false
        properties = generatePersonalizedProperties()
        recordEvent(.searchQuery(query: "", filters: ["filters": filters.activeFilterNames]))
    }
    
    // MARK: - Event Tracking
    
    private func recordEvent(_ event: HomeyEvent) {
        Task { await eventsRepository.recordEvent(event) }
    }
    
    // MARK: - Private Methods
    
    private func generatePersonalizedProperties() -> [PropertyListing] {
        let baseProperties = createBaseProperties()
        return applyFiltersToProperties(baseProperties)
    }
    
    private func createBaseProperties() -> [PropertyListing] {
        return [
            createCobbleHillProperty(),
            createCarrollGardensProperty(),
            createDumboProperty(),
            createGreenpointProperty()
        ]
    }
    
    private func createCobbleHillProperty() -> PropertyListing {
        return PropertyListing(
            id: "match_1",
            address: "456 Cobble Hill, Brooklyn, NY",
            neighborhood: "Cobble Hill",
            price: 3400,
            bedrooms: 2,
            bathrooms: 1.0,
            squareFootage: 950,
            propertyType: .apartment,
            amenities: ["Hardwood Floors", "Dishwasher"],
            images: ["https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400"],
            thumbnailURL: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400",
            coordinates: PropertyCoordinate(latitude: 40.6844, longitude: -73.9967),
            listingDate: Date().addingTimeInterval(-86400 * 3),
            description: "Charming apartment in historic Cobble Hill with hardwood floors.",
            contactInfo: ContactInfo(
                agentName: "Agent Smith",
                agentPhone: "555-0101",
                agentEmail: "agent@example.com",
                brokerageName: "Brooklyn Heights Realty",
                brokeragePhone: "555-0100"
            ),
            isSaved: false,
            availableDate: Date().addingTimeInterval(86400 * 5),
            isNewListing: true
        )
    }
    
    private func createCarrollGardensProperty() -> PropertyListing {
        return PropertyListing(
            id: "match_2",
            address: "789 Carroll Gardens, Brooklyn, NY",
            neighborhood: "Carroll Gardens",
            price: 2900,
            bedrooms: 1,
            bathrooms: 1.0,
            squareFootage: 800,
            propertyType: .apartment,
            amenities: ["Laundry", "Pet Friendly"],
            images: ["https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400"],
            thumbnailURL: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400",
            coordinates: PropertyCoordinate(latitude: 40.6781, longitude: -73.9956),
            listingDate: Date().addingTimeInterval(-86400 * 2),
            description: "Cozy apartment in family-friendly Carroll Gardens.",
            contactInfo: ContactInfo(
                agentName: "Agent Johnson",
                agentPhone: "555-0102",
                agentEmail: "johnson@example.com",
                brokerageName: "Carroll Gardens Properties",
                brokeragePhone: "555-0100"
            ),
            isSaved: false,
            availableDate: Date().addingTimeInterval(86400 * 10),
            isNewListing: false
        )
    }
    
    private func createDumboProperty() -> PropertyListing {
        return PropertyListing(
            id: "agent_exclusive",
            address: "321 DUMBO, Brooklyn, NY",
            neighborhood: "DUMBO",
            price: 4200,
            bedrooms: 2,
            bathrooms: 2.0,
            squareFootage: 1100,
            propertyType: .apartment,
            amenities: ["Gym", "Rooftop", "Concierge"],
            images: ["https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400"],
            thumbnailURL: "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400",
            coordinates: PropertyCoordinate(latitude: 40.7033, longitude: -73.9888),
            listingDate: Date().addingTimeInterval(-86400 * 1),
            description: "Luxury apartment in trendy DUMBO with Manhattan views.",
            contactInfo: ContactInfo(
                agentName: "Agent Brown",
                agentPhone: "555-0103",
                agentEmail: "brown@example.com",
                brokerageName: "DUMBO Luxury Living",
                brokeragePhone: "555-0100"
            ),
            isSaved: false,
            availableDate: Date().addingTimeInterval(86400 * 15),
            isNewListing: true
        )
    }
    
    private func createGreenpointProperty() -> PropertyListing {
        return PropertyListing(
            id: "match_4",
            address: "654 Greenpoint, Brooklyn, NY",
            neighborhood: "Greenpoint",
            price: 3100,
            bedrooms: 2,
            bathrooms: 1.0,
            squareFootage: 900,
            propertyType: .apartment,
            amenities: ["Balcony", "Parking"],
            images: ["https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=400"],
            thumbnailURL: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=400",
            coordinates: PropertyCoordinate(latitude: 40.7308, longitude: -73.9501),
            listingDate: Date().addingTimeInterval(-86400 * 4),
            description: "Modern apartment in up-and-coming Greenpoint with parking.",
            contactInfo: ContactInfo(
                agentName: "Agent Davis",
                agentPhone: "555-0104",
                agentEmail: "davis@example.com",
                brokerageName: "Greenpoint Realty",
                brokeragePhone: "555-0100"
            ),
            isSaved: false,
            availableDate: Date().addingTimeInterval(86400 * 20),
            isNewListing: false
        )
    }
    
    private func applyFiltersToProperties(_ properties: [PropertyListing]) -> [PropertyListing] {
        var filteredProperties = properties
        
        if let priceRange = filters.priceRange {
            filteredProperties = filteredProperties.filter { property in
                let price = Double(property.price)
                return price >= priceRange.lowerBound && price <= priceRange.upperBound
            }
        }
        
        if let minBedrooms = filters.minBedrooms {
            filteredProperties = filteredProperties.filter { $0.bedrooms >= minBedrooms }
        }
        
        if let minBathrooms = filters.minBathrooms {
            filteredProperties = filteredProperties.filter { $0.bathrooms >= Double(minBathrooms) }
        }
        
        if !filters.neighborhoods.isEmpty {
            filteredProperties = filteredProperties.filter { property in
                filters.neighborhoods.contains { neighborhood in
                    property.address.contains(neighborhood)
                }
            }
        }
        
        // Shuffle for variety
        return filteredProperties.shuffled()
    }
}

// MARK: - Matchmaker Filters

struct MatchmakerFilters {
    var priceRange: ClosedRange<Double>?
    var minBedrooms: Int?
    var minBathrooms: Int?
    var neighborhoods: [String] = []
    var mustHaveAmenities: [String] = []
    var dealBreakers: [String] = []
    
    var activeFilterNames: [String] {
        var names: [String] = []
        
        if let range = priceRange {
            names.append("$\(Int(range.lowerBound))K-$\(Int(range.upperBound))K")
        }
        
        if let bedrooms = minBedrooms {
            names.append("\(bedrooms)+ bed")
        }
        
        if let bathrooms = minBathrooms {
            names.append("\(bathrooms)+ bath")
        }
        
        names.append(contentsOf: neighborhoods)
        names.append(contentsOf: mustHaveAmenities.map { "Must have: \($0)" })
        names.append(contentsOf: dealBreakers.map { "No: \($0)" })
        
        return names
    }
    
    mutating func clearAll() {
        priceRange = nil
        minBedrooms = nil
        minBathrooms = nil
        neighborhoods.removeAll()
        mustHaveAmenities.removeAll()
        dealBreakers.removeAll()
    }
}
