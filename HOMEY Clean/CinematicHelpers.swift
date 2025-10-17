//
//  SunPeekingView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 10/14/25.
//

import SwiftUI
import Combine

// MARK: - Configuration

struct CinematicConfig: Equatable {
    var vignetteIntensity: Double = 0.28
    var grainOpacity: Double = 0.06
    var sunScale: CGFloat = 1.0
    var sunDriftRadius: CGFloat = 18
    var sunFlareOpacity: Double = 0.35
    var particlesEnabled: Bool = true
    var particleCount: Int = 36
    var particleSpeed: CGFloat = 0.35
    var particleMaxSize: CGFloat = 7.0
    var particleOpacity: ClosedRange<Double> = 0.12...0.28
    var parallaxAmount: CGFloat = 10
    var colorScheme: [Color] = [
        Color(red: 0.53, green: 0.81, blue: 0.92),
        Color(red: 0.25, green: 0.65, blue: 0.96),
        Color(red: 0.12, green: 0.47, blue: 0.71)
    ]
    
    static let subtle = CinematicConfig(
        vignetteIntensity: 0.22,
        grainOpacity: 0.04,
        sunScale: 0.9,
        sunDriftRadius: 12,
        sunFlareOpacity: 0.25,
        particleCount: 24,
        particleSpeed: 0.25,
        particleMaxSize: 6.0,
        parallaxAmount: 6
    )
    
    static let cinematic = CinematicConfig()
    static let bold = CinematicConfig(
        vignetteIntensity: 0.36,
        grainOpacity: 0.08,
        sunScale: 1.15,
        sunDriftRadius: 26,
        sunFlareOpacity: 0.45,
        particleCount: 48,
        particleSpeed: 0.45,
        particleMaxSize: 9.0,
        parallaxAmount: 14
    )
}

// MARK: - Sun Peeking View
/// A subtle animated sun/light source with soft drift and lens flare
struct SunPeekingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var config: CinematicConfig = .cinematic
    
    @State private var phase: Double = 0
    @State private var driftAngle: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            let baseSize: CGFloat = min(geo.size.width, geo.size.height)
            let sunSize: CGFloat = baseSize * 0.65 * config.sunScale
            
            ZStack {
                // Lens flare halos
                Group {
                    Circle()
                        .fill(
                            RadialGradient(colors: [
                                Color.white.opacity(0.18 * config.sunFlareOpacity),
                                Color.yellow.opacity(0.12 * config.sunFlareOpacity),
                                .clear
                            ], center: .center, startRadius: 0, endRadius: sunSize * 0.9)
                        )
                        .blur(radius: 18)
                        .opacity(0.9)
                    
                    Circle()
                        .fill(
                            RadialGradient(colors: [
                                .white.opacity(0.08 * config.sunFlareOpacity),
                                .yellow.opacity(0.06 * config.sunFlareOpacity),
                                .clear
                            ], center: .center, startRadius: 0, endRadius: sunSize * 1.4)
                        )
                        .blur(radius: 32)
                        .opacity(0.8)
                }
                
                // Core glow
                Circle()
                    .fill(
                        RadialGradient(colors: [
                            Color.white.opacity(0.55),
                            Color.yellow.opacity(0.35),
                            Color.orange.opacity(0.18),
                            .clear
                        ], center: .center, startRadius: 0, endRadius: sunSize * 0.65)
                    )
                    .blur(radius: 22)
                    .opacity(0.9)
                
                // Bright inner core
                Circle()
                    .fill(
                        RadialGradient(colors: [
                            .white.opacity(0.9),
                            .yellow.opacity(0.4),
                            .clear
                        ], center: .center, startRadius: 0, endRadius: sunSize * 0.25)
                    )
                    .blur(radius: 14)
                    .opacity(0.95)
            }
            .frame(width: sunSize, height: sunSize)
            .offset(sunOffset(in: geo.size))
            .compositingGroup()
            .allowsHitTesting(false)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true)) {
                        phase = 1
                    }
                    withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                        driftAngle = 2 * .pi
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func sunOffset(in size: CGSize) -> CGSize {
        // Base top-right position
        let base = CGSize(width: size.width * 0.32, height: -size.height * 0.28)
        guard phase > 0 else { return base }
        // Gentle circular drift
        let r = config.sunDriftRadius
        let dx = cos(driftAngle) * r
        let dy = sin(driftAngle) * r * 0.6
        return CGSize(width: base.width + dx, height: base.height + dy)
    }
}

// MARK: - Vignette Overlay
/// Adaptive vignette that scales with screen and respects intensity
struct VignetteOverlay: View {
    var intensity: Double = 0.28
    
