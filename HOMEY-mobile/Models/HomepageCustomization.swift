//
//  HomepageCustomization.swift
//  HOMEY Clean
//
//  Homepage customization models for personalized user experience
//

import Foundation
import SwiftUI

// MARK: - Homepage Section Types

public enum HomepageSection: String, CaseIterable, Codable, Equatable {
    case discover = "Search"
    case vault = "Vault"
    case education = "Education"
    case directory = "Directory"
    case vision = "Vision"
    case insights = "Insights"
    case matchmaker = "Matchmaker"
    case scout = "Scout"
    case documents = "Documents"
    case profile = "Profile"
    
    public var icon: String {
        switch self {
        case .discover:
            return "magnifyingglass"
        case .vault:
            return "doc.fill"
        case .education:
            return "book.fill"
        case .directory:
            return "person.2.fill"
        case .vision:
            return "eye.fill"
        case .insights:
            return "chart.bar.fill"
        case .matchmaker:
            return "heart.circle"
        case .scout:
            return "location.fill"
        case .documents:
            return "folder.fill"
        case .profile:
            return "person.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .discover:
            return .blue
        case .vault:
            return .orange
        case .education:
            return .green
        case .directory:
            return .purple
        case .vision:
            return .pink
        case .insights:
            return .indigo
        case .matchmaker:
            return .red
        case .scout:
            return .teal
        case .documents:
            return .brown
        case .profile:
            return .gray
        }
    }
    
    public var description: String {
        switch self {
        case .discover:
            return "Search homes"
        case .vault:
            return "Manage your documents"
        case .education:
            return "Learn about home buying"
        case .directory:
            return "Connect with professionals"
        case .vision:
            return "Visualize your future"
        case .insights:
            return "Market data & analytics"
        case .matchmaker:
            return "Find your perfect match"
        case .scout:
            return "Explore neighborhoods"
        case .documents:
            return "Organize your files"
        case .profile:
            return "Manage your account"
        }
    }
}

// MARK: - Homepage Customization Model

public struct HomepageCustomization: Codable, Equatable {
    public var selectedSections: [HomepageSection]
    public var themePreference: ThemePreference
    public var nextUpEnabled: Bool
    public var nextUpBehaviorSettings: NextUpBehaviorSettings
    
    public init(
        selectedSections: [HomepageSection] = [.discover, .vault, .education, .directory],
        themePreference: ThemePreference = .system,
        nextUpEnabled: Bool = true,
        nextUpBehaviorSettings: NextUpBehaviorSettings = NextUpBehaviorSettings()
    ) {
        self.selectedSections = selectedSections
        self.themePreference = themePreference
        self.nextUpEnabled = nextUpEnabled
        self.nextUpBehaviorSettings = nextUpBehaviorSettings
    }
    
    public static let defaultCustomization = HomepageCustomization()
}

// MARK: - Theme Preference

public enum ThemePreference: String, CaseIterable, Codable, Equatable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    public var displayName: String {
        return self.rawValue
    }
    
    public var icon: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
}

// MARK: - Next Up Smart Card Settings

public struct NextUpBehaviorSettings: Codable, Equatable {
    public var showRecommendations: Bool
    public var showUpcomingTasks: Bool
    public var showMarketUpdates: Bool
    public var showPropertyAlerts: Bool
    public var personalizedContent: Bool
    public var refreshFrequency: RefreshFrequency
    
    public init(
        showRecommendations: Bool = true,
        showUpcomingTasks: Bool = true,
        showMarketUpdates: Bool = true,
        showPropertyAlerts: Bool = true,
        personalizedContent: Bool = true,
        refreshFrequency: RefreshFrequency = .daily
    ) {
        self.showRecommendations = showRecommendations
        self.showUpcomingTasks = showUpcomingTasks
        self.showMarketUpdates = showMarketUpdates
        self.showPropertyAlerts = showPropertyAlerts
        self.personalizedContent = personalizedContent
        self.refreshFrequency = refreshFrequency
    }
}

public enum RefreshFrequency: String, CaseIterable, Codable, Equatable {
    case realTime = "Real-time"
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
    
    public var displayName: String {
        return self.rawValue
    }
}

// MARK: - Next Up Content Types

public struct NextUpContent: Codable, Identifiable, Equatable {
    public let id: UUID
    public let type: NextUpContentType
    public let title: String
    public let subtitle: String
    public let actionText: String
    public let priority: ContentPriority
    public let timestamp: Date
    public let metadata: [String: String]
    
    public init(
        id: UUID = UUID(),
        type: NextUpContentType,
        title: String,
        subtitle: String,
        actionText: String,
        priority: ContentPriority = .medium,
        timestamp: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.actionText = actionText
        self.priority = priority
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

public enum NextUpContentType: String, CaseIterable, Codable, Equatable {
    case recommendation = "recommendation"
    case task = "task"
    case marketUpdate = "market_update"
    case propertyAlert = "property_alert"
    case milestone = "milestone"
    case reminder = "reminder"
    
    public var icon: String {
        switch self {
        case .recommendation:
            return "lightbulb.fill"
        case .task:
            return "checkmark.circle.fill"
        case .marketUpdate:
            return "chart.line.uptrend.xyaxis"
        case .propertyAlert:
            return "bell.fill"
        case .milestone:
            return "flag.fill"
        case .reminder:
            return "clock.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .recommendation:
            return .yellow
        case .task:
            return .green
        case .marketUpdate:
            return .blue
        case .propertyAlert:
            return .red
        case .milestone:
            return .purple
        case .reminder:
            return .orange
        }
    }
}

public enum ContentPriority: String, CaseIterable, Codable, Equatable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    public var sortOrder: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}
