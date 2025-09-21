import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [Property] = []
    @Published var recommendations: [Property] = []
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
    
    func saveProperty(_ property: Property) {
        recordEvent(.saveProperty(propertyId: property.id))
        // TODO: Implement save to favorites
    }
    
    func requestTour(_ property: Property) {
        recordEvent(.requestTour(propertyId: property.id))
        // TODO: Implement tour request
    }
    
    // MARK: - Event Tracking
    
    func recordEvent(_ event: HomeyEvent) {
        Task { await eventsRepository.recordEvent(event) }
    }
    
    // MARK: - Private Helper Functions
    
    private func applyFiltersToProperties(_ properties: [Property]) -> [Property] {
        var filtered = properties
        
        for filter in activeFilters {
            switch filter.type {
            case .priceRange:
                if let range = filter.priceRange {
                    filtered = filtered.filter { property in
                        let price = Double(property.price.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) ?? 0
                        return price >= range.lowerBound && price <= range.upperBound
                    }
                }
            case .bedrooms:
                if let bedrooms = filter.bedrooms {
                    filtered = filtered.filter { $0.bedrooms >= bedrooms }
                }
            case .bathrooms:
                if let bathrooms = filter.bathrooms {
                    filtered = filtered.filter { $0.bathrooms >= bathrooms }
                }
            case .neighborhood:
                if let neighborhood = filter.neighborhood {
                    filtered = filtered.filter { $0.address.contains(neighborhood) }
                }
            case .amenities:
                // TODO: Implement amenities filtering
                break
            }
        }
        
        return filtered
    }
    
    private func mockSearchResults(for query: String) -> [Property] {
        let allProperties = mockRecommendations()
        
        if query.isEmpty {
            return allProperties
        }
        
        // Simple search filtering based on query
        return allProperties.filter { property in
            property.address.localizedCaseInsensitiveContains(query) ||
            property.price.localizedCaseInsensitiveContains(query)
        }
    }
    
    private func mockRecommendations() -> [Property] {
        return [
            Property(
                id: "1",
                address: "123 Brooklyn Heights, Brooklyn, NY",
                price: "$3,200/mo",
                bedrooms: 2,
                bathrooms: 1,
                sqft: 900,
                imageUrl: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400"
            ),
            Property(
                id: "2",
                address: "456 Park Slope, Brooklyn, NY",
                price: "$2,800/mo",
                bedrooms: 1,
                bathrooms: 1,
                sqft: 750,
                imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400"
            ),
            Property(
                id: "3",
                address: "789 Williamsburg, Brooklyn, NY",
                price: "$4,100/mo",
                bedrooms: 3,
                bathrooms: 2,
                sqft: 1200,
                imageUrl: "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400"
            ),
            Property(
                id: "4",
                address: "321 Lower East Side, Manhattan, NY",
                price: "$3,800/mo",
                bedrooms: 2,
                bathrooms: 2,
                sqft: 1000,
                imageUrl: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=400"
            ),
            Property(
                id: "5",
                address: "654 Astoria, Queens, NY",
                price: "$2,400/mo",
                bedrooms: 1,
                bathrooms: 1,
                sqft: 650,
                imageUrl: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400"
            )
        ]
    }
    
    private func loadMockData() {
        recommendations = mockRecommendations()
    }
}

// MARK: - Models

struct Property: Identifiable, Codable {
    let id: String
    let address: String
    let price: String
    let bedrooms: Int
    let bathrooms: Int
    let sqft: Int
    let imageUrl: String
}

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