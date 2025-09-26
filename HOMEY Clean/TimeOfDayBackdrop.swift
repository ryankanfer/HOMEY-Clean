import SwiftUI

public struct TimeOfDayBackdrop: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var time = TimeOfDayService.shared

    public init() {}

    public var body: some View {
        ZStack {
            Group {
                switch time.phase {
                case .sunrise:
                    SunriseLayer(reduceMotion: reduceMotion)
                        .transition(.opacity)
                case .day:
                    DayLayer(reduceMotion: reduceMotion)
                        .transition(.opacity)
                case .sunset:
                    SunsetLayer(reduceMotion: reduceMotion)
                        .transition(.opacity)
                case .night:
                    NightLayer(reduceMotion: reduceMotion)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.8), value: time.phase)

            // Subtle atmospheric noise / grain for depth (iOS 26 feel)
            NoiseOverlay()
                .opacity(0.06)
                .blendMode(.softLight)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Sunrise
private struct SunriseLayer: View {
    let reduceMotion: Bool
    @State private var animateSheen = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.55),
                    Color.pink.opacity(0.45),
                    Color.cyan.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 24)

            LinearGradient(
                colors: [Color.white.opacity(0.10), .clear, Color.white.opacity(0.08)],
                startPoint: animateSheen ? .topLeading : .bottomTrailing,
                endPoint: animateSheen ? .bottomTrailing : .topLeading
            )
            .animation(reduceMotion ? nil : .linear(duration: 22).repeatForever(autoreverses: true), value: animateSheen)
            .onAppear { animateSheen = true }
            .blur(radius: 44)
            .opacity(0.85)

            TODSunView()
                .frame(width: 120, height: 120)
                .offset(x: -20, y: 160)
                .opacity(0.9)

            VStack(spacing: 0) {
                TODCloudRow(yOffset: -10, speed: 56, scale: 1.0, opacity: 0.20, reverse: false, reduceMotion: reduceMotion)
                TODCloudRow(yOffset: 70, speed: 66, scale: 1.1, opacity: 0.18, reverse: true, reduceMotion: reduceMotion)
            }
        }
    }
}

// MARK: - Day
private struct DayLayer: View {
    let reduceMotion: Bool
    @State private var animateSheen = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.75),
                    Color.cyan.opacity(0.55),
                    Color.white.opacity(0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 24)

            LinearGradient(
                colors: [Color.white.opacity(0.10), .clear, Color.white.opacity(0.08)],
                startPoint: animateSheen ? .topLeading : .bottomTrailing,
                endPoint: animateSheen ? .bottomTrailing : .topLeading
            )
            .animation(reduceMotion ? nil : .linear(duration: 20).repeatForever(autoreverses: true), value: animateSheen)
            .onAppear { animateSheen = true }
            .blur(radius: 40)

            TODSunView()
                .frame(width: 140, height: 140)
                .offset(x: 120, y: -220)
                .opacity(0.9)

            VStack(spacing: 0) {
                TODCloudRow(yOffset: -140, speed: 36, scale: 1.0, opacity: 0.30, reverse: false, reduceMotion: reduceMotion)
                TODCloudRow(yOffset: -40, speed: 48, scale: 1.1, opacity: 0.25, reverse: true, reduceMotion: reduceMotion)
                TODCloudRow(yOffset: 60, speed: 60, scale: 0.95, opacity: 0.20, reverse: false, reduceMotion: reduceMotion)
            }
        }
    }
}

// MARK: - Sunset
private struct SunsetLayer: View {
    let reduceMotion: Bool
    @State private var animateSheen = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.55),
                    Color.pink.opacity(0.45),
                    Color.purple.opacity(0.40)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 24)

            LinearGradient(
                colors: [Color.white.opacity(0.10), .clear, Color.white.opacity(0.08)],
                startPoint: animateSheen ? .topLeading : .bottomTrailing,
                endPoint: animateSheen ? .bottomTrailing : .topLeading
            )
            .animation(reduceMotion ? nil : .linear(duration: 24).repeatForever(autoreverses: true), value: animateSheen)
            .onAppear { animateSheen = true }
            .blur(radius: 46)
            .opacity(0.8)

            TODSunView()
                .frame(width: 120, height: 120)
                .offset(x: 40, y: 180)
                .opacity(0.85)

            VStack(spacing: 0) {
                TODCloudRow(yOffset: -20, speed: 52, scale: 1.0, opacity: 0.22, reverse: false, reduceMotion: reduceMotion)
                TODCloudRow(yOffset: 80, speed: 64, scale: 1.15, opacity: 0.18, reverse: true, reduceMotion: reduceMotion)
            }
        }
    }
}

