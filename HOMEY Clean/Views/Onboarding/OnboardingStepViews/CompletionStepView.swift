//
//  CompletionStepView.swift
//  HOMEY Clean
//
//  Completion step view for mandatory onboarding flow
//

import SwiftUI

struct CompletionStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("You're all set!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("Ready to find your perfect home")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text("HOMEY is now personalized for your search. Let's start exploring properties that match your preferences.")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 12) {
                CompletionCheckmark(text: "Profile setup complete")
                CompletionCheckmark(text: "Preferences saved")
                CompletionCheckmark(text: "Notifications configured")
                CompletionCheckmark(text: "Ready to search")
            }
        }
    }
}

struct CompletionCheckmark: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundColor(.green)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}