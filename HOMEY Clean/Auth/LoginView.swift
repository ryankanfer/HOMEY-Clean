import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var appear = false
    @State private var presentingCreateAccount: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    private var themeAccent: Color { Theme.primaryAction }
    private var pageAccent: Color { Theme.primaryAction }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Theme.background, Theme.surface], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                LoginAuroraFlowView(primary: themeAccent, secondary: pageAccent, reduceMotion: reduceMotion)
                    .opacity(reduceMotion ? 0.12 : 0.24)
                    .blendMode(.screen)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                LoginLightRaysView(glow: themeAccent, reduceMotion: reduceMotion)
                    .opacity(reduceMotion ? 0.10 : 0.16)
                    .blendMode(.screen)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                LinearGradient(
                    colors: [Color.black.opacity(0.22), .clear, Color.black.opacity(0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        Spacer(minLength: 60)

                        VStack(spacing: Spacing.md) {
                            Text("HOMEY")
                                .homeyTitle()
                                .foregroundStyle(Theme.primaryText.opacity(0.96))

                            Text("Welcome back")
                                .homeyBodyLarge()
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .padding(.bottom, Spacing.lg)

                        VStack(spacing: Spacing.lg) {
                            VStack(spacing: Spacing.sm) {
                                Text("Sign in to continue")
                                    .font(.callout)
                                    .foregroundStyle(Theme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            VStack(spacing: Spacing.md) {
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
                            .scaleEffect(appear ? 1 : 0.96)
                            .animation(.spring(response: 0.6, dampingFraction: 0.85), value: appear)
                            .accessibilityLabel(isLoading ? "Signing in" : "Sign in")
                            .accessibilityHint(isLoading ? "Please wait while we sign you in" : "Tap to sign in with your email and password")

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
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .padScreen()

                        Spacer(minLength: 40)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
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
    let primary: Color
    let secondary: Color
    let reduceMotion: Bool
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ribbon(
                    width: geo.size.width * 1.6,
                    height: geo.size.height * 0.28,
                    rotation: -14,
                    y: geo.size.height * 0.24,
                    speed: reduceMotion ? 60 : 26,
                    colors: [
                        primary.opacity(0.55),
                        secondary.opacity(0.45),
                        Color.white.opacity(0.14)
                    ]
                )
                ribbon(
                    width: geo.size.width * 1.7,
                    height: geo.size.height * 0.32,
                    rotation: 10,
                    y: geo.size.height * 0.52,
                    speed: reduceMotion ? 70 : 30,
                    colors: [
                        secondary.opacity(0.50),
                        primary.opacity(0.40),
                        Color.white.opacity(0.10)
                    ]
                )
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 28).repeatForever(autoreverses: true)) {
                    phase = 1
                }
            }
        }
    }

    private func ribbon(
        width: CGFloat,
        height: CGFloat,
        rotation: Double,
        y: CGFloat,
        speed: Double,
        colors: [Color]
    ) -> some View {
        let grad = LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
        return RoundedRectangle(cornerRadius: height / 2)
            .fill(grad)
            .frame(width: width, height: height)
            .blur(radius: 24)
            .rotationEffect(.degrees(rotation))
            .offset(x: (phase > 0 ? -width * 0.12 : width * 0.12), y: y)
            .animation(
                .easeInOut(duration: speed).repeatForever(autoreverses: true),
                value: phase
            )
    }
}

private struct LoginLightRaysView: View {
    let glow: Color
    let reduceMotion: Bool
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
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                    sweep = 1.1
                }
            }
        }
    }

    private func beam(width: CGFloat, height: CGFloat, angle: Double) -> some View {
        LinearGradient(
            colors: [glow.opacity(0.18), glow.opacity(0.06), .clear],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: width, height: height)
        .blur(radius: 22)
        .rotationEffect(.degrees(angle))
    }
}