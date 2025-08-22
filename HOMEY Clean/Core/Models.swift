//
//  Models.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/16/25.
//

import Foundation

// MARK: - Agent Models

public struct AgentClient: Identifiable, Codable, Sendable {
    public let id: UUID
    public let fullName: String
    public let journeyStage: String
    public let email: String?
    public let lastContact: Date?

    public init(
        id: UUID = UUID(),
        fullName: String,
        journeyStage: String,
        email: String? = nil,
        lastContact: Date? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.journeyStage = journeyStage
        self.email = email
        self.lastContact = lastContact
    }
}

// MARK: - Dashboard Models

public struct MetricCard: Identifiable {
    public let id = UUID()
    public let title: String
    public let value: String
    public let footnote: String
    public let trend: MetricTrend?

    public init(title: String, value: String, footnote: String, trend: MetricTrend? = nil) {
        self.title = title
        self.value = value
        self.footnote = footnote
        self.trend = trend
    }
}

public enum MetricTrend {
    case up(Double) // percentage increase
    case down(Double) // percentage decrease
    case neutral
}

// MARK: - Task Models

public struct DashboardTask: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let dueDate: Date?
    public let priority: TaskPriority
    public let isCompleted: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
    }
}

public enum TaskPriority: String, CaseIterable, Codable {
    case low
    case medium
    case high
    case urgent

    public var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// MARK: - Tour Models

public struct Tour: Identifiable, Codable {
    public let id: UUID
    public let propertyAddress: String
    public let scheduledDate: Date
    public let clientName: String
    public let status: TourStatus
    public let notes: String?

    public init(
        id: UUID = UUID(),
        propertyAddress: String,
        scheduledDate: Date,
        clientName: String,
        status: TourStatus = .scheduled,
        notes: String? = nil
    ) {
        self.id = id
        self.propertyAddress = propertyAddress
        self.scheduledDate = scheduledDate
        self.clientName = clientName
        self.status = status
        self.notes = notes
    }
}

public enum TourStatus: String, CaseIterable, Codable {
    case scheduled
    case confirmed
    case completed
    case cancelled
    case rescheduled
}
