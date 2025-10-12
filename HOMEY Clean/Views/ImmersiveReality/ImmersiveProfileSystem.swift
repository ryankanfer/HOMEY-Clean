import SwiftUI
import Combine

// MARK: - Immersive Profile System
struct ImmersiveProfileSystem {
    
    // MARK: - Reality Configuration
    struct RealityConfig {
        let particleDensity: Int
        let consciousnessLevel: Double
        let dimensionalDepth: CGFloat
        let neuralActivity: Double
        let breathingIntensity: CGFloat
        let portalEnergy: Double
        
        static let `default` = RealityConfig(
            particleDensity: 150,
            consciousnessLevel: 0.8,
            dimensionalDepth: 1000,
            neuralActivity: 0.6,
            breathingIntensity: 15,
            portalEnergy: 0.7
        )
        
        static let intense = RealityConfig(
            particleDensity: 300,
            consciousnessLevel: 1.0,
            dimensionalDepth: 800,
            neuralActivity: 0.9,
            breathingIntensity: 25,
            portalEnergy: 1.0
        )
        
        static let subtle = RealityConfig(
            particleDensity: 75,
            consciousnessLevel: 0.5,
            dimensionalDepth: 1500,
            neuralActivity: 0.3,
            breathingIntensity: 8,
            portalEnergy: 0.4
        )
    }
    
    // MARK: - Particle Field System
    static func particleField(config: RealityConfig = .default) -> some View {
        ImmersiveParticleFieldView(config: config)
    }
    
    // MARK: - Quantum Header System
    static func quantumHeader(
        title: String,
        subtitle: String,
        consciousnessLevel: Double = 0.8
    ) -> some View {
        QuantumHeaderView(
            title: title,
            subtitle: subtitle,
            consciousnessLevel: consciousnessLevel
        )
    }
    
    // MARK: - Consciousness Card System
    static func consciousnessCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ConsciousnessCardView(content: content)
    }
    
    // MARK: - Neural Network System
    static func neuralNetwork(
        intensity: Double = 0.6,
        nodes: Int = 20
    ) -> some View {
        NeuralNetworkView(intensity: intensity, nodes: nodes)
    }
}

// MARK: - Particle Field View
private struct ImmersiveParticleFieldView: View {
    let config: ImmersiveProfileSystem.RealityConfig
    
    @State private var particles: [ParticleData] = []
    @State private var breathingPhase: Double = 0
    @State private var driftPhase: Double = 0
    
    private struct ParticleData: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var size: CGFloat
        var opacity: Double
        var hue: Double
        var phase: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Atmospheric gradient base
                RadialGradient(
                    colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.05),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width
                )
                .scaleEffect(1.0 + sin(breathingPhase) * 0.1)
                .animation(.easeInOut(duration: 4), value: breathingPhase)
                
                // Particle layer
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            Color(
                                hue: particle.hue,
                                saturation: 0.8,
                                brightness: 0.9
                            )
                            .opacity(particle.opacity)
                        )
                        .frame(width: particle.size, height: particle.size)
                        .position(
                            x: particle.position.x + sin(driftPhase + particle.phase) * 20,
                            y: particle.position.y + cos(driftPhase + particle.phase * 0.7) * 15
                        )
                        .blur(radius: particle.size * 0.3)
                }
                
                // Neural connection lines
                Canvas { context, size in
                    for i in 0..<min(particles.count, 10) {
                        for j in (i+1)..<min(particles.count, 10) {
                            let particle1 = particles[i]
                            let particle2 = particles[j]
                            
                            let distance = sqrt(
                                pow(particle1.position.x - particle2.position.x, 2) +
                                pow(particle1.position.y - particle2.position.y, 2)
                            )
                            
                            if distance < 150 {
                                let opacity = max(0, 1 - distance / 150) * 0.3
                                
                                context.stroke(
                                    Path { path in
                                        path.move(to: particle1.position)
                                        path.addLine(to: particle2.position)
                                    },
                                    with: .color(.cyan.opacity(opacity)),
                                    lineWidth: 1
                                )
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            generateParticles()
            startAnimations()
        }
    }
    
    private func generateParticles() {
        particles = (0..<config.particleDensity).map { _ in
            ParticleData(
                position: CGPoint(
                    x: Double.random(in: 0...UIScreen.main.bounds.width),
                    y: Double.random(in: 0...UIScreen.main.bounds.height)
                ),
                velocity: CGVector(
                    dx: Double.random(in: -0.5...0.5),
                    dy: Double.random(in: -0.5...0.5)
                ),
                size: Double.random(in: 2...8),
                opacity: Double.random(in: 0.1...0.6),
                hue: Double.random(in: 0.6...0.8), // Blue to purple range
                phase: Double.random(in: 0...2 * .pi)
            )
        }
    }
    
    private func startAnimations() {
        // Breathing animation
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breathingPhase = 2 * .pi
        }
        
        // Drift animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            driftPhase = 2 * .pi
        }
    }
}

