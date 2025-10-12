import SwiftUI

// MARK: - Consciousness Card Configuration

struct ConsciousnessCardConfig {
    let hoverIntensity: Double
    let holographicIntensity: Double
    let neuralActivity: Double
    let dimensionalDepth: CGFloat
    let energyPulseRate: Double
    let awarenessLevel: Double
    
    static let standard = ConsciousnessCardConfig(
        hoverIntensity: 1.0,
        holographicIntensity: 0.8,
        neuralActivity: 1.0,
        dimensionalDepth: 25,
        energyPulseRate: 2.0,
        awarenessLevel: 0.7
    )
    
    static let intense = ConsciousnessCardConfig(
        hoverIntensity: 1.5,
        holographicIntensity: 1.2,
        neuralActivity: 1.5,
        dimensionalDepth: 35,
        energyPulseRate: 1.5,
        awarenessLevel: 1.0
    )
    
    static let subtle = ConsciousnessCardConfig(
        hoverIntensity: 0.6,
        holographicIntensity: 0.5,
        neuralActivity: 0.6,
        dimensionalDepth: 15,
        energyPulseRate: 3.0,
        awarenessLevel: 0.4
    )
}

// MARK: - Consciousness Card

struct ConsciousnessCard<Content: View>: View {
    
    // MARK: - Properties
    let content: Content
    let config: ConsciousnessCardConfig
    let onTap: (() -> Void)?
    
    @State private var isHovered: Bool = false
    @State private var hoverPosition: CGPoint = .zero
    @State private var neuralPulse: Double = 0
    @State private var holographicRotation: Double = 0
    @State private var energyField: Double = 0
    @State private var awarenessGlow: Double = 0
    @State private var dimensionalShift: Double = 0
    
    // MARK: - Initialization
    
