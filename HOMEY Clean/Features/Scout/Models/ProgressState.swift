import Foundation
import SwiftUI

// MARK: - Progress State Model

@Observable
class ProgressState: Codable {
    var totalSaves: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastSaveDate: Date?
    var unlockedNeighborhoods: Set<String> = []
    var completedTours: Int = 0
    var achievements: [Achievement] = []
    var milestones: [Milestone] = []
    var lastProgressionEvent: ProgressionEvent?

    // MARK: - Computed Properties

    var isOnStreak: Bool {
        guard let lastSave = lastSaveDate else { return false }
        let daysSinceLastSave = Calendar.current.dateComponents([.day], from: lastSave, to: Date()).day ?? 0
        return daysSinceLastSave <= 1
    }

    var nextMilestone: Milestone? {
        return Milestone.allMilestones.first { milestone in
            !milestones.contains { $0.id == milestone.id } && milestone.isUnlocked(for: self)
        }
    }

    var progressToNextMilestone: Double {
        guard let next = nextMilestone else { return 1.0 }
        return next.progress(for: self)
    }

    // MARK: - Methods

    func recordSave(in neighborhood: String) {
        totalSaves += 1

        // Update streak
        if let lastSave = lastSaveDate {
            let daysSinceLastSave = Calendar.current.dateComponents([.day], from: lastSave, to: Date()).day ?? 0
            if daysSinceLastSave == 1 {
                currentStreak += 1
            } else if daysSinceLastSave > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastSaveDate = Date()

        // Check for progression events
        checkForProgressionEvents(neighborhood: neighborhood)
    }

    func recordTourCompletion() {
        completedTours += 1
        checkForProgressionEvents()
    }

    private func checkForProgressionEvents(neighborhood: String? = nil) {
        var events: [ProgressionEvent] = []

        // First save
        if totalSaves == 1 {
            events.append(.trailStarted)
        }

        // Neighborhood unlock (every 10 saves)
        if totalSaves % 10 == 0, let neighborhood = neighborhood {
            unlockedNeighborhoods.insert(neighborhood)
            events.append(.neighborhoodUnlocked(neighborhood))
        }

        // Streak milestones
        if currentStreak == 3 {
            events.append(.streakAchieved(3))
        } else if currentStreak == 7 {
            events.append(.streakAchieved(7))
        } else if currentStreak == 30 {
            events.append(.streakAchieved(30))
        }

        // Tour completion
        if completedTours == 1 {
            events.append(.firstTourCompleted)
        }

        // Check for new achievements
        let newAchievements = Achievement.checkForNewAchievements(progressState: self)
        for achievement in newAchievements {
            if !achievements.contains(where: { $0.id == achievement.id }) {
                achievements.append(achievement)
                events.append(.achievementUnlocked(achievement))
            }
        }

        // Check for new milestones
        let newMilestones = Milestone.checkForNewMilestones(progressState: self)
        for milestone in newMilestones {
            if !milestones.contains(where: { $0.id == milestone.id }) {
                milestones.append(milestone)
                events.append(.milestoneReached(milestone))
            }
        }

        // Fire the most significant event
        if let mostSignificantEvent = events.max(by: { $0.priority < $1.priority }) {
            lastProgressionEvent = mostSignificantEvent
        }
    }

    func clearProgressionEvent() {
        lastProgressionEvent = nil
    }
}

// MARK: - Progression Event

enum ProgressionEvent: Codable, Equatable {
    case trailStarted
    case neighborhoodUnlocked(String)
    case streakAchieved(Int)
    case firstTourCompleted
    case achievementUnlocked(Achievement)
    case milestoneReached(Milestone)

    var title: String {
        switch self {
        case .trailStarted:
            return "Trail Started!"
        case let .neighborhoodUnlocked(neighborhood):
            return "\(neighborhood) Unlocked!"
        case let .streakAchieved(days):
            return "\(days)-Day Streak!"
        case .firstTourCompleted:
            return "First Tour Complete!"
        case let .achievementUnlocked(achievement):
            return achievement.name
        case let .milestoneReached(milestone):
            return milestone.name
        }
    }

