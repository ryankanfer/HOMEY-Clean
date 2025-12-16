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
    @State private var presentingAccessCode: Bool = false
    @State private var presentingCreateAccount: Bool = false

    // Forgot password sheet state
    @State private var showForgotPasswordSheet: Bool = false
    @State private var resetEmail: String = ""
    @State private var resetIsLoading: Bool = false
    @State private var resetError: String?
    @State private var resetInfo: String?

    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    private var themeAccent: Color { Theme.primaryAction }

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen animated gradient background with light rays and particles
                AnimatedAuroraBackground(reduceMotion: reduceMotion)
                    .ignoresSafeArea()

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
                                .shadow(color: Color.black.opacity(0.28), radius: 20, y: 12)

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

                                    // Forgot password button (placed right after the password field)
                                    Button {
                                        // Prefill with current email if available
                                        resetEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                                        resetError = nil
                                        resetInfo = nil
                                        showForgotPasswordSheet = true
                                    } label: {
                                        Text("Forgot password?")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Theme.primaryAction)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 2)
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
                                    presentingAccessCode = true
                                } label: {
                                    Text("Create account")
                                        .font(.callout.weight(.medium))
                                }
                                .tint(Theme.primaryAction)
                                .padding(.top, Spacing.sm)
                                .sheet(isPresented: $presentingAccessCode) {
                                    AccessCodeView {
                                        presentingAccessCode = false
                                        presentingCreateAccount = true
                                    }
                                    .environmentObject(session)
                                }
                                .sheet(isPresented: $presentingCreateAccount) {
                                    CreateAccountView()
                                        .environmentObject(session)
                                }
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                // Crisp inner stroke
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(.white.opacity(0.16), lineWidth: 1)
                            )
                            // Soft outer shadow + subtle color glow to make the card pop
                            .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 12)
                            .shadow(color: themeAccent.opacity(0.18), radius: 22, x: 0, y: 0)
                            // Very subtle inner shading for depth
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(LinearGradient(colors: [.black.opacity(0.12), .clear],
                                                           startPoint: .top, endPoint: .bottom),
                                            lineWidth: 1)
                                    .blendMode(.overlay)
                            )
                        }
                        .padScreen()

                        Spacer(minLength: 24)
                    }
                    .padding(.bottom, 40)
                }
                .scrollContentBackground(.hidden)
            }
            // Hide navigation bar entirely on this screen
            .toolbar(.hidden, for: .navigationBar)
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
            // Forgot password sheet
            .sheet(isPresented: $showForgotPasswordSheet) {
                ForgotPasswordSheet(
                    email: $resetEmail,
                    isLoading: $resetIsLoading,
                    infoMessage: $resetInfo,
                    errorMessage: $resetError,
                    onSend: {
                        Task { await sendPasswordReset() }
                    }
                )
                .presentationDetents([.medium, .large])
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

    @MainActor
    private func sendPasswordReset() async {
        let trimmed = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.contains("@"), trimmed.contains(".") else {
            resetError = "Enter a valid email address."
            resetInfo = nil
            return
        }
        resetIsLoading = true
        resetError = nil
        resetInfo = nil
        defer { resetIsLoading = false }
        do {
            let redirect = URL(string: "homey://auth-callback")!
            try await session.resetPassword(email: trimmed.lowercased(), redirectTo: redirect)
            resetInfo = "Password reset link sent. Check your email."
        } catch {
            resetError = error.localizedDescription
        }
    }
}

// MARK: - Full-screen animated background

private struct AnimatedAuroraBackground: View {
    @Environment(\.colorScheme) private var scheme
    let reduceMotion: Bool

    @State private var animateRays = false
    @State private var animateParticles = false
    @State private var palette: [Color] = []

    // Define palettes to randomize between
    private let palettes: [[Color]] = [
        // Purple
        [Color.purple, Color.indigo, Color.mint.opacity(0.2), .black.opacity(0.2)],
        // Sky blue
        [Theme.skyBlue, Color.blue, Color.cyan.opacity(0.3), .black.opacity(0.2)],
        // White (soft glow with cool tones)
        [Color.white.opacity(0.9), Color.cyan.opacity(0.25), Color.blue.opacity(0.15), .black.opacity(0.2)],
        // Pink
        [Color.pink, Color.mint.opacity(0.2), Color.purple.opacity(0.3), .black.opacity(0.2)],
        // Red
        [Color.red, Color.orange.opacity(0.4), Color.pink.opacity(0.3), .black.opacity(0.25)],
        // Sunset
        [Color.orange, Color.pink, Color.purple.opacity(0.35), .black.opacity(0.2)],
        // Sunrise
        [Color.yellow.opacity(0.9), Color.orange.opacity(0.6), Color.pink.opacity(0.35), .black.opacity(0.2)]
    ]

