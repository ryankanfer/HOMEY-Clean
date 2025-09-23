import SwiftUI
import Foundation

// MARK: - Emotional Property Matcher

@MainActor
class EmotionalPropertyMatcher: ObservableObject {
    
    func matchProperties(
        properties: [PropertyListing],
        emotionalContext: EmotionalContext,
        lifestyle: LifestylePreferences
    ) async -> [PropertyListing] {
        
        var enhancedProperties: [EnhancedProperty] = []
        
        for property in properties {
            let emotionalScore = await calculateEmotionalScore(
                property: property,
                context: emotionalContext,
                lifestyle: lifestyle
            )
            
            let lifestyleMatch = calculateLifestyleMatch(
                property: property,
                lifestyle: lifestyle
            )
            
            let enhancedProperty = EnhancedProperty(
                property: property,
                emotionalScore: emotionalScore,
                lifestyleMatch: lifestyleMatch,
                personalizedInsights: generatePersonalizedInsights(
                    property: property,
                    context: emotionalContext,
                    lifestyle: lifestyle
                )
            )
            
            enhancedProperties.append(enhancedProperty)
        }
        
        // Sort by combined emotional and lifestyle scores
        enhancedProperties.sort { prop1, prop2 in
            let score1 = (prop1.emotionalScore * 0.6) + (prop1.lifestyleMatch * 0.4)
            let score2 = (prop2.emotionalScore * 0.6) + (prop2.lifestyleMatch * 0.4)
            return score1 > score2
        }
        
        return enhancedProperties.map { $0.property }
    }
    
    private func calculateEmotionalScore(
        property: PropertyListing,
        context: EmotionalContext,
        lifestyle: LifestylePreferences
    ) async -> Double {
        
        var score = 0.5 // Base score
        
        let address = property.address.lowercased()
        let neighborhood = extractNeighborhood(from: address)
        
        switch context {
        case .excited:
            // Look for vibrant, trendy areas
            if isVibrantNeighborhood(neighborhood) {
                score += 0.3
            }
            if hasModernAmenities(property) {
                score += 0.2
            }
            
        case .anxious:
            // Prioritize safety, stability, good reviews
            if isSafeNeighborhood(neighborhood) {
                score += 0.4
            }
            if hasReliableAmenities(property) {
                score += 0.2
            }
            
        case .focused:
            // Emphasize practical aspects, value
            if hasGoodValue(property) {
                score += 0.3
            }
            if hasEssentialAmenities(property) {
                score += 0.2
            }
            
        case .neutral:
            // Balanced scoring
            score += calculateBalancedScore(property, neighborhood)
        }
        
        return min(1.0, max(0.0, score))
    }
    
    private func calculateLifestyleMatch(
        property: PropertyListing,
        lifestyle: LifestylePreferences
    ) -> Double {
        
        var score = 0.0
        let address = property.address.lowercased()
        let neighborhood = extractNeighborhood(from: address)
        
        // Quietness preference
        if lifestyle.quietness > 0.7 {
            if isQuietNeighborhood(neighborhood) {
                score += 0.15
            }
        } else if lifestyle.quietness < 0.3 {
            if isLivelyNeighborhood(neighborhood) {
                score += 0.15
            }
        }
        
        // Social activity preference
        if lifestyle.socialActivity > 0.7 {
            if hasNightlife(neighborhood) {
                score += 0.15
            }
        }
        
        // Walkability preference
        if lifestyle.walkability > 0.7 {
            if isWalkable(neighborhood) {
                score += 0.15
            }
        }
        
        // Modern amenities preference
        if lifestyle.modernAmenities > 0.7 {
            if hasModernAmenities(property) {
                score += 0.15
            }
        }
        
        // Family-friendly preference
        if lifestyle.familyFriendly > 0.7 {
            if isFamilyFriendly(neighborhood) && property.bedrooms >= 2 {
                score += 0.2
            }
        }
        
        // Fitness-oriented preference
        if lifestyle.fitnessOriented > 0.7 {
            if hasFitnessAccess(neighborhood) {
                score += 0.1
            }
        }
        
        // Pet-friendly preference
        if lifestyle.petFriendly > 0.7 {
            if isPetFriendly(neighborhood) {
                score += 0.1
            }
        }
        
        return min(1.0, score)
    }
    
