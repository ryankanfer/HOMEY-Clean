//
//  AgentInviteStepView.swift
//  HOMEY Clean
//
//  Agent invite step view for mandatory onboarding flow
//

import SwiftUI

struct AgentInviteStepView: View {
    @Binding var data: [String: String]
    
    @State private var agentCode = ""
    @State private var skipAgent = false
    @State private var showingCodeValidation = false
    @State private var isValidatingCode = false
    @State private var validationMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Connect with an Agent")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("Get personalized guidance")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text("Working with a real estate agent can help you navigate the home buying process more effectively. If you have an agent's invite code, enter it below.")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 20) {
                // Agent Code Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Agent Invite Code")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Enter agent code", text: $agentCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.characters)
                            .onChange(of: agentCode) { value in
                                data["agentCode"] = value
                                validationMessage = ""
                            }
                        
                        if !validationMessage.isEmpty {
                            Text(validationMessage)
                                .font(.caption)
                                .foregroundColor(validationMessage.contains("Valid") ? .green : .red)
                        }
                        
                        if !agentCode.isEmpty {
                            Button("Validate Code") {
                                validateAgentCode()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isValidatingCode)
                        }
                    }
                }
                
                // Benefits of Working with an Agent
                VStack(alignment: .leading, spacing: 12) {
                    Text("Benefits of Working with an Agent")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BenefitRow(
                            icon: "person.fill.checkmark",
                            title: "Expert Guidance",
                            description: "Navigate complex negotiations and paperwork"
                        )
                        
                        BenefitRow(
                            icon: "house.fill",
                            title: "Market Knowledge",
                            description: "Access to off-market listings and local insights"
                        )
                        
                        BenefitRow(
                            icon: "dollarsign.circle.fill",
                            title: "Price Negotiation",
                            description: "Professional negotiation to get the best deal"
                        )
                        
                        BenefitRow(
                            icon: "clock.fill",
                            title: "Save Time",
                            description: "Let an expert handle the heavy lifting"
                        )
                    }
                }
                
                // Skip Option
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("I'll find an agent later", isOn: $skipAgent)
                        .onChange(of: skipAgent) { value in
                            data["skipAgent"] = String(value)
                            if value {
                                agentCode = ""
                                data["agentCode"] = ""
                            }
                        }
                    
                    if skipAgent {
                        Text("You can always connect with an agent later from your profile settings.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            loadExistingData()
        }
    }
    
    private func validateAgentCode() {
        guard !agentCode.isEmpty else { return }
        
        isValidatingCode = true
        validationMessage = "Validating..."
        
        // Simulate API call to validate agent code
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isValidatingCode = false
            
            // Mock validation logic
            if agentCode.count >= 6 && agentCode.allSatisfy({ $0.isLetter || $0.isNumber }) {
                validationMessage = "Valid agent code! ✓"
                data["agentValidated"] = "true"
            } else {
                validationMessage = "Invalid agent code. Please check and try again."
                data["agentValidated"] = "false"
            }
        }
    }
    
    private func loadExistingData() {
        if let code = data["agentCode"] {
            agentCode = code
        }
        
        if let skipStr = data["skipAgent"] {
            skipAgent = Bool(skipStr) ?? false
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AgentInviteStepView(data: .constant([:]))
        .padding()
}