    init(
        config: ConsciousnessCardConfig = .standard,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.config = config
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Neural background field
                neuralBackgroundField
                
                // Main card container
                cardContainer(geometry: geometry)
                
                // Holographic border system
                holographicBorderSystem(geometry: geometry)
                
                // Energy field indicators
                energyFieldIndicators(geometry: geometry)
                
                // Awareness glow overlay
                awarenessGlowOverlay
            }
        }
        .onAppear {
            startConsciousnessAnimations()
        }
        .onTapGesture {
            onTap?()
            triggerNeuralResponse()
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    hoverPosition = value.location
                    if !isHovered {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isHovered = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        isHovered = false
                        hoverPosition = .zero
                    }
                }
        )
    }
    
    // MARK: - Neural Background Field
    
    private var neuralBackgroundField: some View {
        ZStack {
            // Primary neural gradient
            RadialGradient(
                colors: [
                    .cyan.opacity(0.1 * config.neuralActivity),
                    .purple.opacity(0.05 * config.neuralActivity),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 150
            )
            .scaleEffect(1.0 + sin(neuralPulse) * 0.1)
            
            // Secondary awareness field
            LinearGradient(
                colors: [
                    Color.clear,
                    .blue.opacity(0.03 * config.awarenessLevel),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.5 + sin(awarenessGlow) * 0.3)
        }
    }
    
    // MARK: - Card Container
    
    private func cardContainer(geometry: GeometryProxy) -> some View {
        content
            .padding(20)
            .background(
                ZStack {
                    // Base material
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .opacity(0.8)
                    
                    // Consciousness overlay
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .cyan.opacity(0.1),
                                    .purple.opacity(0.05),
                                    .blue.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(config.awarenessLevel)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .perspective3D(
                rotationX: isHovered ? calculateRotationX(geometry: geometry) : 0,
                rotationY: isHovered ? calculateRotationY(geometry: geometry) : 0
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .shadow(
                color: isHovered ? .cyan.opacity(0.3) : .black.opacity(0.1),
                radius: isHovered ? 20 : 5,
                x: 0,
                y: isHovered ? 10 : 2
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isHovered)
    }
    
    // MARK: - Holographic Border System
    
    private func holographicBorderSystem(geometry: GeometryProxy) -> some View {
        ZStack {
            // Outer holographic ring
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    AngularGradient(
                        colors: [
                            .cyan.opacity(config.holographicIntensity),
                            .purple.opacity(config.holographicIntensity * 0.8),
                            .pink.opacity(config.holographicIntensity * 0.6),
                            .blue.opacity(config.holographicIntensity * 0.9),
                            .cyan.opacity(config.holographicIntensity)
                        ],
                        center: .center,
                        startAngle: .degrees(holographicRotation),
                        endAngle: .degrees(holographicRotation + 360)
                    ),
                    lineWidth: isHovered ? 3 : 1
                )
                .opacity(isHovered ? 1.0 : 0.3)
                .scaleEffect(isHovered ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isHovered)
            
            // Inner energy border
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.2),
                            .cyan.opacity(0.4),
                            .white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .opacity(0.5 + sin(energyField) * 0.3)
            
            // Corner energy nodes
            ForEach(0..<4, id: \.self) { corner in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .cyan.opacity(0.8),
                                .purple.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: 8
                        )
                    )
                    .frame(width: isHovered ? 8 : 4, height: isHovered ? 8 : 4)
                    .position(cornerPosition(for: corner, in: geometry))
                    .scaleEffect(1.0 + sin(neuralPulse + Double(corner) * 0.5) * 0.5)
                    .opacity(0.6 + sin(awarenessGlow + Double(corner) * 0.3) * 0.4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovered)
            }
        }
    }
    
    // MARK: - Energy Field Indicators
    
    private func energyFieldIndicators(geometry: GeometryProxy) -> some View {
        ZStack {
            // Neural pathway lines
            if isHovered {
                ForEach(0..<6, id: \.self) { i in
                    Path { path in
                        let startPoint = CGPoint(
                            x: geometry.size.width * 0.1,
                            y: geometry.size.height * (0.2 + Double(i) * 0.12)
                        )
                        let endPoint = CGPoint(
                            x: geometry.size.width * 0.9,
                            y: geometry.size.height * (0.2 + Double(i) * 0.12)
                        )
                        
                        path.move(to: startPoint)
                        path.addLine(to: endPoint)
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                .cyan.opacity(0.4),
                                .purple.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
                    .opacity(0.3 + sin(neuralPulse + Double(i) * 0.3) * 0.4)
                    .animation(.easeInOut(duration: 0.5).delay(Double(i) * 0.1), value: isHovered)
                }
            }
            
            // Energy pulse indicators
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        .cyan.opacity(0.4),
                        lineWidth: 1
                    )
                    .frame(width: 20 + CGFloat(i) * 15, height: 20 + CGFloat(i) * 15)
                    .scaleEffect(1.0 + sin(energyField + Double(i) * 0.7) * 0.3)
                    .opacity(isHovered ? 0.6 : 0.2)
                    .animation(.easeInOut(duration: 1.0 + Double(i) * 0.3).repeatForever(autoreverses: true), value: energyField)
            }
        }
    }
    
    // MARK: - Awareness Glow Overlay
    
    private var awarenessGlowOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                RadialGradient(
                    colors: [
                        .white.opacity(isHovered ? 0.1 : 0.02),
                        Color.clear
                    ],
                    center: UnitPoint(
                        x: hoverPosition.x / UIScreen.main.bounds.width,
                        y: hoverPosition.y / 200
                    ),
                    startRadius: 10,
                    endRadius: 100
                )
            )
            .opacity(config.awarenessLevel)
            .blendMode(.screen)
    }
    
    // MARK: - Helper Methods
    
    private func calculateRotationX(geometry: GeometryProxy) -> Double {
        let centerY = geometry.size.height / 2
        let offset = (hoverPosition.y - centerY) / centerY
        return Double(offset) * config.hoverIntensity * 15
    }
    
    private func calculateRotationY(geometry: GeometryProxy) -> Double {
        let centerX = geometry.size.width / 2
        let offset = (hoverPosition.x - centerX) / centerX
        return Double(-offset) * config.hoverIntensity * 15
    }
    
    private func cornerPosition(for corner: Int, in geometry: GeometryProxy) -> CGPoint {
        let width = geometry.size.width
        let height = geometry.size.height
        
        switch corner {
        case 0: return CGPoint(x: 8, y: 8)
        case 1: return CGPoint(x: width - 8, y: 8)
        case 2: return CGPoint(x: 8, y: height - 8)
        case 3: return CGPoint(x: width - 8, y: height - 8)
        default: return CGPoint(x: width/2, y: height/2)
        }
    }
    
    private func startConsciousnessAnimations() {
        // Neural pulse animation
        withAnimation(.easeInOut(duration: config.energyPulseRate).repeatForever(autoreverses: true)) {
            neuralPulse = 2 * .pi
        }
        
        // Holographic rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            holographicRotation = 360
        }
        
        // Energy field animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            energyField = 2 * .pi
        }
        
        // Awareness glow animation
        withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
            awarenessGlow = 2 * .pi
        }
        
        // Dimensional shift animation
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            dimensionalShift = 2 * .pi
        }
    }
    
    private func triggerNeuralResponse() {
        // Trigger intense neural activity on tap
        withAnimation(.easeOut(duration: 0.8)) {
            neuralPulse += .pi
            energyField += .pi / 2
            awarenessGlow += .pi / 3
        }
    }
}

