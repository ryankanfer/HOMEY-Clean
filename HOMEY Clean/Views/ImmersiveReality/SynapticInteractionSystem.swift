import SwiftUI

// MARK: - Synaptic Interaction System

/// Neural network firing states with light pulses and energy fields
struct SynapticInteractionSystem {
    
    // MARK: - Synaptic Configuration
    struct SynapticConfig {
        let firingRate: Double
        let pulseIntensity: Double
        let networkDensity: Int
        let energyFieldRadius: CGFloat
        let connectionThreshold: CGFloat
        let neuralResponseTime: Double
        
        static let standard = SynapticConfig(
            firingRate: 2.0,
            pulseIntensity: 0.8,
            networkDensity: 15,
            energyFieldRadius: 120,
            connectionThreshold: 150,
            neuralResponseTime: 0.3
        )
        
        static let intense = SynapticConfig(
            firingRate: 1.2,
            pulseIntensity: 1.2,
            networkDensity: 25,
            energyFieldRadius: 180,
            connectionThreshold: 200,
            neuralResponseTime: 0.2
        )
        
        static let subtle = SynapticConfig(
            firingRate: 3.5,
            pulseIntensity: 0.5,
            networkDensity: 10,
            energyFieldRadius: 80,
            connectionThreshold: 100,
            neuralResponseTime: 0.5
        )
    }
    
    // MARK: - Neural Node
    struct NeuralNode: Identifiable {
        let id = UUID()
        var position: CGPoint
        var isActive: Bool = false
        var activationLevel: Double = 0.0
        var lastFired: Date = Date()
        var connections: [UUID] = []
        var nodeType: NodeType
        var pulsePhase: Double = 0.0
        
        enum NodeType {
            case sensory, processing, memory, output
            
            var color: Color {
                switch self {
                case .sensory: return .cyan
                case .processing: return .purple
                case .memory: return .blue
                case .output: return .pink
                }
            }
            
            var size: CGFloat {
                switch self {
                case .sensory: return 8
                case .processing: return 6
                case .memory: return 10
                case .output: return 7
                }
            }
        }
        
        init(position: CGPoint, type: NodeType) {
            self.position = position
            self.nodeType = type
            self.pulsePhase = Double.random(in: 0...2 * .pi)
        }
    }
    
    // MARK: - Synaptic Connection
    struct SynapticConnection: Identifiable {
        let id = UUID()
        let fromNodeId: UUID
        let toNodeId: UUID
        var strength: Double
        var isActive: Bool = false
        var pulsePosition: Double = 0.0
        var lastPulse: Date = Date()
        
        init(from: UUID, to: UUID, strength: Double = 1.0) {
            self.fromNodeId = from
            self.toNodeId = to
            self.strength = strength
        }
    }
    
    // MARK: - Neural Pulse
    struct NeuralPulse: Identifiable {
        let id = UUID()
        var position: CGPoint
        var intensity: Double
        var radius: CGFloat
        var creationTime: Date
        var lifespan: Double
        
        init(at position: CGPoint, intensity: Double = 1.0, lifespan: Double = 2.0) {
            self.position = position
            self.intensity = intensity
            self.radius = 5
            self.creationTime = Date()
            self.lifespan = lifespan
        }
        
        var age: Double {
            Date().timeIntervalSince(creationTime)
        }
        
        var isAlive: Bool {
            age < lifespan
        }
        
        var opacity: Double {
            max(0, 1.0 - (age / lifespan))
        }
    }
}

// MARK: - Synaptic Network View

struct SynapticNetworkView: View {
    let config: SynapticInteractionSystem.SynapticConfig
    
    @State private var nodes: [SynapticInteractionSystem.NeuralNode] = []
    @State private var connections: [SynapticInteractionSystem.SynapticConnection] = []
    @State private var pulses: [SynapticInteractionSystem.NeuralPulse] = []
    @State private var networkTime: Double = 0
    @State private var interactionPoint: CGPoint = .zero
    @State private var energyField: Double = 0
    
    init(config: SynapticInteractionSystem.SynapticConfig = .standard) {
        self.config = config
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Neural network canvas
                Canvas { context, size in
                    drawNeuralNetwork(context: context, size: size)
                }
                .onAppear {
                    initializeNetwork(in: geometry.frame(in: .local))
                    startNeuralActivity()
                }
                .onChange(of: geometry.size) { _, newSize in
                    initializeNetwork(in: CGRect(origin: .zero, size: newSize))
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            interactionPoint = value.location
                            triggerNeuralResponse(at: value.location)
                        }
                )
                
                // Energy field overlay
                energyFieldOverlay(geometry: geometry)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Network Initialization
    