    var body: some View {
        ZStack {
            // Base gradient fill for the whole screen, adaptive to scheme
            LinearGradient(
                colors: [
                    Theme.background.opacity(scheme == .dark ? 1 : 1),
                    Theme.background.opacity(scheme == .dark ? 0.96 : 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Light rays: slowly rotating angular gradient
            AngularGradient(
                gradient: Gradient(colors: raysColors()),
                center: .center,
                angle: .degrees(animateRays ? 360 : 0)
            )
            .opacity(scheme == .dark ? 0.45 : 0.35)
            .blur(radius: 40)
            .animation(reduceMotion ? nil : .linear(duration: 40).repeatForever(autoreverses: false), value: animateRays)

            // Large particles: drifting, scaling soft blobs
            ZStack {
                ForEach(0..<6, id: \.self) { idx in
                    ParticleBlob(color: particleColor(for: idx), index: idx, reduceMotion: reduceMotion, animate: animateParticles)
                }
            }
            .allowsHitTesting(false)
        }
        .onAppear {
            // Choose a palette at appearance
            if palette.isEmpty {
                palette = palettes.randomElement() ?? palettes[0]
            }
            guard !reduceMotion else { return }
            animateRays = true
            // Stagger particle animation start slightly for variety
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateParticles = true
            }
        }
    }

    private func raysColors() -> [Color] {
        let cols = palette
        // Interleave palette colors with transparent separators for ray-like beams
        let transparent = Color.clear
        // Repeat pattern to create multiple beams
        var rays: [Color] = []
        for c in cols {
            rays.append(c.opacity(0.9))
            rays.append(c.opacity(0.2))
            rays.append(transparent)
        }
        return rays + rays // double up for smoother distribution
    }

    private func particleColor(for index: Int) -> Color {
        guard !palette.isEmpty else { return Theme.primaryAction.opacity(0.3) }
        let base = palette[index % palette.count]
        return base.opacity(scheme == .dark ? 0.25 : 0.20)
    }
}

private struct ParticleBlob: View {
    let color: Color
    let index: Int
    let reduceMotion: Bool
    let animate: Bool

    // Randomized parameters per index for position/size pathing
    private var size: CGFloat {
        let base: CGFloat = 220
        return base + CGFloat((index % 3) * 40)
    }

    private var startOffset: CGSize {
        switch index % 6 {
        case 0: return CGSize(width: -140, height: -260)
        case 1: return CGSize(width: 160, height: -200)
        case 2: return CGSize(width: -180, height: 220)
        case 3: return CGSize(width: 140, height: 260)
        case 4: return CGSize(width: -40, height: 40)
        default: return CGSize(width: 60, height: -60)
        }
    }

    private var endOffset: CGSize {
        switch index % 6 {
        case 0: return CGSize(width: -120, height: -180)
        case 1: return CGSize(width: 120, height: -120)
        case 2: return CGSize(width: -120, height: 180)
        case 3: return CGSize(width: 100, height: 200)
        case 4: return CGSize(width: -20, height: 80)
        default: return CGSize(width: 100, height: -20)
        }
    }

    private var duration: Double {
        // Different durations per particle
        28 + Double((index % 4) * 6)
    }

    @State private var progress: CGFloat = 0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 80)
            .scaleEffect(1 + 0.06 * sin(progress * .pi * 2))
            .offset(interpolatedOffset(t: (1 + cos(progress * .pi * 2)) / 2))
            .opacity(0.9)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    progress = 1
                }
            }
    }

    private func interpolatedOffset(t: CGFloat) -> CGSize {
        let x = CGFloat.lerp(start: startOffset.width, end: endOffset.width, t: t)
        let y = CGFloat.lerp(start: startOffset.height, end: endOffset.height, t: t)
        return CGSize(width: x, height: y)
    }
}

private extension CGFloat {
    static func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        start + (end - start) * t
    }
}

// MARK: - Animated gradient behind auth card

private struct AnimatedAuthGradient: View {
    @Environment(\.colorScheme) private var scheme
    let reduceMotion: Bool

    @State private var animate = false

    private var baseColors: [Color] {
        // Slate gray to purple, tuned for both modes
        let slate = Theme.slateGray.opacity(scheme == .dark ? 0.50 : 0.40)
        let purple = Color.purple.opacity(scheme == .dark ? 0.42 : 0.34)
        let blackOverlay = Color.black.opacity(scheme == .dark ? 0.28 : 0.10)
        return [slate, purple, blackOverlay]
    }

    var body: some View {
        ZStack {
            // Moving angular gradient for a subtle ambient motion
            AngularGradient(
                gradient: Gradient(colors: baseColors),
                center: .center,
                angle: .degrees(animate ? 360 : 0)
            )
            .opacity(0.42)

            // Gentle radial glow to add depth
            RadialGradient(
                colors: [Color.purple.opacity(0.24), .clear],
                center: .topLeading,
                startRadius: 30,
                endRadius: 360
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

// MARK: - Forgot Password Sheet

private struct ForgotPasswordSheet: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var infoMessage: String?
    @Binding var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var onSend: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Reset your password")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email address")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)

                    TextField("name@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .textContentType(.emailAddress)
                        .submitLabel(.go)
                        .onSubmit { onSend() }
                        .authFieldStyle()
                }

                if let info = infoMessage, !info.isEmpty {
                    Banner(text: info, style: .info)
                }
                if let err = errorMessage, !err.isEmpty {
                    Banner(text: err, style: .error)
                }

                Button {
                    onSend()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading { ProgressView().tint(.white) }
                        Text(isLoading ? "Sending…" : "Send reset link")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isLoading || !isValidEmail(email))

                Spacer(minLength: 12)
            }
            .padding(20)
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func isValidEmail(_ e: String) -> Bool {
        let trimmed = e.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.contains("@") && trimmed.contains(".")
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
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}