// MARK: - Quantum Header View
private struct QuantumHeaderView: View {
    let title: String
    let subtitle: String
    let consciousnessLevel: Double
    
    @State private var morphPhase: Double = 0
    @State private var energyPulse: Double = 0
    @State private var dimensionalShift: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quantum title with morphing effects
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .cyan,
                            .purple,
                            .pink,
                            .blue
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(1.0 + sin(energyPulse) * 0.05)
                .rotation3DEffect(
                    .degrees(sin(morphPhase) * 2),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 1000
                )
                .brightness(sin(energyPulse * 1.5) * 0.1)
            
            // Consciousness subtitle
            Text(subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    Color.white.opacity(0.8)
                )
                .offset(x: sin(morphPhase * 0.7) * 3)
            
            // Neural activity indicator
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            Color.cyan.opacity(
                                0.3 + sin(energyPulse + Double(index) * 0.5) * 0.4
                            )
                        )
                        .frame(width: 6, height: 6)
                        .scaleEffect(
                            1.0 + sin(energyPulse + Double(index) * 0.3) * 0.5
                        )
                }
                
                Text("Neural Activity: \(Int(consciousnessLevel * 100))%")
                    .font(.caption)
                    .foregroundStyle(Color.cyan.opacity(0.8))
            }
        }
        .padding(.vertical, 20)
        .onAppear {
            startQuantumAnimations()
        }
    }
    
    private func startQuantumAnimations() {
        // Morphing animation
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            morphPhase = 2 * .pi
        }
        
        // Energy pulse
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            energyPulse = 2 * .pi
        }
        
        // Dimensional shift
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            dimensionalShift = 10
        }
    }
}

// MARK: - Consciousness Card View
private struct ConsciousnessCardView<Content: View>: View {
    let content: Content
    
    @State private var isHovered: Bool = false
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    @State private var holographicRotation: Double = 0
    @State private var neuralPulse: Double = 0
    @State private var energyField: CGFloat = 0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(24)
            .background(
                ZStack {
                    // Base consciousness layer
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.3),
                                    Color.purple.opacity(0.1),
                                    Color.blue.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: isHovered ? 2 : 0)
                    
                    // Neural activity overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.cyan.opacity(neuralPulse * 0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                    
                    // Holographic border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    .cyan.opacity(0.8),
                                    .purple.opacity(0.8),
                                    .pink.opacity(0.8),
                                    .blue.opacity(0.8),
                                    .cyan.opacity(0.8)
                                ],
                                center: .center,
                                angle: .degrees(holographicRotation)
                            ),
                            lineWidth: isHovered ? 3 : 1
                        )
                }
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .rotation3DEffect(
                .degrees(rotationX),
                axis: (x: 1, y: 0, z: 0),
                perspective: 1000
            )
            .rotation3DEffect(
                .degrees(rotationY),
                axis: (x: 0, y: 1, z: 0),
                perspective: 1000
            )
            .shadow(
                color: Color.cyan.opacity(isHovered ? 0.3 : 0.1),
                radius: isHovered ? 20 : 10,
                x: 0,
                y: isHovered ? 10 : 5
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isHovered)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: rotationX)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: rotationY)
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    // Generate random 3D rotation on hover
                    rotationX = Double.random(in: -15...15)
                    rotationY = Double.random(in: -15...15)
                } else {
                    rotationX = 0
                    rotationY = 0
                }
            }
            .onAppear {
                startConsciousnessAnimations()
            }
    }
    
    private func startConsciousnessAnimations() {
        // Holographic border rotation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            holographicRotation = 360
        }
        
        // Neural pulse
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            neuralPulse = 1.0
        }
        
        // Energy field expansion
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            energyField = 20
        }
    }
}

