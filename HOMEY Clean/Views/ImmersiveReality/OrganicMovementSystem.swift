import SwiftUI

// MARK: - Organic Movement System

/// Physics-based floating animations with breathing effects and natural drift patterns
struct OrganicMovementSystem {
    
    // MARK: - Movement Configuration
    struct MovementConfig {
        let floatAmplitude: CGFloat
        let floatFrequency: Double
        let breathingIntensity: Double
        let breathingCycle: Double
        let driftRange: CGFloat
        let driftSpeed: Double
        let turbulenceStrength: Double
        let dampingFactor: Double
        let springTension: Double
        let gravityStrength: Double
        
        static let standard = MovementConfig(
            floatAmplitude: 15.0,
            floatFrequency: 0.8,
            breathingIntensity: 0.15,
            breathingCycle: 4.0,
            driftRange: 30.0,
            driftSpeed: 0.3,
            turbulenceStrength: 0.5,
            dampingFactor: 0.95,
            springTension: 0.1,
            gravityStrength: 0.02
        )
        
        static let intense = MovementConfig(
            floatAmplitude: 25.0,
            floatFrequency: 0.6,
            breathingIntensity: 0.25,
            breathingCycle: 3.0,
            driftRange: 50.0,
            driftSpeed: 0.5,
            turbulenceStrength: 0.8,
            dampingFactor: 0.92,
            springTension: 0.15,
            gravityStrength: 0.03
        )
        
        static let subtle = MovementConfig(
            floatAmplitude: 8.0,
            floatFrequency: 1.2,
            breathingIntensity: 0.08,
            breathingCycle: 6.0,
            driftRange: 15.0,
            driftSpeed: 0.2,
            turbulenceStrength: 0.3,
            dampingFactor: 0.98,
            springTension: 0.05,
            gravityStrength: 0.01
        )
    }
    
    // MARK: - Physics State
    struct PhysicsState {
        var position: CGPoint = .zero
        var velocity: CGPoint = .zero
        var acceleration: CGPoint = .zero
        var restPosition: CGPoint = .zero
        var mass: Double = 1.0
        var drag: Double = 0.98
        var elasticity: Double = 0.8
        
        mutating func applyForce(_ force: CGPoint) {
            acceleration.x += force.x / CGFloat(mass)
            acceleration.y += force.y / CGFloat(mass)
        }
        
        mutating func update(deltaTime: Double) {
            velocity.x += acceleration.x * CGFloat(deltaTime)
            velocity.y += acceleration.y * CGFloat(deltaTime)
            
            velocity.x *= CGFloat(drag)
            velocity.y *= CGFloat(drag)
            
            position.x += velocity.x * CGFloat(deltaTime)
            position.y += velocity.y * CGFloat(deltaTime)
            
            acceleration = .zero
        }
    }
    
    // MARK: - Organic Oscillator
    class OrganicOscillator: ObservableObject {
        @Published var currentOffset: CGPoint = .zero
        @Published var breathingScale: Double = 1.0
        @Published var rotationAngle: Double = 0
        
        private var physicsState = PhysicsState()
        private var timeAccumulator: Double = 0
        private var noiseOffset: (x: Double, y: Double) = (0, 0)
        private var breathingPhase: Double = 0
        private var rotationPhase: Double = 0
        
        let config: MovementConfig
        let uniqueId: UUID
        
        init(config: MovementConfig = .standard) {
            self.config = config
            self.uniqueId = UUID()
            self.noiseOffset = (
                x: Double.random(in: 0...1000),
                y: Double.random(in: 0...1000)
            )
            startAnimation()
        }
        
        private func startAnimation() {
            Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
                self.updatePhysics()
            }
        }
        
        private func updatePhysics() {
            let deltaTime = 1.0 / 60.0
            timeAccumulator += deltaTime
            
            // Generate organic forces
            let floatingForce = generateFloatingForce()
            let driftForce = generateDriftForce()
            let turbulenceForce = generateTurbulenceForce()
            let springForce = generateSpringForce()
            let gravityForce = generateGravityForce()
            
            // Apply all forces
            physicsState.applyForce(floatingForce)
            physicsState.applyForce(driftForce)
            physicsState.applyForce(turbulenceForce)
            physicsState.applyForce(springForce)
            physicsState.applyForce(gravityForce)
            
            // Update physics
            physicsState.update(deltaTime: deltaTime)
            
            // Update breathing
            breathingPhase += deltaTime * (2 * .pi / config.breathingCycle)
            let breathingOffset = sin(breathingPhase) * config.breathingIntensity
            breathingScale = 1.0 + breathingOffset
            
            // Update rotation
            rotationPhase += deltaTime * config.floatFrequency * 0.5
            rotationAngle = sin(rotationPhase) * 5.0 // Small rotation oscillation
            
            // Apply damping to prevent excessive movement
            physicsState.position.x *= CGFloat(config.dampingFactor)
            physicsState.position.y *= CGFloat(config.dampingFactor)
            
            // Update published values
            DispatchQueue.main.async {
                self.currentOffset = self.physicsState.position
            }
        }
        
