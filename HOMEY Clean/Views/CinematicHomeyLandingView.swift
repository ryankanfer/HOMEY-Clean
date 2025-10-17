import SwiftUI
import CoreMotion

struct CinematicHomeyLandingView: View {
    @State private var showPortal = false
    @EnvironmentObject private var router: AppRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            SkyLandingBackdrop(showPortal: $showPortal)
                .environmentObject(router)
                .opacity(showPortal ? 0 : 1)
            
            if showPortal {
                RefinedPortalView(isPresented: $showPortal)
                    .environmentObject(router)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: showPortal)
        .safeAreaInset(edge: .top) {
            // Top-centered HOMEY title in JosefinSans-Thin
            HStack {
                Spacer()
                Text("HOMEY")
                    .font(.custom(TypographySystem.JosefinSans.thin, size: 24))
                    .tracking(2.0)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.45), radius: 8, x: 0, y: 4)
                    .padding(.top, 8)
                Spacer()
            }
            .padding(.bottom, 6)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.15), .clear],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
            )
        }
    }
}

// MARK: - Minimal Sky Landing (no cards, with homepage_group_wave)
struct SkyLandingBackdrop: View {
    @Binding var showPortal: Bool
    @EnvironmentObject private var router: AppRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    
    // Time of day
    @State private var timeOfDay: LandingTimeOfDay = .current()
    @State private var timer: Timer?
    
    // Center title (random witty copy chosen per events)
    @State private var currentTitle: String = ""
    
    // CTA rotating copy
    @State private var currentCTA: String = ""
    @State private var ctaTimer: Timer?
    
    // Parallax motion (for subtle wave drift)
    @State private var roll: CGFloat = 0
    @State private var pitch: CGFloat = 0
    private let motionManager = CMMotionManager()
    
    // CTA pulse
    @State private var pulseScale: CGFloat = 1.0
    
    // Wave fade-in
    @State private var waveOpacity: Double = 0.0
    
    // Quick actions
    @State private var showQuickActions = false
    
    var body: some View {
        ZStack {
            // Background: gradient + vignette + grain + sun/moon
            ZStack {
                LinearGradient(
                    colors: gradientColors(for: timeOfDay),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Group {
                    switch timeOfDay {
                    case .night:
                        MoonGlowView().allowsHitTesting(false)
                    default:
                        SunPeekingView().allowsHitTesting(false)
                    }
                }
                
                VignetteOverlay(intensity: 0.26).allowsHitTesting(false)
                GrainOverlay(opacity: 0.05).allowsHitTesting(false)
            }
            
            // Optional ambient particles
            ThickSkyParticles()
                .opacity(0.85)
                .allowsHitTesting(false)
            
            // Center headline — moved up
            VStack(spacing: 0) {
                Spacer()
                Text(currentTitle)
                    .font(.custom(TypographySystem.JosefinSans.bold, size: 28))
                    .foregroundStyle(.white)
                    .shadow(color: glowShadow(for: timeOfDay), radius: 20, y: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 160) // was 120; increase to move text up
                    .offset(y: -10) // subtle extra lift; adjust as needed
                Spacer(minLength: 0)
            }
            .allowsHitTesting(false)
            
            // Bottom artwork and CTA
            VStack(spacing: 0) {
                Spacer()
                
                // Hero group artwork: edge-to-edge, tall, bottom-aligned
                GeometryReader { geo in
                    let h = geo.size.height
                    // Make it big: 52% of screen height, clamped for consistency across devices
                    let targetH = min(max(h * 0.52, 300), 480)
                    
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Image("homepage_group_wave")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: targetH, alignment: .bottom)
                            .clipped()
                            // Slight upward bias so feet are fully visible while filling width
                            .offset(y: -80)
                            .accessibilityHidden(true)
                            .opacity(waveOpacity)
                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                            // Subtle parallax (reduced to avoid noticeable drift on tall art)
                            .offset(x: parallax(amount: 6, axis: .x),
                                    y: parallax(amount: 4, axis: .y))
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { waveOpacity = 0.5 }
                                withAnimation(.easeOut(duration: 0.6).delay(0.5)) { waveOpacity = 0.8 }
                                withAnimation(.easeOut(duration: 0.6).delay(0.9)) { waveOpacity = 1.0 }
                            }
                    }
                    .frame(width: geo.size.width, height: targetH, alignment: .bottom)
                    .padding(.bottom, max(geo.safeAreaInsets.bottom - 4, 0))
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: .bottom)
                }
                .frame(height: 160) // give it generous space so it reads like the reference
                .zIndex(1)
                