// MARK: - Specialized Consciousness Cards

struct ImmersiveProfileSectionCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    let content: Content
    let onTap: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.onTap = onTap
        self.content = content()
    }
    
    var body: some View {
        ConsciousnessCard(config: .standard, onTap: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and title
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Content
                content
            }
        }
    }
}

struct JourneyProgressCard: View {
    let progress: Double
    let currentMilestone: String
    let nextMilestone: String
    
    var body: some View {
        ConsciousnessCard(config: .intense) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Neural Journey")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Consciousness Evolution")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.title3.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                // Progress visualization
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current: \(currentMilestone)")
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("Next: \(nextMilestone)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Neural progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.quaternary)
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 6)
                                .cornerRadius(3)
                                .shadow(color: .cyan.opacity(0.5), radius: 4)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
    }
}

struct QuickActionsCard: View {
    let actions: [QuickAction]
    
    struct QuickAction {
        let title: String
        let icon: String
        let action: () -> Void
    }
    
    var body: some View {
        ConsciousnessCard(config: .subtle) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Quick Actions")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(actions.indices, id: \.self) { index in
                        Button(action: actions[index].action) {
                            VStack(spacing: 8) {
                                Image(systemName: actions[index].icon)
                                    .font(.title3)
                                    .foregroundColor(.cyan)
                                
                                Text(actions[index].title)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.quaternary.opacity(0.5))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 20) {
                JourneyProgressCard(
                    progress: 0.65,
                    currentMilestone: "Digital Awakening",
                    nextMilestone: "Neural Integration"
                )
                
                ImmersiveProfileSectionCard(
                    title: "Personal Data",
                    subtitle: "Neural patterns & preferences",
                    icon: "person.crop.circle"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Consciousness Level: Advanced")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Neural pathways optimized for real estate analysis and human connection patterns.")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                
                QuickActionsCard(actions: [
                    QuickActionsCard.QuickAction(title: "Scan Reality", icon: "viewfinder", action: {}),
                    QuickActionsCard.QuickAction(title: "Neural Sync", icon: "brain", action: {}),
                    QuickActionsCard.QuickAction(title: "Portal Access", icon: "circle.hexagongrid", action: {}),
                    QuickActionsCard.QuickAction(title: "Consciousness", icon: "eye", action: {})
                ])
            }
            .padding()
        }
    }
}