//
//  DefaultStepView.swift
//  HOMEY Clean
//
//  Default step view for mandatory onboarding flow
//

import SwiftUI

struct DefaultStepView: View {
    @Binding var data: [String: String]
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Spacer()
            
            // Error Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            VStack(spacing: 16) {
                Text("Oops! Something went wrong")
                    .font(.title.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("We encountered an unexpected step in the onboarding process. This shouldn't happen, but don't worry - you can continue or restart the onboarding.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            VStack(spacing: 12) {
                Button("Continue Anyway") {
                    data["defaultStepAction"] = "continue"
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Restart Onboarding") {
                    data["defaultStepAction"] = "restart"
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            Spacer()
            
            // Debug Information (only in debug builds)
            #if DEBUG
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug Information")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                
                Text("Current data keys: \(data.keys.sorted().joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            #endif
        }
        .padding()
        .onAppear {
            // Log this occurrence for debugging
            print("⚠️ DefaultStepView appeared - unexpected onboarding step")
            print("Current data: \(data)")
        }
    }
}

#Preview {
    DefaultStepView(data: .constant([
        "step": "unknown",
        "userId": "12345",
        "progress": "0.5"
    ]))
}