import SwiftUI
import AuthenticationServices
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
#if canImport(CryptoKit)
import CryptoKit
#endif
#if canImport(Supabase)
import Supabase
#endif

struct LoginView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.openURL) private var openURL

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var appear = false
    @State private var presentingCreateAccount: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    private var themeAccent: Color { Theme.primaryAction }

    var body: some View {
        NavigationStack {
            ZStack {
                // Native-friendly background with subtle ambient glow
                LinearGradient(
                    colors: [
                        Theme.background,
                        Theme.background.opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if !reduceMotion {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [themeAccent.opacity(0.22), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 380, height: 380)
                            .blur(radius: 80)
                            .offset(x: -140, y: -220)
                        Circle()
                            .fill(LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .bottomTrailing, endPoint: .topLeading))
                            .frame(width: 320, height: 320)
                            .blur(radius: 90)
                            .offset(x: 120, y: 200)
                    }
                    .allowsHitTesting(false)
                }

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        VStack(spacing: 8) {
                            Text("HOMEY")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundStyle(Theme.primaryText)
                                .accessibilityLabel("Homey")

                            Text("Welcome back")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .padding(.top, 24)

                        // Card with animated gradient backdrop
                        ZStack {
                            // Subtle animated slate gray -> purple gradient behind the card
                            AnimatedAuthGradient(reduceMotion: reduceMotion)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(.white.opacity(0.06), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.25), radius: 18, y: 10)

                            // Card
                            VStack(spacing: Spacing.lg) {
                                // Guidance
                                VStack(spacing: 6) {
                                    Text("Sign in to continue")
                                        .font(.callout)
                                        .foregroundStyle(Theme.secondaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                // Fields
                                VStack(spacing: Spacing.md) {
                                    // Email
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "envelope")
                                                .foregroundStyle(Theme.secondaryText)
                                                .font(.callout)
                                                .accessibilityHidden(true)
                                            TextField("Email address", text: $email)
                                                .keyboardType(.emailAddress)
                                                .textContentType(.emailAddress)
                                                .textInputAutocapitalization(.never)
                                                .disableAutocorrection(true)
                                                .submitLabel(.next)
                                                .focused($focusedField, equals: .email)
                                                .onSubmit { focusedField = .password }
                                                .accessibilityLabel("Email address")
                                                .accessibilityHint("Enter your email address to sign in")
                                        }
                                    }
                                    .authFieldStyle()

                                    // Password
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "lock")
                                                .foregroundStyle(Theme.secondaryText)
                                                .font(.callout)
                                                .accessibilityHidden(true)
                                            SecureField("Password", text: $password)
                                                .textContentType(.password)
                                                .submitLabel(.go)
                                                .focused($focusedField, equals: .password)
                                                .onSubmit { trySignIn() }
                                                .accessibilityLabel("Password")
                                                .accessibilityHint("Enter your password to sign in")
                                        }
                                    }
                                    .authFieldStyle()
                                }

                                // Error
                                if let msg = errorMessage, !msg.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.red)
                                            .font(.caption)
                                        Text(msg)
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, 6)
                                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                // Primary button
                                Button(action: trySignIn) {
                                    HStack(spacing: 8) {
                                        if isLoading {
                                            ProgressView()
                                                .scaleEffect(0.9)
                                                .tint(.white)
                                                .accessibilityHidden(true)
                                        }
                                        Text(isLoading ? "Signing In..." : "Sign In")
                                            .font(.headline.weight(.semibold))
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(isLoading || email.isEmpty || password.isEmpty)
                                .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.7 : 1)
                                .scaleEffect(appear ? 1 : 0.98)
                                .animation(.spring(response: 0.5, dampingFraction: 0.9), value: appear)
                                .accessibilityLabel(isLoading ? "Signing in" : "Sign in")
                                .accessibilityHint(isLoading ? "Please wait while we sign you in" : "Tap to sign in with your email and password")

                                // Social sign-in (native)
                                VStack(spacing: 10) {
                                    Text("Or continue with")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Theme.secondaryText)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 2)

                                    HStack(spacing: Spacing.md) {
                                        // Apple
                                        Button {
                                            Task { await signInWithApple() }
                                        } label: {
                                            Label("Apple", systemImage: "apple.logo")
                                                .labelStyle(.titleAndIcon)
                                                .font(.callout.weight(.semibold))
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(Theme.primaryAction.opacity(0.9))
                                        .disabled(isLoading)

                                        // Google
                                        Button {
                                            Task { await signInWithGoogle() }
                                        } label: {
                                            Label("Google", systemImage: "globe")
                                                .labelStyle(.titleAndIcon)
                                                .font(.callout.weight(.semibold))
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(Theme.primaryAction.opacity(0.9))
                                        .disabled(isLoading)
                                    }
                                }

                                // Create account
                                Button {
                                    presentingCreateAccount = true
                                } label: {
                                    Text("Create account")
                                        .font(.callout.weight(.medium))
                                }
                                .tint(Theme.primaryAction)
                                .padding(.top, Spacing.sm)
                                .sheet(isPresented: $presentingCreateAccount) {
                                    CreateAccountView()
                                        .environmentObject(session)
                                }
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(.white.opacity(0.16), lineWidth: 1)
                            )
                        }
                        .padScreen()

                        Spacer(minLength: 24)
                    }
                    .padding(.bottom, 40)
                }
                .scrollContentBackground(.hidden)
            }
            // Removed the "Sign In" navigation title
            // .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.9).delay(0.05)) {
                    appear = true
                }
            }
        }
    }

    private func trySignIn() {
        guard !email.isEmpty, !password.isEmpty, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await session.signIn(email: email.trimLower(), password: password)
            } catch {
                let nsError = error as NSError
                print("[LoginView] Sign-in error: \(nsError.localizedDescription)")
                print("[LoginView] Error domain: \(nsError.domain)")
                print("[LoginView] Error code: \(nsError.code)")
                print("[LoginView] Error userInfo: \(nsError.userInfo)")
                errorMessage = nsError.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - Animated gradient behind auth card

private struct AnimatedAuthGradient: View {
    @Environment(\.colorScheme) private var scheme
    let reduceMotion: Bool

    @State private var animate = false

    private var baseColors: [Color] {
        // Slate gray to purple, tuned for both modes
        let slate = Theme.slateGray.opacity(scheme == .dark ? 0.45 : 0.35)
        let purple = Color.purple.opacity(scheme == .dark ? 0.35 : 0.28)
        let blackOverlay = Color.black.opacity(scheme == .dark ? 0.25 : 0.08)
        return [slate, purple, blackOverlay]
    }

    var body: some View {
        ZStack {
            // Moving angular gradient for a very subtle ambient motion
            AngularGradient(
                gradient: Gradient(colors: baseColors),
                center: .center,
                angle: .degrees(animate ? 360 : 0)
            )
            .opacity(0.35)

            // Gentle radial glow to add depth
            RadialGradient(
                colors: [Color.purple.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 280
            )
            .blendMode(.plusLighter)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

// MARK: - Provider Sign-In
extension LoginView {
    @MainActor
    private func signInWithApple() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let nonce = CryptoNonce.randomNonceString()
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = CryptoNonce.sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInCoordinator()
            controller.delegate = delegate
            controller.presentationContextProvider = delegate

            try await delegate.perform(controller: controller)

            guard let idToken = delegate.idTokenString else {
                throw AuthFlowError.missingIDToken
            }

            #if canImport(Supabase)
            // Use credentials-based API compatible with current supabase-swift
            _ = try await session.supabaseClient.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )
            #endif
        } catch {
            errorMessage = "Apple sign-in failed: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func signInWithGoogle() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        #if canImport(GoogleSignIn)
        do {
            guard let rootScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = rootScene.keyWindow?.rootViewController else {
                throw AuthFlowError.presentationContextUnavailable
            }

            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            let user = signInResult.user

            guard let idToken = user.idToken?.tokenString else {
                throw AuthFlowError.missingIDToken
            }
            let accessToken = user.accessToken.tokenString

            #if canImport(Supabase)
            // Use credentials-based API compatible with current supabase-swift
            _ = try await session.supabaseClient.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )
            #endif
        } catch {
            errorMessage = "Google sign-in failed: \(error.localizedDescription)"
        }
        #else
        errorMessage = "Google Sign-In SDK not found. Add 'google/GoogleSignIn-iOS' via Swift Package Manager."
        #endif
    }
}

// MARK: - Coordinators & Helpers

private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    fileprivate var continuation: CheckedContinuation<Void, Error>?
    fileprivate var idTokenString: String?

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Provide the current key window or a fallback window
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.keyWindow {
            return window
        }
        return UIWindow()
    }

    func perform(controller: ASAuthorizationController) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.continuation = continuation
            controller.performRequests()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { continuation = nil }
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = appleIDCredential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            continuation?.resume(throwing: AuthFlowError.missingIDToken)
            return
        }
        self.idTokenString = token
        continuation?.resume()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

private enum AuthFlowError: LocalizedError {
    case missingIDToken
    case presentationContextUnavailable

    var errorDescription: String? {
        switch self {
        case .missingIDToken: return "Missing identity token."
        case .presentationContextUnavailable: return "Unable to present sign-in UI."
        }
    }
}

private enum CryptoNonce {
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        let charsetArray = Array(charset)
        var result = ""
        var remaining = length

        while remaining > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status)")
            }
            randoms.forEach { random in
                if remaining == 0 { return }
                let idx = Int(random) % charsetArray.count
                result.append(charsetArray[idx])
                remaining -= 1
            }
        }
        return result
    }

    static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        #if canImport(CryptoKit)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
        #else
        // Minimal fallback if CryptoKit isn't available
        return data.base64EncodedString()
        #endif
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        return self.windows.first(where: { $0.isKeyWindow })
    }
}
