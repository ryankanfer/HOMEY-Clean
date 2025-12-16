import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

struct AccessCodeView: View {
    @EnvironmentObject private var session: AppSessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var accessCode: String = ""
    @State private var isValidating: Bool = false
    @State private var errorMessage: String?
    @State private var isCodeValid: Bool = false

    var onValidated: () -> Void

    var body: some View {
        ZStack {
            // Gradient background matching web app
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Header
                VStack(spacing: 8) {
                    Text("HOMEY")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .kerning(4)

                    Text("Early Access")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    Text("Enter your access code to continue")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 4)
                }

                // Access Code Input Card
                VStack(spacing: 24) {
                    // Input field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.4))

                            TextField("ACCESS CODE", text: $accessCode)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled(true)
                                .multilineTextAlignment(.leading)
                                .onChange(of: accessCode) { _, newValue in
                                    accessCode = newValue.uppercased()
                                    errorMessage = nil
                                }
                                .onSubmit {
                                    Task { await validateCode() }
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(16)

                        // Error message
                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            .padding(.horizontal, 4)
                        }
                    }

                    // Verify button
                    Button {
                        Task { await validateCode() }
                    } label: {
                        HStack(spacing: 10) {
                            if isValidating {
                                ProgressView()
                                    .tint(.black)
                            }
                            Text(isValidating ? "Validating..." : "Verify Access")
                                .font(.headline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .foregroundStyle(.black)
                        .cornerRadius(16)
                    }
                    .disabled(accessCode.isEmpty || isValidating)
                    .opacity(accessCode.isEmpty || isValidating ? 0.5 : 1.0)

                    // Back to login
                    Button {
                        dismiss()
                    } label: {
                        Text("Back to login")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(28)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(.white)
            }
        }
    }

    @MainActor
    private func validateCode() async {
        guard !accessCode.isEmpty else { return }

        isValidating = true
        errorMessage = nil

        defer { isValidating = false }

        #if canImport(Supabase)
        do {
            let client = session.supabaseClient

            // Call the RPC function to validate the code
            let response = try await client
                .rpc("validate_early_access_code", params: ["access_code": accessCode.trimmingCharacters(in: .whitespacesAndNewlines)])
                .execute()
                .value as? [String: Any]

            guard let result = response,
                  let isValid = result["valid"] as? Bool else {
                errorMessage = "Unable to validate code. Please try again."
                return
            }

            if isValid {
                // Code is valid, proceed to create account
                isCodeValid = true
                onValidated()
            } else {
                let message = result["message"] as? String ?? "Invalid access code"
                errorMessage = message
            }
        } catch {
            print("[AccessCodeView] Validation error: \(error)")
            errorMessage = "Unable to validate code. Please try again."
        }
        #else
        // Fallback for non-Supabase builds
        errorMessage = "Supabase not available"
        #endif
    }
}
