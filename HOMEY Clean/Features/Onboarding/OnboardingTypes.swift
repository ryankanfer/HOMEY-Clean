import SwiftUI

// MARK: - Onboarding Stage
enum OnboardingStage: String, CaseIterable {
    case welcome = "welcome"
    case role = "role"
    case goals = "goals"
    case lifestyle = "lifestyle"
    case preferences = "preferences"
    case team = "team"
    case complete = "complete"
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .role:
            return "Your Role"
        case .goals:
            return "Your Goals"
        case .lifestyle:
            return "Lifestyle"
        case .preferences:
            return "Preferences"
        case .team:
            return "Meet Your Team"
        case .complete:
            return "Complete"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome:
            return "Let's get started with your journey"
        case .role:
            return "Tell us about your real estate needs"
        case .goals:
            return "What are you hoping to achieve?"
        case .lifestyle:
            return "Help us understand your preferences"
        case .preferences:
            return "Fine-tune your experience"
        case .team:
            return "Your AI-powered support team"
        case .complete:
            return "You're all set!"
        }
    }
}

// MARK: - Onboarding Goal
struct OnboardingGoal: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: GoalCategory
    
    enum GoalCategory {
        case buying
        case selling
        case renting
        case investing
        case general
    }
    
    static let allGoals: [OnboardingGoal] = [
        OnboardingGoal(
            id: "find_home",
            title: "Find My Dream Home",
            description: "Search for the perfect property",
            icon: "house.fill",
            category: .buying
        ),
        OnboardingGoal(
            id: "sell_property",
            title: "Sell My Property",
            description: "Get the best price for my home",
            icon: "dollarsign.circle.fill",
            category: .selling
        ),
        OnboardingGoal(
            id: "rent_apartment",
            title: "Find Rental",
            description: "Discover great rental properties",
            icon: "key.fill",
            category: .renting
        ),
        OnboardingGoal(
            id: "investment",
            title: "Investment Property",
            description: "Build wealth through real estate",
            icon: "chart.line.uptrend.xyaxis",
            category: .investing
        ),
        OnboardingGoal(
            id: "market_research",
            title: "Market Research",
            description: "Learn about market trends",
            icon: "magnifyingglass",
            category: .general
        ),
        OnboardingGoal(
            id: "refinance",
            title: "Refinance",
            description: "Lower my mortgage payments",
            icon: "percent",
            category: .general
        )
    ]
}