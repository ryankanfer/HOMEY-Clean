import SwiftUI

// MARK: - Consciousness Profile Card
struct ConsciousnessProfileCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let hasNewContent: Bool
    let action: () -> Void
    
    @State private var isHovered: Bool = false
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    @State private var holographicRotation: Double = 0
    @State private var neuralPulse: Double = 0
    @State private var energyField: CGFloat = 0
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Quantum icon container
                ZStack {
                    // Energy field background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30 + energyField
                            )
                        )
                        .frame(width: 60 + energyField, height: 60 + energyField)
                    
                    // Icon core
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: icon)
                                .font(.title2.bold())
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [color, color.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(1.0 + sin(neuralPulse) * 0.1)
                        )
                }
                
                // Content with neural activity
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.headline.bold())
                            .foregroundStyle(Color.white)
                        
                        if hasNewContent {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.red, .pink],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 4
                                    )
                                )
                                .frame(width: 8, height: 8)
                                .scaleEffect(1.0 + sin(neuralPulse * 2) * 0.3)
                        }
                        
                        Spacer()
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                // Quantum chevron
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(isHovered ? 1.2 : 1.0)
                    .offset(x: isHovered ? 5 : 0)
            }
            .padding(20)
            .background(
                ZStack {
                    // Base consciousness layer
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.4),
                                    color.opacity(0.05),
                                    Color.purple.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: isHovered ? 1 : 0)
                    
                    // Neural activity overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(neuralPulse * 0.08),
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
                                    color.opacity(0.6),
                                    .cyan.opacity(0.4),
                                    .purple.opacity(0.4),
                                    color.opacity(0.6)
                                ],
                                center: .center,
                                angle: .degrees(holographicRotation)
                            ),
                            lineWidth: isHovered ? 2 : 1
                        )
                }
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
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
                color: color.opacity(isHovered ? 0.3 : 0.1),
                radius: isHovered ? 15 : 8,
                x: 0,
                y: isHovered ? 8 : 4
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isHovered)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: rotationX)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: rotationY)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                // Generate subtle 3D rotation on hover
                rotationX = Double.random(in: -5...5)
                rotationY = Double.random(in: -5...5)
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
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            holographicRotation = 360
        }
        
        // Neural pulse
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            neuralPulse = 1.0
        }
        
        // Energy field expansion
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            energyField = 10
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ConsciousnessProfileCard(
                title: "Neural Insights",
                description: "AI-powered insights about your consciousness journey",
                icon: "brain.head.profile",
                color: .cyan,
                hasNewContent: true
            ) {
                print("Neural Insights tapped")
            }
            
            ConsciousnessProfileCard(
                title: "Quantum Settings",
                description: "Configure your reality interface preferences",
                icon: "gearshape.2",
                color: .purple,
                hasNewContent: false
            ) {
                print("Quantum Settings tapped")
            }
        }
        .padding()
    }
}