    var message: String {
        switch self {
        case .trailStarted:
            return "Your property discovery journey begins!"
        case let .neighborhoodUnlocked(neighborhood):
            return "You've explored \(neighborhood) thoroughly"
        case let .streakAchieved(days):
            return "Scout on a roll! \(days) consecutive days"
        case .firstTourCompleted:
            return "Great job completing your first property tour!"
        case let .achievementUnlocked(achievement):
            return achievement.description
        case let .milestoneReached(milestone):
            return milestone.description
        }
    }

    var icon: String {
        switch self {
        case .trailStarted:
            return "flag.fill"
        case .neighborhoodUnlocked:
            return "map.fill"
        case .streakAchieved:
            return "flame.fill"
        case .firstTourCompleted:
            return "checkmark.circle.fill"
        case .achievementUnlocked:
            return "star.fill"
        case .milestoneReached:
            return "trophy.fill"
        }
    }

    var color: Color {
        switch self {
        case .trailStarted:
            return .green
        case .neighborhoodUnlocked:
            return .blue
        case .streakAchieved:
            return .orange
        case .firstTourCompleted:
            return .purple
        case .achievementUnlocked:
            return .yellow
        case .milestoneReached:
            return .gold
        }
    }

    var priority: Int {
        switch self {
        case .trailStarted: return 1
        case .streakAchieved: return 2
        case .firstTourCompleted: return 3
        case .achievementUnlocked: return 4
        case .neighborhoodUnlocked: return 5
        case .milestoneReached: return 6
        }
    }

    var hasConfetti: Bool {
        switch self {
        case .neighborhoodUnlocked, .milestoneReached, .achievementUnlocked:
            return true
        default:
            return false
        }
    }

    var soundEffect: String? {
        switch self {
        case .trailStarted:
            return "route_start"
        case .neighborhoodUnlocked, .milestoneReached, .achievementUnlocked:
            return "save"
        case .streakAchieved, .firstTourCompleted:
            return "pulse"
        }
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let color: Color
    let requirement: AchievementRequirement
    let unlockedDate: Date?

    init(name: String, description: String, icon: String, color: Color, requirement: AchievementRequirement) {
        id = UUID()
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.requirement = requirement
        unlockedDate = nil
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, description, icon, requirement, unlockedDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        icon = try container.decode(String.self, forKey: .icon)
        requirement = try container.decode(AchievementRequirement.self, forKey: .requirement)
        unlockedDate = try container.decodeIfPresent(Date.self, forKey: .unlockedDate)

        // Color will be derived from the achievement type
        color = .blue // Default color, will be set properly in static data
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(icon, forKey: .icon)
        try container.encode(requirement, forKey: .requirement)
        try container.encodeIfPresent(unlockedDate, forKey: .unlockedDate)
    }

    func isUnlocked(for progressState: ProgressState) -> Bool {
        return requirement.isMet(by: progressState)
    }

    static func checkForNewAchievements(progressState: ProgressState) -> [Achievement] {
        return allAchievements.filter { achievement in
            achievement.isUnlocked(for: progressState) &&
                !progressState.achievements.contains { $0.id == achievement.id }
        }
    }

    static let allAchievements: [Achievement] = [
        Achievement(
            name: "Explorer",
            description: "Save your first property",
            icon: "map.fill",
            color: .green,
            requirement: .totalSaves(1)
        ),
        Achievement(
            name: "Collector",
            description: "Save 25 properties",
            icon: "square.stack.3d.up.fill",
            color: .blue,
            requirement: .totalSaves(25)
        ),
        Achievement(
            name: "Curator",
            description: "Save 100 properties",
            icon: "star.fill",
            color: .purple,
            requirement: .totalSaves(100)
        ),
        Achievement(
            name: "Streak Master",
            description: "Maintain a 7-day streak",
            icon: "flame.fill",
            color: .orange,
            requirement: .streak(7)
        ),
        Achievement(
            name: "Neighborhood Expert",
            description: "Unlock 5 neighborhoods",
            icon: "building.2.fill",
            color: .cyan,
            requirement: .neighborhoodsUnlocked(5)
        ),
        Achievement(
            name: "Tour Guide",
            description: "Complete 10 property tours",
            icon: "figure.walk",
            color: .mint,
            requirement: .toursCompleted(10)
        )
    ]
}

// MARK: - Achievement Requirement

enum AchievementRequirement: Codable, Hashable, Equatable {
    case totalSaves(Int)
    case streak(Int)
    case neighborhoodsUnlocked(Int)
    case toursCompleted(Int)

