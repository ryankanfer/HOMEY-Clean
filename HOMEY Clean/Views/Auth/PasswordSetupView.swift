import SwiftUI

struct PasswordSetupView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("🔐 Final Stop: Secure Your Account")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Lastly, enter a password")
                    .font(.title.bold())
                
                Text("Keep your HOMEY account secure with a strong password.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 16)
            
            // Password Fields
            VStack(spacing: 16) {
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                    
                    HStack {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Confirm password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.headline)
                    
                    HStack {
                        if showConfirmPassword {
                            TextField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Button(action: { showConfirmPassword.toggle() }) {
                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Password requirements
            VStack(alignment: .leading, spacing: 4) {
                Text("Password must contain:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(password.count >= 8 ? .green : .secondary)
                        .font(.caption)
                    Text("At least 8 characters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: containsUppercase ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(containsUppercase ? .green : .secondary)
                        .font(.caption)
                    Text("One uppercase letter")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: containsNumber ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(containsNumber ? .green : .secondary)
                        .font(.caption)
                    Text("One number")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Complete button
            Button(action: handlePasswordSetup) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Label("Complete Setup", systemImage: "checkmark.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isValidPassword ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isValidPassword || isLoading)
        }
        .padding(24)
    }
    
    // MARK: - Computed Properties
    
    private var containsUppercase: Bool {
        password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    private var containsNumber: Bool {
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    private var isValidPassword: Bool {
        password.count >= 8 &&
        containsUppercase &&
        containsNumber &&
        password == confirmPassword &&
        !password.isEmpty
    }
    
    // MARK: - Actions
    
    private func handlePasswordSetup() {
        guard isValidPassword else {
            errorMessage = "Please ensure all password requirements are met and passwords match."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // TODO: Implement actual password update via Supabase
        // For now, simulate the API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            onComplete()
        }
    }
}

#Preview {
    PasswordSetupView(onComplete: {
        print("Password setup completed!")
    })
}