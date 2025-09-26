import SwiftUI

private struct ProfileRole: Decodable { let role: String }

struct LoginView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var appear = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        NavigationStack {
            ZStack {
                // Neutral cinematic background (no sky elements)
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.10, blue: 0.12),
                        Color(red: 0.06, green: 0.06, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle aurora-style motion
                LoginAuroraFlowView()
                    .opacity(0.35)
                    .blendMode(.screen)
                    .ignoresSafeArea()

                // Occasional light rays sweep
                LoginLightRaysView()
                    .opacity(0.20)
                    .blendMode(.screen)
                    .ignoresSafeArea()

                // Soft vignette for readability
                LinearGradient(
                    colors: [Color.black.opacity(0.28), .clear, Color.black.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        Spacer(minLength: 60)
                        
                        // Modern header with improved typography
                        VStack(spacing: Spacing.md) {
                            Text("HOMEY")
                                .titleText()
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Welcome back")
                                .subtitleText(color: .white.opacity(0.9))
                        }
                        .padding(.bottom, Spacing.lg)
                        
                        // Liquid glass login form
                        VStack(spacing: Spacing.lg) {
                            VStack(spacing: Spacing.sm) {
                                Text("Sign in to continue")
                                    .font(.callout)
                                    .foregroundStyle(ThemeColor.secondaryLabel)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            VStack(spacing: Spacing.md) {
                                // Modern email field
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "envelope")
                                            .foregroundStyle(ThemeColor.secondaryLabel)
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

                                // Modern password field
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lock")
                                            .foregroundStyle(ThemeColor.secondaryLabel)
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

                            // Error message with better styling
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

                            // Modern sign in button
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
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Theme.primary, Theme.primary.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                )
                                .foregroundStyle(.white)
                                .shadow(
                                    color: Theme.primary.opacity(0.3),
                                    radius: 8,
                                    y: 4
                                )
                            }
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1)
                            .scaleEffect(appear ? 1 : 0.95)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appear)
                            .accessibilityLabel(isLoading ? "Signing in" : "Sign in")
                            .accessibilityHint(isLoading ? "Please wait while we sign you in" : "Tap to sign in with your email and password")

                            // Modern sign up link
                            NavigationLink("Create account") { SignupView() }
                                .font(.callout.weight(.medium))
                                .foregroundStyle(Theme.primary)
                                .padding(.top, Spacing.sm)
                        }
                        .padding(20)
                        .background(
                            ZStack {
                                // True liquid glass: thin material + gradient sheen + subtle border
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
                        .padScreen()
                        
                        Spacer(minLength: 40)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.1)) {
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
                // Enhanced error handling to help debug the issue
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

private struct LoginAuroraFlowView: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ribbon(width: geo.size.width * 1.6, height: geo.size.height * 0.28, rotation: -14, y: geo.size.height * 0.24, speed: 26,
                       colors: [Color(red: 0.30, green: 0.70, blue: 1.0).opacity(0.6), Color(red: 0.25, green: 0.90, blue: 0.80).opacity(0.55), Color.white.opacity(0.2)])
                ribbon(width: geo.size.width * 1.7, height: geo.size.height * 0.32, rotation: 10, y: geo.size.height * 0.52, speed: 30,
                       colors: [Color(red: 1.0, green: 0.60, blue: 0.35).opacity(0.55), Color(red: 0.85, green: 0.40, blue: 0.85).opacity(0.5), Color(red: 0.45, green: 0.35, blue: 0.85).opacity(0.5)])
            }
            .onAppear {
                withAnimation(.linear(duration: 28).repeatForever(autoreverses: true)) {
                    phase = 1
                }
            }
        }
    }
    private func ribbon(width: CGFloat, height: CGFloat, rotation: Double, y: CGFloat, speed: Double, colors: [Color]) -> some View {
        let grad = LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
        return RoundedRectangle(cornerRadius: height / 2)
            .fill(grad)
            .frame(width: width, height: height)
            .blur(radius: 24)
            .rotationEffect(.degrees(rotation))
            .offset(x: (phase > 0 ? -width * 0.12 : width * 0.12), y: y)
            .animation(.easeInOut(duration: speed).repeatForever(autoreverses: true), value: phase)
    }
}

private struct LoginLightRaysView: View {
    @State private var sweep: CGFloat = -1.1
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                beam(width: w * 0.9, height: h * 0.16, angle: 20)
                    .offset(x: sweep * (w + 300), y: -h * 0.12)
                beam(width: w * 1.05, height: h * 0.20, angle: -16)
                    .offset(x: -sweep * (w + 300), y: h * 0.18)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                    sweep = 1.1
                }
            }
        }
    }
    private func beam(width: CGFloat, height: CGFloat, angle: Double) -> some View {
        LinearGradient(
            colors: [Color.white.opacity(0.18), Color.white.opacity(0.06), .clear],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: width, height: height)
        .blur(radius: 22)
        .rotationEffect(.degrees(angle))
    }
}
