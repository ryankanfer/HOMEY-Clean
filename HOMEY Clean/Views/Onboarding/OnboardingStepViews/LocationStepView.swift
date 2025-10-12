//
//  LocationStepView.swift
//  HOMEY Clean
//
//  Location step view for mandatory onboarding flow
//

import SwiftUI

struct LocationStepView: View {
    @Binding var data: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Where are you looking?")
                    .font(.title.bold())
                    .foregroundColor(.primary)
                
                Text("Tell us your preferred area")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                TextField("Enter neighborhood or city", text: Binding(
                    get: { data["neighborhood"] ?? "" },
                    set: { data["neighborhood"] = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .font(.body)
                
                Text("Examples: Manhattan, Brooklyn Heights, Chelsea, Upper East Side")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if data["neighborhood"]?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false {
                    Text("Please enter a location to continue")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
        }
    }
}