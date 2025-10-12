import SwiftUI

// MARK: - Quantum Configuration
struct QuantumConfig {
    let breathingRate: Double
    let energyPulseRate: Double
    let morphingIntensity: Double
    let holographicIntensity: Double
    let dimensionalDepth: Double
    
    static let standard = QuantumConfig(
        breathingRate: 3.0,
        energyPulseRate: 2.5,
        morphingIntensity: 0.3,
        holographicIntensity: 0.4,
        dimensionalDepth: 0.2
    )
    
    static let intense = QuantumConfig(
        breathingRate: 2.0,
        energyPulseRate: 1.8,
        morphingIntensity: 0.5,
        holographicIntensity: 0.7,
        dimensionalDepth: 0.4
    )
}

// MARK: - Quantum Header
struct QuantumHeader: View {
    let title: String
    let subtitle: String
    let config: QuantumConfig
    @Binding var consciousnessLevel: Double
    @Binding var dimensionalPhase: Double
    
    @State private var titleGradientRotation: Double = 0
    @State private var headerMorph: CGFloat = 0
    @State private var brightnessPulse: Double = 0
    @State private var quantumShimmer: Double = 0
    @State private var dimensionalShift: CGFloat = 0
    
    // Missing animation state variables
    @State private var morphingPhase: Double = 0
    @State private var dimensionalRotation: Double = 0
    @State private var energyPulse: Double = 0
    @State private var holographicShift: Double = 0
    @State private var quantumFluctuation: Double = 0
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Quantum field background
                quantumFieldBackground
                
                // Dimensional container
                dimensionalContainer(geometry: geometry)
                
                // Holographic overlay
                holographicOverlay
                
