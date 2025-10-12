import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

struct CreateAccountView: View {
    @EnvironmentObject private var session: AppSessionManager
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?
    @State private var showResend = false
    @State private var resendInFlight = false
    @State private var attemptedSubmit = false
    @State private var showVerifyGuidance = false

    @FocusState private var focus: Field?
    enum Field { case fullName, email, password, confirmPassword }

    var body: some View {
        NavigationStack {
            ZStack {
                // Soft animated backdrop
                LinearGradient(
                    colors: [
                        Color(.sRGB, red: 0.10, green: 0.12, blue: 0.16, opacity: 1),
                        Color(.sRGB, red: 0.06, green: 0.06, blue: 0.08, opacity: 1)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .overlay(
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Theme.primaryAction.opacity(0.28), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 420, height: 420)
                            .blur(radius: 60)
                            .offset(x: -160, y: -240)
                        Circle()
                            .fill(LinearGradient(colors: [.white.opacity(0.16), .clear], startPoint: .bottomTrailing, endPoint: .topLeading))
                            .frame(width: 360, height: 360)
                            .blur(radius: 70)
                            .offset(x: 140, y: 220)
                    }
                )

                ScrollView {
                    VStack(spacing: 18) {
                        Text("Create account")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.top, 12)

                        if let info = infoMessage { Banner(text: info, style: .info) }
                        if let err = errorMessage { Banner(text: err, style: .error) }

                        // Floating liquid glass card
                        VStack(spacing: 14) {
                            // Full Name
                            TextField("Full Name", text: $fullName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(false)
                                .textContentType(.name)
                                .submitLabel(.next)
                                .focused($focus, equals: .fullName)
                                .onSubmit { focus = .email }
                                .authFieldStyle()
                            
                            // Email
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .textContentType(.emailAddress)
                                .submitLabel(.next)
                                .focused($focus, equals: .email)
                                .onSubmit { focus = .password }
                                .authFieldStyle()
                            
                            // Password
                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .submitLabel(.next)
                                .focused($focus, equals: .password)
                                .onSubmit { focus = .confirmPassword }
                                .authFieldStyle()
                            
                            // Confirm Password
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .submitLabel(.go)
                                .focused($focus, equals: .confirmPassword)
                                .onSubmit { Task { await sendMagicLink() } }
                                .authFieldStyle()
                            let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
                            if (attemptedSubmit || !emailTrimmed.isEmpty) && !(emailTrimmed.lowercased().contains("@") && emailTrimmed.lowercased().contains(".")) {
                                validationText("Enter a valid email address.")
                            }
                            
                            if (attemptedSubmit || !password.isEmpty) && password.count < 6 {
                                validationText("Password must be at least 6 characters.")
                            }
                            
                            if (attemptedSubmit || !confirmPassword.isEmpty) && password != confirmPassword {
                                validationText("Passwords don't match.")
                            }

                            // Primary action
                            Button {
                                Task { await sendMagicLink() }
                            } label: {
                                HStack(spacing: 8) {
                                    if isLoading { ProgressView().tint(.white) }
                                    Text(isLoading ? "Creating…" : "Create Account")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!canSubmit || isLoading)
                            .padding(.top, 6)

                            // Resend + Open email actions (only shown when relevant)
                            if showResend {
                                VStack(spacing: 10) {
                                    Button {
                                        Task { await resendMagicLink() }
                                    } label: {
                                        HStack(spacing: 8) {
                                            if resendInFlight { ProgressView().tint(.white) }
                                            Text(resendInFlight ? "Sending…" : "Resend magic link")
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.primaryAction)

                                    Button {
                                        openEmailApp()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "envelope.fill")
                                            Text("Open email app")
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(Theme.primaryAction)
                                }
                                .padding(.top, 6)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.16), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 18, y: 10)

                        Text("By continuing, you agree to our Terms and acknowledge our Privacy Policy.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focus = nil }
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(isLoading)
        .sheet(isPresented: $showVerifyGuidance) {
            EmailVerificationGuidanceView(
                email: email,
                onResend: {
                    Task { await resendMagicLink() }
                },
                onOpenEmail: {
                    openEmailApp()
                },
                onVerified: {
                    Task {
                        await session.restoreIfPossible()
                        await MainActor.run {
                            email = ""
                            showVerifyGuidance = false
                            dismiss()
                        }
                    }
                }
            )
        }
    }

    private var canSubmit: Bool {
        let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !emailTrimmed.isEmpty &&
               emailTrimmed.contains("@") &&
               emailTrimmed.contains(".") &&
               password.count >= 6 &&
               password == confirmPassword
    }

    // MARK: - Actions
    @MainActor
    private func sendMagicLink() async {
        attemptedSubmit = true
        
        guard canSubmit else { return }
        
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        
        do {
            // Use signUp with password instead of signInWithOTP
            try await session.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            // Set onboarding as not completed for new users
            UserDefaults.standard.set(false, forKey: "OnboardingCompleted")
            
            infoMessage = "Account created successfully! Please check your email to verify your account."
            showVerifyGuidance = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    @MainActor
    private func resendMagicLink() async {
        let emailLower = email.trimLower()
        guard !emailLower.isEmpty else { return }
        resendInFlight = true
        defer { resendInFlight = false }
        do {
            #if canImport(Supabase)
            let client = session.supabaseClient
            try await client.auth.signInWithOTP(
                email: emailLower,
                redirectTo: URL(string: "homey://auth-callback")
            )
            #endif
            infoMessage = "Magic link sent again. Please check your inbox."
        } catch {
            errorMessage = "Couldn't resend. \(error.localizedDescription)"
        }
    }

    private func openEmailApp() {
        // Try to open the user's default email app
        // First try the generic mailto: scheme which should open the default email app
        if let url = URL(string: "mailto:") {
            openURL(url)
        }
    }

    // MARK: - Helpers
    private func mapSignupError(_ error: Error) -> String {
        let msg = error.localizedDescription
        if msg.localizedCaseInsensitiveContains("rate") &&
            msg.localizedCaseInsensitiveContains("limit") {
            return "Too many requests. Please wait a minute and try again."
        }
        if msg.localizedCaseInsensitiveContains("already registered") ||
            msg.localizedCaseInsensitiveContains("duplicate") ||
            msg.localizedCaseInsensitiveContains("unique constraint") {
            return "That email is already registered. Check your inbox for a magic link or try signing in."
        }
        if msg.localizedCaseInsensitiveContains("network") ||
            msg.localizedCaseInsensitiveContains("timed out") ||
            msg.localizedCaseInsensitiveContains("internet") {
            return "Can’t reach the server. Check your connection and try again."
        }
        return "Couldn’t create account. \(msg)"
    }

    @ViewBuilder
    private func validationText(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if canImport(Supabase)
// Nothing else needed for passwordless sign-up; AppSessionManager will pick up the session
// via auth state changes after the link is opened.
#endif

private struct EmailVerificationGuidanceView: View {
    let email: String
    let onResend: () -> Void
    let onOpenEmail: () -> Void
    let onVerified: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.primaryAction)
                    .padding(.top, 12)
                Text("Check your email")
                    .font(.title2.weight(.semibold))
                Text("We sent a magic link to \(email). Tap it on this device to complete sign-in.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                VStack(spacing: 10) {
                    Button(action: onOpenEmail) {
                        Label("Open email app", systemImage: "envelope.open")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primaryAction)

                    Button(action: onResend) {
                        Label("Resend magic link", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.primaryAction)
                }
                .padding(.top, 6)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Magic Link")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

private struct Banner: View {
    enum Style { case info, error }
    let text: String
    let style: Style
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(style == .error ? .white : .black)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(style == .error ? Color.red : Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

extension String { func trimLower() -> String { trimmingCharacters(in: .whitespacesAndNewlines).lowercased() } }