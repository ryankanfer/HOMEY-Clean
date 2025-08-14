import SwiftUI

// MARK: - Create Account Screen (Liquid Glass)

struct CreateAccountView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var referral = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, referral }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 22) {
                HStack {
                    Button("Cancel") { /* wire up later */ }
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.tint)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Create Account")
                        .font(.system(size: 36, weight: .heavy, design: .serif))
                        .kerning(-0.5)
                        .foregroundStyle(.primary)

                    Text("Welcome to HOMEY — concierge-in-your-pocket. Two minutes and a good password.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                GlassGroupBox {
                    GlassField(icon: "person.fill",
                               placeholder: "Full Name",
                               text: $fullName)
                        .textContentType(.name)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .name)
                        .onSubmit { focusedField = .email }

                    GlassField(icon: "envelope.fill",
                               placeholder: "Email",
                               text: $email,
                               keyboard: .emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                        .onSubmit { focusedField = .password }

                    GlassSecureField(icon: "lock.fill",
                                     placeholder: "Password",
                                     text: $password,
                                     showPassword: $showPassword)
                        .textContentType(.newPassword)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .password)
                        .onSubmit { focusedField = .referral }

                    GlassField(icon: "tag.fill",
                               placeholder: "Referral Code (optional)",
                               text: $referral)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .referral)
                }
                .padding(.horizontal, 20)

                Button(action: signUp) {
                    HStack(spacing: 10) {
                        if isLoading { ProgressView().tint(.white) }
                        Text(isLoading ? "Signing Up…" : "Sign Up")
                            .font(.headline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(GlossyGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white.opacity(0.35), lineWidth: 0.8)
                            .blendMode(.overlay)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 18, y: 8)
                }
                .padding(.horizontal, 20)
                .disabled(!formIsValid || isLoading)
                .opacity(formIsValid ? 1 : 0.6)
                .padding(.top, 6)

                Spacer(minLength: 12)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { focusedField = .name }
    }

    private var formIsValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 8 && !fullName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func signUp() {
        guard formIsValid else { return }
        isLoading = true
        // Simulate a network call; replace with your real auth later.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            // handle success
        }
    }
}

// MARK: - Components

/// Frosted container with subtle inner/outer strokes
struct GlassGroupBox<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 14) {
            content
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AngularGradient(colors: [
                    .white.opacity(0.65),
                    .white.opacity(0.15),
                    .white.opacity(0.65)
                ], center: .center), lineWidth: 1)
                .blendMode(.overlay)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.06))
                .blur(radius: 10)
                .offset(y: 8)
                .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .shadow(color: .black.opacity(0.12), radius: 22, y: 12)
    }
}

/// TextField with icon and glass capsule
struct GlassField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .font(.body)
                .padding(.vertical, 12)
                .textInputAutocapitalization(.words)
        }
        .padding(.horizontal, 14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.30), lineWidth: 0.8)
                .blendMode(.overlay)
        )
    }
}

/// Secure field with eye toggle, glass capsule
struct GlassSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)

            Group {
                if showPassword {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.body)
            .padding(.vertical, 12)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                withAnimation(.snappy) { showPassword.toggle() }
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(6)
            }
            .accessibilityLabel(showPassword ? "Hide password" : "Show password")
        }
        .padding(.horizontal, 14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.30), lineWidth: 0.8)
                .blendMode(.overlay)
        )
    }
}

/// Button background with glossy top highlight
struct GlossyGradient: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color.blue.opacity(0.95),
                Color.indigo.opacity(0.95)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)

            // Subtle gloss
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.22))
                .frame(height: 24)
                .blur(radius: 18)
                .offset(y: -18)
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Animated Liquid Glass Background

struct LiquidGlassBackground: View {
    @State private var t: CGFloat = 0

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(white: 0.08),
                    Color(white: 0.12)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Moving “blobs” rendered to a canvas with blur & blend
            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    let blobs = blobs(at: now, in: size)

                    for blob in blobs {
                        var resolve = context.resolve(Text(""))
                        resolve.shading = .color(blob.color)
                        let circle = Path(ellipseIn: blob.frame)
                        context.fill(circle, with: .linearGradient(
                            Gradient(colors: [blob.color.opacity(0.9), blob.color.opacity(0.5)]),
                            startPoint: blob.frame.origin,
                            endPoint: CGPoint(x: blob.frame.maxX, y: blob.frame.maxY)
                        ))
                    }
                }
                .blur(radius: 48)
                .blendMode(.plusLighter)
                .opacity(0.85)
                .ignoresSafeArea()
            }

            // Very subtle noise for texture
            Rectangle()
                .fill(.black.opacity(0.1))
                .blendMode(.overlay)
                .allowsHitTesting(false)
        }
    }

    private func blobs(at time: TimeInterval, in size: CGSize) -> [Blob] {
        func pos(_ seed: Double, _ ampX: CGFloat, _ ampY: CGFloat) -> CGPoint {
            let x = size.width  * 0.5 + sin(time * 0.5 + seed) * ampX
            let y = size.height * 0.5 + cos(time * 0.7 + seed) * ampY
            return CGPoint(x: x, y: y)
        }

        let b1 = Blob(center: pos(0.0, size.width * 0.32, size.height * 0.28),
                      radius: max(size.width, size.height) * 0.36,
                      color: Color(hex: 0x6FB7C5)) // Pool Tile Blue
        let b2 = Blob(center: pos(2.4, size.width * 0.28, size.height * 0.22),
                      radius: max(size.width, size.height) * 0.30,
                      color: Color(hex: 0xE6A0A2)) // Sunburnt Blush
        let b3 = Blob(center: pos(5.1, size.width * 0.26, size.height * 0.30),
                      radius: max(size.width, size.height) * 0.26,
                      color: Color(hex: 0xD4AF37)) // Martini Gold

        return [b1, b2, b3]
    }

    struct Blob {
        var center: CGPoint
        var radius: CGFloat
        var color: Color

        var frame: CGRect {
            CGRect(x: center.x - radius/2, y: center.y - radius/2, width: radius, height: radius)
        }
    }
}

// MARK: - Helpers

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

// MARK: - Preview

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
            .preferredColorScheme(.dark)
    }
}

import PlaygroundSupport

PlaygroundPage.current.setLiveView(
    CreateAccountView()
        .preferredColorScheme(.dark)
)
