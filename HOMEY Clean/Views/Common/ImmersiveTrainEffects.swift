import SwiftUI
import AVFoundation

// MARK: - Immersive Train Effects System

struct ImmersiveTrainEffects {
    
    // MARK: - Camera Shake Effect
    struct CameraShakeEffect: ViewModifier {
        let intensity: Double
        let isActive: Bool
        
        @State private var shakeOffset: CGSize = .zero
        
        func body(content: Content) -> some View {
            content
                .offset(shakeOffset)
                .onAppear {
                    if isActive {
                        startShaking()
                    }
                }
                .onChange(of: isActive) { active in
                    if active {
                        startShaking()
                    } else {
                        stopShaking()
                    }
                }
        }
        
        private func startShaking() {
            let shakeAnimation = Animation
                .easeInOut(duration: 0.1)
                .repeatForever(autoreverses: true)
            
            withAnimation(shakeAnimation) {
                shakeOffset = CGSize(
                    width: CGFloat.random(in: -intensity...intensity),
                    height: CGFloat.random(in: -intensity...intensity)
                )
            }
        }
        
        private func stopShaking() {
            withAnimation(.easeOut(duration: 0.3)) {
                shakeOffset = .zero
            }
        }
    }
    
    // MARK: - Speed Blur Effect
    struct SpeedBlurEffect: View {
        let isMoving: Bool
        let intensity: Double
        
        @State private var blurOffset: CGFloat = 0
        
        var body: some View {
            ZStack {
                // Horizontal motion blur lines
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.1 * intensity),
                                    .cyan.opacity(0.05 * intensity),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .offset(
                            x: blurOffset + CGFloat(index * 20),
                            y: CGFloat(index * 15 - 60)
                        )
                        .opacity(isMoving ? 1 : 0)
                }
            }
            .onAppear {
                if isMoving {
                    startBlurAnimation()
                }
            }
            .onChange(of: isMoving) { moving in
                if moving {
                    startBlurAnimation()
                }
            }
        }
        
        private func startBlurAnimation() {
            withAnimation(
                .linear(duration: 0.2)
                .repeatForever(autoreverses: false)
            ) {
                blurOffset = -300
            }
        }
    }
    
    // MARK: - Environmental Atmosphere
    struct EnvironmentalAtmosphere: View {
        let isMoving: Bool
        
        @State private var dustParticles: [DustParticle] = []
        @State private var windEffect: Double = 0
        
        var body: some View {
            ZStack {
                // Dust particles
                ForEach(dustParticles) { particle in
                    Circle()
                        .fill(.white.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .blur(radius: 1)
                }
                
                // Wind effect overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.02),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: windEffect)
                    .opacity(isMoving ? 1 : 0)
            }
            .onAppear {
                generateDustParticles()
                if isMoving {
                    animateEnvironment()
                }
            }
            .onChange(of: isMoving) { moving in
                if moving {
                    animateEnvironment()
                }
            }
        }
        
        private func generateDustParticles() {
            dustParticles = (0..<15).map { _ in
                DustParticle(
                    position: CGPoint(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat.random(in: 0...200)
                    ),
                    size: CGFloat.random(in: 1...3),
                    opacity: Double.random(in: 0.1...0.3)
                )
            }
        }
        
        private func animateEnvironment() {
            // Animate dust particles
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                for index in dustParticles.indices {
                    dustParticles[index].position.x -= CGFloat.random(in: 100...200)
                }
            }
            
            // Wind effect
            withAnimation(
                .linear(duration: 0.8)
                .repeatForever(autoreverses: false)
            ) {
                windEffect = -200
            }
        }
    }
    
    // MARK: - Realistic Train Physics
    struct TrainPhysicsEffect: ViewModifier {
        let isAccelerating: Bool
        let isDecelerating: Bool
        let currentSpeed: Double
        
        @State private var momentum: Double = 0
        @State private var tilt: Double = 0
        
        func body(content: Content) -> some View {
            content
                .rotationEffect(.degrees(tilt))
                .scaleEffect(1.0 + momentum * 0.02)
                .onAppear {
                    updatePhysics()
                }
                .onChange(of: isAccelerating) { _ in updatePhysics() }
                .onChange(of: isDecelerating) { _ in updatePhysics() }
        }
        
        private func updatePhysics() {
            if isAccelerating {
                withAnimation(.easeOut(duration: 2.0)) {
                    momentum = 1.0
                    tilt = -0.5
                }
            } else if isDecelerating {
                withAnimation(.easeOut(duration: 1.5)) {
                    momentum = -0.3
                    tilt = 0.3
                }
            } else {
                withAnimation(.easeInOut(duration: 1.0)) {
                    momentum = 0
                    tilt = 0
                }
            }
        }
    }
}

