import SwiftUI
import Combine

@MainActor
class MatchmakerViewModel: ObservableObject {
    @Published var properties: [Property] = []
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
    
    func saveProperty(_ property: Property) {
        recordEvent(.saveProperty(propertyId: property.id))
        print("💖 Saved property: \(property.address)")
    }
    
    func passProperty(_ property: Property) {
        recordEvent(.listingSave(listingId: property.id, action: "pass"))
        print("❌ Passed on property: \(property.address)")
    }
    
    func requestTour(_ property: Property) {
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
    
    private func generatePersonalizedProperties() -> [Property] {
        let baseProperties = [
            Property(
                id: "match_1",
                address: "456 Cobble Hill, Brooklyn, NY",
                price: "$3,400/mo",
                bedrooms: 2,
                bathrooms: 1,
                sqft: 950,
                imageUrl: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400"
            ),
            Property(
                id: "match_2",
                address: "789 Carroll Gardens, Brooklyn, NY",
                price: "$2,900/mo",
                bedrooms: 1,
                bathrooms: 1,
                sqft: 800,
                imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400"
            ),
            Property(
                id: "agent_exclusive",
                address: "321 DUMBO, Brooklyn, NY",
                price: "$4,200/mo",
                bedrooms: 2,
                bathrooms: 2,
                sqft: 1100,
                imageUrl: "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400"
            ),
            Property(
                id: "match_4",
                address: "654 Greenpoint, Brooklyn, NY",
                price: "$3,100/mo",
                bedrooms: 2,
                bathrooms: 1,
                sqft: 900,
                imageUrl: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=400"
            ),
            Property(
                id: "match_5",
                address: "987 Red Hook, Brooklyn, NY",
                price: "$2,700/mo",
                bedrooms: 1,
                bathrooms: 1,
                sqft: 700,
                imageUrl: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400"
            ),
            Property(
                id: "match_6",
                address: "147 Boerum Hill, Brooklyn, NY",
                price: "$3,600/mo",
                bedrooms: 2,
                bathrooms: 2,
                sqft: 1000,
                imageUrl: "https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=400"
            ),
            Property(
                id: "match_7",
                address: "258 Fort Greene, Brooklyn, NY",
                price: "$3,300/mo",
                bedrooms: 2,
                bathrooms: 1,
                sqft: 950,
                imageUrl: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400"
            ),
            Property(
                id: "match_8",
                address: "369 Prospect Heights, Brooklyn, NY",
                price: "$3,800/mo",
                bedrooms: 3,
                bathrooms: 2,
                sqft: 1200,
                imageUrl: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400"
            )
        ]
        
        // Apply filters if any are active
        var filteredProperties = baseProperties
        
        if let priceRange = filters.priceRange {
            filteredProperties = filteredProperties.filter { property in
                let price = Double(property.price.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "/mo", with: "").replacingOccurrences(of: ",", with: "")) ?? 0
                return price >= priceRange.lowerBound && price <= priceRange.upperBound
            }
        }
        
        if let minBedrooms = filters.minBedrooms {
            filteredProperties = filteredProperties.filter { $0.bedrooms >= minBedrooms }
        }
        
        if let minBathrooms = filters.minBathrooms {
            filteredProperties = filteredProperties.filter { $0.bathrooms >= minBathrooms }
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