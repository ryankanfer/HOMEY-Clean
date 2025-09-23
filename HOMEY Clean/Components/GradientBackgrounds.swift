import SwiftUI

// MARK: - 1. Calm Skyflow
struct CalmSkyflowBackground: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: soft blue → aqua → pale lavender
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 1.0),    // soft blue
                    Color(red: 0.4, green: 0.9, blue: 0.9),    // aqua
                    Color(red: 0.8, green: 0.7, blue: 0.9)     // pale lavender
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Slow diagonal drift overlay
            LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.clear,
                    Color.blue.opacity(0.1)
                ],
                startPoint: UnitPoint(
                    x: 0.2 + 0.6 * phase,
                    y: 0.1 + 0.3 * phase
                ),
                endPoint: UnitPoint(
                    x: 0.8 + 0.2 * phase,
                    y: 0.7 + 0.3 * phase
                )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - Animated Gradient Background Component
struct AnimatedGradientBackground: View {
    @EnvironmentObject var themeManager: ThemeManager
    let page: AppPage?
    
    init(for page: AppPage? = nil) {
        self.page = page
    }
    
    var body: some View {
        let theme = themeManager.currentTheme(for: page)
        
        switch theme {
        case .calmSkyflow:
            AnyView(CalmSkyflowBackground())
        case .sunsetPulse:
            AnyView(SunsetPulseBackground())
        case .midnightLuxe:
            AnyView(MidnightLuxeBackground())
        case .urbanEnergy:
            AnyView(UrbanEnergyBackground())
        case .desertMirage:
            AnyView(DesertMirageBackground())
        case .auroraFlow:
            AnyView(AuroraFlowBackground())
        case .monochromeSheen:
            AnyView(MonochromeSheenBackground())
        case .cinematicLounge:
            AnyView(CinematicLoungeBackground())
        }
    }
}

// MARK: - Static Gradient Background Component
struct StaticGradientBackground: View {
    @EnvironmentObject var themeManager: ThemeManager
    let page: AppPage?
    
    init(for page: AppPage? = nil) {
        self.page = page
    }
    
    var body: some View {
        let theme = themeManager.currentTheme(for: page)
        Theme.gradientForTheme(theme)
    }
}

// MARK: - Card Gradient Background Component
struct CardGradientBackground: View {
    @EnvironmentObject var themeManager: ThemeManager
    let page: AppPage?
    let opacity: Double
    
    init(for page: AppPage? = nil, opacity: Double = 0.3) {
        self.page = page
        self.opacity = opacity
    }
    
    var body: some View {
        let theme = themeManager.currentTheme(for: page)
        Theme.gradientForTheme(theme)
            .opacity(opacity)
    }
}

// MARK: - 2. Sunset Pulse
struct SunsetPulseBackground: View {
    @State private var pulsePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: coral → peach → blush → gold
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.3),    // coral
                    Color(red: 1.0, green: 0.7, blue: 0.5),    // peach
                    Color(red: 1.0, green: 0.8, blue: 0.8),    // blush
                    Color(red: 1.0, green: 0.8, blue: 0.2)     // gold
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            
            // Gentle radial breathing effect
            RadialGradient(
                colors: [
                    Color.orange.opacity(0.3),
                    Color.clear,
                    Color.pink.opacity(0.2)
                ],
                center: .center,
                startRadius: 100 + 50 * sin(pulsePhase * 2 * .pi),
                endRadius: 300 + 100 * cos(pulsePhase * 2 * .pi)
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                pulsePhase = 1
            }
        }
    }
}

// MARK: - 3. Midnight Luxe
struct MidnightLuxeBackground: View {
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: indigo → violet → deep teal
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.0, blue: 0.5),    // indigo
                    Color(red: 0.5, green: 0.0, blue: 0.8),    // violet
                    Color(red: 0.0, green: 0.4, blue: 0.4)     // deep teal
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Smooth wave oscillation
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.4),
                    Color.clear,
                    Color.teal.opacity(0.3)
                ],
                startPoint: UnitPoint(
                    x: 0.5 + 0.4 * sin(wavePhase * 2 * .pi),
                    y: 0.2
                ),
                endPoint: UnitPoint(
                    x: 0.5 - 0.4 * sin(wavePhase * 2 * .pi),
                    y: 0.8
                )
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                wavePhase = 1
            }
        }
    }
}

// MARK: - 4. Urban Energy
struct UrbanEnergyBackground: View {
    @State private var sweepPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: electric blue → mint → neon purple
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.5, blue: 1.0),    // electric blue
                    Color(red: 0.4, green: 1.0, blue: 0.7),    // mint
                    Color(red: 0.6, green: 0.0, blue: 1.0)     // neon purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Sharp, angled sweeps with fast → slow easing
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.5),
                    Color.clear,
                    Color.purple.opacity(0.4)
                ],
                startPoint: UnitPoint(
                    x: sweepPhase < 0.5 ? sweepPhase * 2 : 1.0,
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: sweepPhase < 0.5 ? 0.0 : (sweepPhase - 0.5) * 2,
                    y: 1.0
                )
            )
        }
        .onAppear {
            withAnimation(.timingCurve(0.25, 0.1, 0.25, 1, duration: 3).repeatForever(autoreverses: true)) {
                sweepPhase = 1
            }
        }
    }
}

