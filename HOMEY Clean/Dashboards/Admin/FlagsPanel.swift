//
//  FlagsPanel.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI

struct FlagsPanel: View {
    @EnvironmentObject private var flags: FeatureFlags
    var body: some View {
        SectionCard(title: "Feature flags", subtitle: "Flip responsibly") {
            #if DEBUG
            Toggle("Dev: Bypass Referral Validation", isOn: $flags.devBypassReferralValidation)
                .foregroundColor(Theme.text)
            #else
            Text("No active feature flags")
                .foregroundColor(Theme.textMuted)
                .font(.caption)
            #endif
            // Toggle("AI: Chat enabled", isOn: $flags.aiChatEnabled)
            // Toggle("Onboarding: New role picker", isOn: $flags.newRolePicker)
        }
    }
}
