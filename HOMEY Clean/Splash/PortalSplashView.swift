import SwiftUI

struct PortalSplashView: View {
    var onUnlock: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Interaction
    @State private var unlockProgress: CGFloat = 0
    @State private var hasUnlocked: Bool = false

    // Visual state
    @State private var portalPulse: CGFloat = 0
    @State private var portalOpen: Bool = false
    @State private var lightFlash: Bool = false

    // Haptics
    private let successHaptic = UINotificationFeedbackGenerator()

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Background subtle vignette
                Circle()
                    .fill(.black.opacity(0.15))
                    .frame(width: 260, height: 260)
                    .blur(radius: 30)
                    .opacity(0.7)

                // Concentric rings (calm “signal” animation)
                if !reduceMotion {
                    PulsingRings(progress: unlockProgress)
                        .frame(width: 320, height: 320)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                // Portal core
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(portalFillOpacity),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(portalStrokeGradient, lineWidth: 2)
                                .blur(radius: 0.2)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 10)
                                .blendMode(.overlay)
                        )
                        .shadow(color: Color.cyan.opacity(0.28 + 0.22 * unlockProgress), radius: 24 + 18 * unlockProgress, x: 0, y: 18)

                    // Portal highlight that grows with progress
                    Circle()
                        .stroke(Color.white.opacity(0.35 + 0.25 * unlockProgress), lineWidth: 6)
                        .frame(width: 180 + 30 * unlockProgress, height: 180 + 30 * unlockProgress)
                        .blur(radius: 10)
                        .opacity(reduceMotion ? 0.2 : 1)
                        .blendMode(.screen)

                    // Brand title
                    Text("HOMEY")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .kerning(2)
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 6)
                        .opacity(portalOpen ? 0.0 : 1.0)
                }
                .frame(width: portalSize, height: portalSize)
                .scaleEffect(portalOpen ? 1.15 : 1.0)
                .blur(radius: portalOpen ? 1.0 : 0)

                // Light burst on unlock
                if lightFlash {
                    RadialGradient(colors: [Color.white.opacity(0.9), .clear], center: .center, startRadius: 0, endRadius: 160)
                        .frame(width: 260, height: 260)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 300)
            .padding(.top, 8)
            .accessibilityHidden(true)

            if reduceMotion {
                // Accessible fallback
                Button(action: triggerUnlock) {
                    Label("Continue", systemImage: "key.fill")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.white.opacity(0.15)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Unlock HOMEY")
            } else {
                swipeKeyControl
            }

            // Small subtitle
            Text("One place to bring your search together.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                portalPulse = 1
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HOMEY splash. Swipe key to unlock.")
    }

    // MARK: - Portal visuals

    private var portalSize: CGFloat {
        220 + (reduceMotion ? 0 : 6 * portalPulse) + 10 * unlockProgress
    }

    private var portalFillOpacity: CGFloat {
        0.18 + (reduceMotion ? 0 : 0.07 * portalPulse) + 0.15 * unlockProgress
    }

    private var portalStrokeGradient: AngularGradient {
        AngularGradient(colors: [Color.cyan, Color.blue, Color.purple, Color.cyan], center: .center)
    }

    // MARK: - Swipe control

    private var swipeKeyControl: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let knobWidth: CGFloat = 56
            let trackTravel = max(1, width - knobWidth) // avoid div-by-zero

            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .frame(height: 48)
                    .overlay(
                        // Prompt text fades as you drag
                        Text("Slide to unlock")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85 - 0.75 * unlockProgress))
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                    )

                // Progress fill
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Color.white.opacity(0.16), Color.white.opacity(0.08)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(knobWidth, knobWidth + unlockProgress * trackTravel), height: 48)
                    .opacity(0.35)
                    .allowsHitTesting(false)

                // Draggable key
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "key.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black.opacity(0.85))
                    )
                    .frame(width: knobWidth, height: 40)
                    .offset(x: unlockProgress * trackTravel)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 5)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard !hasUnlocked else { return }
                                // Use predictedEndLocation for a forgiving feel
                                let x = max(0, min(value.location.x - knobWidth/2, trackTravel))
                                let progress = x / trackTravel
                                withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.92)) {
                                    unlockProgress = progress
                                }
                            }
                            .onEnded { value in
                                guard !hasUnlocked else { return }
                                // Consider where the drag was heading, not just where it ended
                                let predictedX = max(0, min(value.predictedEndLocation.x - knobWidth/2, trackTravel))
                                let predictedProgress = predictedX / trackTravel
                                let finalProgress = max(unlockProgress, predictedProgress)

                                if finalProgress >= 0.9 {
                                    // Success: call directly
                                    successHaptic.notificationOccurred(.success)
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                        unlockProgress = 1
                                        portalOpen = true
                                    }
                                    withAnimation(.easeOut(duration: 0.18)) { lightFlash = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                        withAnimation(.easeOut(duration: 0.25)) { lightFlash = false }
                                    }
                                    triggerUnlock()
                                } else {
                                    // Revert
                                    withAnimation(.easeOut(duration: 0.35)) {
                                        unlockProgress = 0
                                        portalOpen = false
                                    }
                                }
                            }
                    )
                    .accessibilityLabel("Swipe key to unlock")
            }
        }
        .frame(height: 48)
        .accessibilityAddTraits(.isButton)
    }

    private func triggerUnlock() {
        guard !hasUnlocked else { return }
        hasUnlocked = true
        // Small final open animation then callback
        withAnimation(.easeIn(duration: 0.2)) {
            portalOpen = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onUnlock?()
        }
    }
}

// MARK: - Concentric pulsing rings

private struct PulsingRings: View {
    var progress: CGFloat // tie subtle intensity to swipe progress
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            ring(radius: 150, baseOpacity: 0.25, speed: 1.8)
            ring(radius: 190, baseOpacity: 0.18, speed: 2.4)
            ring(radius: 230, baseOpacity: 0.12, speed: 3.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }

    private func ring(radius: CGFloat, baseOpacity: CGFloat, speed: Double) -> some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.35 + 0.35 * progress),
                        Color.blue.opacity(0.25 + 0.25 * progress),
                        Color.purple.opacity(0.20 + 0.20 * progress)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
            .frame(width: radius * (0.96 + 0.06 * phase), height: radius * (0.96 + 0.06 * phase))
            .blur(radius: 0.6)
            .opacity(baseOpacity + 0.12 * phase + 0.15 * progress)
            .animation(.easeInOut(duration: speed).repeatForever(autoreverses: true), value: phase)
            .accessibilityHidden(true)
    }
}

struct PortalSplashView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            PortalSplashView(onUnlock: {})
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}