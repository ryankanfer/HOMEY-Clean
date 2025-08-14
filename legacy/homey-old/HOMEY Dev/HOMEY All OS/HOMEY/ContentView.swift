import SwiftUI

enum WelcomeStep {
    case email, referrer
}


struct LegacyContentView: View {
    @State private var step: WelcomeStep = .email
    @State private var email: String = ""
    @State private var referrerCode: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isPageVisible: Bool = false
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black, Color.black.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack {
                Spacer(minLength: 40)
                // Logo & Header
                VStack(spacing: 16) {
                    Image("logo_white")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 250)

                    Text("Finally, everything real estate, right in your pocket")
                        .font(.headline)
                        .foregroundStyle(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)
                .padding(.top, 16)
                .opacity(isPageVisible ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: isPageVisible)

                Spacer(minLength: 20)
                // Main Card
                VStack {
                    if isLoading {
                        ProgressView().scaleEffect(1.5)
                            .padding(32)
                    } else {
                        if step == .email {
                            emailStep
                        } else {
                            referrerStep
                        }
                    }
                }
                .frame(maxWidth: 400)
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.4)))
                .shadow(radius: 8)
                .opacity(isPageVisible ? 1 : 0)
                .animation(.easeInOut(duration: 1).delay(0.2), value: isPageVisible)

                Spacer(minLength: 30)

                // Footer
                VStack(spacing: 4) {
                    Text("Don't have an agent? We've got you — meet")
                        .foregroundColor(Color.white.opacity(0.7))
                    Text("Ryan")
                        .foregroundColor(.purple)
                        .underline()
                        .bold()
                        .onTapGesture {
                            contactRyan(by: "phone")
                        }
                }
                .font(.system(size: 14))
                .padding(12)
                .background(Color.black.opacity(0.4))
                .clipShape(Capsule())
                .opacity(isPageVisible ? 1 : 0.8)
            }
            .padding(.horizontal, 24)

            // Agent Access button (top right)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        agentAccess()
                    } label: {
                        Label("Agent Access", systemImage: "shield")
                            .foregroundColor(.gray)
                            .padding(10)
                            .background(Color.black.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.trailing, 12)
                    .padding(.top, 12)
                }
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPageVisible = true
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    var emailStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sign in to HOMEY")
                .font(.title2).bold()
                .foregroundColor(.white)

            TextField("you@example.com", text: $email)
                .padding()
                .background(Color.black.opacity(0.12))
                .foregroundColor(.white)
                .cornerRadius(12)

            Button {
                handleEmailSubmit()
            } label: {
                HStack {
                    if isLoading { ProgressView().scaleEffect(0.7) }
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(14)

            Button {
                showAlert(title: "Coming Soon", message: "Google login will be available soon!")
            } label: {
                HStack {
                    Image(systemName: "globe")
                    Text("Continue with Google")
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.black.opacity(0.14))
            .foregroundColor(.white)
            .cornerRadius(14)

            Button {
                step = .referrer
            } label: {
                Text("New to HOMEY? Create an account")
                    .font(.footnote)
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 6)
        }
    }

    var referrerStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("One Last Step")
                .font(.title2).bold()
                .foregroundColor(.white)
            Text("Please enter your agent's referrer code to continue.")
                .foregroundColor(.gray)

            TextField("e.g., NYC001", text: $referrerCode)
                .padding()
                .background(Color.black.opacity(0.12))
                .foregroundColor(.white)
                .cornerRadius(12)

            Button {
                handleReferrerSubmit()
            } label: {
                if isLoading { ProgressView().scaleEffect(0.7) }
                Text("Start Onboarding")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(14)
        }
    }

    private func handleEmailSubmit() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, email.contains("@"), email.contains(".") else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        isLoading = true
        Task {
            do {
                // TODO: Replace this stub with your backend validation
                let result = try await checkEmail(email: email)
                if result.exists, let userName = result.userName {
                    showAlert(title: "Welcome back, \(userName)!", message: "You've been logged in successfully.")
                    // TODO: Navigate to dashboard
                } else {
                    step = .referrer
                }
            } catch {
                showAlert(title: "An error occurred", message: "Could not verify your email. Please try again.")
            }
            isLoading = false
        }
    }

    private func handleReferrerSubmit() {
        guard !referrerCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Referrer code required", message: "Please enter your agent referrer code to continue.")
            return
        }
        isLoading = true
        Task {
            do {
                // TODO: Replace this stub with your backend validation
                let agentValid = try await getAgent(referrerCode: referrerCode)
                if agentValid {
                    // TODO: Save code and navigate to onboarding
                } else {
                    showAlert(title: "Invalid Referrer Code", message: "Please check the code and try again.")
                }
            } catch {
                showAlert(title: "Invalid Referrer Code", message: "Please check the code and try again.")
            }
            isLoading = false
        }
    }

    private func agentAccess() {
        // In iOS, a prompt can be done with .alert or a custom sheet
        // For now, show a placeholder alert
        showAlert(title: "Agent Access", message: "Agent access via code would go here.")
    }

    private func contactRyan(by type: String) {
        if type == "phone" {
#if os(iOS)
            if let url = URL(string: "tel:+13239199993") {
                UIApplication.shared.open(url)
            }
#endif
        } else {
            if let url = URL(string: "mailto:Kanfer.Ryan@gmail.com") {
#if os(iOS)
                UIApplication.shared.open(url)
#endif
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }

    // MARK: - Async Stubs for Backend
    private func checkEmail(email: String) async throws -> (exists: Bool, userName: String?) {
        try await Task.sleep(nanoseconds: 800_000_000) // simulate network delay
        if email.lowercased() == "kanfer.ryan@gmail.com" {
            return (true, "Ryan")
        }
        return (false, nil)
    }

    private func getAgent(referrerCode: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 800_000_000) // simulate network delay
        return referrerCode.uppercased() == "NYC001"
    }
}
