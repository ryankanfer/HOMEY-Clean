import SwiftUI

// MARK: - Action Button Component
struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Glass Orb Unlock View
public struct GlassOrbUnlockView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var sessionManager: AppSessionManager

    @State private var isPressing: Bool = false
    @State private var phase: Double = 0
    @State private var breathingPhase: Double = 0
    @State private var amplitude: CGFloat = 0.15
    @State private var frequency: CGFloat = 6
    @State private var elasticity: CGFloat = 1.0
    @State private var unlocked: Bool = false
    @State private var showActionBubbles: Bool = false
    @State private var showKeyTwist: Bool = false
    @State private var neonKeyColor: Color = .cyan
    @State private var showParticles: Bool = false
    @State private var isAnimatingFingerprint = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var fadeOpacity: Double = 1.0

    public init() {}

    public var body: some View {
        ZStack {
            // Blurred/immersive background effect when unlocked
            if unlocked {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .blur(radius: 20)
                    .opacity(0.8)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.6), value: unlocked)
            }
            
            orbView
                .scaleEffect(isPressing ? 0.9 : 1)
                .scaleEffect(zoomScale)
                .opacity(fadeOpacity)
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isPressing)
                .overlay(
                    // Dissolving outline effect overlay
                    DissolvingOrbView {
                        // On dissolve complete, show action bubbles
                        DispatchQueue.main.async {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                unlocked = true
                                showActionBubbles = true
                                showParticles = true
                            }
                        }
                    }
                    .opacity(unlocked ? 0 : 1)
                )

            if unlocked {
                ZStack {
                    // Background tap area for redo functionality
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            redo()
                        }
                    
                    // Particle effects background
                    if showParticles {
                        ForEach(0..<12, id: \.self) { index in
                            Circle()
                                .fill(neonKeyColor.opacity(0.8))
                                .frame(width: 4, height: 4)
                                .offset(
                                    x: cos(Double(index) * .pi / 6) * 100,
                                    y: sin(Double(index) * .pi / 6) * 100
                                )
                                .scaleEffect(showParticles ? 1 : 0)
                                .opacity(showParticles ? 0.8 : 0)
                                .animation(
                                    .easeOut(duration: 0.8)
                                    .delay(Double(index) * 0.05),
                                    value: showParticles
                                )
                        }
                    }
                    
                    VStack(spacing: 24) {
                        // Action buttons in 2x2 grid - positioned higher
                         if showActionBubbles {
                             VStack(spacing: 20) {
                                 HStack(spacing: 20) {
                                     ActionButton(
                                         icon: "magnifyingglass.circle.fill",
                                         label: "Search",
                                         color: neonKeyColor
                                     )
                                     ActionButton(
                                         icon: "folder.fill",
                                         label: "Vault",
                                         color: neonKeyColor
                                     )
                                 }
                                 HStack(spacing: 20) {
                                     ActionButton(
                                         icon: "folder.fill",
                                         label: "Directory",
                                         color: neonKeyColor
                                     )
                                     ActionButton(
                                         icon: "chart.bar.fill",
                                         label: "Insights",
                                         color: neonKeyColor
                                     )
                                 }
                             }
                             .scaleEffect(showActionBubbles ? 1 : 0.5)
                             .opacity(showActionBubbles ? 1 : 0)
                             .animation(
                                 .spring(response: 0.6, dampingFraction: 0.8)
                                 .delay(0.8),
                                 value: showActionBubbles
                             )
                         }
                    }
                    .offset(y: -60) // Move buttons up
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }
        }
        .frame(maxWidth: 280, maxHeight: 280)
        .padding(40)
        .onAppear {
            startBreathingAnimation()
        }
    }

    private var orbView: some View {
        ZStack {
            // Simple thin white circle
            Circle()
                .stroke(.white.opacity(0.6), lineWidth: 2)
                .frame(width: 160, height: 160)
                .scaleEffect(isPressing ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isPressing)
            
            // Fingerprint-style neon outline
            Circle()
                .trim(from: 0, to: phase)
                .stroke(
                    neonKeyColor,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-90)) // Start from top
                .shadow(color: neonKeyColor.opacity(0.8), radius: 8)
                .shadow(color: neonKeyColor.opacity(0.4), radius: 16)
        }
    }

    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathingPhase = 2 * .pi
        }
    }
    
    private func generateRandomNeonColor() {
        let neonColors: [Color] = [.cyan, .pink, .purple, .green, .orange, .yellow, .red]
        neonKeyColor = neonColors.randomElement() ?? .cyan
    }

    private func startPhaseAnimation() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            phase = 1
        }
    }

    private func stopPhaseAnimation() {
        withAnimation(.easeOut(duration: 0.4)) {
            phase = 0
        }
    }

    private func unlock() {
        withAnimation(.easeInOut(duration: 0.6)) {
            unlocked = true
            showActionBubbles = true
        }
    }

    private func route(to action: OrbContextAction) {
        switch action {
        case .documents:
            router.route = .documents
        case .directory:
            router.route = .directory
        case .insights:
            router.route = .insights
        case .search:
            router.route = .search
        }
    }
    
    private func redo() {
        withAnimation(.easeInOut(duration: 0.5)) {
            unlocked = false
            showActionBubbles = false
            showParticles = false
            showKeyTwist = false
            isAnimatingFingerprint = false
            phase = 0
            amplitude = 0.15
            elasticity = 1.0
            isPressing = false
            zoomScale = 1.0
            fadeOpacity = 1.0
        }
    }
    
    private func randomizeNeonColor() {
        let neonColors: [Color] = [
            .cyan, .mint, .green, .yellow, .orange, .pink, .purple, .blue, .indigo
        ]
        neonKeyColor = neonColors.randomElement() ?? .cyan
    }
    
    private func startFingerprintAnimation() {
        randomizeNeonColor()
        isAnimatingFingerprint = true
        
        // Rapid zoom animation into circular focal point
        withAnimation(.easeIn(duration: 0.3)) {
            zoomScale = 1.5
        }
        
        withAnimation(.easeInOut(duration: 1.2)) {
            phase = 1.0
        }
        
        // After fingerprint completes, fade out and show particles and action buttons
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // Smooth fade-out
            withAnimation(.easeOut(duration: 0.4)) {
                fadeOpacity = 0.3
                zoomScale = 1.0
            }
            
            // Show particles and action buttons
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showParticles = true
                showActionBubbles = true
                unlocked = true
            }
        }
    }
}

