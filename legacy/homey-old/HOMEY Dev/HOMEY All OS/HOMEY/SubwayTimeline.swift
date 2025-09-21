//
//  SubwayTimeline.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/8/25.
//

import SwiftUI

enum JourneyStage: String, CaseIterable {
    case onboarding, search, offer, escrow, close
}

struct SubwayTimeline: View {
    var currentStage: JourneyStage
    var body: some View {
        HStack(spacing: 12) {
            ForEach(JourneyStage.allCases, id: \.self) { stage in
                VStack(spacing: 8) {
                    Circle()
                        .fill(color(for: stage))
                        .frame(width: 12, height: 12)
                    Text(stage.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if stage != JourneyStage.allCases.last {
                    Rectangle()
                        .fill(color(for: stage))
                        .frame(height: 2)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
    }

    private func color(for stage: JourneyStage) -> Color {
        let idx = JourneyStage.allCases.firstIndex(of: stage)!
        let current = JourneyStage.allCases.firstIndex(of: currentStage)!
        if idx < current { return .green } // completed
        if idx == current { return .blue } // active
        return .gray.opacity(0.4) // locked
    }
}