    var body: some View {
        GeometryReader { geo in
            let end = max(geo.size.width, geo.size.height) * 0.9
            RadialGradient(
                colors: [
                    .clear,
                    Color.black.opacity(intensity)
                ],
                center: .center,
                startRadius: end * 0.28,
                endRadius: end
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Grain Overlay
/// Subtle film grain with reduced-motion fallback and overlay blending
struct GrainOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var opacity: Double = 0.06
    @State private var jitter: CGFloat = 0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    ImagePaint(
                        image: Image(systemName: "circle.grid.cross.fill"),
                        sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                        scale: 0.022
                    )
                )
                .opacity(opacity)
                .blendMode(.overlay)
                .offset(x: jitter, y: jitter)
            
            if !reduceMotion {
                Rectangle()
                    .fill(
                        ImagePaint(
                            image: Image(systemName: "square.grid.3x3.fill"),
                            sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                            scale: 0.017
                        )
                    )
                    .opacity(opacity * 0.5)
                    .blendMode(.overlay)
                    .offset(x: -jitter, y: -jitter)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) {
                jitter = 0.8
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Canvas Sky Particles (Optimized)
/// Canvas-based floating particles for depth with parallax and cleanup
struct ThickSkyParticles: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var config: CinematicConfig = .cinematic
    
    @State private var time: Double = 0
    @State private var tilt: CGSize = .zero
    @State private var parallaxPhase: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            Canvas { context, canvasSize in
                guard config.particlesEnabled else { return }
                
                let count = config.particleCount
                let baseSpeed = config.particleSpeed
                let maxSize = config.particleMaxSize
                let parallax = config.parallaxAmount
                
                for i in 0..<count {
                    let seed = Double(i) * 37.0
                    let px = noise(seed + time * Double(baseSpeed)) * canvasSize.width
                    let py = fmod(noise(seed * 1.7 + time * Double(baseSpeed) * 0.8) * (canvasSize.height + 160), canvasSize.height + 160) - 80
                    let s = CGFloat(noise(seed * 2.3)) * maxSize * 0.7 + maxSize * 0.3
                    let o = lerp(config.particleOpacity.lowerBound, config.particleOpacity.upperBound, noise(seed * 3.1))
                    
                    let parallaxX = tilt.width * (parallax / 40) * CGFloat(Double(i % 7) / 6.0)
                    let parallaxY = tilt.height * (parallax / 50) * CGFloat(Double((i + 3) % 7) / 6.0)
                    
                    let rect = CGRect(x: px + parallaxX, y: py + parallaxY, width: s, height: s)
                    
                    // soft glow then core
                    context.addFilter(.blur(radius: s * 0.6))
                    context.fill(Path(ellipseIn: rect.insetBy(dx: -s * 0.6, dy: -s * 0.6)), with: .color(.white.opacity(o * 0.18)))
                    context.addFilter(.blur(radius: 0))
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(o)))
                }
            }
            .onAppear {
                if !reduceMotion {
                    withAnimation(.linear(duration: 1/0.00001)) {
                        // No-op; Canvas redraws via time updates below.
                    }
                }
            }
            .onReceive(Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()) { _ in
                guard !reduceMotion else { return }
                time += 1/60
                parallaxPhase += 1/60
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let nx = (value.location.x / size.width - 0.5) * 2
                        let ny = (value.location.y / size.height - 0.5) * 2
                        withAnimation(.easeOut(duration: 0.2)) {
                            tilt = CGSize(width: nx * config.parallaxAmount, height: ny * config.parallaxAmount)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            tilt = .zero
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    // Helpers
    private func noise(_ x: Double) -> Double {
        // Simple deterministic pseudo-noise based on sine
        return (sin(x) + 1) / 2
    }
    
    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * t
    }
}

// MARK: - Gradient Background with Subtle Motion
struct CinematicGradientBackground: View {
    var colors: [Color]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Double = 0
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: reduceMotion ? .topLeading : (phase < 0.5 ? .topLeading : .leading),
            endPoint: reduceMotion ? .bottomTrailing : (phase < 0.5 ? .bottomTrailing : .trailing)
        )
        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: phase)
        .onAppear {
            guard !reduceMotion else { return }
            phase = 1
        }
        .ignoresSafeArea()
    }
}

// MARK: - Composed Background
/// Drop-in cinematic background with sensible defaults and configurability
struct CinematicBackdrop: View {
    var config: CinematicConfig = .cinematic
    
    var body: some View {
        ZStack {
            CinematicGradientBackground(colors: config.colorScheme)
            SunPeekingView(config: config)
            ThickSkyParticles(config: config)
            VignetteOverlay(intensity: config.vignetteIntensity)
            GrainOverlay(opacity: config.grainOpacity)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Demo Usage Example
struct CinematicBackgroundExample: View {
    @State private var style: Int = 1
    
    private var currentConfig: CinematicConfig {
        switch style {
        case 0: return .subtle
        case 1: return .cinematic
        default: return .bold
        }
    }
    
    var body: some View {
        ZStack {
            CinematicBackdrop(config: currentConfig)
            
            VStack(spacing: 16) {
                Text("Your App Content")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 2)
                
                Text("Cinematic ambience with accessible motion and performance-aware effects.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Picker("Style", selection: $style) {
                    Text("Subtle").tag(0)
                    Text("Cinematic").tag(1)
                    Text("Bold").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)
                .padding(.top, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
            }
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Previews
#Preview("Sun Peeking") {
    ZStack {
        Color.black.ignoresSafeArea()
        SunPeekingView(config: .bold)
    }
}

#Preview("Vignette Overlay") {
    ZStack {
        CinematicGradientBackground(colors: CinematicConfig.cinematic.colorScheme)
        VignetteOverlay(intensity: 0.34)
    }
}

#Preview("Grain Overlay") {
    ZStack {
        Color.blue.ignoresSafeArea()
        GrainOverlay(opacity: 0.08)
    }
}

#Preview("Thick Sky Particles") {
    ZStack {
        CinematicGradientBackground(colors: CinematicConfig.subtle.colorScheme)
        ThickSkyParticles(config: .cinematic)
    }
}

#Preview("Full Cinematic Example") {
    CinematicBackgroundExample()
}
