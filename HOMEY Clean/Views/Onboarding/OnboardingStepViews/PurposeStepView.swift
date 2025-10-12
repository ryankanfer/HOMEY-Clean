//
//  PurposeStepView.swift
//  HOMEY Clean
//
//  Purpose step view for mandatory onboarding flow
//

import SwiftUI

struct PurposeStepView: View {
    @Binding var data: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What brings you here?")
                    .font(.title.bold())
                    .foregroundColor(.primary)
                
                Text("Let us know what you're looking for")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                PurposeChoiceRow(
                    title: "I'm looking to rent",
                    subtitle: "Find rental properties",
                    value: "Renting",
                    selection: Binding(
                        get: { data["purpose"] },
                        set: { data["purpose"] = $0 ?? "" }
                    )
                )
                
                PurposeChoiceRow(
                    title: "I'm looking to buy",
                    subtitle: "Purchase a home",
                    value: "Buying",
                    selection: Binding(
                        get: { data["purpose"] },
                        set: { data["purpose"] = $0 ?? "" }
                    )
                )
                
                PurposeChoiceRow(
                    title: "I'm exploring options",
                    subtitle: "Not sure yet, just browsing",
                    value: "Exploring",
                    selection: Binding(
                        get: { data["purpose"] },
                        set: { data["purpose"] = $0 ?? "" }
                    )
                )
            }
            
            if data["purpose"]?.isEmpty != false {
                Text("Please select an option to continue")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
}

struct PurposeChoiceRow: View {
    let title: String
    let subtitle: String
    let value: String
    @Binding var selection: String?
    
    var body: some View {
        Button(action: { selection = value }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: selection == value ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selection == value ? .blue : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selection == value ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selection == value ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}