// SetPasswordView.swift
import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

struct SetPasswordView: View {
    @EnvironmentObject private var session: AppSessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var password: String = ""
    @State private var confirm: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color.black.opacity(0.85)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("Set your password")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.top, 12)

                    if let msg = errorMessage {
                        banner(text: msg, isError: true)
                    }
                    if let msg = successMessage {
                        banner(text: msg, isError: false)
                    }

                    VStack(spacing: 14) {
                        SecureField("New password", text: $password)
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                            .authFieldStyle()

                        SecureField("Confirm password", text: $confirm)
                            .textContentType(.newPassword)
                            .submitLabel(.go)
                            .onSubmit { Task { await submit() } }
                            .authFieldStyle()

                        if !password.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                validationRow(ok: password.count >= 6, text: "At least 6 characters")
                                validationRow(ok: containsUppercase(password), text: "At least one uppercase letter")
                                validationRow(ok: containsSpecial(password), text: "At least one special symbol")
                                if !confirm.isEmpty {
                                    validationRow(ok: password == confirm, text: "Passwords match")
                                }
                            }
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                        }

                        Button {
                            Task { await submit() }
                        } label: {
                            HStack(spacing: 8) {
                                if isSubmitting { ProgressView().tint(.white) }
                                Text(isSubmitting ? "Saving…" : "Save password")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!canSubmit || isSubmitting)
                        .padding(.top, 6)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 18, y: 10)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Set Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
        .interactiveDismissDisabled(isSubmitting)
    }

    private var canSubmit: Bool {
        !password.isEmpty &&
        !confirm.isEmpty &&
        password == confirm &&
        password.count >= 6 &&
        containsUppercase(password) &&
        containsSpecial(password)
    }

    @MainActor
    private func submit() async {
        guard canSubmit else {
            errorMessage = "Please meet all password requirements."
            return
        }
        errorMessage = nil
        successMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            #if canImport(Supabase)
            let client = session.supabaseClient
            try await client.auth.update(user: UserAttributes(password: password))
            #endif

            successMessage = "Password updated successfully."
            // Mark onboarding complete and close
            UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
            onComplete()
            dismiss()
        } catch {
            errorMessage = "Couldn’t update password. \(error.localizedDescription)"
        }
    }

    private func containsUppercase(_ s: String) -> Bool {
        s.rangeOfCharacter(from: .uppercaseLetters) != nil
    }

    private func containsSpecial(_ s: String) -> Bool {
        // Any non-alphanumeric character
        s.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil
    }

    @ViewBuilder
    private func banner(text: String, isError: Bool) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(isError ? .white : .black)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isError ? Color.red : Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    @ViewBuilder
    private func validationRow(ok: Bool, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(ok ? .green : .red)
            Text(text)
        }
    }
}
