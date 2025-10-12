//
//  PasswordSetupStepView.swift
//  HOMEY Clean
//
//  Password setup step view for mandatory onboarding flow
//

import SwiftUI

struct PasswordSetupStepView: View {
    @Binding var data: [String: String]
    
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var passwordStrength: PasswordStrength = .weak
    @State private var validationErrors: [String] = []
    
    enum PasswordStrength: String, CaseIterable {
        case weak = "Weak"
        case fair = "Fair"
        case good = "Good"
        case strong = "Strong"
        
        var color: Color {
            switch self {
            case .weak: return .red
            case .fair: return .orange
            case .good: return .yellow
            case .strong: return .green
            }
        }
        
        var progress: Double {
            switch self {
            case .weak: return 0.25
            case .fair: return 0.5
            case .good: return 0.75
            case .strong: return 1.0
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Secure Your Account")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("Create a strong password")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text("Your password should be unique and secure. We recommend using a combination of letters, numbers, and special characters.")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 20) {
                // Password Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Password")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if showPassword {
                                TextField("Enter your password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onChange(of: password) { value in
                            data["password"] = value
                            updatePasswordStrength()
                            validatePasswords()
                        }
                        
                        // Password Strength Indicator
                        if !password.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Password Strength:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(passwordStrength.rawValue)
                                        .font(.caption.bold())
                                        .foregroundColor(passwordStrength.color)
                                }
                                
                                ProgressView(value: passwordStrength.progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: passwordStrength.color))
                                    .scaleEffect(x: 1, y: 0.5)
                            }
                        }
                    }
                }
                
                // Confirm Password Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Confirm Password")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    HStack {
                        if showConfirmPassword {
                            TextField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: { showConfirmPassword.toggle() }) {
                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: confirmPassword) { value in
                        data["confirmPassword"] = value
                        validatePasswords()
                    }
                }
                
                // Password Requirements
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password Requirements")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        RequirementRow(
                            text: "At least 8 characters",
                            isMet: password.count >= 8
                        )
                        
                        RequirementRow(
                            text: "Contains uppercase letter",
                            isMet: password.contains { $0.isUppercase }
                        )
                        
                        RequirementRow(
                            text: "Contains lowercase letter",
                            isMet: password.contains { $0.isLowercase }
                        )
                        
                        RequirementRow(
                            text: "Contains number",
                            isMet: password.contains { $0.isNumber }
                        )
                        
                        RequirementRow(
                            text: "Contains special character",
                            isMet: password.contains { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }
                        )
                        
                        if !confirmPassword.isEmpty {
                            RequirementRow(
                                text: "Passwords match",
                                isMet: password == confirmPassword
                            )
                        }
                    }
                }
                
                // Validation Errors
                if !validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(validationErrors, id: \.self) { error in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Security Tips
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Security Tips")
                                .font(.caption.bold())
                                .foregroundColor(.primary)
                            
                            Text("• Use a unique password you haven't used elsewhere\n• Consider using a password manager\n• Don't share your password with anyone")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadExistingData()
        }
    }
    
    private func updatePasswordStrength() {
        let hasMinLength = password.count >= 8
        let hasUppercase = password.contains { $0.isUppercase }
        let hasLowercase = password.contains { $0.isLowercase }
        let hasNumber = password.contains { $0.isNumber }
        let hasSpecialChar = password.contains { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }
        
        let criteriaCount = [hasMinLength, hasUppercase, hasLowercase, hasNumber, hasSpecialChar].filter { $0 }.count
        
        switch criteriaCount {
        case 0...1:
            passwordStrength = .weak
        case 2...3:
            passwordStrength = .fair
        case 4:
            passwordStrength = .good
        case 5:
            passwordStrength = .strong
        default:
            passwordStrength = .weak
        }
    }
    
    private func validatePasswords() {
        validationErrors.removeAll()
        
        if !password.isEmpty && password.count < 8 {
            validationErrors.append("Password must be at least 8 characters long")
        }
        
        if !confirmPassword.isEmpty && password != confirmPassword {
            validationErrors.append("Passwords do not match")
        }
        
        data["passwordValid"] = String(validationErrors.isEmpty && !password.isEmpty && !confirmPassword.isEmpty)
    }
    
    private func loadExistingData() {
        if let pwd = data["password"] {
            password = pwd
            updatePasswordStrength()
        }
        
        if let confirmPwd = data["confirmPassword"] {
            confirmPassword = confirmPwd
        }
        
        validatePasswords()
    }
}

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundColor(isMet ? .green : .secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(isMet ? .primary : .secondary)
                .strikethrough(isMet)
        }
    }
}

#Preview {
    PasswordSetupStepView(data: .constant([:]))
        .padding()
}