// MARK: - OrbContextAction

internal enum OrbContextAction: CaseIterable, Identifiable {
    case documents, directory, insights, search

    var id: Self { self }

    var title: String {
        switch self {
        case .documents: return "Documents"
        case .directory: return "Directory"
        case .insights: return "Insights"
        case .search: return "Search"
        }
    }

    var systemImage: String {
        switch self {
        case .documents: return "doc.text.fill"
        case .directory: return "folder.fill"
        case .insights: return "chart.bar.fill"
        case .search: return "magnifyingglass.circle.fill"
        }
    }
}

// MARK: - OrbActionBubblesView

internal struct OrbActionBubblesView: View {
    let actions: [OrbContextAction]
    let actionHandler: (OrbContextAction) -> Void

    @State private var appeared: Bool = false

    var body: some View {
        HStack(spacing: 28) {
            ForEach(actions) { action in
                OrbActionBubble(action: action) {
                    actionHandler(action)
                }
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut.delay(Double(actions.firstIndex(of: action) ?? 0) * 0.12), value: appeared)
            }
        }
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - OrbActionBubble

internal struct OrbActionBubble: View {
    let action: OrbContextAction
    let tapAction: () -> Void

    var body: some View {
        Button {
            tapAction()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: action.systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.6), radius: 6, x: 0, y: 2)

                Text(action.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.4), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.8), .pink.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Advanced3DGlassOrb

internal struct Advanced3DGlassOrb: Shape {
    var phase: Double // 0 to 1 (animatable)
    var breathingPhase: Double // Continuous breathing animation
    var amplitude: CGFloat
    var frequency: CGFloat
    var elasticity: CGFloat

