import SwiftUI

struct MilestoneCelebrationView: View {
    let milestone: String
    let isVisible: Bool
    let onComplete: () -> Void
    
    @State private var celebrationScale: Double = 0.1
    @State private var particleExplosion: Bool = false
    @State private var holographicRotation: Double = 0
    @State private var quantumRipple: Double = 0
    @State private var neuralBurst: Double = 0
    @State private var dimensionalShift: Double = 0
    @State private var celebrationOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dimensional backdrop
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCelebration()
                }
            
            // Quantum particle explosion
            if particleExplosion {
                ForEach(0..<20, id: \.self) { index in
                    QuantumParticle(
                        delay: Double(index) * 0.1,
                        color: celebrationColors[index % celebrationColors.count]
                    )
                }
            }
            
            // Main celebration content
            VStack(spacing: 32) {
                // Quantum achievement icon
                ZStack {
                    // Energy rings
                    ForEach(0..<3) { ring in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.cyan.opacity(0.8),
                                        Color.purple.opacity(0.6),
                                        Color.cyan.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 120 + CGFloat(ring * 30))
                            .scaleEffect(quantumRipple + Double(ring) * 0.2)
                            .opacity(0.7 - Double(ring) * 0.2)
                    }
                    
                    // Central achievement symbol
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.cyan.opacity(0.8),
                                        Color.purple.opacity(0.6),
                                        Color.black.opacity(0.3)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .scaleEffect(neuralBurst)
                    }
                }
                .rotation3DEffect(
                    .degrees(holographicRotation),
                    axis: (x: 0, y: 1, z: 0)
                )
                
                // Milestone text with quantum effects
                VStack(spacing: 16) {
                    Text("Quantum Achievement Unlocked!")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(milestone)
                        .font(.title2)
                        .foregroundColor(.cyan)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("Your consciousness has expanded to new dimensions")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Quantum continue button
                Button(action: dismissCelebration) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.title3)
                        
                        Text("Continue Journey")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        ZStack {
                            // Base layer
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.cyan.opacity(0.2))
                            
                            // Holographic border
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    AngularGradient(
                                        colors: [
                                            Color.cyan,
                                            Color.purple,
                                            Color.cyan,
                                            Color.purple,
                                            Color.cyan
                                        ],
                                        center: .center,
                                        angle: .degrees(holographicRotation * 2)
                                    ),
                                    lineWidth: 2
                                )
                        }
                    )
                }
                .scaleEffect(celebrationScale)
            }
            .scaleEffect(celebrationScale)
            .opacity(celebrationOpacity)
        }
        .onAppear {
            if isVisible {
                startCelebrationSequence()
            }
        }
        .onChange(of: isVisible) { visible in
            if visible {
                startCelebrationSequence()
            }
        }
    }
    
    private let celebrationColors: [Color] = [
        .cyan, .purple, .pink, .blue, .mint, .indigo
    ]
    
    private func startCelebrationSequence() {
        // Initial appearance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            celebrationOpacity = 1.0
            celebrationScale = 1.0
        }
        
        // Particle explosion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 2)) {
                particleExplosion = true
            }
        }
        
        // Quantum ripple effect
        withAnimation(.easeOut(duration: 3).repeatForever(autoreverses: true)) {
            quantumRipple = 1.5
        }
        
        // Holographic rotation
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            holographicRotation = 360
        }
        
        // Neural burst
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            neuralBurst = 1.2
        }
        
        // Dimensional shift
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            dimensionalShift = 1.0
        }
    }
    
    private func dismissCelebration() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            celebrationScale = 0.1
            celebrationOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onComplete()
        }
    }
}

struct QuantumParticle: View {
    let delay: Double
    let color: Color
    @State private var position: CGPoint = CGPoint(x: 0, y: 0)
    @State private var opacity: Double = 1.0
    @State private var scale: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onAppear {
                animateParticle()
            }
    }
    
    private func animateParticle() {
        let randomAngle = Double.random(in: 0...(2 * .pi))
        let randomDistance = Double.random(in: 100...300)
        
        let targetX = cos(randomAngle) * randomDistance
        let targetY = sin(randomAngle) * randomDistance
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: 2)) {
                position = CGPoint(x: targetX, y: targetY)
                opacity = 0
                scale = 0.1
            }
        }
    }
}

#Preview {
    MilestoneCelebrationView(
        milestone: "First Property Saved",
        isVisible: true,
        onComplete: {}
    )
}