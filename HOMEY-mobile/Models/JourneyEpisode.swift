import SwiftUI

// MARK: - Journey Episode Model

struct JourneyEpisode: Identifiable, Hashable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let description: String
    let posterImageName: String
    let status: EpisodeStatus
    let progress: Double // 0.0 to 1.0
    let estimatedTime: String
    let actionTitle: String
    let actionType: EpisodeActionType

    init(
        title: String,
        subtitle: String,
        description: String,
        posterImageName: String,
        status: EpisodeStatus,
        progress: Double,
        estimatedTime: String,
        actionTitle: String,
        actionType: EpisodeActionType
    ) {
        id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.posterImageName = posterImageName
        self.status = status
        self.progress = progress
        self.estimatedTime = estimatedTime
        self.actionTitle = actionTitle
        self.actionType = actionType
    }

    // MARK: - Equatable

    static func == (lhs: JourneyEpisode, rhs: JourneyEpisode) -> Bool {
        return lhs.id == rhs.id
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static let sampleEpisodes: [JourneyEpisode] = [
        // Current Episode
        JourneyEpisode(
            title: "Document Prep",
            subtitle: "Gather Your Papers",
            description: "Time to collect all the essential documents you'll need for your home buying journey. We'll guide you through each requirement step by step.",
            posterImageName: "episode_poster_01",
            status: .current,
            progress: 0.6,
            estimatedTime: "15 min",
            actionTitle: "Continue Prep",
            actionType: .`continue`
        ),

        // Upcoming Episodes
        JourneyEpisode(
            title: "Pre-Approval",
            subtitle: "Get Your Budget",
            description: "Connect with lenders to understand your buying power and get pre-approved for a mortgage.",
            posterImageName: "episode_poster_02",
            status: .upcoming,
            progress: 0.0,
            estimatedTime: "30 min",
            actionTitle: "Start Pre-Approval",
            actionType: .start
        ),

        JourneyEpisode(
            title: "Neighborhood Scout",
            subtitle: "Find Your Area",
            description: "Explore different neighborhoods and discover the perfect area that matches your lifestyle and budget.",
            posterImageName: "episode_poster_03",
            status: .upcoming,
            progress: 0.0,
            estimatedTime: "45 min",
            actionTitle: "Explore Areas",
            actionType: .start
        ),

        JourneyEpisode(
            title: "House Hunting",
            subtitle: "Find The One",
            description: "Start viewing properties that match your criteria and budget. We'll help you organize tours and track favorites.",
            posterImageName: "episode_poster_04",
            status: .upcoming,
            progress: 0.0,
            estimatedTime: "Ongoing",
            actionTitle: "Start Hunting",
            actionType: .start
        ),

        JourneyEpisode(
            title: "Make an Offer",
            subtitle: "Seal the Deal",
            description: "Found your dream home? Let's craft a competitive offer that gets you the keys.",
            posterImageName: "episode_poster_05",
            status: .upcoming,
            progress: 0.0,
            estimatedTime: "2 hours",
            actionTitle: "Prepare Offer",
            actionType: .start
        ),

        JourneyEpisode(
            title: "Home Inspection",
            subtitle: "Check Everything",
            description: "Ensure your future home is in great condition with a thorough professional inspection.",
            posterImageName: "episode_poster_06",
            status: .upcoming,
            progress: 0.0,
            estimatedTime: "3 hours",
            actionTitle: "Schedule Inspection",
            actionType: .start
        ),

        // Completed Episodes
        JourneyEpisode(
            title: "Welcome Aboard",
            subtitle: "Your Journey Begins",
            description: "Welcome to HOMEY! Let's get you set up and ready for your home buying adventure.",
            posterImageName: "episode_poster_07",
            status: .completed,
            progress: 1.0,
            estimatedTime: "10 min",
            actionTitle: "Review",
            actionType: .review
        ),

        JourneyEpisode(
            title: "Meet Your Team",
            subtitle: "Your HOMEY Crew",
            description: "Get acquainted with Charlie, Paige, Scout, Drew, Isla, and Viza - your personal home buying team.",
            posterImageName: "episode_poster_08",
            status: .completed,
            progress: 1.0,
            estimatedTime: "5 min",
            actionTitle: "Review",
            actionType: .review
        ),

        JourneyEpisode(
            title: "Set Your Goals",
            subtitle: "Define Your Dream",
            description: "Tell us about your ideal home, budget, and timeline so we can personalize your journey.",
            posterImageName: "episode_poster_09",
            status: .completed,
            progress: 1.0,
            estimatedTime: "15 min",
            actionTitle: "Review",
            actionType: .review
        )
    ]
}

// MARK: - Episode Status

enum EpisodeStatus: Equatable, Hashable {
    case completed
    case current
    case upcoming
    case locked

    var displayName: String {
        switch self {
        case .completed:
            return "Completed"
        case .current:
            return "In Progress"
        case .upcoming:
            return "Coming Soon"
        case .locked:
            return "Locked"
        }
    }

    var color: Color {
        switch self {
        case .completed:
            return .green
        case .current:
            return .blue
        case .upcoming:
            return .orange
        case .locked:
            return .gray
        }
    }
}

// MARK: - Episode Action Type

enum EpisodeActionType: Equatable, Hashable {
    case start
    case `continue`
    case complete
    case review
    case documentUpload
    case lenderConnection
    case neighborhoodExploration
    case propertySearch
    case offerPreparation
    case inspectionScheduling
    case custom(String)

    var systemIcon: String {
        switch self {
        case .start:
            return "play.fill"
        case .`continue`:
            return "arrow.right.circle.fill"
        case .complete:
            return "checkmark.circle.fill"
        case .review:
            return "arrow.clockwise"
        case .documentUpload:
            return "doc.fill"
        case .lenderConnection:
            return "building.columns.fill"
        case .neighborhoodExploration:
            return "map.fill"
        case .propertySearch:
            return "house.fill"
        case .offerPreparation:
            return "hand.raised.fill"
        case .inspectionScheduling:
            return "magnifyingglass"
        case .custom:
            return "star.fill"
        }
    }
}
