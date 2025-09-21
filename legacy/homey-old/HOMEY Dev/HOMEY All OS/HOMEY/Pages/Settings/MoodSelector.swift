//
//  MoodSelector.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/11/25.
//

import SwiftUI

enum HomeyMood: String, CaseIterable, Identifiable {
    case professional, friendly, playful
    var id: String { rawValue }

    var title: String {
        switch self {
        case .professional: return "Professional"
        case .friendly: return "Friendly"
        case .playful: return "Playful"
        }
    }

    var subtitle: String {
        switch self {
        case .professional: return "Minimal motion, direct copy"
        case .friendly: return "Warm copy, gentle motion"
        case .playful: return "More personality, bouncier UI"
        }
    }

    var icon: String {
        switch self {
        case .professional: return "briefcase.fill"
        case .friendly: return "hand.wave.fill"
        case .playful: return "sparkles"
        }
    }
}

struct MoodSelectorView: View {
    @AppStorage("homeyMood") private var storedMood: String = HomeyMood.friendly.rawValue

    private var mood: HomeyMood {
        HomeyMood(rawValue: storedMood) ?? .friendly
    }

    var body: some View {
        List {
            Section("Choose your HOMEY mood") {
                ForEach(HomeyMood.allCases) { option in
                    HStack(spacing: 12) {
                        Image(systemName: option.icon)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title).font(.headline)
                            Text(option.subtitle).font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if option == mood { Image(systemName: "checkmark.circle.fill") }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { storedMood = option.rawValue }
                }
            }

            Section("About") {
                Text("Mood influences micro-copy and animation intensity. You can change this anytime in Settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("HOMEY Mood")
    }
}
