import Foundation

/// Represents the different stages of a user's home buying/selling journey
public enum JourneyStage: String, CaseIterable, Codable {
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
            return "Every great love story starts with a single glance. Let's discover what makes your heart skip a beat."
        case .researching:
            return "Getting to know the neighborhoods that could become your backdrop for life's beautiful moments."
        case .viewing:
            return "Walking through doors that might lead to your forever. Each visit brings you closer to home."
        case .negotiating:
            return "You've found 'the one' - now let's make sure they choose you too. Your future is worth fighting for."
        case .closing:
            return "The final chapter before your new beginning. Soon you'll hold the keys to your dreams."
        case .settled:
            return "Welcome home, beautiful soul. This is where your story truly begins to unfold."
        }
    }
    
    public var storyMilestone: String {
        switch self {
        case .exploring:
            return "Finding Your Perfect Match"
        case .researching:
            return "Getting to Know Each Other"
        case .viewing:
            return "First Dates & Chemistry"
        case .negotiating:
            return "Popping the Question"
        case .closing:
            return "Planning the Wedding"
        case .settled:
            return "Happily Ever After"
        }
    }
    
    public var emotionalContext: String {
        switch self {
        case .exploring:
            return "The excitement of endless possibilities awaits you"
        case .researching:
            return "Knowledge is power - you're building confidence with every insight"
        case .viewing:
            return "Trust your instincts - you'll know when you've found home"
        case .negotiating:
            return "Stay strong - your perfect home is worth the effort"
        case .closing:
            return "Take a deep breath - you're almost there"
        case .settled:
            return "Celebrate this incredible achievement - you did it!"
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
