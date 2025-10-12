import SwiftUI

// MARK: - Particle Field System for Living Digital Consciousness

/// Particle system that creates breathing, drifting gradients and atmospheric effects
struct ParticleFieldSystem {
    
    // MARK: - Particle Configuration
    struct ParticleConfig {
        let particleCount: Int
        let particleSize: CGFloat
        let speed: Double
        let opacity: Double
        let colors: [Color]
        let breathingIntensity: Double
        let driftRange: CGFloat
        
        static let ambient = ParticleConfig(
            particleCount: 50,
            particleSize: 3.0,
            speed: 2.0,
            opacity: 0.3,
            colors: [.cyan.opacity(0.6), .purple.opacity(0.4), .pink.opacity(0.5)],
            breathingIntensity: 0.8,
            driftRange: 100
        )
        
        static let intense = ParticleConfig(
            particleCount: 80,
            particleSize: 4.0,
            speed: 1.5,
            opacity: 0.5,
            colors: [.blue.opacity(0.7), .purple.opacity(0.6), .cyan.opacity(0.8)],
            breathingIntensity: 1.2,
            driftRange: 150
        )
        
        static let subtle = ParticleConfig(
            particleCount: 30,
            particleSize: 2.0,
            speed: 3.0,
            opacity: 0.2,
            colors: [.white.opacity(0.3), .blue.opacity(0.2), .purple.opacity(0.3)],
            breathingIntensity: 0.5,
            driftRange: 80
        )
    }
    
    // MARK: - Particle Data
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var size: CGFloat
        var opacity: Double
        var color: Color
        var phase: Double
        var breathingOffset: Double
        
        init(in bounds: CGRect, config: ParticleConfig) {
            self.position = CGPoint(
                x: CGFloat.random(in: 0...bounds.width),
                y: CGFloat.random(in: 0...bounds.height)
            )
            self.velocity = CGVector(
                dx: CGFloat.random(in: -1...1) * CGFloat(config.speed),
                dy: CGFloat.random(in: -1...1) * CGFloat(config.speed)
            )
            self.size = config.particleSize * CGFloat.random(in: 0.5...1.5)
            self.opacity = config.opacity * Double.random(in: 0.3...1.0)
            self.color = config.colors.randomElement() ?? .white
            self.phase = Double.random(in: 0...2 * .pi)
            self.breathingOffset = Double.random(in: 0...2 * .pi)
        }
    }
}

// MARK: - Particle Field Background View

struct ParticleFieldBackground: View {
    let config: ParticleFieldSystem.ParticleConfig
    
    @State private var particles: [ParticleFieldSystem.Particle] = []
    @State private var animationTime: Double = 0
    @State private var breathingPhase: Double = 0
    
    init(config: ParticleFieldSystem.ParticleConfig = .ambient) {
        self.config = config
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base atmospheric gradient
                atmosphericGradient
                
                // Particle field canvas
                Canvas { context, size in
                    drawParticles(context: context, size: size)
                }
                .onAppear {
                    initializeParticles(in: geometry.frame(in: .local))
                    startAnimation()
                }
                .onChange(of: geometry.size) { _, newSize in
                    initializeParticles(in: CGRect(origin: .zero, size: newSize))
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Atmospheric Gradient
    
    private var atmosphericGradient: some View {
        ZStack {
            // Primary breathing gradient
            RadialGradient(
                colors: [
                    config.colors[0].opacity(0.1),
                    config.colors[1].opacity(0.05),
                    Color.clear
                ],
                center: UnitPoint(x: 0.3, y: 0.2),
                startRadius: 50,
                endRadius: 300
            )
            .scaleEffect(1.0 + sin(breathingPhase) * 0.2)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: breathingPhase)
            
            // Secondary breathing gradient
            RadialGradient(
                colors: [
                    config.colors[2].opacity(0.08),
                    config.colors[0].opacity(0.03),
                    Color.clear
                ],
                center: UnitPoint(x: 0.7, y: 0.8),
                startRadius: 80,
                endRadius: 400
            )
            .scaleEffect(1.0 + cos(breathingPhase * 0.7) * 0.15)
            .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: breathingPhase)
            
            // Ambient overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    config.colors[1].opacity(0.02),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.5 + sin(breathingPhase * 0.5) * 0.3)
            .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: breathingPhase)
        }
        .onAppear {
            withAnimation {
                breathingPhase = .pi
            }
        }
    }
    
    // MARK: - Particle System Methods
    
    private func initializeParticles(in bounds: CGRect) {
        particles = (0..<config.particleCount).map { _ in
            ParticleFieldSystem.Particle(in: bounds, config: config)
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            animationTime += 1/60
            updateParticles()
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            // Update position with drift
            particles[i].position.x += particles[i].velocity.dx
            particles[i].position.y += particles[i].velocity.dy
            
            // Add breathing effect to size and opacity
            let breathingFactor = sin(animationTime * config.breathingIntensity + particles[i].breathingOffset)
            particles[i].size = CGFloat(config.particleSize) * (1.0 + CGFloat(breathingFactor) * 0.3)
            particles[i].opacity = config.opacity * (0.5 + breathingFactor * 0.5)
            
            // Wrap around screen edges
            if particles[i].position.x < -10 {
                particles[i].position.x = UIScreen.main.bounds.width + 10
            } else if particles[i].position.x > UIScreen.main.bounds.width + 10 {
                particles[i].position.x = -10
            }
            
            if particles[i].position.y < -10 {
                particles[i].position.y = UIScreen.main.bounds.height + 10
            } else if particles[i].position.y > UIScreen.main.bounds.height + 10 {
                particles[i].position.y = -10
            }
            
            // Subtle velocity changes for organic movement
            if Int(animationTime * 60) % 120 == 0 {
                particles[i].velocity.dx += CGFloat.random(in: -0.1...0.1)
                particles[i].velocity.dy += CGFloat.random(in: -0.1...0.1)
                
                // Clamp velocity
                particles[i].velocity.dx = max(-config.speed, min(config.speed, particles[i].velocity.dx))
                particles[i].velocity.dy = max(-config.speed, min(config.speed, particles[i].velocity.dy))
            }
        }
    }
    
    private func drawParticles(context: GraphicsContext, size: CGSize) {
        for particle in particles {
            let rect = CGRect(
                x: particle.position.x - particle.size/2,
                y: particle.position.y - particle.size/2,
                width: particle.size,
                height: particle.size
            )
            
            // Draw glow effect first (larger, more transparent)
            let glowRect = CGRect(
                x: particle.position.x - particle.size,
                y: particle.position.y - particle.size,
                width: particle.size * 2,
                height: particle.size * 2
            )
            context.fill(
                Path(ellipseIn: glowRect),
                with: .color(particle.color.opacity(particle.opacity * 0.2))
            )
            
            // Draw main particle
            context.fill(
                Path(ellipseIn: rect),
                with: .color(particle.color.opacity(particle.opacity))
            )
        }
    }
}

