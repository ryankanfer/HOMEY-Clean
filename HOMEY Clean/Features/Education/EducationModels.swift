//
//  EducationModels.swift
//  HOMEY Clean
//
//  Minimal course/lesson models used by EducationProgressStore
//

import Foundation

public struct EducationLesson: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var durationMinutes: Int?

    public init(id: UUID = UUID(), title: String, durationMinutes: Int? = nil) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
    }
}

public struct EducationCourse: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var subtitle: String?
    public var lessons: [EducationLesson]

    public init(id: UUID = UUID(), title: String, subtitle: String? = nil, lessons: [EducationLesson] = []) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.lessons = lessons
    }
}
