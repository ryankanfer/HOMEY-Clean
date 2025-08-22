import SwiftUI

struct ProgressionEventView: View {
    let event: ProgressionEvent
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissEvent()
                }

            // Event card
            VStack(spacing: 20) {
                // Icon
                Image(systemName: event.icon)
                    .font(.system(size: 60))
                    .foregroundColor(event.color)
                    .scaleEffect(isVisible ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)

                // Title and message
                VStack(spacing: 8) {
                    Text(event.title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(event.message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5).delay(0.2), value: isVisible)

                // Dismiss button
                Button("Continue") {
                    dismissEvent()
                }
                .buttonStyle(.borderedProminent)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5).delay(0.4), value: isVisible)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 40)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)

            // Confetti overlay
            if showConfetti {
                ProgressionConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }

            // Show confetti for special events
            if event.hasConfetti {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showConfetti = true
                }
            }

            // Play sound effect
            if let soundEffect = event.soundEffect {
                playSound(soundEffect)
            }
        }
    }

    private func dismissEvent() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    private func playSound(_ soundName: String) {
        // TODO: Implement sound playback
        // AudioServicesPlaySystemSound(SystemSoundID(soundName))
        print("Playing sound: \(soundName)")
    }
}

// MARK: - Confetti View

struct ProgressionConfettiView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0 ..< 50, id: \.self) { _ in
                ConfettiPiece()
                    .offset(
                        x: animate ? CGFloat.random(in: -200 ... 200) : 0,
                        y: animate ? CGFloat.random(in: -300 ... 300) : -100
                    )
                    .rotationEffect(.degrees(animate ? Double.random(in: 0 ... 360) : 0))
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: Double.random(in: 1.0 ... 2.0))
                            .delay(Double.random(in: 0 ... 0.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    let color = Color.random

    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: 8, height: 8)
            .cornerRadius(2)
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1)
        )
    }
}