// MARK: - 5. Desert Mirage
struct DesertMirageBackground: View {
    @State private var shimmerPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: terracotta → sand → dusty rose
            LinearGradient(
                colors: [
                    Color(red: 0.8, green: 0.4, blue: 0.3),    // terracotta
                    Color(red: 0.9, green: 0.8, blue: 0.6),    // sand
                    Color(red: 0.8, green: 0.6, blue: 0.6)     // dusty rose
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Shimmering horizontal gradient (heat waves)
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.3),
                    Color.clear,
                    Color.pink.opacity(0.2),
                    Color.clear,
                    Color.yellow.opacity(0.1)
                ],
                startPoint: UnitPoint(
                    x: 0.0,
                    y: 0.3 + 0.4 * sin(shimmerPhase * 4 * .pi)
                ),
                endPoint: UnitPoint(
                    x: 1.0,
                    y: 0.7 + 0.2 * cos(shimmerPhase * 3 * .pi)
                )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                shimmerPhase = 1
            }
        }
    }
}

// MARK: - 6. Aurora Flow
struct AuroraFlowBackground: View {
    @State private var ribbonPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: emerald → cyan → pink → violet
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.8, blue: 0.4),    // emerald
                    Color(red: 0.0, green: 0.8, blue: 0.8),    // cyan
                    Color(red: 1.0, green: 0.4, blue: 0.8),    // pink
                    Color(red: 0.6, green: 0.0, blue: 0.8)     // violet
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Vertical gradient ribbons weaving
            LinearGradient(
                colors: [
                    Color.green.opacity(0.4),
                    Color.clear,
                    Color.pink.opacity(0.3),
                    Color.clear,
                    Color.purple.opacity(0.2)
                ],
                startPoint: UnitPoint(
                    x: 0.2 + 0.3 * sin(ribbonPhase * 2 * .pi),
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: 0.8 + 0.2 * cos(ribbonPhase * 3 * .pi),
                    y: 1.0
                )
            )
            
            // Second ribbon layer
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.3),
                    Color.clear,
                    Color.purple.opacity(0.4)
                ],
                startPoint: UnitPoint(
                    x: 0.6 + 0.2 * cos(ribbonPhase * 2.5 * .pi),
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: 0.4 + 0.3 * sin(ribbonPhase * 1.5 * .pi),
                    y: 1.0
                )
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                ribbonPhase = 1
            }
        }
    }
}

// MARK: - 7. Monochrome Sheen
struct MonochromeSheenBackground: View {
    @State private var sheenPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: slate gray → silver → charcoal
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.5, blue: 0.5),    // slate gray
                    Color(red: 0.7, green: 0.7, blue: 0.7),    // silver
                    Color(red: 0.2, green: 0.2, blue: 0.2)     // charcoal
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Slow shimmer loop with metallic feel
            LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.clear,
                    Color.gray.opacity(0.4),
                    Color.clear,
                    Color.white.opacity(0.2)
                ],
                startPoint: UnitPoint(
                    x: -0.5 + 2 * sheenPhase,
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: 0.5 + 2 * sheenPhase,
                    y: 1.0
                )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                sheenPhase = 1
            }
        }
    }
}

// MARK: - 8. Cinematic Lounge
struct CinematicLoungeBackground: View {
    @State private var ambientPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient: slate gray → dark charcoal
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.18),  // slate gray
                    Color(red: 0.08, green: 0.08, blue: 0.12),  // near black
                    Color(red: 0.12, green: 0.12, blue: 0.15)   // dark charcoal
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle ambient overlay for depth
            LinearGradient(
                colors: [
                    Color.white.opacity(0.02),
                    Color.clear,
                    Color.white.opacity(0.01)
                ],
                startPoint: UnitPoint(
                    x: 0.5 + 0.2 * cos(ambientPhase * 2 * .pi),
                    y: 0.5 + 0.2 * sin(ambientPhase * 2 * .pi)
                ),
                endPoint: UnitPoint(
                    x: 0.5 - 0.2 * cos(ambientPhase * 2 * .pi),
                    y: 0.5 - 0.2 * sin(ambientPhase * 2 * .pi)
                )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                ambientPhase = 1
            }
        }
    }
}

// MARK: - View Extensions for Easy Access
public extension View {
    /// Applies an animated gradient background based on the current theme
    func animatedGradientBackground(for page: AppPage? = nil) -> some View {
        self.background(AnimatedGradientBackground(for: page))
    }
    
    /// Applies a static gradient background based on the current theme
    func staticGradientBackground(for page: AppPage? = nil) -> some View {
        self.background(StaticGradientBackground(for: page))
    }
    
    /// Applies a card-style gradient background with opacity
    func cardGradientBackground(for page: AppPage? = nil, opacity: Double = 0.3) -> some View {
        self.background(CardGradientBackground(for: page, opacity: opacity))
    }
}