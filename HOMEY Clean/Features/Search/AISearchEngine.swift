import SwiftUI
import Foundation

// MARK: - AI Search Engine

@MainActor
class AISearchEngine: ObservableObject {
    
    func processConversationalQuery(
        query: String,
        context: EmotionalContext,
        userHistory: [SearchQuery]
    ) async throws -> AISearchResult {
        
        // Parse natural language query
        let parsedQuery = parseNaturalLanguage(query)
        
        // Generate contextual suggestions
        let suggestions = generateConversationalSuggestions(
            from: query,
            context: context,
            history: userHistory
        )
        
        // Create predictive filters based on user behavior
        let predictiveFilters = generatePredictiveFilters(
            from: userHistory,
            currentQuery: parsedQuery
        )
        
        // Infer lifestyle preferences
        let lifestyle = inferLifestylePreferences(
            from: query,
            context: context,
            history: userHistory
        )
        
        // Get properties (mock for now, would integrate with real API)
        let properties = await fetchPropertiesWithAI(
            parsedQuery: parsedQuery,
            lifestyle: lifestyle,
            context: context
        )
        
        return AISearchResult(
            properties: properties,
            suggestions: suggestions,
            predictiveFilters: predictiveFilters,
            inferredLifestyle: lifestyle
        )
    }
    