                // CTA pill overlapping the legs (in front)
                Button {
                    TRAEMotionSystem.shared.triggerHaptic(.light)
                    showPortal = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                        Text(currentCTA.isEmpty ? ctaTitle(for: timeOfDay) : currentCTA)
                            .font(.custom(TypographySystem.JosefinSans.bold, size: 18))
                            .tracking(0.6)
                            .id(currentCTA)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(0.62)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(Color.white.opacity(0.38), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 12)
                    .scaleEffect(pulseScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            pulseScale = 1.02
                        }
                    }
                }
                // Reliable long-press on the button itself
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            TRAEHapticManager.shared.trigger(.medium)
                            showQuickActions = true
                        }
                )
                .confirmationDialog("Quick actions", isPresented: $showQuickActions, titleVisibility: .visible) {
                    Button("Search") { router.route = .search }
                    Button("Documents") { router.route = .documents }
                    Button("Directory") { router.route = .directory }
                    Button("Vision") { router.route = .vision }
                    Button("Cancel", role: .cancel) { }
                }
                .padding(.bottom, 18) // sits just above bottom and overlaps image slightly
                .offset(y: -58) // move CTA up (adjust value to taste)
                .zIndex(2)
            }
        }
        .onAppear {
            startMotionIfAvailable()
            startDayPhaseTimer()
            currentTitle = centerTitle(for: timeOfDay)
            currentCTA = randomCTA()
            startCTATimerIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                currentTitle = centerTitle(for: LandingTimeOfDay.current())
                currentCTA = randomCTA()
                startCTATimerIfNeeded()
            } else if newPhase == .inactive || newPhase == .background {
                stopCTATimer()
            }
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
            timer?.invalidate()
            timer = nil
            stopCTATimer()
        }
    }
    
    // MARK: - Witty Copy
    private let wittyTitles: [LandingTimeOfDay: [String]] = [
        .sunrise: [
            "Golden Hour",
            "Early Riser Energy",
            "Coffee Then Closings",
            "Doors Open Early"
        ],
        .day: [
            "Welcome Home",
            "Let’s Make Moves",
            "Inbox: New Listings",
            "Tour Ready, Are You?"
        ],
        .sunset: [
            "Golden Hour Redux",
            "Last Light, Best Picks",
            "Deals Love Dusk",
            "One More Refresh"
        ],
        .night: [
            "Stargazing",
            "Midnight Zillow Scroller",
            "Dream Home, Literally",
            "Sleep Is Optional"
        ]
    ]
    
    private let wittyCTAs: [String] = [
        "Continue where you left off",
        "Want to see what’s next?",
        "Click me, you know you want to",
        "Let’s find your place"
    ]
    
    // MARK: - CTA rotation helpers
    private func randomCTA() -> String {
        wittyCTAs.randomElement() ?? "Find home"
    }
    
    private func startCTATimerIfNeeded() {
        guard !reduceMotion else { return }
        stopCTATimer()
        ctaTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                currentCTA = randomCTA()
            }
        }
    }
    
    private func stopCTATimer() {
        ctaTimer?.invalidate()
        ctaTimer = nil
    }
    
    // MARK: - Utilities
    private enum Axis { case x, y }
    private func parallax(amount: CGFloat, axis: Axis) -> CGFloat {
        guard motionManager.isDeviceMotionAvailable else { return 0 }
        if axis == .x { return roll * amount } else { return -pitch * amount }
    }
    
    private func startMotionIfAvailable() {
        guard motionManager.isDeviceMotionAvailable, !reduceMotion else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion = motion else { return }
            let maxTilt: Double = 0.4
            let r = max(-maxTilt, min(maxTilt, motion.attitude.roll))
            let p = max(-maxTilt, min(maxTilt, motion.attitude.pitch))
            roll = CGFloat(r)
            pitch = CGFloat(p)
        }
    }
    
    private func startDayPhaseTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                timeOfDay = .current()
                currentTitle = centerTitle(for: timeOfDay)
                currentCTA = randomCTA()
            }
        }
    }
    
    private func gradientColors(for tod: LandingTimeOfDay) -> [Color] {
        switch tod {
        case .sunrise:
            return [Color(hex: "8fd7ff"), Color(hex: "a9c3ff"), Color(hex: "bff6ea")]
        case .day:
            return [Color(hex: "9fd9ff"), Color(hex: "b7e0ff"), Color(hex: "e5fff9")]
        case .sunset:
            return [Color(red: 0.98, green: 0.7, blue: 0.5),
                    Color(red: 0.7, green: 0.55, blue: 0.85),
                    Color(red: 0.2, green: 0.3, blue: 0.5)]
        case .night:
            return [Color(red: 0.05, green: 0.07, blue: 0.15),
                    Color(red: 0.06, green: 0.08, blue: 0.18),
                    Color(red: 0.03, green: 0.05, blue: 0.12)]
        }
    }
    
    private func centerTitle(for tod: LandingTimeOfDay) -> String {
        let options = wittyTitles[tod] ?? ["HOMEY"]
        return options.randomElement() ?? "HOMEY"
    }
    
    private func ctaTitle(for tod: LandingTimeOfDay) -> String {
        switch tod {
        case .night, .sunrise, .day, .sunset:
            return "Find home"
        }
    }
    
    private func glowShadow(for tod: LandingTimeOfDay) -> Color {
        switch tod {
        case .night: return Color.blue.opacity(0.35)
        case .sunrise: return Color.orange.opacity(0.3)
        case .day: return Color(hex: "0ea5e9").opacity(0.3)
        case .sunset: return Color.pink.opacity(0.3)
        }
    }
}

// MARK: - Time of Day (scoped to this file)
private enum LandingTimeOfDay {
    case sunrise, day, sunset, night
    
    static func current() -> LandingTimeOfDay {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<8: return .sunrise
        case 8..<17: return .day
        case 17..<20: return .sunset
        default: return .night
        }
    }
}

// MARK: - Moon Glow (unchanged)
private struct MoonGlowView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Double = 0
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.25), Color.blue.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .blur(radius: 28)
                .opacity(0.9)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.7), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .blur(radius: 16)
        }
        .frame(width: 260, height: 260)
        .offset(x: 130, y: -200)
        .opacity(0.85)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
        .allowsHitTesting(false)
    }
}
