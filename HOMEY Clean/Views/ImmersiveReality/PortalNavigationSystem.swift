import SwiftUI

// MARK: - Portal Navigation System

/// Gateway elements with dimensional travel transitions for profile navigation
struct PortalNavigationSystem {
    
    // MARK: - Portal Configuration
    struct PortalConfig {
        let coreSize: CGFloat
        let energyRings: Int
        let rotationSpeed: Double
        let pulseIntensity: Double
        let transitionDuration: Double
        let dimensionalLayers: Int
        let portalDepth: CGFloat
        
        static let standard = PortalConfig(
            coreSize: 80,
            energyRings: 4,
            rotationSpeed: 1.0,
            pulseIntensity: 0.8,
            transitionDuration: 1.2,
            dimensionalLayers: 6,
            portalDepth: 200
        )
        
        static let intense = PortalConfig(
            coreSize: 120,
            energyRings: 6,
            rotationSpeed: 0.7,
            pulseIntensity: 1.2,
            transitionDuration: 1.8,
            dimensionalLayers: 8,
            portalDepth: 300
        )
        
        static let subtle = PortalConfig(
            coreSize: 60,
            energyRings: 3,
            rotationSpeed: 1.5,
            pulseIntensity: 0.5,
            transitionDuration: 0.8,
            dimensionalLayers: 4,
            portalDepth: 150
        )
    }
    
    // MARK: - Portal Destination
    enum PortalDestination: String, CaseIterable {
        case profile = "Profile"
        case journey = "Journey"
        case insights = "Insights"
        case settings = "Settings"
        case achievements = "Achievements"
        case connections = "Connections"
        
        var icon: String {
            switch self {
            case .profile: return "person.circle.fill"
            case .journey: return "map.fill"
            case .insights: return "chart.line.uptrend.xyaxis"
            case .settings: return "gearshape.fill"
            case .achievements: return "trophy.fill"
            case .connections: return "person.2.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .profile: return .cyan
            case .journey: return .purple
            case .insights: return .blue
            case .settings: return .orange
            case .achievements: return .yellow
            case .connections: return .pink
            }
        }
        
        var description: String {
            switch self {
            case .profile: return "Your digital consciousness"
            case .journey: return "Path through realities"
            case .insights: return "Data streams & analytics"
            case .settings: return "Reality configuration"
            case .achievements: return "Dimensional milestones"
            case .connections: return "Neural network links"
            }
        }
    }
    
    // MARK: - Portal State
    enum PortalState {
        case dormant
        case awakening
        case active
        case transitioning
        case closing
        
        var energyLevel: Double {
            switch self {
            case .dormant: return 0.2
            case .awakening: return 0.6
            case .active: return 1.0
            case .transitioning: return 1.5
            case .closing: return 0.1
            }
        }
    }
    
    // MARK: - Dimensional Particle
    struct DimensionalParticle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var size: CGFloat
        var opacity: Double
        var color: Color
        var rotationAngle: Double
        var lifespan: Double
        var age: Double = 0
        
        init(position: CGPoint, color: Color) {
            self.position = position
            self.velocity = CGPoint(
                x: Double.random(in: -50...50),
                y: Double.random(in: -50...50)
            )
            self.size = CGFloat.random(in: 2...8)
            self.opacity = Double.random(in: 0.3...1.0)
            self.color = color
            self.rotationAngle = Double.random(in: 0...2 * .pi)
            self.lifespan = Double.random(in: 2...5)
        }
        
        var isAlive: Bool {
            age < lifespan
        }
        
        var currentOpacity: Double {
            opacity * max(0, 1.0 - (age / lifespan))
        }
    }
}

// MARK: - Portal Core View

struct PortalCoreView: View {
    let destination: PortalNavigationSystem.PortalDestination
    let config: PortalNavigationSystem.PortalConfig
    let isActive: Bool
    let onActivate: () -> Void
    