                // Energy field indicators
                energyFieldIndicators
            }
        }
        .frame(height: 200)
        .clipped()
        .onAppear {
            startQuantumAnimations()
        }
    }
    
    // MARK: - Quantum Field Background
    
    private var quantumFieldBackground: some View {
        ZStack {
            // Primary quantum gradient
            RadialGradient(
                colors: [
                    .cyan.opacity(0.3),
                    .purple.opacity(0.2),
                    .blue.opacity(0.1),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.3),
                startRadius: 20,
                endRadius: 200
            )
            .scaleEffect(1.0 + sin(morphingPhase) * config.morphingIntensity * 0.2)
            .rotationEffect(.degrees(dimensionalRotation * 0.3))
            
            // Secondary energy field
            LinearGradient(
                colors: [
                    Color.clear,
                    .cyan.opacity(0.1),
                    .purple.opacity(0.15),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.5 + sin(energyPulse) * 0.3)
            
            // Quantum fluctuation overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.05),
                            Color.clear,
                            .cyan.opacity(0.03)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: sin(quantumFluctuation) * 100)
                .opacity(0.6)
        }
    }
    
    // MARK: - Dimensional Container
    
    private func dimensionalContainer(geometry: GeometryProxy) -> some View {
        VStack(spacing: 12) {
            // Quantum title
            quantumTitle
            
            // Consciousness subtitle
            consciousnessSubtitle
            
            // Status indicators
            statusIndicators
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .perspective3D(
            config: .default,
            rotationX: sin(dimensionalRotation * 0.01) * config.dimensionalDepth * 0.5,
            rotationY: cos(dimensionalRotation * 0.008) * config.dimensionalDepth * 0.3
        )
        .scaleEffect(1.0 + sin(morphingPhase * 0.7) * 0.05)
    }
    
    // MARK: - Quantum Title
    
    private var quantumTitle: some View {
        HStack {
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            .cyan.opacity(0.9),
                            .purple.opacity(0.8),
                            .white
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .brightness(0.1 + sin(energyPulse) * 0.2)
                .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 0)
                .scaleEffect(1.0 + sin(consciousnessLevel) * 0.03)
            
            Spacer()
            
            // Consciousness indicator
            consciousnessIndicator
        }
    }
    
    // MARK: - Consciousness Subtitle
    
    private var consciousnessSubtitle: some View {
        HStack {
            Text(subtitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.8),
                            .cyan.opacity(0.6),
                            .white.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(0.7 + sin(morphingPhase * 0.5) * 0.2)
            
            Spacer()
        }
    }
    
    // MARK: - Consciousness Indicator
    
    private var consciousnessIndicator: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            .cyan,
                            .purple,
                            .pink,
                            .cyan
                        ],
                        center: .center,
                        startAngle: .degrees(holographicShift),
                        endAngle: .degrees(holographicShift + 360)
                    ),
                    lineWidth: 3
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(holographicShift))
            
            // Inner core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.8),
                            .cyan.opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 15
                    )
                )
                .frame(width: 20, height: 20)
                .scaleEffect(1.0 + sin(energyPulse * 1.5) * 0.3)
                .brightness(0.2 + sin(consciousnessLevel * 2) * 0.3)
            
            // Quantum dots
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 2, height: 2)
                    .offset(y: -25)
                    .rotationEffect(.degrees(Double(i) * 60 + holographicShift * 0.5))
                    .opacity(0.5 + sin(energyPulse + Double(i) * 0.5) * 0.5)
            }
        }
    }
    
    // MARK: - Status Indicators
    
    private var statusIndicators: some View {
        HStack(spacing: 20) {
            // Neural activity indicator
            neuralActivityIndicator
            
            // Energy level indicator
            energyLevelIndicator
            
            // Dimensional stability indicator
            dimensionalStabilityIndicator
            
            Spacer()
        }
    }
    
    private var neuralActivityIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.green.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(1.0 + sin(energyPulse * 3) * 0.5)
                .shadow(color: .green, radius: 4)
            
            Text("Neural")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var energyLevelIndicator: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 20, height: 4)
                .cornerRadius(2)
                .scaleEffect(x: 0.5 + sin(consciousnessLevel) * 0.5, y: 1.0)
            
            Text("Energy")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var dimensionalStabilityIndicator: some View {
        HStack(spacing: 6) {
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Rectangle()
                        .fill(.blue.opacity(0.6))
                        .frame(width: 2, height: 8)
                        .offset(x: CGFloat(i - 1) * 4)
                        .scaleEffect(y: 0.3 + sin(morphingPhase + Double(i) * 0.7) * 0.7)
                }
            }
            
            Text("Stable")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // MARK: - Holographic Overlay
    
    private var holographicOverlay: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        .cyan.opacity(0.1),
                        Color.clear,
                        .purple.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .opacity(config.holographicIntensity * 0.5)
            .offset(x: sin(holographicShift * 0.01) * 50)
            .blendMode(.screen)
    }
    
    // MARK: - Energy Field Indicators
    
    private var energyFieldIndicators: some View {
        ZStack {
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
                            endRadius: 10
                        )
                    )
                    .frame(width: 6, height: 6)
                    .position(cornerPosition(for: corner))
                    .scaleEffect(1.0 + sin(energyPulse + Double(corner) * 0.5) * 0.5)
                    .opacity(0.6 + sin(consciousnessLevel + Double(corner) * 0.3) * 0.4)
            }
            
            // Energy flow lines
            Path { path in
                path.move(to: CGPoint(x: 20, y: 20))
                path.addLine(to: CGPoint(x: UIScreen.main.bounds.width - 20, y: 20))
                path.move(to: CGPoint(x: 20, y: 180))
                path.addLine(to: CGPoint(x: UIScreen.main.bounds.width - 20, y: 180))
            }
            .stroke(
                LinearGradient(
                    colors: [
                        Color.clear,
                        .cyan.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 1
            )
            .opacity(0.4 + sin(energyPulse * 0.7) * 0.3)
        }
    }
    
    // MARK: - Helper Methods
    
    private func cornerPosition(for corner: Int) -> CGPoint {
        let width = UIScreen.main.bounds.width
        let height: CGFloat = 200
        
        switch corner {
        case 0: return CGPoint(x: 20, y: 20)
        case 1: return CGPoint(x: width - 20, y: 20)
        case 2: return CGPoint(x: 20, y: height - 20)
        case 3: return CGPoint(x: width - 20, y: height - 20)
        default: return CGPoint(x: width/2, y: height/2)
        }
    }
    
    private func startQuantumAnimations() {
        // Morphing animation
        withAnimation(.easeInOut(duration: config.breathingRate).repeatForever(autoreverses: true)) {
            morphingPhase = 2 * .pi
        }
        
        // Dimensional rotation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            dimensionalRotation = 360
        }
        
        // Energy pulse
        withAnimation(.easeInOut(duration: config.energyPulseRate).repeatForever(autoreverses: true)) {
            energyPulse = 2 * .pi
        }
        
        // Holographic shift
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            holographicShift = 360
        }
        
        // Consciousness level
        withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
            consciousnessLevel = 2 * .pi
        }
        
        // Quantum fluctuation
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            quantumFluctuation = 2 * .pi
        }
    }
}

// MARK: - Quantum Header Variants

struct QuantumProfileHeader: View {
    let userName: String
    let userStatus: String
    @State private var consciousnessLevel: Double = 0
    @State private var dimensionalPhase: Double = 0
    
    var body: some View {
        QuantumHeader(
            title: userName,
            subtitle: userStatus,
            config: .standard,
            consciousnessLevel: $consciousnessLevel,
            dimensionalPhase: $dimensionalPhase
        )
    }
}

struct QuantumWelcomeHeader: View {
    @State private var consciousnessLevel: Double = 0
    @State private var dimensionalPhase: Double = 0
    
    var body: some View {
        QuantumHeader(
            title: "HOMEY",
            subtitle: "Welcome to digital consciousness",
            config: .intense,
            consciousnessLevel: $consciousnessLevel,
            dimensionalPhase: $dimensionalPhase
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 30) {
            QuantumWelcomeHeader()
            
            QuantumProfileHeader(
                userName: "Ryan Kanfer",
                userStatus: "Neural pathways active"
            )
        }
    }
}