    private func parseNaturalLanguage(_ query: String) -> ParsedQuery {
        let lowercased = query.lowercased()
        
        // Extract price information
        var priceRange: ClosedRange<Int>?
        if lowercased.contains("under") {
            if let price = extractPrice(from: lowercased, pattern: "under.*?(\\d+)") {
                priceRange = 0...price
            }
        } else if lowercased.contains("over") || lowercased.contains("above") {
            if let price = extractPrice(from: lowercased, pattern: "(over|above).*?(\\d+)") {
                priceRange = price...10000
            }
        }
        
        // Extract bedroom count
        var bedrooms: Int?
        if let match = lowercased.range(of: #"\d+\s*(br|bed|bedroom)"#, options: .regularExpression) {
            let bedroomText = String(lowercased[match])
            bedrooms = Int(bedroomText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        }
        
        // Extract neighborhoods
        let neighborhoods = extractNeighborhoods(from: lowercased)
        
        // Extract amenities
        let amenities = extractAmenities(from: lowercased)
        
        // Extract emotional keywords
        let emotionalKeywords = extractEmotionalKeywords(from: lowercased)
        
        return ParsedQuery(
            originalText: query,
            priceRange: priceRange,
            bedrooms: bedrooms,
            neighborhoods: neighborhoods,
            amenities: amenities,
            emotionalKeywords: emotionalKeywords
        )
    }
    
    private func extractPrice(from text: String, pattern: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        if let match = regex.firstMatch(in: text, options: [], range: range) {
            let priceRange = Range(match.range(at: match.numberOfRanges - 1), in: text)
            if let priceRange = priceRange {
                let priceString = String(text[priceRange])
                return Int(priceString.replacingOccurrences(of: ",", with: ""))
            }
        }
        return nil
    }
    
    private func extractNeighborhoods(from text: String) -> [String] {
        let knownNeighborhoods = [
            "brooklyn heights", "park slope", "williamsburg", "dumbo",
            "carroll gardens", "cobble hill", "fort greene", "prospect heights",
            "greenpoint", "red hook", "boerum hill", "gowanus", "bushwick",
            "bed-stuy", "crown heights", "sunset park", "bay ridge"
        ]
        
        return knownNeighborhoods.filter { neighborhood in
            text.contains(neighborhood)
        }
    }
    
    private func extractAmenities(from text: String) -> [String] {
        let amenityKeywords = [
            ("pet", "Pet Friendly"),
            ("dog", "Pet Friendly"),
            ("cat", "Pet Friendly"),
            ("parking", "Parking"),
            ("garage", "Parking"),
            ("laundry", "Laundry"),
            ("gym", "Gym"),
            ("fitness", "Gym"),
            ("doorman", "Doorman"),
            ("elevator", "Elevator"),
            ("balcony", "Balcony"),
            ("terrace", "Outdoor Space"),
            ("dishwasher", "Dishwasher"),
            ("ac", "Air Conditioning"),
            ("air conditioning", "Air Conditioning")
        ]
        
        var amenities: [String] = []
        for (keyword, amenity) in amenityKeywords {
            if text.contains(keyword) && !amenities.contains(amenity) {
                amenities.append(amenity)
            }
        }
        return amenities
    }
    
    private func extractEmotionalKeywords(from text: String) -> [String] {
        let emotionalKeywords = [
            "cozy", "bright", "spacious", "quiet", "vibrant", "modern",
            "charming", "luxury", "affordable", "safe", "walkable",
            "trendy", "historic", "peaceful", "lively", "convenient"
        ]
        
        return emotionalKeywords.filter { keyword in
            text.contains(keyword)
        }
    }
    
    private func generateConversationalSuggestions(
        from query: String,
        context: EmotionalContext,
        history: [SearchQuery]
    ) -> [String] {
        
        var suggestions: [String] = []
        
        // Context-based suggestions
        switch context {
        case .excited:
            suggestions.append("Show me move-in ready places with great natural light")
            suggestions.append("Find trendy neighborhoods with vibrant nightlife")
        case .anxious:
            suggestions.append("Show me safe, quiet neighborhoods with good reviews")
            suggestions.append("Find places with flexible lease terms")
        case .focused:
            suggestions.append("Show me properties within my exact budget range")
            suggestions.append("Find places with the shortest commute to work")
        case .neutral:
            suggestions.append("Show me similar properties in different neighborhoods")
            suggestions.append("Find places with the best value for money")
        }
        
        // History-based suggestions
        if !history.isEmpty {
            let recentSearches = Array(history.suffix(3))
            if recentSearches.allSatisfy({ $0.text.contains("brooklyn") }) {
                suggestions.append("Explore similar options in Queens or Manhattan")
            }
            
            if recentSearches.contains(where: { $0.text.contains("pet") }) {
                suggestions.append("Show me more pet-friendly buildings with dog runs")
            }
        }
        
        return Array(suggestions.prefix(4))
    }
    
    private func generatePredictiveFilters(
        from history: [SearchQuery],
        currentQuery: ParsedQuery
    ) -> [PredictiveFilter] {
        
        var filters: [PredictiveFilter] = []
        
        // Analyze search patterns
        let recentQueries = Array(history.suffix(5))
        
        // Price pattern prediction
        let priceRanges = recentQueries.compactMap { query -> ClosedRange<Int>? in
            // Extract price from historical queries (simplified)
            if query.text.contains("$") {
                return 2000...4000 // Mock extraction
            }
            return nil
        }
        
        if !priceRanges.isEmpty {
            let avgMin = priceRanges.map { $0.lowerBound }.reduce(0, +) / priceRanges.count
            let avgMax = priceRanges.map { $0.upperBound }.reduce(0, +) / priceRanges.count
            
            filters.append(PredictiveFilter(
                type: .priceRange,
                displayName: "Your usual range: $\(avgMin)-\(avgMax)",
                confidence: 0.8,
                suggestedValue: "\(avgMin)-\(avgMax)"
            ))
        }
        
        // Neighborhood pattern prediction
        let mentionedNeighborhoods = recentQueries.flatMap { query in
            extractNeighborhoods(from: query.text.lowercased())
        }
        
        if let mostCommon = mostFrequent(in: mentionedNeighborhoods) {
            filters.append(PredictiveFilter(
                type: .neighborhood,
                displayName: "More in \(mostCommon.capitalized)",
                confidence: 0.7,
                suggestedValue: mostCommon
            ))
        }
        
        // Amenity pattern prediction
        let mentionedAmenities = recentQueries.flatMap { query in
            extractAmenities(from: query.text.lowercased())
        }
        
        if let mostCommon = mostFrequent(in: mentionedAmenities) {
            filters.append(PredictiveFilter(
                type: .amenity,
                displayName: "Usually want: \(mostCommon)",
                confidence: 0.6,
                suggestedValue: mostCommon
            ))
        }
        
        return filters
    }
    
    private func mostFrequent<T: Hashable>(in array: [T]) -> T? {
        let counts = Dictionary(grouping: array, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    private func inferLifestylePreferences(
        from query: String,
        context: EmotionalContext,
        history: [SearchQuery]
    ) -> LifestylePreferences {
        
        let lowercased = query.lowercased()
        var preferences = LifestylePreferences()
        
        // Infer from current query
        if lowercased.contains("quiet") || lowercased.contains("peaceful") {
            preferences.quietness = 0.8
        } else if lowercased.contains("vibrant") || lowercased.contains("nightlife") {
            preferences.socialActivity = 0.9
        }
        
        if lowercased.contains("walkable") || lowercased.contains("transit") {
            preferences.walkability = 0.9
        }
        
        if lowercased.contains("modern") || lowercased.contains("luxury") {
            preferences.modernAmenities = 0.8
        }
        
        if lowercased.contains("family") || lowercased.contains("school") {
            preferences.familyFriendly = 0.9
        }
        
        // Infer from search history patterns
        let allQueries = history.map { $0.text.lowercased() }.joined(separator: " ")
        
        if allQueries.contains("gym") || allQueries.contains("fitness") {
            preferences.fitnessOriented = 0.7
        }
        
        if allQueries.contains("pet") || allQueries.contains("dog") {
            preferences.petFriendly = 0.9
        }
        
        return preferences
    }
    
    private func fetchPropertiesWithAI(
        parsedQuery: ParsedQuery,
        lifestyle: LifestylePreferences,
        context: EmotionalContext
    ) async -> [PropertyListing] {
        
        // Mock AI-enhanced property results
        // In real implementation, this would call ML models and property APIs
        
        var properties = mockProperties()
        
        // Filter by parsed criteria
        if let priceRange = parsedQuery.priceRange {
            properties = properties.filter { property in
                let price = extractPriceValue(from: property.price)
                return priceRange.contains(price)
            }
        }
        
        if let bedrooms = parsedQuery.bedrooms {
            properties = properties.filter { $0.bedrooms == bedrooms }
        }
        
        if !parsedQuery.neighborhoods.isEmpty {
            properties = properties.filter { property in
                parsedQuery.neighborhoods.contains { neighborhood in
                    property.address.lowercased().contains(neighborhood)
                }
            }
        }
        
        // Sort by lifestyle match score
        properties = properties.sorted { prop1, prop2 in
            let score1 = calculateLifestyleMatchScore(property: prop1, lifestyle: lifestyle)
            let score2 = calculateLifestyleMatchScore(property: prop2, lifestyle: lifestyle)
            return score1 > score2
        }
        
        return Array(properties.prefix(20))
    }
    
    private func extractPriceValue(from priceString: String) -> Int {
        let numbers = priceString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers) ?? 0
    }

    private func extractPriceValue(from price: Double) -> Int {
        return Int(price.rounded())
    }
    
    private func calculateLifestyleMatchScore(property: PropertyListing, lifestyle: LifestylePreferences) -> Double {
        var score = 0.0
        
        // Mock scoring based on property characteristics
        // In real implementation, this would use property metadata
        
        if property.address.lowercased().contains("park") && lifestyle.quietness > 0.5 {
            score += 0.3
        }
        
        if property.address.lowercased().contains("williamsburg") && lifestyle.socialActivity > 0.5 {
            score += 0.4
        }
        
        if property.bedrooms >= 2 && lifestyle.familyFriendly > 0.5 {
            score += 0.2
        }
        
        return score
    }
    
    private func mockProperties() -> [PropertyListing] {
        return [
            PropertyListing(
                id: "ai_1",
                address: "123 AI Street, Apt 4B",
                neighborhood: "Tech District",
                price: 4500,
                bedrooms: 2,
                bathrooms: 1.5,
                squareFootage: 850,
                propertyType: .apartment,
                amenities: ["Smart Home", "High-Speed Internet", "Gym"],
                images: ["ai_property_1"],
                thumbnailURL: "ai_property_1",
                coordinates: PropertyCoordinate(latitude: 40.7410, longitude: -73.9896),
                listingDate: Date(),
                description: "AI-optimized apartment with smart features",
                contactInfo: ContactInfo(
                    agentName: "AI Agent",
                    agentPhone: "(555) AI-HOMES",
                    agentEmail: "ai@properties.com",
                    brokerageName: "AI Realty",
                    brokeragePhone: nil
                ),
                isSaved: false,
                availableDate: Date().addingTimeInterval(86400 * 7),
                isNewListing: true
            ),
            PropertyListing(
                id: "ai_2",
                address: "456 Machine Learning Blvd",
                neighborhood: "Innovation Quarter",
                price: 6200,
                bedrooms: 3,
                bathrooms: 2.0,
                squareFootage: 1200,
                propertyType: .condo,
                amenities: ["Rooftop", "Parking", "Pet Friendly"],
                images: ["ai_property_2"],
                thumbnailURL: "ai_property_2",
                coordinates: PropertyCoordinate(latitude: 40.7549, longitude: -73.9707),
                listingDate: Date(),
                description: "Modern condo in tech-forward neighborhood",
                contactInfo: ContactInfo(
                    agentName: "ML Agent",
                    agentPhone: "(555) ML-HOMES",
                    agentEmail: "ml@properties.com",
                    brokerageName: "ML Realty",
                    brokeragePhone: nil
                ),
                isSaved: false,
                availableDate: Date().addingTimeInterval(86400 * 14),
                isNewListing: false
            )
        ]
    }
}

// MARK: - Supporting Models

struct AISearchResult {
    let properties: [PropertyListing]
    let suggestions: [String]
    let predictiveFilters: [PredictiveFilter]
    let inferredLifestyle: LifestylePreferences
}

struct ParsedQuery {
    let originalText: String
    let priceRange: ClosedRange<Int>?
    let bedrooms: Int?
    let neighborhoods: [String]
    let amenities: [String]
    let emotionalKeywords: [String]
}

struct PredictiveFilter {
    let type: PredictiveFilterType
    let displayName: String
    let confidence: Double
    let suggestedValue: String
}

enum PredictiveFilterType {
    case priceRange
    case neighborhood
    case amenity
    case bedrooms
    case lifestyle
}

struct LifestylePreferences {
    var quietness: Double = 0.5
    var socialActivity: Double = 0.5
    var walkability: Double = 0.5
    var modernAmenities: Double = 0.5
    var familyFriendly: Double = 0.5
    var fitnessOriented: Double = 0.5
    var petFriendly: Double = 0.5
}

enum EmotionalContext {
    case excited
    case anxious
    case focused
    case neutral
}

struct SearchQuery {
    let text: String
    let timestamp: Date
    let emotionalContext: EmotionalContext
    let resultCount: Int
}