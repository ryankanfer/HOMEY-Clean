//
//  JourneyEvent.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/19/25.
//

// JourneyEvent.swift
import Foundation

struct JourneyEvent: Decodable, Identifiable {
    private let rawId: UUID?
    let kind: String?
    let note: String?
    let created_at: String

    var id: UUID { rawId ?? UUID() }

    enum CodingKeys: String, CodingKey {
        case rawId = "id", kind, note, created_at
    }
}