        private func generateFloatingForce() -> CGPoint {
            let floatX = sin(timeAccumulator * config.floatFrequency * 2 * .pi) * config.floatAmplitude
            let floatY = cos(timeAccumulator * config.floatFrequency * 1.7 * .pi) * config.floatAmplitude * 0.7
            
            return CGPoint(
                x: CGFloat(floatX * 0.1),
                y: CGFloat(floatY * 0.1)
            )
        }
        
        private func generateDriftForce() -> CGPoint {
            // Perlin-like noise for organic drift
            let driftX = perlinNoise(
                x: timeAccumulator * config.driftSpeed + noiseOffset.x,
                y: 0
            ) * config.driftRange
            
            let driftY = perlinNoise(
                x: 0,
                y: timeAccumulator * config.driftSpeed + noiseOffset.y
            ) * config.driftRange
            
            return CGPoint(
                x: CGFloat(driftX * 0.05),
                y: CGFloat(driftY * 0.05)
            )
        }
        
        private func generateTurbulenceForce() -> CGPoint {
            let turbulenceX = perlinNoise(
                x: timeAccumulator * 2.0 + noiseOffset.x,
                y: timeAccumulator * 1.5 + noiseOffset.y
            ) * config.turbulenceStrength
            
            let turbulenceY = perlinNoise(
                x: timeAccumulator * 1.8 + noiseOffset.x,
                y: timeAccumulator * 2.2 + noiseOffset.y
            ) * config.turbulenceStrength
            
            return CGPoint(
                x: CGFloat(turbulenceX * 0.02),
                y: CGFloat(turbulenceY * 0.02)
            )
        }
        
        private func generateSpringForce() -> CGPoint {
            let springX = (physicsState.restPosition.x - physicsState.position.x) * CGFloat(config.springTension)
            let springY = (physicsState.restPosition.y - physicsState.position.y) * CGFloat(config.springTension)
            
            return CGPoint(x: springX, y: springY)
        }
        
        private func generateGravityForce() -> CGPoint {
            return CGPoint(x: 0, y: CGFloat(config.gravityStrength))
        }
        
        // Simplified Perlin noise implementation
        private func perlinNoise(x: Double, y: Double) -> Double {
            let xi = Int(floor(x)) & 255
            let yi = Int(floor(y)) & 255
            
            let xf = x - floor(x)
            let yf = y - floor(y)
            
            let u = fade(xf)
            let v = fade(yf)
            
            let aa = hash(xi) + yi
            let ab = hash(xi) + yi + 1
            let ba = hash(xi + 1) + yi
            let bb = hash(xi + 1) + yi + 1
            
            let x1 = lerp(grad(hash(aa), xf, yf), grad(hash(ba), xf - 1, yf), u)
            let x2 = lerp(grad(hash(ab), xf, yf - 1), grad(hash(bb), xf - 1, yf - 1), u)
            
            return lerp(x1, x2, v)
        }
        
        private func fade(_ t: Double) -> Double {
            return t * t * t * (t * (t * 6 - 15) + 10)
        }
        
        private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
            return a + t * (b - a)
        }
        
        private func grad(_ hash: Int, _ x: Double, _ y: Double) -> Double {
            let h = hash & 15
            let u = h < 8 ? x : y
            let v = h < 4 ? y : (h == 12 || h == 14 ? x : 0)
            return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
        }
        
        private func hash(_ x: Int) -> Int {
            var h = x
            h = ((h >> 16) ^ h) * 0x45d9f3b
            h = ((h >> 16) ^ h) * 0x45d9f3b
            h = (h >> 16) ^ h
            return h & 255
        }
        
        func applyExternalForce(_ force: CGPoint) {
            physicsState.applyForce(force)
        }
        
        func setRestPosition(_ position: CGPoint) {
            physicsState.restPosition = position
        }
    }
}

// MARK: - Organic Movement View

struct OrganicMovementView<Content: View>: View {
    let content: Content
    let config: OrganicMovementSystem.MovementConfig
    
    @StateObject private var oscillator: OrganicMovementSystem.OrganicOscillator
    @State private var interactionForce: CGPoint = .zero
    
    init(
        config: OrganicMovementSystem.MovementConfig = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.config = config
        self._oscillator = StateObject(wrappedValue: OrganicMovementSystem.OrganicOscillator(config: config))
    }
    
    var body: some View {
        content
            .offset(x: oscillator.currentOffset.x, y: oscillator.currentOffset.y)
            .scaleEffect(oscillator.breathingScale)
            .rotationEffect(.degrees(oscillator.rotationAngle))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let force = CGPoint(
                            x: (value.location.x - value.startLocation.x) * 0.1,
                            y: (value.location.y - value.startLocation.y) * 0.1
                        )
                        oscillator.applyExternalForce(force)
                    }
                    .onEnded { _ in
                        // Apply a small random force when interaction ends
                        let randomForce = CGPoint(
                            x: CGFloat(Double.random(in: -5...5)),
                            y: CGFloat(Double.random(in: -5...5))
                        )
                        oscillator.applyExternalForce(randomForce)
                    }
            )
    }
}