    func isMet(by progressState: ProgressState) -> Bool {
        switch self {
        case let .totalSaves(required):
            return progressState.totalSaves >= required
        case let .streak(required):
            return progressState.longestStreak >= required
        case let .neighborhoodsUnlocked(required):
            return progressState.unlockedNeighborhoods.count >= required
        case let .toursCompleted(required):
            return progressState.completedTours >= required
        }
    }
}

// MARK: - Milestone

struct Milestone: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let color: Color
    let targetValue: Int
    let keyPathIdentifier: String // Store string identifier instead of KeyPath

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, description, icon, targetValue, keyPathIdentifier
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        color: Color,
        targetValue: Int,
        keyPathIdentifier: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.targetValue = targetValue
        self.keyPathIdentifier = keyPathIdentifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        icon = try container.decode(String.self, forKey: .icon)
        targetValue = try container.decode(Int.self, forKey: .targetValue)
        keyPathIdentifier = try container.decode(String.self, forKey: .keyPathIdentifier)

        // Color will be derived from the milestone type
        color = .blue // Default color, will be set properly in static data
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(icon, forKey: .icon)
        try container.encode(targetValue, forKey: .targetValue)
        try container.encode(keyPathIdentifier, forKey: .keyPathIdentifier)
    }

    func isUnlocked(for progressState: ProgressState) -> Bool {
        let currentValue = getCurrentValue(for: progressState)
        return currentValue >= targetValue
    }

    private func getCurrentValue(for progressState: ProgressState) -> Int {
        switch keyPathIdentifier {
        case "totalSaves":
            return progressState.totalSaves
        case "completedTours":
            return progressState.completedTours
        default:
            return 0
        }
    }

    func progress(for progressState: ProgressState) -> Double {
        let currentValue = getCurrentValue(for: progressState)
        return min(1.0, Double(currentValue) / Double(targetValue))
    }

    static func checkForNewMilestones(progressState: ProgressState) -> [Milestone] {
        return allMilestones.filter { milestone in
            milestone.isUnlocked(for: progressState) &&
                !progressState.milestones.contains { $0.id == milestone.id }
        }
    }

    static let allMilestones: [Milestone] = [
        Milestone(
            id: UUID(),
            name: "First Steps",
            description: "Save 5 properties",
            icon: "footprints",
            color: .green,
            targetValue: 5,
            keyPathIdentifier: "totalSaves"
        ),
        Milestone(
            id: UUID(),
            name: "Getting Serious",
            description: "Save 25 properties",
            icon: "target",
            color: .blue,
            targetValue: 25,
            keyPathIdentifier: "totalSaves"
        ),
        Milestone(
            id: UUID(),
            name: "Power User",
            description: "Save 100 properties",
            icon: "bolt.fill",
            color: .yellow,
            targetValue: 100,
            keyPathIdentifier: "totalSaves"
        ),
        Milestone(
            id: UUID(),
            name: "Tour Enthusiast",
            description: "Complete 5 tours",
            icon: "figure.walk.circle",
            color: .purple,
            targetValue: 5,
            keyPathIdentifier: "completedTours"
        )
    ]
}

// MARK: - Color Extension

extension Color {

}

// MARK: - Sample Data

extension ProgressState {
    static let sample: ProgressState = {
        let state = ProgressState()
        state.totalSaves = 15
        state.currentStreak = 3
        state.longestStreak = 7
        state.lastSaveDate = Date().addingTimeInterval(-86400) // Yesterday
        state.unlockedNeighborhoods = ["Flatiron", "West Village"]
        state.completedTours = 2
        state.achievements = [Achievement.allAchievements[0]] // Explorer achievement
        return state
    }()
}
