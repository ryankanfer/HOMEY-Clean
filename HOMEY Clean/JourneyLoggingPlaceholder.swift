//
//  JourneyLogging.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/14/25.
//


// File: codex/logging/JourneyLogging.swift
import Foundation

public protocol JourneyLogging {
    func log(_ event: String, metadata: [String: String]?)
}

public struct NoopJourneyLogger: JourneyLogging {
    public init() {}
    public func log(_ event: String, metadata: [String: String]? = nil) {}
}