// MARK: - Neural Network View
private struct NeuralNetworkView: View {
    let intensity: Double
    let nodes: Int
    
    @State private var nodePositions: [CGPoint] = []
    @State private var connectionPulses: [Double] = []
    @State private var networkActivity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Draw neural connections
                for i in 0..<nodePositions.count {
                    for j in (i+1)..<nodePositions.count {
                        let node1 = nodePositions[i]
                        let node2 = nodePositions[j]
                        
                        let distance = sqrt(
                            pow(node1.x - node2.x, 2) +
                            pow(node1.y - node2.y, 2)
                        )
                        
                        if distance < 100 {
                            let pulseIndex = (i + j) % connectionPulses.count
                            let opacity = connectionPulses[pulseIndex] * intensity * 0.5
                            
                            context.stroke(
                                Path { path in
                                    path.move(to: node1)
                                    path.addLine(to: node2)
                                },
                                with: .color(.cyan.opacity(opacity)),
                                lineWidth: 2
                            )
                        }
                    }
                }
                
                // Draw neural nodes
                for (index, position) in nodePositions.enumerated() {
                    let pulseIndex = index % connectionPulses.count
                    let nodeSize = 4 + connectionPulses[pulseIndex] * 6
                    let nodeOpacity = 0.6 + connectionPulses[pulseIndex] * 0.4
                    
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: position.x - nodeSize/2,
                            y: position.y - nodeSize/2,
                            width: nodeSize,
                            height: nodeSize
                        )),
                        with: .color(.cyan.opacity(nodeOpacity))
                    )
                }
            }
        }
        .onAppear {
            generateNeuralNetwork()
            startNeuralActivity()
        }
    }
    
    private func generateNeuralNetwork() {
        nodePositions = (0..<nodes).map { _ in
            CGPoint(
                x: Double.random(in: 50...UIScreen.main.bounds.width - 50),
                y: Double.random(in: 50...UIScreen.main.bounds.height - 50)
            )
        }
        
        connectionPulses = (0..<nodes).map { _ in
            Double.random(in: 0...1)
        }
    }
    
    private func startNeuralActivity() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                for i in 0..<connectionPulses.count {
                    connectionPulses[i] = Double.random(in: 0...1) * intensity
                }
            }
        }
    }
}

// MARK: - Extension for View Modifiers
extension View {
    func immersiveReality(config: ImmersiveProfileSystem.RealityConfig = .default) -> some View {
        ZStack {
            ImmersiveProfileSystem.particleField(config: config)
                .ignoresSafeArea()
            
            self
        }
    }
    
    func consciousnessCard() -> some View {
        ImmersiveProfileSystem.consciousnessCard {
            self
        }
    }
    
    func quantumHeader(title: String, subtitle: String, consciousnessLevel: Double = 0.8) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ImmersiveProfileSystem.quantumHeader(
                title: title,
                subtitle: subtitle,
                consciousnessLevel: consciousnessLevel
            )
            
            self
        }
    }
    
    func neuralOverlay(intensity: Double = 0.6, nodes: Int = 20) -> some View {
        ZStack {
            self
            
            ImmersiveProfileSystem.neuralNetwork(intensity: intensity, nodes: nodes)
                .allowsHitTesting(false)
        }
    }
}