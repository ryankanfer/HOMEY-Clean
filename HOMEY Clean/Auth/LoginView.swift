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
                // Use the new animated gradient background system
                AnimatedGradientBackground(for: .homey)
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
                        
                        // Modern glass card login form
                        GlassCard(cornerRadius: 20) {
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
                        }
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
