import SwiftUI

// MARK: - 3D Journey Onboarding (Lightweight placeholder)
// This view is intentionally self-contained so we can swap it in quickly.
// You can flesh this out with your full 3D implementation later.
public struct SwiftJourney3DOnboardingView: View {
    public let onComplete: () -> Void

    @State private var step: Int = 0
    @State private var rotation: Double = 0
    @State private var tilt: CGSize = .zero

    private struct Step: Identifiable { let id = UUID(); let title: String; let subtitle: String; let icon: String; let color: Color }
    private let steps: [Step] = [
        .init(title: "Welcome to HOMEY", subtitle: "Your journey, visualized in 3D", icon: "sparkles", color: .cyan),
        .init(title: "Express Setup", subtitle: "Answer a few quick questions", icon: "bolt.fill", color: .orange),
        .init(title: "Smart Matching", subtitle: "We’ll recommend what fits your vibe", icon: "brain.head.profile", color: .mint),
        .init(title: "Ready to Roll", subtitle: "Let’s get you on the fast track", icon: "train.side.front.car", color: .purple)
    ]

    public init(onComplete: @escaping () -> Void) { self.onComplete = onComplete }

    public var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [.black, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            RadialGradient(colors: [.white.opacity(0.08), .clear], center: .center, startRadius: 20, endRadius: 400)
                .blendMode(.plusLighter)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer(minLength: 12)
                TabView(selection: $step) {
                    ForEach(steps.indices, id: \.self) { idx in
                        stepCard(steps[idx])
                            .padding(.horizontal, 24)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .frame(maxHeight: 520)
                Spacer(minLength: 12)
                controls
            }
            .padding(.bottom, 34)
        }
        .onAppear { startSpin() }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Label("HOMEY", systemImage: "cube.transparent")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .symbolRenderingMode(.hierarchical)
            Spacer()
            Text("Step \(step + 1)/\(steps.count)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    // MARK: - Step Card
    @ViewBuilder
    private func stepCard(_ step: Step) -> some View {
        VStack(spacing: 22) {
            // 3D hero
            ZStack {
                // Floating rings
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(step.color.opacity(0.25 - Double(ring) * 0.06), lineWidth: 2)
                        .frame(width: 160 + CGFloat(ring * 30), height: 160 + CGFloat(ring * 30))
                        .rotation3DEffect(.degrees(rotation * (Double(ring) * 0.4 + 0.6)), axis: (x: 0.0, y: 1.0, z: 0.0))
                        .offset(x: tilt.width * CGFloat(ring) * 0.12, y: tilt.height * CGFloat(ring) * 0.12)
                        .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: rotation)
                }
                // Core cube symbol
                Image(systemName: step.icon)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(step.color)
                    .rotation3DEffect(.degrees(rotation), axis: (x: 10/180, y: 1, z: 0))
                    .shadow(color: step.color.opacity(0.6), radius: 12, y: 6)
            }
            .frame(height: 220)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            tilt = CGSize(width: value.translation.width / 6, height: value.translation.height / 6)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { tilt = .zero }
                    }
            )

            VStack(spacing: 8) {
                Text(step.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(step.subtitle)
                    .font(.callout)
                    .foregroundStyle(step.color)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)

            // Placeholder copy
            Text("This is a lightweight 3D-styled onboarding placeholder. Replace this with your full SceneKit/RealityKit content when ready.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(step.color.opacity(0.35), lineWidth: 1)
                )
        )
        .rotation3DEffect(.degrees(tilt.width * 0.08), axis: (x: 0, y: 1, z: 0))
        .shadow(color: .black.opacity(0.6), radius: 16, y: 10)
        .padding(.vertical, 8)
    }

    // MARK: - Controls
    private var controls: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { step = max(0, step - 1) }
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.2))
            .disabled(step == 0)

            Spacer()

            Button {
                if step < steps.count - 1 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { step += 1 }
                } else {
                    onComplete()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(step == steps.count - 1 ? "Get Started" : "Continue")
                    Image(systemName: step == steps.count - 1 ? "arrow.up.right.circle.fill" : "chevron.right")
                }
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Animations
    private func startSpin() {
        withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

// MARK: - Factory function the caller requested
public func swiftJourney3DOnboardingView(onComplete: @escaping () -> Void) -> some View {
    SwiftJourney3DOnboardingView(onComplete: onComplete)
}

// MARK: - Preview
#Preview {
    SwiftJourney3DOnboardingView(onComplete: {})
        .preferredColorScheme(.dark)
}