    var animatableData: AnimatablePair<Double, AnimatablePair<Double, CGFloat>> {
        get { AnimatablePair(phase, AnimatablePair(breathingPhase, elasticity)) }
        set { 
            phase = newValue.first
            breathingPhase = newValue.second.first
            elasticity = newValue.second.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 16 // More points for smoother curves
        let baseRadius = min(rect.width, rect.height) / 2
        let angleStep = 2 * .pi / CGFloat(points)

        var currentAngle: CGFloat = 0
        var pointsArray: [CGPoint] = []

        for i in 0..<points {
            let theta = currentAngle
            
            // Multi-layered wave distortion for enhanced fluidity
            let primaryWave = sin(Double(i) * Double(frequency) + phase * 2 * .pi)
            let secondaryWave = sin(Double(i) * Double(frequency * 1.7) + phase * 3 * .pi) * 0.3
            let breathingWave = sin(breathingPhase * 2 * .pi) * 0.15
            
            // Combine waves with elasticity factor
            let combinedOffset = (primaryWave + secondaryWave + breathingWave) * Double(amplitude * elasticity)
            let radius = baseRadius + CGFloat(combinedOffset) * baseRadius
            
            // Add subtle 3D perspective distortion
            let perspectiveScale = 1.0 + sin(theta + breathingPhase * .pi) * 0.05
            let adjustedRadius = radius * perspectiveScale

            let x = center.x + adjustedRadius * cos(theta)
            let y = center.y + adjustedRadius * sin(theta)

            pointsArray.append(CGPoint(x: x, y: y))
            currentAngle += angleStep
        }

        // Create ultra-smooth curves using cubic Bézier curves
        path.move(to: pointsArray[0])
        
        for i in 0..<points {
            let current = pointsArray[i]
            let next = pointsArray[(i + 1) % points]
            let nextNext = pointsArray[(i + 2) % points]
            
            // Calculate control points for smooth cubic curves
            let controlPoint1 = CGPoint(
                x: current.x + (next.x - pointsArray[(i - 1 + points) % points].x) * 0.2,
                y: current.y + (next.y - pointsArray[(i - 1 + points) % points].y) * 0.2
            )
            
            let controlPoint2 = CGPoint(
                x: next.x - (nextNext.x - current.x) * 0.2,
                y: next.y - (nextNext.y - current.y) * 0.2
            )
            
            path.addCurve(to: next, control1: controlPoint1, control2: controlPoint2)
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - ParticleEffectView

internal struct ParticleEffectView: View {
    let color: Color
    @State private var particles: [Particle] = []
    @State private var animationTimer: Timer?
    
    private struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var size: CGFloat
        var opacity: Double
        var life: Double
        var maxLife: Double
    }
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.position.x - particle.size / 2,
                    y: particle.position.y - particle.size / 2,
                    width: particle.size,
                    height: particle.size
                )
                
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(color.opacity(particle.opacity))
                )
                
                // Add glow effect
                context.addFilter(.blur(radius: particle.size * 0.3))
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(color.opacity(particle.opacity * 0.3))
                )
            }
        }
        .onAppear {
            startParticleSystem()
        }
        .onDisappear {
            stopParticleSystem()
        }
    }
    
    private func startParticleSystem() {
        // Create initial particles
        for _ in 0..<20 {
            createParticle()
        }
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func stopParticleSystem() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func createParticle() {
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2
        
        let angle = Double.random(in: 0...(2 * .pi))
        let distance = Double.random(in: 50...150)
        
        let particle = Particle(
            position: CGPoint(
                x: centerX + cos(angle) * distance,
                y: centerY + sin(angle) * distance
            ),
            velocity: CGPoint(
                x: Double.random(in: -30...30),
                y: Double.random(in: -30...30)
            ),
            size: CGFloat.random(in: 2...8),
            opacity: Double.random(in: 0.3...0.8),
            life: 0,
            maxLife: Double.random(in: 2...4)
        )
        
        particles.append(particle)
    }
    
    private func updateParticles() {
        for i in particles.indices.reversed() {
            particles[i].position.x += particles[i].velocity.x * 0.016
            particles[i].position.y += particles[i].velocity.y * 0.016
            particles[i].life += 0.016
            
            // Fade out over time
            let lifeRatio = particles[i].life / particles[i].maxLife
            particles[i].opacity = max(0, 1 - lifeRatio)
            
            // Remove dead particles
            if particles[i].life >= particles[i].maxLife {
                particles.remove(at: i)
            }
        }
        
        // Create new particles to maintain count
        while particles.count < 20 {
            createParticle()
        }
    }
}

// MARK: - KeyShape

internal struct KeyShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()

        // Key head - circle
        let headRadius = w * 0.35
        let headCenter = CGPoint(x: w * 0.35, y: h * 0.5)
        path.addEllipse(in: CGRect(x: headCenter.x - headRadius, y: headCenter.y - headRadius, width: headRadius * 2, height: headRadius * 2))

        // Key shaft - rectangle
        let shaftWidth = w * 0.25
        let shaftHeight = h * 0.15
        let shaftOrigin = CGPoint(x: headCenter.x + headRadius * 0.4, y: h * 0.425)
        path.addRoundedRect(in: CGRect(origin: shaftOrigin, size: CGSize(width: shaftWidth, height: shaftHeight)), cornerSize: CGSize(width: shaftHeight / 2, height: shaftHeight / 2))

        // Key teeth
        let toothWidth = shaftWidth / 3
        let toothHeight = shaftHeight / 2
        let tooth1Origin = CGPoint(x: shaftOrigin.x + toothWidth, y: shaftOrigin.y + shaftHeight)
        path.addRect(CGRect(origin: tooth1Origin, size: CGSize(width: toothWidth * 0.5, height: toothHeight)))

        let tooth2Origin = CGPoint(x: shaftOrigin.x + toothWidth * 2, y: shaftOrigin.y + shaftHeight)
        path.addRect(CGRect(origin: tooth2Origin, size: CGSize(width: toothWidth * 0.5, height: toothHeight * 0.75)))

        return path
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.03, green: 0.03, blue: 0.05),
                Color(red: 0.08, green: 0.08, blue: 0.15),
                Color(red: 0.02, green: 0.02, blue: 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        GlassOrbUnlockView()
            .environmentObject(AppRouter.preview)
            .environmentObject(UserProfileManager.preview)
            .environmentObject(AppSessionManager.preview)
    }
}

#if DEBUG
extension AppRouter {
    static let preview: AppRouter = {
        AppRouter()
    }()
}

extension UserProfileManager {
    static let preview: UserProfileManager = {
        UserProfileManager.shared
    }()
}

extension AppSessionManager {
    static let preview: AppSessionManager = {
        AppSessionManager.shared
    }()
}
#endif

