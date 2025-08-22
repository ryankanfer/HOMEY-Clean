import SwiftUI
#if canImport(Supabase)
    import Supabase
#endif

struct SignupView: View {
    @EnvironmentObject private var session: AppSessionManager

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var referralCode = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?

    @FocusState private var focus: Field?
    enum Field { case name, email, password, referral }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.sRGB, red: 0.95, green: 0.97, blue: 0.99, opacity: 1),
                    Color(.sRGB, red: 0.88, green: 0.94, blue: 0.98, opacity: 1)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 10) {
                        Image("homey_logo").resizable().scaledToFit().frame(width: 72, height: 72)
                        Text("Create your HOMEY account")
                            .font(.title3.weight(.semibold))
                        Text("in your pocket. on your side.")
                            .font(.footnote).foregroundStyle(Theme.textMuted)
                    }
                    .padding(.top, 36)

                    if let info = infoMessage { Banner(text: info, style: .info) }
                    if let err = errorMessage { Banner(text: err, style: .error) }

                    VStack(spacing: 12) {
                        TextField("Full name", text: $fullName)
                            .textContentType(.name)
                            .submitLabel(.next)
                            .focused($focus, equals: .name)
                            .onSubmit { focus = .email }
                            .authFieldStyle()

                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textContentType(.emailAddress)
                            .submitLabel(.next)
                            .focused($focus, equals: .email)
                            .onSubmit { focus = .password }
                            .authFieldStyle()

                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                            .focused($focus, equals: .password)
                            .onSubmit { focus = .referral }
                            .authFieldStyle()

                        TextField("Referral code", text: $referralCode)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.go)
                            .focused($focus, equals: .referral)
                            .onSubmit { Task { await createAccount() } }
                            .authFieldStyle()

                        Button {
                            Task { await createAccount() }
                        } label: {
                            HStack {
                                if isLoading { ProgressView().tint(.white) }
                                Text(isLoading ? "Creating…" : "Create account")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!canSubmit || isLoading)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)

                    Text("By continuing, you agree to our Terms and acknowledge our Privacy Policy.")
                        .font(.caption)
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Spacer(minLength: 20)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
            }
        }
    }

    private var canSubmit: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !password.isEmpty &&
            !referralCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @MainActor
    private func createAccount() async {
        guard canSubmit else { return }
        errorMessage = nil
        infoMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            #if canImport(Supabase)
                // Use your existing edge function to create auth user + profile with role.
                let functions = SupabaseFunctionsService(client: session.supabaseClient)
                let req = ReferralSignupRequest(
                    email: email.trimLower(), password: password,
                    full_name: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    referral_code: referralCode.trimLower()
                )
                _ = try await functions.referralSignup(req)
            #endif

            // Then attempt sign-in; if email confirm is required, surface that gently.
            try await session.signIn(email: email.trimLower(), password: password)

            #if canImport(Supabase)
                // Redeem invite/referral code right after successful sign-in
                do {
                    // auth.session is non-optional in this SDK build; token should be present right after sign-in
                    let authSession = try await session.supabaseClient.auth.session
                    let accessToken = authSession.accessToken
                    let result = try await InviteRedeemer.redeem(
                        code: referralCode.trimmingCharacters(in: .whitespacesAndNewlines),
                        accessToken: accessToken,
                        projectRef: "fafbjfajmmsjftiivhil"
                    )
                    // Surface a lightweight message; don't fail the signup if already redeemed
                    if result.ok {
                        infoMessage = result.already ? "Invite already redeemed." : "Invite redeemed."
                    }
                } catch let InviteRedeemError.http(status) {
                    switch status {
                    case 400: errorMessage = "Invalid or expired invite code."
                    case 401: errorMessage = "Session expired. Please sign in again."
                    case 404: errorMessage = "Invite code not found."
                    default: errorMessage = "Couldn’t redeem invite (HTTP \(status))."
                    }
                } catch {
                    // Network or parsing error; keep the account but show a gentle message
                    infoMessage = "Account created. We’ll retry invite redemption in-app."
                }
            #endif
        } catch let e as AppSessionManager.SignInError {
            switch e {
            case .emailNotConfirmed:
                infoMessage = "Account created. Please confirm your email, then sign in."
            case .invalidCredentials:
                errorMessage = "Couldn’t sign in after creating the account. Try after confirming your email."
            case .network:
                errorMessage = "Can’t reach the server. Try again."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } catch {
            errorMessage = "Couldn’t create account. \(error.localizedDescription)"
        }
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
