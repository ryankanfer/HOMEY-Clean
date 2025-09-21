//
//  JourneyModels.swift
//  HOMIE
//

import Foundation

/// Mirrors `public.journey_state` for a single client
struct JourneyStateRow: Decodable, Identifiable {
    let user_id: UUID
    let current_step: String
    let progress: Int
    let updated_at: Date

    var id: UUID { user_id }
}

/// Handy typed view-model you can use in UI
struct JourneyState: Equatable {
    var step: Step
    var progress: Int

    enum Step: String, CaseIterable {
        case onboarding, search, offer, closing, complete, unknown
    }

    init(db: JourneyStateRow) {
        step = Step(rawValue: db.current_step) ?? .unknown
        progress = db.progress
    }
} //
//  JourneyModels.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/8/25.
//
