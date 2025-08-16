//
//  EducationCenterSection.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


import Foundation

public struct EducationCenterSection: Identifiable, Sendable {
    public let id: UUID = .init()
    public var title: String
    public var subtitle: String?
    public var icon: String?

    public init(title: String, subtitle: String? = nil, icon: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}