    @State private var coreRotation: Double = 0
    @State private var energyPulse: Double = 0
    @State private var dimensionalShift: Double = 0
    @State private var portalState: PortalNavigationSystem.PortalState = .dormant
    @State private var particles: [PortalNavigationSystem.DimensionalParticle] = []
    
    init(
        destination: PortalNavigationSystem.PortalDestination,
        config: PortalNavigationSystem.PortalConfig = .standard,
        isActive: Bool = false,
        onActivate: @escaping () -> Void
    ) {
        self.destination = destination
        self.config = config
        self.isActive = isActive
        self.onActivate = onActivate
    }
    
    var body: some View {
        ZStack {
            // Portal depth layers
            ForEach(0..<config.dimensionalLayers, id: \.self) { layer in
                portalLayer(layer: layer)
            }
            
            // Energy rings
            ForEach(0..<config.energyRings, id: \.self) { ring in
                energyRing(ring: ring)
            }
            
            // Portal core
            portalCore
            
            // Dimensional particles
            particleField
            
            // Portal label
            portalLabel
        }
        .frame(width: config.coreSize * 2, height: config.coreSize * 2)
        .onAppear {
            startPortalAnimations()
            generateParticles()
        }
        .onChange(of: isActive) { _, newValue in
            updatePortalState(active: newValue)
        }
        .onTapGesture {
            activatePortal()
        }
    }
    
    // MARK: - Portal Components
    
    private func portalLayer(layer: Int) -> some View {
        let layerDepth = CGFloat(layer) / CGFloat(config.dimensionalLayers)
        let layerSize = config.coreSize * (1.0 - layerDepth * 0.3)
        let layerOpacity = 0.1 + layerDepth * 0.2
        
        return Circle()
            .fill(
                RadialGradient(
                    colors: [
                        destination.color.opacity(layerOpacity),
                        destination.color.opacity(layerOpacity * 0.3),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: layerSize * 0.3,
                    endRadius: layerSize * 0.8
                )
            )
            .frame(width: layerSize, height: layerSize)
            .scaleEffect(1.0 + dimensionalShift * layerDepth * 0.5)
            .rotation3DEffect(
                .degrees(coreRotation * (1.0 + layerDepth)),
                axis: (x: 0, y: 0, z: 1)
            )
            .blur(radius: layerDepth * 2)
    }
    
    private func energyRing(ring: Int) -> some View {
        let ringSize = config.coreSize * (1.2 + CGFloat(ring) * 0.3)
        let ringOpacity = portalState.energyLevel * (0.8 - Double(ring) * 0.15)
        
        return Circle()
            .stroke(
                AngularGradient(
                    colors: [
                        destination.color.opacity(ringOpacity),
                        destination.color.opacity(ringOpacity * 0.3),
                        Color.clear,
                        destination.color.opacity(ringOpacity * 0.6)
                    ],
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                lineWidth: 2
            )
            .frame(width: ringSize, height: ringSize)
            .rotationEffect(.degrees(coreRotation * config.rotationSpeed * (1.0 + Double(ring) * 0.2)))
            .scaleEffect(1.0 + energyPulse * 0.1)
            .opacity(ringOpacity)
    }
    
    private var portalCore: some View {
        ZStack {
            // Core background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.9),
                            destination.color.opacity(0.8),
                            destination.color.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: config.coreSize * 0.6
                    )
                )
                .frame(width: config.coreSize, height: config.coreSize)
                .scaleEffect(1.0 + energyPulse * 0.2)
            
            // Core icon
            Image(systemName: destination.icon)
                .font(.system(size: config.coreSize * 0.3, weight: .light))
                .foregroundColor(.white)
                .shadow(color: destination.color, radius: 10)
                .scaleEffect(1.0 + energyPulse * 0.1)
                .rotation3DEffect(
                    .degrees(dimensionalShift * 180),
                    axis: (x: 1, y: 1, z: 0)
                )
            
            // Energy pulse overlay
            Circle()
                .stroke(
                    destination.color.opacity(0.6),
                    lineWidth: 3
                )
                .frame(width: config.coreSize, height: config.coreSize)
                .scaleEffect(1.0 + energyPulse * 0.3)
                .opacity(portalState.energyLevel * 0.7)
        }
    }
    