// MARK: - Supporting Models

struct DustParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
}

// MARK: - View Extensions

extension View {
    func cameraShake(intensity: Double = 2.0, isActive: Bool) -> some View {
        self.modifier(
            ImmersiveTrainEffects.CameraShakeEffect(
                intensity: intensity,
                isActive: isActive
            )
        )
    }
    
    func trainPhysics(
        isAccelerating: Bool = false,
        isDecelerating: Bool = false,
        currentSpeed: Double = 0
    ) -> some View {
        self.modifier(
            ImmersiveTrainEffects.TrainPhysicsEffect(
                isAccelerating: isAccelerating,
                isDecelerating: isDecelerating,
                currentSpeed: currentSpeed
            )
        )
    }
}

// MARK: - Enhanced Sound Manager

class ImmersiveTrainSoundManager: ObservableObject {
    private var trainMovementPlayer: AVAudioPlayer?
    private var ambientSoundPlayer: AVAudioPlayer?
    private var brakingPlayer: AVAudioPlayer?
    
    @Published var isPlayingMovement = false
    @Published var currentVolume: Float = 0.5
    
    func startTrainMovement() {
        // In a real implementation, you would load actual train sound files
        playTrainMovementSound()
        isPlayingMovement = true
    }
    
    func stopTrainMovement() {
        trainMovementPlayer?.stop()
        isPlayingMovement = false
    }
    
    func playBrakingSound() {
        // Play braking/deceleration sound
        playBrakingEffect()
    }
    
    func playAccelerationSound() {
        // Play acceleration sound with increasing pitch
        playAccelerationEffect()
    }
    
    func setAmbientVolume(_ volume: Float) {
        currentVolume = volume
        trainMovementPlayer?.volume = volume
        ambientSoundPlayer?.volume = volume * 0.3
    }
    
    private func playTrainMovementSound() {
        // Implementation would use actual audio files
        // For now, we'll use system sounds or generate procedural audio
    }
    
    private func playBrakingEffect() {
        // Implementation for braking sound effect
    }
    
    private func playAccelerationEffect() {
        // Implementation for acceleration sound effect
    }
}

// MARK: - Complete Immersive Train Experience

struct ImmersiveTrainExperience: View {
    let isMoving: Bool
    let isAccelerating: Bool
    let isDecelerating: Bool
    let speed: Double
    
    @StateObject private var soundManager = ImmersiveTrainSoundManager()
    @StateObject private var hapticManager = HapticFeedbackManager()
    
    var body: some View {
        ZStack {
            // Environmental atmosphere
            ImmersiveTrainEffects.EnvironmentalAtmosphere(isMoving: isMoving)
            
            // Speed blur overlay
            ImmersiveTrainEffects.SpeedBlurEffect(
                isMoving: isMoving,
                intensity: speed
            )
        }
        .cameraShake(
            intensity: speed * 3,
            isActive: isMoving
        )
        .trainPhysics(
            isAccelerating: isAccelerating,
            isDecelerating: isDecelerating,
            currentSpeed: speed
        )
        .hapticFeedback(
            hapticManager,
            type: .trainMovement,
            trigger: isMoving
        )
        .hapticFeedback(
            hapticManager,
            type: .trainAcceleration,
            trigger: isAccelerating
        )
        .hapticFeedback(
            hapticManager,
            type: .trainDeceleration,
            trigger: isDecelerating
        )
        .onAppear {
            if isMoving {
                soundManager.startTrainMovement()
            }
        }
        .onChange(of: isMoving) { moving in
            if moving {
                soundManager.startTrainMovement()
            } else {
                soundManager.stopTrainMovement()
            }
        }
        .onChange(of: isAccelerating) { accelerating in
            if accelerating {
                soundManager.playAccelerationSound()
            }
        }
        .onChange(of: isDecelerating) { decelerating in
            if decelerating {
                soundManager.playBrakingSound()
            }
        }
    }
}