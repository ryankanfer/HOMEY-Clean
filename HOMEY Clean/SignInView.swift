import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var session: SessionManager

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?

    // Show "Resend confirmation" after specific error
    @State private var canResendConfirmation = false

    var body: some View {
        Form {
            Section(header: Text("Welcome back")) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)

                SecureField("Password", text: $password)
                    .textContentType(.password)
            }

            if let msg = errorMessage {
                Section {
                    Text(msg)
                        .foregroundStyle(.red)
                }
            }

            if let msg = infoMessage {
                Section {
                    Text(msg)
                        .foregroundStyle(.blue)
                }
            }

            Section {
                Button {
                    Task { await signIn() }
                } label: {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("Sign In")
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
            }

            // Forgot password button
            Section {
                Button("Forgot password?") {
                    Task { await sendReset() }
                }
                .disabled(email.isEmpty)
            }

            // Resend confirmation shown only when needed
            if canResendConfirmation {
                Section {
                    Button("Resend confirmation email") {
                        Task { await resendConfirmation() }
                    }
                    .disabled(email.isEmpty)
                }
            }
        }
        .navigationTitle("Sign In")
    }

    // MARK: - Actions

    @MainActor
    private func signIn() async {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        canResendConfirmation = false
        defer { isLoading = false }

        do {
            try await session.signIn(email: email, password: password)
        } catch let e as SessionManager.SignInError {
            errorMessage = e.localizedDescription
            if case .emailNotConfirmed = e { canResendConfirmation = true }
        } catch {
            errorMessage = "Something went wrong. \(error.localizedDescription)"
        }
    }

    @MainActor
    private func resendConfirmation() async {
        errorMessage = nil
        infoMessage = nil
        do {
            try await session.resendConfirmation(email: email)
            infoMessage = "Confirmation email sent."
        } catch {
            errorMessage = "Couldn’t resend confirmation. \(error.localizedDescription)"
        }
    }

    @MainActor
    private func sendReset() async {
        errorMessage = nil
        infoMessage = nil
        guard !email.isEmpty else {
            errorMessage = "Enter your email first."
            return
        }
        guard let url = URL(string: "https://awake-ace-seahorse.ngrok-free.app/reset.html") else {
            errorMessage = "Invalid reset URL."
            return
        }
        do {
            try await session.resetPassword(email: email, redirectTo: url)
            infoMessage = "Password reset email sent."
        } catch {
            errorMessage = "Couldn’t send reset email. \(error.localizedDescription)"
        }
    }
}