    private func generatePersonalizedInsights(
        property: PropertyListing,
        context: EmotionalContext,
        lifestyle: LifestylePreferences
    ) -> [PropertyInsight] {
        
        var insights: [PropertyInsight] = []
        let address = property.address.lowercased()
        let neighborhood = extractNeighborhood(from: address)
        
        // Context-based insights
        switch context {
        case .excited:
            if isVibrantNeighborhood(neighborhood) {
                insights.append(PropertyInsight(
                    type: .lifestyle,
                    title: "Perfect for Your Energy!",
                    description: "This vibrant neighborhood matches your excitement with trendy cafes and nightlife.",
                    confidence: 0.8
                ))
            }
            
        case .anxious:
            if isSafeNeighborhood(neighborhood) {
                insights.append(PropertyInsight(
                    type: .safety,
                    title: "Peace of Mind",
                    description: "This area has excellent safety ratings and a strong community feel.",
                    confidence: 0.9
                ))
            }
            
        case .focused:
            if hasGoodValue(property) {
                insights.append(PropertyInsight(
                    type: .value,
                    title: "Smart Investment",
                    description: "Great value for money with strong rental history in this area.",
                    confidence: 0.7
                ))
            }
            
        case .neutral:
            insights.append(PropertyInsight(
                type: .general,
                title: "Well-Rounded Choice",
                description: "Balanced option with good amenities and neighborhood features.",
                confidence: 0.6
            ))
        }
        
        // Lifestyle-based insights
        if lifestyle.walkability > 0.7 && isWalkable(neighborhood) {
            insights.append(PropertyInsight(
                type: .transportation,
                title: "Walker's Paradise",
                description: "Walk Score of 95+ with subway, shops, and restaurants within blocks.",
                confidence: 0.8
            ))
        }
        
        if lifestyle.familyFriendly > 0.7 && isFamilyFriendly(neighborhood) {
            insights.append(PropertyInsight(
                type: .family,
                title: "Family Haven",
                description: "Top-rated schools and family activities nearby.",
                confidence: 0.8
            ))
        }
        
        if lifestyle.petFriendly > 0.7 && isPetFriendly(neighborhood) {
            insights.append(PropertyInsight(
                type: .pets,
                title: "Pet Paradise",
                description: "Dog runs, pet stores, and vet clinics all within walking distance.",
                confidence: 0.7
            ))
        }
        
        return insights
    }
    
    // MARK: - Neighborhood Analysis Helpers
    
    private func extractNeighborhood(from address: String) -> String {
        let neighborhoods = [
            "brooklyn heights", "park slope", "williamsburg", "dumbo",
            "carroll gardens", "cobble hill", "fort greene", "prospect heights",
            "greenpoint", "red hook", "boerum hill", "gowanus"
        ]
        
        for neighborhood in neighborhoods {
            if address.contains(neighborhood) {
                return neighborhood
            }
        }
        return "unknown"
    }
    
    private func isVibrantNeighborhood(_ neighborhood: String) -> Bool {
        let vibrantAreas = ["williamsburg", "dumbo", "park slope", "fort greene"]
        return vibrantAreas.contains(neighborhood)
    }
    
    private func isSafeNeighborhood(_ neighborhood: String) -> Bool {
        let safeAreas = ["brooklyn heights", "park slope", "cobble hill", "carroll gardens", "prospect heights"]
        return safeAreas.contains(neighborhood)
    }
    
    private func isQuietNeighborhood(_ neighborhood: String) -> Bool {
        let quietAreas = ["brooklyn heights", "cobble hill", "carroll gardens", "boerum hill"]
        return quietAreas.contains(neighborhood)
    }
    