// MARK: - Neural Network Background

struct NeuralNetworkBackground: View {
    @State private var connectionOpacity: Double = 0.3
    @State private var pulsePhase: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawNeuralNetwork(context: context, size: size)
            }
        }
        .onAppear {
            startNeuralAnimation()
        }
        .ignoresSafeArea()
    }
    
    private func startNeuralAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            connectionOpacity = 0.8
        }
        
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            pulsePhase = 2 * .pi
        }
    }
    
    private func drawNeuralNetwork(context: GraphicsContext, size: CGSize) {
        let nodeCount = 12
        let nodes = (0..<nodeCount).map { i in
            CGPoint(
                x: CGFloat.random(in: size.width * 0.1...size.width * 0.9),
                y: CGFloat.random(in: size.height * 0.1...size.height * 0.9)
            )
        }
        
        // Draw connections
        for i in 0..<nodes.count {
            for j in (i+1)..<nodes.count {
                let distance = sqrt(pow(nodes[i].x - nodes[j].x, 2) + pow(nodes[i].y - nodes[j].y, 2))
                if distance < 200 {
                    let opacity = connectionOpacity * (1.0 - distance / 200)
                    
                    var path = Path()
                    path.move(to: nodes[i])
                    path.addLine(to: nodes[j])
                    
                    context.stroke(
                        path,
                        with: .color(.cyan.opacity(opacity)),
                        lineWidth: 1.0
                    )
                    
                    // Add pulse effect
                    let pulsePosition = (sin(pulsePhase + Double(i) * 0.5) + 1) / 2
                    let pulsePoint = CGPoint(
                        x: nodes[i].x + (nodes[j].x - nodes[i].x) * pulsePosition,
                        y: nodes[i].y + (nodes[j].y - nodes[i].y) * pulsePosition
                    )
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: pulsePoint.x - 2, y: pulsePoint.y - 2, width: 4, height: 4)),
                        with: .color(.white.opacity(0.8))
                    )
                }
            }
        }
        
        // Draw nodes
        for node in nodes {
            context.fill(
                Path(ellipseIn: CGRect(x: node.x - 3, y: node.y - 3, width: 6, height: 6)),
                with: .color(.cyan.opacity(0.8))
            )
        }
    }
}

// MARK: - Consciousness Atmosphere

struct ConsciousnessAtmosphere: View {
    let intensity: Double
    
    @State private var wavePhase: Double = 0
    @State private var energyPulse: Double = 0
    
    init(intensity: Double = 1.0) {
        self.intensity = intensity
    }
    
    var body: some View {
        ZStack {
            // Base particle field
            ParticleFieldBackground(config: .ambient)
            
            // Neural network overlay
            NeuralNetworkBackground()
                .opacity(0.4 * intensity)
            
            // Energy waves
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .cyan.opacity(0.3),
                                .purple.opacity(0.2),
                                .clear
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .scaleEffect(1.0 + sin(wavePhase + Double(i) * 0.7) * 0.3)
                    .opacity(0.5 + sin(energyPulse + Double(i) * 0.5) * 0.3)
                    .animation(
                        .easeInOut(duration: 4.0 + Double(i))
                        .repeatForever(autoreverses: true),
                        value: wavePhase
                    )
            }
        }
        .onAppear {
            withAnimation {
                wavePhase = 2 * .pi
                energyPulse = 2 * .pi
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Adds particle field background
    func particleFieldBackground(
        config: ParticleFieldSystem.ParticleConfig = .ambient
    ) -> some View {
        self.background(
            ParticleFieldBackground(config: config)
        )
    }
    
    /// Adds neural network background
    func neuralNetworkBackground() -> some View {
        self.background(
            NeuralNetworkBackground()
        )
    }
    
    /// Adds consciousness atmosphere
    func consciousnessAtmosphere(intensity: Double = 1.0) -> some View {
        self.background(
            ConsciousnessAtmosphere(intensity: intensity)
        )
    }
}