// MARK: - Breathing Container

struct BreathingContainer<Content: View>: View {
    let content: Content
    let intensity: Double
    let cycle: Double
    
    @State private var breathingPhase: Double = 0
    @State private var breathingScale: Double = 1.0
    @State private var breathingOpacity: Double = 1.0
    
    init(
        intensity: Double = 0.1,
        cycle: Double = 4.0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.intensity = intensity
        self.cycle = cycle
    }
    
    var body: some View {
        content
            .scaleEffect(breathingScale)
            .opacity(breathingOpacity)
            .onAppear {
                startBreathing()
            }
    }
    
    private func startBreathing() {
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            breathingPhase += (1/60) * (2 * .pi / cycle)
            
            let breathingOffset = sin(breathingPhase) * intensity
            breathingScale = 1.0 + breathingOffset
            breathingOpacity = 1.0 + breathingOffset * 0.3
        }
    }
}

// MARK: - Floating Field

struct FloatingField<Content: View>: View {
    let content: Content
    let particleCount: Int
    let config: OrganicMovementSystem.MovementConfig
    
    @State private var floatingElements: [FloatingElement] = []
    
    struct FloatingElement: Identifiable {
        let id = UUID()
        var oscillator: OrganicMovementSystem.OrganicOscillator
        let size: CGFloat
        let opacity: Double
        let color: Color
        
        init(config: OrganicMovementSystem.MovementConfig) {
            self.oscillator = OrganicMovementSystem.OrganicOscillator(config: config)
            self.size = CGFloat.random(in: 2...8)
            self.opacity = Double.random(in: 0.2...0.6)
            self.color = [Color.cyan, Color.purple, Color.blue, Color.pink].randomElement() ?? .cyan
        }
    }
    
    init(
        particleCount: Int = 20,
        config: OrganicMovementSystem.MovementConfig = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.particleCount = particleCount
        self.config = config
    }
    
    var body: some View {
        ZStack {
            // Floating particles
            ForEach(floatingElements) { element in
                Circle()
                    .fill(element.color.opacity(element.opacity))
                    .frame(width: element.size, height: element.size)
                    .offset(x: element.oscillator.currentOffset.x, y: element.oscillator.currentOffset.y)
                    .scaleEffect(element.oscillator.breathingScale)
                    .blur(radius: 1)
            }
            
            // Main content
            content
        }
        .onAppear {
            generateFloatingElements()
        }
    }
    
    private func generateFloatingElements() {
        floatingElements = (0..<particleCount).map { _ in
            FloatingElement(config: config)
        }
        
        // Set random rest positions
        for i in floatingElements.indices {
            let randomPosition = CGPoint(
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -200...200)
            )
            floatingElements[i].oscillator.setRestPosition(randomPosition)
        }
    }
}

// MARK: - Organic Movement Modifiers

extension View {
    /// Adds organic floating movement with physics-based animation
    func organicMovement(
        config: OrganicMovementSystem.MovementConfig = .standard
    ) -> some View {
        OrganicMovementView(config: config) {
            self
        }
    }
    
    /// Adds breathing animation effect
    func breathing(
        intensity: Double = 0.1,
        cycle: Double = 4.0
    ) -> some View {
        BreathingContainer(intensity: intensity, cycle: cycle) {
            self
        }
    }
    
    /// Adds floating particle field background
    func floatingField(
        particleCount: Int = 20,
        config: OrganicMovementSystem.MovementConfig = .standard
    ) -> some View {
        FloatingField(particleCount: particleCount, config: config) {
            self
        }
    }
    
    /// Combines multiple organic movement effects
    func livingInterface(
        movementConfig: OrganicMovementSystem.MovementConfig = .standard,
        breathingIntensity: Double = 0.08,
        breathingCycle: Double = 5.0,
        particleCount: Int = 15
    ) -> some View {
        self
            .organicMovement(config: movementConfig)
            .breathing(intensity: breathingIntensity, cycle: breathingCycle)
            .floatingField(particleCount: particleCount, config: movementConfig)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            // Organic movement example
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 150, height: 100)
                .organicMovement()
            
            // Breathing example
            Circle()
                .fill(.blue.opacity(0.6))
                .frame(width: 80, height: 80)
                .breathing(intensity: 0.2, cycle: 3.0)
            
            // Combined living interface
            RoundedRectangle(cornerRadius: 15)
                .fill(.pink.opacity(0.3))
                .frame(width: 120, height: 80)
                .livingInterface()
        }
        .floatingField(particleCount: 30)
    }
}