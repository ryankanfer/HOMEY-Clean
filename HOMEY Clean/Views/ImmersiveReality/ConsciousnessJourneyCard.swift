import SwiftUI

// MARK: - Consciousness Journey Card
struct ConsciousnessJourneyCard: View {
    let progress: Double
    let title: String
    let description: String
    let inspirationalText: String
    
    @State private var neuralActivity: Double = 0
    @State private var energyFlow: Double = 0
    @State private var consciousnessRipple: CGFloat = 0
    @State private var quantumParticles: [QuantumParticle] = []
    @State private var holographicRotation: Double = 0
    @State private var dimensionalPulse: Double = 0
    
    private struct QuantumParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        var scale: CGFloat
        var color: Color
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Neural activity header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("\(Int(progress * 100))% of your consciousness journey complete")
                        .font(.caption.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                
                // Consciousness level visualization
                ZStack {
                    // Outer energy ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    .cyan.opacity(0.3),
                                    .purple.opacity(0.5),
                                    .pink.opacity(0.4),
                                    .cyan.opacity(0.3)
                                ],
                                center: .center,
                                angle: .degrees(holographicRotation)
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 60, height: 60)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    // Center consciousness indicator
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.8),
                                    .cyan.opacity(0.6),
                                    .purple.opacity(0.4)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: 30, height: 30)
                        .scaleEffect(1.0 + sin(dimensionalPulse) * 0.1)
                        .overlay(
                            Text("\(Int(progress * 100))")
                                .font(.caption.bold())
                                .foregroundColor(.black)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // Description with neural effects
            VStack(alignment: .leading, spacing: 16) {
                Text(description)
                    .font(.body)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .opacity(0.7 + neuralActivity * 0.3)
                
                // Inspirational quantum text
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(1.0 + sin(energyFlow) * 0.2)
                    
                    Text(inspirationalText)
                        .font(.caption.italic())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.yellow.opacity(0.7),
                                    Color.white.opacity(0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(
            ZStack {
                // Base consciousness layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.6),
                                Color.cyan.opacity(0.08),
                                Color.purple.opacity(0.05),
                                Color.black.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Neural activity overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.cyan.opacity(neuralActivity * 0.1),
                                Color.purple.opacity(neuralActivity * 0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                
                // Quantum particles
                ForEach(quantumParticles) { particle in
                    Circle()
                        .fill(particle.color.opacity(particle.opacity))
                        .frame(width: 2, height: 2)
                        .scaleEffect(particle.scale)
                        .position(x: particle.x, y: particle.y)
                }
                
                // Consciousness ripple effect
                Circle()
                    .stroke(
                        RadialGradient(
                            colors: [
                                .cyan.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: consciousnessRipple
                        ),
                        lineWidth: 2
                    )
                    .frame(width: consciousnessRipple * 2, height: consciousnessRipple * 2)
                    .opacity(1.0 - consciousnessRipple / 100)
                
                // Holographic border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        AngularGradient(
                            colors: [
                                .cyan.opacity(0.4),
                                .purple.opacity(0.3),
                                .pink.opacity(0.2),
                                .cyan.opacity(0.4)
                            ],
                            center: .center,
                            angle: .degrees(holographicRotation)
                        ),
                        lineWidth: 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(
            color: .cyan.opacity(0.2),
            radius: 15,
            x: 0,
            y: 8
        )
        .onAppear {
            startConsciousnessAnimations()
            generateQuantumParticles()
        }
    }
    
    private func startConsciousnessAnimations() {
        // Neural activity pulse
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            neuralActivity = 1.0
        }
        
        // Energy flow
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            energyFlow = 2 * .pi
        }
        
        // Consciousness ripple
        withAnimation(.easeOut(duration: 4).repeatForever()) {
            consciousnessRipple = 100
        }
        
        // Holographic rotation
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            holographicRotation = 360
        }
        
        // Dimensional pulse
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            dimensionalPulse = 2 * .pi
        }
    }
    
    private func generateQuantumParticles() {
        quantumParticles = (0..<15).map { _ in
            QuantumParticle(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 50...200),
                opacity: Double.random(in: 0.2...0.8),
                scale: CGFloat.random(in: 0.5...1.5),
                color: [.cyan, .purple, .pink, .white].randomElement() ?? .cyan
            )
        }
        
        // Animate particles
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2)) {
                for i in quantumParticles.indices {
                    quantumParticles[i].x += CGFloat.random(in: -2...2)
                    quantumParticles[i].y += CGFloat.random(in: -2...2)
                    quantumParticles[i].opacity = Double.random(in: 0.1...0.9)
                    quantumParticles[i].scale = CGFloat.random(in: 0.3...1.8)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ConsciousnessJourneyCard(
            progress: 0.65,
            title: "Finding Your Perfect Match",
            description: "Every great love story starts with a single glance. Let's discover what makes your heart sing and find your perfect dimensional companion.",
            inspirationalText: "The excitement of endless possibilities awaits you."
        )
        .padding()
    }
}