    private func initializeNetwork(in bounds: CGRect) {
        // Create neural nodes
        nodes = (0..<config.networkDensity).map { i in
            let nodeType: SynapticInteractionSystem.NeuralNode.NodeType
            let random = Double.random(in: 0...1)
            
            switch random {
            case 0..<0.3: nodeType = .sensory
            case 0.3..<0.6: nodeType = .processing
            case 0.6..<0.8: nodeType = .memory
            default: nodeType = .output
            }
            
            return SynapticInteractionSystem.NeuralNode(
                position: CGPoint(
                    x: CGFloat.random(in: bounds.width * 0.1...bounds.width * 0.9),
                    y: CGFloat.random(in: bounds.height * 0.1...bounds.height * 0.9)
                ),
                type: nodeType
            )
        }
        
        // Create connections between nearby nodes
        connections = []
        for i in 0..<nodes.count {
            for j in (i+1)..<nodes.count {
                let distance = sqrt(
                    pow(nodes[i].position.x - nodes[j].position.x, 2) +
                    pow(nodes[i].position.y - nodes[j].position.y, 2)
                )
                
                if distance < config.connectionThreshold {
                    let strength = 1.0 - (distance / config.connectionThreshold)
                    connections.append(
                        SynapticInteractionSystem.SynapticConnection(
                            from: nodes[i].id,
                            to: nodes[j].id,
                            strength: strength
                        )
                    )
                    
                    nodes[i].connections.append(nodes[j].id)
                    nodes[j].connections.append(nodes[i].id)
                }
            }
        }
    }
    
    // MARK: - Neural Activity
    
    private func startNeuralActivity() {
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            networkTime += 1/60
            updateNeuralActivity()
            updatePulses()
            
            // Random neural firing
            if Double.random(in: 0...1) < 0.02 {
                fireRandomNeuron()
            }
        }
        
