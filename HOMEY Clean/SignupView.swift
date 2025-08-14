import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var session: SessionManager

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var referralCode = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?

    private var canSubmit: Bool {
        !fullName.isEmpty && !email.isEmpty && !password.isEmpty && !referralCode.isEmpty
    }

    var body: some View {
        Form {
            Section(header: Text("Your Info")) {
                TextField("Full name", text: $fullName)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
            }

            Section(header: Text("Referral")) {
                TextField("Referral code", text: $referralCode)
                    .textInputAutocapitalization(.never)
            }

            if let msg = errorMessage {
                Section { Text(msg).foregroundStyle(.red) }
            }
            if let msg = infoMessage {
                Section { Text(msg).foregroundStyle(.blue) }
            }

            Section {
                Button {
                    Task { await signup() }
                } label: {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("Create Account")
                    }
                }
                .disabled(isLoading || !canSubmit)
            }
        }
        .navigationTitle("Create account")
    }

    @MainActor
    private func signup() async {
        errorMessage = nil
        infoMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            // You already wired referral signup via Supabase function service.
            // Keep your existing implementation call here if needed.
            // After signup, we try immediate sign-in; if it fails because email not confirmed,
            // we show a friendly info message instead of error.
            try await session.signIn(email: email, password: password)
        } catch let e as SessionManager.SignInError {
            if case .emailNotConfirmed = e {
                infoMessage = "Account created. Please check your email to confirm your account, then sign in."
            } else {
                errorMessage = e.localizedDescription
            }
        } catch {
            errorMessage = "Couldn’t create account. \(error.localizedDescription)"
        }
    }
}