    private var particleField: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.currentOpacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .rotationEffect(.degrees(particle.rotationAngle))
                    .blur(radius: 1)
            }
        }
        .allowsHitTesting(false)
    }
    
    private var portalLabel: some View {
        VStack(spacing: 4) {
            Text(destination.rawValue)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: destination.color, radius: 5)
            
            Text(destination.description)
                .font(.system(size: 8, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .offset(y: config.coreSize * 1.2)
        .opacity(portalState == .active ? 1.0 : 0.6)
    }
    
    // MARK: - Animations
    
    private func startPortalAnimations() {
        // Core rotation
        withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
            coreRotation = 360
        }
        
        // Energy pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            energyPulse = 1.0
        }
        
        // Dimensional shift
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            dimensionalShift = 1.0
        }
        
        // Particle animation timer
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func updatePortalState(active: Bool) {
        withAnimation(.easeInOut(duration: 0.5)) {
            portalState = active ? .active : .dormant
        }
        
        if active {
            generateMoreParticles()
        }
    }
    
    private func activatePortal() {
        portalState = .transitioning
        
        withAnimation(.easeInOut(duration: config.transitionDuration)) {
            dimensionalShift = 2.0
            energyPulse = 2.0
        }
        
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Call activation handler after transition
        DispatchQueue.main.asyncAfter(deadline: .now() + config.transitionDuration * 0.7) {
            onActivate()
        }
        
        // Reset state
        DispatchQueue.main.asyncAfter(deadline: .now() + config.transitionDuration) {
            withAnimation(.easeOut(duration: 0.5)) {
                portalState = .dormant
                dimensionalShift = 0
                energyPulse = 0
            }
        }
    }
    
    // MARK: - Particle System
    
    private func generateParticles() {
        particles = (0..<20).map { _ in
            PortalNavigationSystem.DimensionalParticle(
                position: CGPoint(
                    x: CGFloat.random(in: -config.coreSize...config.coreSize),
                    y: CGFloat.random(in: -config.coreSize...config.coreSize)
                ),
                color: destination.color
            )
        }
    }
    
    private func generateMoreParticles() {
        let newParticles = (0..<10).map { _ in
            PortalNavigationSystem.DimensionalParticle(
                position: CGPoint(x: 0, y: 0),
                color: destination.color
            )
        }
        particles.append(contentsOf: newParticles)
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].age += 1/60
            particles[i].position.x += particles[i].velocity.x * (1/60)
            particles[i].position.y += particles[i].velocity.y * (1/60)
            particles[i].rotationAngle += 2.0
            
            // Apply portal attraction
            let distance = sqrt(
                pow(particles[i].position.x, 2) + pow(particles[i].position.y, 2)
            )
            
            if distance > 0 {
                let attraction = portalState.energyLevel * 20.0 / distance
                particles[i].velocity.x -= particles[i].position.x * attraction * (1/60)
                particles[i].velocity.y -= particles[i].position.y * attraction * (1/60)
            }
        }
        
        // Remove dead particles
        particles = particles.filter { $0.isAlive }
        
        // Add new particles if needed
        if particles.count < 15 && portalState != .dormant {
            generateMoreParticles()
        }
    }
}

// MARK: - Portal Navigation Grid

struct PortalNavigationGrid: View {
    let destinations: [PortalNavigationSystem.PortalDestination]
    let config: PortalNavigationSystem.PortalConfig
    let onNavigate: (PortalNavigationSystem.PortalDestination) -> Void
    
    @State private var activePortal: PortalNavigationSystem.PortalDestination?
    @State private var gridRotation: Double = 0
    