// MARK: - Night
private struct NightLayer: View {
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.65),
                    Color.blue.opacity(0.45),
                    Color.black.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 16)

            TODStarsLayer(count: 80, twinkle: !reduceMotion)
                .opacity(0.9)

            TODMoonView()
                .frame(width: 90, height: 90)
                .offset(x: -120, y: -200)
                .opacity(0.95)
        }
    }
}

// MARK: - Building Blocks
private struct TODSunView: View {
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [Color.yellow.opacity(0.7), Color.orange.opacity(0.3), .clear],
                                   center: .center, startRadius: 0, endRadius: 120)
                )
                .scaleEffect(pulse ? 1.06 : 0.98)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulse)
            Circle()
                .fill(Color.yellow.opacity(0.95))
        }
        .onAppear { pulse = true }
    }
}

private struct TODMoonView: View {
    @State private var glow = false
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [Color.white.opacity(0.65), Color.white.opacity(0.15), .clear],
                                   center: .center, startRadius: 0, endRadius: 100)
                )
                .blur(radius: glow ? 9 : 5)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glow)
            Circle()
                .fill(Color.white.opacity(0.95))
            Circle()
                .fill(Color.black.opacity(0.85))
                .offset(x: 12)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        .onAppear { glow = true }
    }
}

private struct TODCloudRow: View {
    let yOffset: CGFloat
    let speed: Double
    let scale: CGFloat
    let opacity: Double
    let reverse: Bool
    let reduceMotion: Bool
    @State private var x: CGFloat = -600

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            HStack(spacing: 80) {
                TODCloudView().frame(width: 180, height: 70)
                TODCloudView().frame(width: 140, height: 56)
                TODCloudView().frame(width: 200, height: 80)
                TODCloudView().frame(width: 120, height: 48)
            }
            .opacity(opacity)
            .scaleEffect(scale, anchor: .center)
            .offset(x: x, y: yOffset)
            .onAppear {
                guard !reduceMotion else { return }
                x = reverse ? (width + 220) : (-width - 220)
                withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                    x = reverse ? (-width - 220) : (width + 220)
                }
            }
        }
    }
}

private struct TODCloudView: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.75)).frame(width: 68, height: 54).offset(x: -30, y: -6)
            Circle().fill(Color.white.opacity(0.75)).frame(width: 84, height: 64).offset(x: 0, y: -10)
            Circle().fill(Color.white.opacity(0.75)).frame(width: 64, height: 50).offset(x: 34, y: -4)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.75))
                .frame(width: 160, height: 40)
                .offset(y: 8)
        }
        .blur(radius: 0.6)
    }
}

private struct TODStarsLayer: View {
    let count: Int
    let twinkle: Bool
    @State private var phase = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let px = pseudoRandom(i, seed: 73) * w
                    let py = pseudoRandom(i, seed: 19) * (h * 0.7)
                    let size = 1.0 + pseudoRandom(i, seed: 101) * 2.0
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: size, height: size)
                        .position(x: px, y: py)
                        .opacity(twinkle ? (0.5 + 0.5 * sin((Double(i) * 0.7) + (phase ? 0 : .pi))) : 0.9)
                }
            }
            .onAppear {
                guard twinkle else { return }
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: true)) {
                    phase.toggle()
                }
            }
        }
    }

    private func pseudoRandom(_ i: Int, seed: Int) -> CGFloat {
        let v = abs(sin(Double(i * seed)) * 10_000).truncatingRemainder(dividingBy: 1)
        return CGFloat(v)
    }
}

private struct NoiseOverlay: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        TimelineView(.animation) { _ in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.clear,
                            Color.white.opacity(0.10),
                            Color.clear
                        ],
                        startPoint: UnitPoint(x: 0.2 + 0.6 * sin(phase), y: 0.1),
                        endPoint: UnitPoint(x: 0.8 + 0.4 * cos(phase), y: 0.9)
                    )
                )
                .blur(radius: 24)
                .onAppear {
                    withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                }
        }
    }
}
