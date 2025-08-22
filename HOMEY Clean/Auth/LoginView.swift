import SwiftUI

private struct ProfileRole: Decodable { let role: String }

struct LoginView: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground(theme: heroTheme(for: .drew))
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome back")
                                .font(.largeTitle.bold())
                            Text("Sign in to continue")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)

                        // Fields card
                        VStack(spacing: 14) {
                            HStack {
                                Image(systemName: "envelope.fill").foregroundStyle(.secondary)
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .email)
                                    .onSubmit { focusedField = .password }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                            HStack {
                                Image(systemName: "lock.fill").foregroundStyle(.secondary)
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .submitLabel(.go)
                                    .focused($focusedField, equals: .password)
                                    .onSubmit { trySignIn() }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }

                        if let msg = errorMessage, !msg.isEmpty {
                            Text(msg)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .padding(.top, -8)
                        }

                        // Primary action
                        Button(action: trySignIn) {
                            HStack {
                                if isLoading { ProgressView() }
                                Text(isLoading ? "Signing in…" : "Sign In")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading || email.isEmpty || password.isEmpty)

                        // Secondary actions
                        HStack {
                            Spacer()
                            NavigationLink("Create account") { SignupView() }
                        }
                        .font(.callout)
                        .padding(.top, -4)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .padScreen()
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
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
                errorMessage = (error as NSError).localizedDescription
            }
            isLoading = false
        }
    }
}
