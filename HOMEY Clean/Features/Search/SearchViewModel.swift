import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [PropertyListing] = []
    @Published var recommendations: [PropertyListing] = []
    @Published var activeFilters: [SearchFilter] = []
    @Published var filters = SearchFilters()
    @Published var isSearching = false
    @Published var showFilters = false
    @Published var conversationalSuggestions: [String] = []
    @Published var emotionalContext: EmotionalContext = .neutral
    @Published var predictiveFilters: [PredictiveFilter] = []
    @Published var searchHistory: [SearchQuery] = []
    
    private let eventsRepository = EventsRepository()
    private var cancellables = Set<AnyCancellable>()
    private let aiSearchEngine = AISearchEngine()
    private let emotionalMatcher = EmotionalPropertyMatcher()
    
    init() {
        loadMockData()
    }
    
    // MARK: - Search Functions
    
    func performSearch(query: String) {
        guard !query.isEmpty else { return }
        
        isSearching = true
        
        // Record search query for learning
        let searchQuery = SearchQuery(
            text: query,
            timestamp: Date(),
            emotionalContext: emotionalContext,
            resultCount: 0
        )
        searchHistory.append(searchQuery)
        
        // AI-powered conversational search
        Task {
            do {
                let aiResults = try await aiSearchEngine.processConversationalQuery(
                    query: query,
                    context: emotionalContext,
                    userHistory: searchHistory
                )
                
                // Apply emotional property matching
                let emotionallyMatchedResults = await emotionalMatcher.matchProperties(
                    properties: aiResults.properties,
                    emotionalContext: emotionalContext,
                    lifestyle: aiResults.inferredLifestyle
                )
                
                await MainActor.run {
                    self.searchResults = emotionallyMatchedResults
                    self.conversationalSuggestions = aiResults.suggestions
                    self.predictiveFilters = aiResults.predictiveFilters
                    self.isSearching = false
                    
                    // Update search history with result count
                    if let lastQuery = self.searchHistory.last {
                        self.searchHistory[self.searchHistory.count - 1] = SearchQuery(
                            text: lastQuery.text,
                            timestamp: lastQuery.timestamp,
                            emotionalContext: lastQuery.emotionalContext,
                            resultCount: emotionallyMatchedResults.count
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    // Fallback to traditional search
                    self.searchResults = self.mockSearchResults(for: query)
                    self.isSearching = false
                }
            }
        }
    }
    
    func loadRecommendations() {
        recommendations = mockRecommendations()
        recordEvent(.listingView(listingId: "recommendations", source: "search"))
    }
    
    func refreshRecommendations() async {
        await MainActor.run {
            loadRecommendations()
        }
    }
    
    // MARK: - Filter Functions
    
    func applyFilters() {
        activeFilters = filters.activeFilters
        showFilters = false
        
        // Apply filters to search results or recommendations
        if !searchResults.isEmpty {
            searchResults = applyFiltersToProperties(searchResults)
        } else {
            recommendations = applyFiltersToProperties(recommendations)
        }
        
        recordEvent(.searchQuery(query: "", filters: ["filters": activeFilters.map { $0.displayName }]))
    }
    
    func removeFilter(_ filter: SearchFilter) {
        activeFilters.removeAll { $0.id == filter.id }
        filters.removeFilter(filter)
        
        // Reapply remaining filters
        if !searchResults.isEmpty {
            searchResults = applyFiltersToProperties(mockSearchResults(for: ""))
        } else {
            recommendations = applyFiltersToProperties(mockRecommendations())
        }
    }
    
    func clearAllFilters() {
        activeFilters.removeAll()
        filters.clearAll()
        
        // Reset to unfiltered results
        if !searchResults.isEmpty {
            searchResults = mockSearchResults(for: "")
        } else {
            recommendations = mockRecommendations()
        }
    }
    
    // MARK: - Property Actions
    
    func saveProperty(_ property: PropertyListing) {
        recordEvent(.saveProperty(propertyId: property.id))
        print("💖 Saved property: \(property.address)")
    }
    
    func requestTour(_ property: PropertyListing) {
        recordEvent(.requestTour(propertyId: property.id))
        print("📅 Requested tour for: \(property.address)")
    }
    
    // MARK: - Event Tracking
    
    func recordEvent(_ event: HomeyEvent) {
        Task { await eventsRepository.recordEvent(event) }
    }
    
    // MARK: - Private Helper Functions
    
    private func applyFiltersToProperties(_ properties: [PropertyListing]) -> [PropertyListing] {
        var filteredProperties = properties
        
        // Apply price filter
        if let priceRange = filters.priceRange {
            filteredProperties = filteredProperties.filter { property in
                let price = Double(property.price)
                return price >= priceRange.lowerBound && price <= priceRange.upperBound
            }
        }
        
        // Apply bedroom filter
        if let minBedrooms = filters.minBedrooms {
            filteredProperties = filteredProperties.filter { $0.bedrooms >= minBedrooms }
        }
        
        // Apply bathroom filter
        if let minBathrooms = filters.minBathrooms {
            filteredProperties = filteredProperties.filter { $0.bathrooms >= Double(minBathrooms) }
        }
        
        // Apply neighborhood filter
        if !filters.neighborhoods.isEmpty {
            filteredProperties = filteredProperties.filter { property in
                filters.neighborhoods.contains(property.neighborhood ?? "")
            }
        }
        
        // Apply amenities filter
        if !filters.amenities.isEmpty {
            filteredProperties = filteredProperties.filter { property in
                filters.amenities.allSatisfy { amenity in
                    property.amenities.contains(amenity)
                }
            }
        }
        
        return filteredProperties
    }
    
    private func mockSearchResults(for query: String) -> [PropertyListing] {
        // Return mock search results based on query
        return mockRecommendations().prefix(3).map { $0 }
    }
    
    private func mockRecommendations() -> [PropertyListing] {
        return [
            PropertyListing(
                id: "rec_1",
                address: "123 Brooklyn Heights, Brooklyn, NY",
                neighborhood: "Brooklyn Heights",
                price: 3200,
                bedrooms: 2,
                bathrooms: 1.0,
                squareFootage: 850,
                propertyType: .apartment,
                amenities: ["Gym", "Rooftop"],
                images: ["https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400"],
                thumbnailURL: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400",
                coordinates: PropertyCoordinate(latitude: 40.6962, longitude: -73.9961),
                listingDate: Date().addingTimeInterval(-86400 * 2),
                description: "Beautiful apartment in Brooklyn Heights with stunning views.",
                contactInfo: ContactInfo(
                    agentName: "Agent Wilson",
                    agentPhone: "555-0201",
                    agentEmail: "wilson@example.com",
                    brokerageName: "Brooklyn Realty",
                    brokeragePhone: "555-0200"
                ),
                isSaved: false,
                availableDate: Date().addingTimeInterval(86400 * 7),
                isNewListing: true
            ),
            PropertyListing(
                id: "rec_2",
                address: "456 Park Slope, Brooklyn, NY",
                neighborhood: "Park Slope",
                price: 2800,
                bedrooms: 1,
                bathrooms: 1.0,
                squareFootage: 750,
                propertyType: .apartment,
                amenities: ["Laundry", "Pet Friendly"],
                images: ["https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400"],
                thumbnailURL: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400",
                coordinates: PropertyCoordinate(latitude: 40.6782, longitude: -73.9776),
                listingDate: Date().addingTimeInterval(-86400 * 1),
                description: "Cozy apartment in trendy Park Slope neighborhood.",
                contactInfo: ContactInfo(
                    agentName: "Agent Taylor",
                    agentPhone: "555-0202",
                    agentEmail: "taylor@example.com",
                    brokerageName: "Park Slope Properties",
                    brokeragePhone: "555-0200"
                ),
                isSaved: false,
                availableDate: Date().addingTimeInterval(86400 * 14),
                isNewListing: false
            )
        ]
    }
    
    private func loadMockData() {
        recommendations = mockRecommendations()
    }
}

// MARK: - Supporting Structures

struct SearchFilter: Identifiable {
    let id = UUID()
    let type: FilterType
    let displayName: String
    let priceRange: ClosedRange<Double>?
    let bedrooms: Int?
    let bathrooms: Int?
    let neighborhood: String?
    let amenities: [String]?
    
    enum FilterType {
        case priceRange
        case bedrooms
        case bathrooms
        case neighborhood
        case amenities
    }
}

struct SearchFilters {
    var priceRange: ClosedRange<Double>?
    var minBedrooms: Int?
    var minBathrooms: Int?
    var neighborhoods: [String] = []
    var amenities: [String] = []
    
    var activeFilters: [SearchFilter] {
        var filters: [SearchFilter] = []
        
        if let range = priceRange {
            filters.append(SearchFilter(
                type: .priceRange,
                displayName: "$\(Int(range.lowerBound))K - $\(Int(range.upperBound))K",
                priceRange: range,
                bedrooms: nil,
                bathrooms: nil,
                neighborhood: nil,
                amenities: nil
            ))
        }
        
        if let bedrooms = minBedrooms {
            filters.append(SearchFilter(
                type: .bedrooms,
                displayName: "\(bedrooms)+ bed",
                priceRange: nil,
                bedrooms: bedrooms,
                bathrooms: nil,
                neighborhood: nil,
                amenities: nil
            ))
        }
        
        if let bathrooms = minBathrooms {
            filters.append(SearchFilter(
                type: .bathrooms,
                displayName: "\(bathrooms)+ bath",
                priceRange: nil,
                bedrooms: nil,
                bathrooms: bathrooms,
                neighborhood: nil,
                amenities: nil
            ))
        }
        
        for neighborhood in neighborhoods {
            filters.append(SearchFilter(
                type: .neighborhood,
                displayName: neighborhood,
                priceRange: nil,
                bedrooms: nil,
                bathrooms: nil,
                neighborhood: neighborhood,
                amenities: nil
            ))
        }
        
        if !amenities.isEmpty {
            filters.append(SearchFilter(
                type: .amenities,
                displayName: "Amenities (\(amenities.count))",
                priceRange: nil,
                bedrooms: nil,
                bathrooms: nil,
                neighborhood: nil,
                amenities: amenities
            ))
        }
        
        return filters
    }
    
    mutating func removeFilter(_ filter: SearchFilter) {
        switch filter.type {
        case .priceRange:
            priceRange = nil
        case .bedrooms:
            minBedrooms = nil
        case .bathrooms:
            minBathrooms = nil
        case .neighborhood:
            if let neighborhood = filter.neighborhood {
                neighborhoods.removeAll { $0 == neighborhood }
            }
        case .amenities:
            amenities.removeAll()
        }
    }
    
    mutating func clearAll() {
        priceRange = nil
        minBedrooms = nil
        minBathrooms = nil
        neighborhoods.removeAll()
        amenities.removeAll()
    }
}