import Foundation
import SwiftUI

public enum SuggestionType: String, Codable, Hashable {
    case nextAction
    case missingDocument
    case directoryContact
    case insight
    case marketTrend
    case visionSuggestion
}

public struct Suggestion: Identifiable, Hashable, Codable {
    public let id: UUID
    public let type: SuggestionType
    public let title: String
    public let subtitle: String
    public let actionText: String
    public let icon: String
    public let page: AppPage?
    public let priority: ContentPriority
    public let metadata: [String: String]
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        type: SuggestionType,
        title: String,
        subtitle: String,
        actionText: String,
        icon: String,
        page: AppPage? = nil,
        priority: ContentPriority = .medium,
        metadata: [String: String] = [:],
        createdAt: Date = .now
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.actionText = actionText
        self.icon = icon
        self.page = page
        self.priority = priority
        self.metadata = metadata
        self.createdAt = createdAt
    }
}

// Copy helpers - never brand as an AI agent
public enum SuggestionCopy {
    public static func heresWhatsNext(_ title: String) -> String {
        "Here’s what’s next: \(title)"
    }

    public static func recommendedForYou(_ title: String) -> String {
        "Recommended for you: \(title)"
    }

    public static func basedOnYourActivity(_ title: String) -> String {
        "Based on your activity: \(title)"
    }
}