    init(
        destinations: [PortalNavigationSystem.PortalDestination] = PortalNavigationSystem.PortalDestination.allCases,
        config: PortalNavigationSystem.PortalConfig = .standard,
        onNavigate: @escaping (PortalNavigationSystem.PortalDestination) -> Void
    ) {
        self.destinations = destinations
        self.config = config
        self.onNavigate = onNavigate
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background dimensional grid
                dimensionalGrid(geometry: geometry)
                
                // Portal arrangement
                ForEach(Array(destinations.enumerated()), id: \.element) { index, destination in
                    let angle = Double(index) * (2 * .pi / Double(destinations.count))
                    let radius = min(geometry.size.width, geometry.size.height) * 0.3
                    
                    let x = geometry.size.width / 2 + cos(angle + gridRotation) * radius
                    let y = geometry.size.height / 2 + sin(angle + gridRotation) * radius
                    
                    PortalCoreView(
                        destination: destination,
                        config: config,
                        isActive: activePortal == destination
                    ) {
                        navigateToDestination(destination)
                    }
                    .position(x: x, y: y)
                    .scaleEffect(activePortal == destination ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: activePortal)
                }
            }
        }
        .onAppear {
            startGridRotation()
        }
    }
    
    // MARK: - Grid Components
    
    private func dimensionalGrid(geometry: GeometryProxy) -> some View {
        ZStack {
            // Grid lines
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * .pi / 4
                
                Path { path in
                    let startX = geometry.size.width / 2 + cos(angle) * 50
                    let startY = geometry.size.height / 2 + sin(angle) * 50
                    let endX = geometry.size.width / 2 + cos(angle) * 200
                    let endY = geometry.size.height / 2 + sin(angle) * 200
                    
                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addLine(to: CGPoint(x: endX, y: endY))
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            .cyan.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .center,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
                .rotationEffect(.degrees(gridRotation * 10))
            }
            
            // Central nexus
            Circle()
                .stroke(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.5),
                            .cyan.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    ),
                    lineWidth: 2
                )
                .frame(width: 100, height: 100)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .scaleEffect(1.0 + sin(gridRotation * 2) * 0.1)
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToDestination(_ destination: PortalNavigationSystem.PortalDestination) {
        activePortal = destination
        
        // Trigger navigation after portal animation
        DispatchQueue.main.asyncAfter(deadline: .now() + config.transitionDuration) {
            onNavigate(destination)
            activePortal = nil
        }
    }
    
    private func startGridRotation() {
        withAnimation(.linear(duration: 60.0).repeatForever(autoreverses: false)) {
            gridRotation = 2 * .pi
        }
    }
}

// MARK: - Portal Navigation Modifiers

extension View {
    /// Adds portal navigation overlay
    func portalNavigation(
        destinations: [PortalNavigationSystem.PortalDestination] = PortalNavigationSystem.PortalDestination.allCases,
        config: PortalNavigationSystem.PortalConfig = .standard,
        onNavigate: @escaping (PortalNavigationSystem.PortalDestination) -> Void
    ) -> some View {
        self.overlay(
            PortalNavigationGrid(
                destinations: destinations,
                config: config,
                onNavigate: onNavigate
            )
        )
    }
    
    /// Adds dimensional travel transition effect
    func dimensionalTransition(
        isActive: Bool,
        duration: Double = 1.2
    ) -> some View {
        self
            .scaleEffect(isActive ? 0.8 : 1.0)
            .rotation3DEffect(
                .degrees(isActive ? 180 : 0),
                axis: (x: 1, y: 1, z: 0)
            )
            .opacity(isActive ? 0.3 : 1.0)
            .blur(radius: isActive ? 10 : 0)
            .animation(.easeInOut(duration: duration), value: isActive)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        PortalNavigationGrid { destination in
            print("Navigating to: \(destination.rawValue)")
        }
    }
}