        // Energy field animation
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            energyField = 2 * .pi
        }
    }
    
    private func updateNeuralActivity() {
        for i in nodes.indices {
            // Update pulse phase
            nodes[i].pulsePhase += 0.1
            
            // Decay activation
            if nodes[i].isActive {
                nodes[i].activationLevel = max(0, nodes[i].activationLevel - 0.02)
                if nodes[i].activationLevel < 0.1 {
                    nodes[i].isActive = false
                }
            }
            
            // Spontaneous firing based on node type
            let firingProbability: Double
            switch nodes[i].nodeType {
            case .sensory: firingProbability = 0.005
            case .processing: firingProbability = 0.003
            case .memory: firingProbability = 0.002
            case .output: firingProbability = 0.004
            }
            
            if Double.random(in: 0...1) < firingProbability {
                fireNeuron(at: i)
            }
        }
        
        // Update connections
        for i in connections.indices {
            if connections[i].isActive {
                connections[i].pulsePosition += 0.05
                if connections[i].pulsePosition >= 1.0 {
                    connections[i].isActive = false
                    connections[i].pulsePosition = 0.0
                    
                    // Activate target neuron
                    if let targetIndex = nodes.firstIndex(where: { $0.id == connections[i].toNodeId }) {
                        fireNeuron(at: targetIndex)
                    }
                }
            }
        }
    }
    
    private func updatePulses() {
        pulses = pulses.filter { $0.isAlive }
        
        for i in pulses.indices {
            pulses[i].radius += 2.0
        }
    }
    
    private func fireNeuron(at index: Int) {
        guard index < nodes.count else { return }
        
        nodes[index].isActive = true
        nodes[index].activationLevel = 1.0
        nodes[index].lastFired = Date()
        
        // Create neural pulse
        pulses.append(
            SynapticInteractionSystem.NeuralPulse(
                at: nodes[index].position,
                intensity: config.pulseIntensity
            )
        )
        
        // Activate outgoing connections
        for connection in connections.indices {
            if connections[connection].fromNodeId == nodes[index].id {
                connections[connection].isActive = true
                connections[connection].pulsePosition = 0.0
                connections[connection].lastPulse = Date()
            }
        }
    }
    
    private func fireRandomNeuron() {
        if !nodes.isEmpty {
            let randomIndex = Int.random(in: 0..<nodes.count)
            fireNeuron(at: randomIndex)
        }
    }
    
    private func triggerNeuralResponse(at point: CGPoint) {
        // Find nearby neurons and activate them
        for i in nodes.indices {
            let distance = sqrt(
                pow(nodes[i].position.x - point.x, 2) +
                pow(nodes[i].position.y - point.y, 2)
            )
            
            if distance < config.energyFieldRadius {
                let delay = distance / config.energyFieldRadius * config.neuralResponseTime
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    fireNeuron(at: i)
                }
            }
        }
        
        // Create interaction pulse
        pulses.append(
            SynapticInteractionSystem.NeuralPulse(
                at: point,
                intensity: config.pulseIntensity * 1.5,
                lifespan: 3.0
            )
        )
    }
    
    // MARK: - Drawing
    
    private func drawNeuralNetwork(context: GraphicsContext, size: CGSize) {
        // Draw connections
        for connection in connections {
            guard let fromNode = nodes.first(where: { $0.id == connection.fromNodeId }),
                  let toNode = nodes.first(where: { $0.id == connection.toNodeId }) else { continue }
            
            var path = Path()
            path.move(to: fromNode.position)
            path.addLine(to: toNode.position)
            
            let opacity = connection.isActive ? connection.strength * 0.8 : connection.strength * 0.2
            
            context.stroke(
                path,
                with: .color(.cyan.opacity(opacity)),
                lineWidth: connection.isActive ? 2.0 : 1.0
            )
            
            // Draw pulse along connection
            if connection.isActive {
                let pulseX = fromNode.position.x + (toNode.position.x - fromNode.position.x) * connection.pulsePosition
                let pulseY = fromNode.position.y + (toNode.position.y - fromNode.position.y) * connection.pulsePosition
                
                context.fill(
                    Path(ellipseIn: CGRect(x: pulseX - 3, y: pulseY - 3, width: 6, height: 6)),
                    with: .color(.white.opacity(0.9))
                )
                
                // Glow effect
                context.drawLayer(content: { context in
                    context.addFilter(.blur(radius: 2))
                    context.fill(
                        Path(ellipseIn: CGRect(x: pulseX - 5, y: pulseY - 5, width: 10, height: 10)),
                        with: .color(.cyan.opacity(0.5))
                    )
                })
            }
        }
        
        // Draw nodes
        for node in nodes {
            let size = node.nodeType.size * (node.isActive ? 1.5 : 1.0)
            let rect = CGRect(
                x: node.position.x - size/2,
                y: node.position.y - size/2,
                width: size,
                height: size
            )
            
            // Node core
            context.fill(
                Path(ellipseIn: rect),
                with: .color(node.nodeType.color.opacity(node.isActive ? 1.0 : 0.6))
            )
            
            // Activation glow
            if node.isActive {
                context.drawLayer(content: { context in
                    context.addFilter(.blur(radius: 4))
                    context.fill(
                        Path(ellipseIn: rect.insetBy(dx: -2, dy: -2)),
                        with: .color(node.nodeType.color.opacity(node.activationLevel * 0.5))
                    )
                })
            }
            
            // Pulse ring
            if node.isActive {
                let pulseSize = size * (1.0 + sin(node.pulsePhase) * 0.5)
                let pulseRect = CGRect(
                    x: node.position.x - pulseSize/2,
                    y: node.position.y - pulseSize/2,
                    width: pulseSize,
                    height: pulseSize
                )
                
                context.stroke(
                    Path(ellipseIn: pulseRect),
                    with: .color(node.nodeType.color.opacity(0.4)),
                    lineWidth: 1
                )
            }
        }
        
        // Draw neural pulses
        for pulse in pulses {
            let rect = CGRect(
                x: pulse.position.x - pulse.radius/2,
                y: pulse.position.y - pulse.radius/2,
                width: pulse.radius,
                height: pulse.radius
            )
            
            context.fill(
                Path(ellipseIn: rect),
                with: .color(.white.opacity(pulse.opacity * pulse.intensity))
            )
            
            // Expanding ring
            context.stroke(
                Path(ellipseIn: rect.insetBy(dx: -5, dy: -5)),
                with: .color(.cyan.opacity(pulse.opacity * 0.3)),
                lineWidth: 2
            )
        }
    }
    
    // MARK: - Energy Field Overlay
    
    private func energyFieldOverlay(geometry: GeometryProxy) -> some View {
        ZStack {
            // Interaction energy field
            if interactionPoint != .zero {
                Circle()
                    .stroke(
                        RadialGradient(
                            colors: [
                                .cyan.opacity(0.6),
                                .purple.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: config.energyFieldRadius
                        ),
                        lineWidth: 2
                    )
                    .frame(width: config.energyFieldRadius * 2, height: config.energyFieldRadius * 2)
                    .position(interactionPoint)
                    .scaleEffect(1.0 + sin(energyField) * 0.2)
                    .opacity(0.7)
            }
            
            // Ambient energy waves
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        .cyan.opacity(0.1),
                        lineWidth: 1
                    )
                    .frame(
                        width: 100 + CGFloat(i) * 50,
                        height: 100 + CGFloat(i) * 50
                    )
                    .scaleEffect(1.0 + sin(energyField + Double(i) * 0.7) * 0.3)
                    .opacity(0.3 + sin(networkTime + Double(i) * 0.5) * 0.2)
                    .position(
                        x: geometry.size.width * (0.2 + Double(i) * 0.3),
                        y: geometry.size.height * (0.3 + Double(i) * 0.2)
                    )
            }
        }
    }
}

// MARK: - Synaptic Interaction Modifiers

extension View {
    /// Adds synaptic interaction system overlay
    func synapticInteractions(
        config: SynapticInteractionSystem.SynapticConfig = .standard
    ) -> some View {
        self.overlay(
            SynapticNetworkView(config: config)
                .allowsHitTesting(false)
        )
    }
    
    /// Adds neural response to tap gestures
    func neuralResponse(
        intensity: Double = 1.0,
        onActivation: @escaping (CGPoint) -> Void = { _ in }
    ) -> some View {
        self.onTapGesture { location in
            onActivation(location)
            
            // Visual feedback
            withAnimation(.easeOut(duration: 0.8)) {
                // Trigger neural pulse animation
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        SynapticNetworkView(config: .standard)
        
        VStack {
            Spacer()
            
            Text("Touch anywhere to trigger neural response")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding()
        }
    }
}