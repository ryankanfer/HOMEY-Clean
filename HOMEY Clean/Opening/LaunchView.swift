import SwiftUI

public struct LaunchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showFirst = false
    @State private var showSecond = false
    @ObservedObject private var time = TimeOfDayService.shared
    @State private var taglineSecondVisible = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Neutral cinematic background (no clouds/sun)
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.10, blue: 0.12),
                    Color(red: 0.06, green: 0.06, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle aurora-style motion
            LaunchAuroraFlowView()
                .opacity(0.35)
                .blendMode(.screen)
                .ignoresSafeArea()
            
            // Occasional light rays sweep
            LaunchLightRaysView()
                .opacity(0.18)
                .blendMode(.screen)
                .ignoresSafeArea()
            
            // Soft vignette for readability
            LinearGradient(
                colors: [Color.black.opacity(0.25), .clear, Color.black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 16) {
                Spacer()
                
                // Single-line tagline with staged fade-ins
                HStack(spacing: 6) {
                    Text("in your pocket.")
                        .font(.custom("JosefinSans-Regular", size: 18))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("on your side.")
                        .font(.custom("JosefinSans-Regular", size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(taglineSecondVisible ? 1.0 : 0.0)
                        .animation(reduceMotion ? .none : .easeOut(duration: 0.6), value: taglineSecondVisible)
                }
                .opacity(showFirst ? 1.0 : 0.0)
                .offset(y: showFirst ? 0 : 10)
                .animation(reduceMotion ? .none : .easeOut(duration: 0.8), value: showFirst)
                
                Spacer()
            }
        }
        .onAppear {
            // First phrase fades in immediately
            withAnimation(reduceMotion ? .none : .easeOut(duration: 0.8)) {
                showFirst = true
            }
            
            // Second phrase fades in shortly after
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(reduceMotion ? .none : .easeOut(duration: 0.6)) {
                    showSecond = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                taglineSecondVisible = true
            }
        }
        .onChange(of: time.phase) { _, newPhase in
            if newPhase == .sunrise {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    taglineSecondVisible = true
                }
            } else if newPhase == .day {
                taglineSecondVisible = true
            } else if newPhase == .night {
                taglineSecondVisible = false
            }
        }
    }
    
    private struct GlassWordmark: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        let text: String
        var visible: Bool
        
        var body: some View {
            let mark = Text(text)
                .font(.playfairDisplayBold(56))
                .tracking(2)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            return ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(mark)
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.95),
                        Color.white.opacity(0.35)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                    .mask(mark)
                    .opacity(0.65)
            }
            .opacity(visible ? 1 : 0)
            .scaleEffect(visible ? 1.0 : 0.96)
            .blur(radius: visible || reduceMotion ? 0 : 1.5)
            .animation(reduceMotion ? .none : .easeOut(duration: 0.5).delay(0.1), value: visible)
        }
    }
}

private struct LaunchAuroraFlowView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ribbon(width: geo.size.width * 1.6, height: geo.size.height * 0.30, rotation: -16, y: geo.size.height * 0.22, speed: 26,
                       colors: [Color(red: 0.30, green: 0.70, blue: 1.0).opacity(0.7), Color(red: 0.25, green: 0.90, blue: 0.80).opacity(0.6), Color.white.opacity(0.2)])
                ribbon(width: geo.size.width * 1.8, height: geo.size.height * 0.34, rotation: 10, y: geo.size.height * 0.48, speed: 30,
                       colors: [Color(red: 1.0, green: 0.60, blue: 0.35).opacity(0.6), Color(red: 0.85, green: 0.40, blue: 0.85).opacity(0.5), Color(red: 0.45, green: 0.35, blue: 0.85).opacity(0.5)])
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 28).repeatForever(autoreverses: true)) {
                    phase = 1
                }
            }
        }
    }
    private func ribbon(width: CGFloat, height: CGFloat, rotation: Double, y: CGFloat, speed: Double, colors: [Color]) -> some View {
        let grad = LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
        return RoundedRectangle(cornerRadius: height / 2)
            .fill(grad)
            .frame(width: width, height: height)
            .blur(radius: 24)
            .rotationEffect(.degrees(rotation))
            .offset(x: (phase > 0 ? -width * 0.12 : width * 0.12), y: y)
            .animation(reduceMotion ? nil : .easeInOut(duration: speed).repeatForever(autoreverses: true), value: phase)
    }
}

private struct LaunchLightRaysView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sweep: CGFloat = -1.1
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                beam(width: w * 0.9, height: h * 0.16, angle: 20)
                    .offset(x: sweep * (w + 300), y: -h * 0.12)
                beam(width: w * 1.05, height: h * 0.20, angle: -16)
                    .offset(x: -sweep * (w + 300), y: h * 0.18)
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                    sweep = 1.1
                }
            }
        }
    }
    private func beam(width: CGFloat, height: CGFloat, angle: Double) -> some View {
        LinearGradient(
            colors: [Color.white.opacity(0.18), Color.white.opacity(0.06), .clear],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: width, height: height)
        .blur(radius: 22)
        .rotationEffect(.degrees(angle))
    }
}
