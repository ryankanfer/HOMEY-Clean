//
//  PreferencesStepView.swift
//  HOMEY Clean
//
//  Preferences step view for mandatory onboarding flow
//

import SwiftUI

struct PreferencesStepView: View {
    @Binding var data: [String: String]
    
    @State private var selectedStyles: Set<String> = []
    @State private var workFromHome = false
    @State private var hasPets = false
    @State private var walkabilityImportance: Double = 3.0
    @State private var safetyImportance: Double = 4.0
    
    private let designStyles = [
        "Modern", "Traditional", "Minimalist", "Industrial", 
        "Scandinavian", "Bohemian", "Mid-Century", "Farmhouse"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Preferences")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("Help us personalize your experience")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text("Tell us about your lifestyle and preferences so we can show you homes that truly fit your needs.")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 20) {
                // Lifestyle Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lifestyle")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    Toggle("I work from home", isOn: $workFromHome)
                        .onChange(of: workFromHome) { value in
                            data["workFromHome"] = String(value)
                        }
                    
                    Toggle("I have pets", isOn: $hasPets)
                        .onChange(of: hasPets) { value in
                            data["hasPets"] = String(value)
                        }
                }
                
                // Neighborhood Priorities
                VStack(alignment: .leading, spacing: 12) {
                    Text("Neighborhood Priorities")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Walkability")
                                .font(.subheadline)
                            Spacer()
                            Text(walkabilityLabel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $walkabilityImportance, in: 1...5, step: 1)
                            .onChange(of: walkabilityImportance) { value in
                                data["walkability"] = String(Int(value))
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Safety")
                                .font(.subheadline)
                            Spacer()
                            Text(safetyLabel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $safetyImportance, in: 1...5, step: 1)
                            .onChange(of: safetyImportance) { value in
                                data["safety"] = String(Int(value))
                            }
                    }
                }
                
                // Design Style Preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Design Style Preferences")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    Text("Select styles you're drawn to (optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(designStyles, id: \.self) { style in
                            StyleChip(
                                title: style,
                                isSelected: selectedStyles.contains(style)
                            ) {
                                if selectedStyles.contains(style) {
                                    selectedStyles.remove(style)
                                } else {
                                    selectedStyles.insert(style)
                                }
                                data["selectedStyles"] = Array(selectedStyles).joined(separator: ",")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadExistingData()
        }
    }
    
    private var walkabilityLabel: String {
        switch Int(walkabilityImportance) {
        case 1: return "Not important"
        case 2: return "Somewhat important"
        case 3: return "Moderately important"
        case 4: return "Very important"
        case 5: return "Essential"
        default: return "Moderately important"
        }
    }
    
    private var safetyLabel: String {
        switch Int(safetyImportance) {
        case 1: return "Not important"
        case 2: return "Somewhat important"
        case 3: return "Moderately important"
        case 4: return "Very important"
        case 5: return "Essential"
        default: return "Very important"
        }
    }
    
    private func loadExistingData() {
        if let workFromHomeStr = data["workFromHome"] {
            workFromHome = Bool(workFromHomeStr) ?? false
        }
        
        if let hasPetsStr = data["hasPets"] {
            hasPets = Bool(hasPetsStr) ?? false
        }
        
        if let walkabilityStr = data["walkability"] {
            walkabilityImportance = Double(walkabilityStr) ?? 3.0
        }
        
        if let safetyStr = data["safety"] {
            safetyImportance = Double(safetyStr) ?? 4.0
        }
        
        if let stylesStr = data["selectedStyles"], !stylesStr.isEmpty {
            selectedStyles = Set(stylesStr.components(separatedBy: ","))
        }
    }
}

struct StyleChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PreferencesStepView(data: .constant([:]))
        .padding()
}