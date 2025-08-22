import Foundation
import SwiftUI

// MARK: - Enums

enum Character: String, CaseIterable {
    case charlie
    case scout
    case paige
    case isla

    var displayName: String {
        return rawValue.capitalized
    }

    var avatarImageName: String {
        switch self {
        case .charlie: return "person.circle.fill"
        case .scout: return "binoculars.circle.fill"
        case .paige: return "doc.circle.fill"
        case .isla: return "chart.line.uptrend.xyaxis.circle.fill"
        }
    }

    var primaryColor: Color {
        switch self {
        case .charlie: return .blue
        case .scout: return .green
        case .paige: return .purple
        case .isla: return .orange
        }
    }
}

// MARK: - Character Task Models

struct CharacterTask: Identifiable, Hashable {
    let id = UUID()
    let character: Character
    let title: String
    let status: CharacterTask.TaskStatus
    let dueDate: Date?

    enum TaskStatus: String, CaseIterable {
        case pending
        case inProgress = "in_progress"
        case completed
        case overdue

        var color: Color {
            switch self {
            case .pending: return .yellow
            case .inProgress: return .blue
            case .completed: return .green
            case .overdue: return .red
            }
        }

        var statusSystemImageName: String {
            switch self {
            case .pending:
                return "clock.fill"
            case .inProgress:
                return "arrow.clockwise"
            case .completed:
                return "checkmark.circle.fill"
            case .overdue:
                return "exclamationmark.triangle.fill"
            }
        }
    }
}

// MARK: - Tonight's Features Models

struct TonightFeature: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let glowColor: Color
    let action: FeatureAction

    enum FeatureAction {
        case tourBooked
        case boardReady
        case neighborhoodMatch
    }
}

// MARK: - Coming Up Task Models

struct UpcomingTask: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let dueDate: Date
    let thumbnailImageName: String
    let priority: TaskPriority

    enum TaskPriority {
        case low, medium, high, urgent

        var color: Color {
            switch self {
            case .low: return .gray
            case .medium: return .blue
            case .high: return .orange
            case .urgent: return .red
            }
        }
    }
}

// MARK: - Story Stats Models

struct StoryStat: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let currentValue: Int
    let totalValue: Int?
    let iconName: String
    let color: Color

    var displayText: String {
        if let total = totalValue {
            return "\(currentValue)/\(total)"
        } else {
            return "\(currentValue)"
        }
    }

    var progressPercentage: Double {
        guard let total = totalValue, total > 0 else { return 1.0 }
        return Double(currentValue) / Double(total)
    }
}

// MARK: - Education Center Models

struct LearningCard: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let tag: String
    let estimatedReadTime: String
    let thumbnailImageName: String
    let content: String
    let progress: Double // 0.0 to 1.0
    let isCompleted: Bool

    var progressText: String {
        if isCompleted {
            return "Completed"
        } else if progress > 0 {
            return "\(Int(progress * 100))% read"
        } else {
            return "Not started"
        }
    }
}

// MARK: - Sample Data

extension CharacterTask {
    static let sampleTasks: [CharacterTask] = [
        CharacterTask(
            character: .charlie,
            title: "Review next 3 steps",
            status: .pending,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
        ),
        CharacterTask(
            character: .scout,
            title: "Neighborhood shortlist",
            status: .inProgress,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        ),
        CharacterTask(
            character: .paige,
            title: "2 docs missing",
            status: .overdue,
            dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())
        ),
        CharacterTask(
            character: .isla,
            title: "Rate trends this week",
            status: .pending,
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
        ),
        CharacterTask(character: .charlie, title: "Schedule pre-approval", status: .completed, dueDate: nil),
        CharacterTask(
            character: .scout,
            title: "Tour availability check",
            status: .pending,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        )
    ]
}

extension TonightFeature {
    static let sampleFeatures: [TonightFeature] = [
        TonightFeature(
            title: "Tour Booked",
            subtitle: "Tomorrow at 2:00 PM",
            iconName: "house.fill",
            glowColor: .blue,
            action: .tourBooked
        ),
        TonightFeature(
            title: "Board Ready",
            subtitle: "Package approved",
            iconName: "checkmark.seal.fill",
            glowColor: .green,
            action: .boardReady
        ),
        TonightFeature(
            title: "Neighborhood Match",
            subtitle: "3 new areas found",
            iconName: "location.fill",
            glowColor: .orange,
            action: .neighborhoodMatch
        )
    ]
}

extension UpcomingTask {
    static let sampleTasks: [UpcomingTask] = [
        UpcomingTask(
            title: "Bank Statement Upload",
            subtitle: "Due in 2 days",
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            thumbnailImageName: "doc.text.fill",
            priority: .high
        ),
        UpcomingTask(
            title: "Property Tour",
            subtitle: "123 Main St",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            thumbnailImageName: "house.fill",
            priority: .urgent
        ),
        UpcomingTask(
            title: "Loan Application Review",
            subtitle: "Final check needed",
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            thumbnailImageName: "doc.badge.gearshape.fill",
            priority: .medium
        )
    ]
}

extension StoryStat {
    static let sampleStats: [StoryStat] = [
        StoryStat(
            title: "Docs uploaded",
            currentValue: 8,
            totalValue: 12,
            iconName: "doc.fill",
            color: .blue
        ),
        StoryStat(
            title: "Areas saved",
            currentValue: 3,
            totalValue: nil,
            iconName: "heart.fill",
            color: .red
        ),
        StoryStat(
            title: "Tours booked",
            currentValue: 1,
            totalValue: nil,
            iconName: "calendar.badge.plus",
            color: .green
        ),
        StoryStat(
            title: "Offers made",
            currentValue: 0,
            totalValue: nil,
            iconName: "hand.raised.fill",
            color: .orange
        )
    ]
}

extension LearningCard {
    static let sampleCards: [LearningCard] = [
        LearningCard(
            title: "Co-op 101",
            tag: "Basics",
            estimatedReadTime: "5 min read",
            thumbnailImageName: "building.2.fill",
            content: "Understanding cooperative housing...",
            progress: 0.0,
            isCompleted: false
        ),
        LearningCard(
            title: "What boards ask",
            tag: "Interview Prep",
            estimatedReadTime: "8 min read",
            thumbnailImageName: "person.3.fill",
            content: "Common board interview questions...",
            progress: 0.6,
            isCompleted: false
        ),
        LearningCard(
            title: "Pre-approval vs pre-qualification",
            tag: "Financing",
            estimatedReadTime: "4 min read",
            thumbnailImageName: "creditcard.fill",
            content: "Understanding the difference...",
            progress: 1.0,
            isCompleted: true
        ),
        LearningCard(
            title: "How to read a rent roll",
            tag: "Analysis",
            estimatedReadTime: "6 min read",
            thumbnailImageName: "chart.bar.doc.horizontal.fill",
            content: "Analyzing building financials...",
            progress: 0.0,
            isCompleted: false
        )
    ]
}
