import SwiftUI

struct CreateAccountView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var referral = ""
    @State private var isLoading = false
    @FocusState private var focusField: Field?

    enum Field { case name, email, password, referral }

    private var isValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            email.contains("@") && email.contains(".") &&
            password.count >= 8
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            ScrollView {
                VStack(spacing: 18) {
                    Text("Create your account")
                        .font(.largeTitle.weight(.bold))
                        .padding(.top, 24)

                    GlassGroupBox("Details") {
                        GlassField(title: "Full name", text: $fullName, placeholder: "First Last")
                            .focused($focusField, equals: .name)
                        GlassField(
                            title: "Email",
                            text: $email,
                            placeholder: "you@example.com",
                            keyboard: .emailAddress
                        )
                        .focused($focusField, equals: .email)
                        GlassSecureField(title: "Password", text: $password, placeholder: "Minimum 8 characters")
                            .focused($focusField, equals: .password)
                        GlassField(title: "Referral code (optional)", text: $referral, placeholder: "CODE123")
                            .focused($focusField, equals: .referral)
                    }

                    Button {
                        guard !isLoading, isValid else { return }
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isLoading = false
                        }
                    } label: {
                        HStack {
                            if isLoading { ProgressView().controlSize(.small) }
                            Text(isLoading ? "Creating..." : "Create account")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isValid ? Color.accentColor : Color.gray.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(!isValid || isLoading)

                    Spacer(minLength: 24)
                }
                .padding(20)
            }
            GlossyGradient()
        }
    }
}
