import Foundation

/// Represents the different stages of a user's home buying/selling journey
public enum JourneyStage: String, CaseIterable {
    case exploring
    case researching
    case viewing
    case negotiating
    case closing
    case settled

    public var displayName: String {
        switch self {
        case .exploring:
            return "Exploring Options"
        case .researching:
            return "Researching Areas"
        case .viewing:
            return "Viewing Properties"
        case .negotiating:
            return "Making Offers"
        case .closing:
            return "Closing Process"
        case .settled:
            return "Settled In"
        }
    }

    public var description: String {
        switch self {
        case .exploring:
            return "Just starting your journey? Let's explore what's possible."
        case .researching:
            return "Diving deep into neighborhoods and market trends."
        case .viewing:
            return "Actively viewing properties and scheduling tours."
        case .negotiating:
            return "Found the one? Time to make competitive offers."
        case .closing:
            return "Almost there! Handling inspections and paperwork."
        case .settled:
            return "Welcome home! Let's optimize your new space."
        }
    }

    public var smartPicksTitle: String {
        switch self {
        case .exploring:
            return "Getting Started Essentials"
        case .researching:
            return "Market Insights"
        case .viewing:
            return "Property Viewing Tools"
        case .negotiating:
            return "Negotiation Support"
        case .closing:
            return "Closing Checklist"
        case .settled:
            return "Home Optimization"
        }
    }

    public var smartPicksItems: [String] {
        switch self {
        case .exploring:
            return ["Pre-approval Calculator", "Budget Planning Guide", "First-time Buyer Resources"]
        case .researching:
            return ["Neighborhood Comparisons", "School District Info", "Market Trend Analysis"]
        case .viewing:
            return ["Property Checklist", "Virtual Tour Scheduler", "Inspection Guidelines"]
        case .negotiating:
            return ["Offer Strategy Guide", "Comparable Sales Data", "Negotiation Tips"]
        case .closing:
            return ["Document Checklist", "Timeline Tracker", "Moving Preparation"]
        case .settled:
            return ["Home Maintenance Tips", "Local Service Providers", "Community Resources"]
        }
    }
}