    private func isLivelyNeighborhood(_ neighborhood: String) -> Bool {
        let livelyAreas = ["williamsburg", "dumbo", "fort greene", "greenpoint"]
        return livelyAreas.contains(neighborhood)
    }
    
    private func hasNightlife(_ neighborhood: String) -> Bool {
        let nightlifeAreas = ["williamsburg", "park slope", "fort greene", "greenpoint"]
        return nightlifeAreas.contains(neighborhood)
    }
    
    private func isWalkable(_ neighborhood: String) -> Bool {
        let walkableAreas = ["brooklyn heights", "dumbo", "park slope", "williamsburg", "fort greene"]
        return walkableAreas.contains(neighborhood)
    }
    
    private func isFamilyFriendly(_ neighborhood: String) -> Bool {
        let familyAreas = ["park slope", "carroll gardens", "cobble hill", "prospect heights", "boerum hill"]
        return familyAreas.contains(neighborhood)
    }
    
    private func hasFitnessAccess(_ neighborhood: String) -> Bool {
        let fitnessAreas = ["williamsburg", "dumbo", "park slope", "fort greene"]
        return fitnessAreas.contains(neighborhood)
    }
    
    private func isPetFriendly(_ neighborhood: String) -> Bool {
        let petFriendlyAreas = ["park slope", "carroll gardens", "fort greene", "prospect heights"]
        return petFriendlyAreas.contains(neighborhood)
    }
    
    // MARK: - Property Analysis Helpers
    
    private func hasModernAmenities(_ property: PropertyListing) -> Bool {
        // Mock analysis - in real app, would check property amenities
        return (property.squareFootage ?? 0) > 800 || property.bathrooms >= 2
    }
    
    private func hasReliableAmenities(_ property: PropertyListing) -> Bool {
        // Mock analysis for essential, reliable features
        return property.bedrooms >= 1 && property.bathrooms >= 1
    }
    
    private func hasGoodValue(_ property: PropertyListing) -> Bool {
        // Mock value analysis
        guard let sqft = property.squareFootage, sqft > 0 else { return false }
        let pricePerSqft = property.price / Double(sqft)
        return pricePerSqft < 4.5 // Reasonable price per sqft
    }
    
    private func hasEssentialAmenities(_ property: PropertyListing) -> Bool {
        // Mock analysis for practical amenities
        return (property.squareFootage ?? 0) >= 600 && property.bedrooms >= 1
    }
    
    private func calculateBalancedScore(_ property: PropertyListing, _ neighborhood: String) -> Double {
        var score = 0.0
        
        if isSafeNeighborhood(neighborhood) { score += 0.1 }
        if isWalkable(neighborhood) { score += 0.1 }
        if hasGoodValue(property) { score += 0.1 }
        
        return score
    }
    
    private func extractPriceValue(from priceString: String) -> Int {
        let numbers = priceString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers) ?? 3000 // Default fallback
    }
}

// MARK: - Supporting Models

struct EnhancedProperty {
    let property: PropertyListing
    let emotionalScore: Double
    let lifestyleMatch: Double
    let personalizedInsights: [PropertyInsight]
}

struct PropertyInsight {
    let type: PropertyInsightType
    let title: String
    let description: String
    let confidence: Double
}

enum PropertyInsightType {
    case lifestyle
    case safety
    case value
    case transportation
    case family
    case pets
    case general
    
    var icon: String {
        switch self {
        case .lifestyle: return "heart.fill"
        case .safety: return "shield.fill"
        case .value: return "dollarsign.circle.fill"
        case .transportation: return "figure.walk"
        case .family: return "house.fill"
        case .pets: return "pawprint.fill"
        case .general: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .lifestyle: return .pink
        case .safety: return .green
        case .value: return .blue
        case .transportation: return .orange
        case .family: return .purple
        case .pets: return .brown
        case .general: return .gray
        }
    }
}