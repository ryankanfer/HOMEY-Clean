import SwiftUI

struct CircularMask: View {
    let size: LensSize
    let position: CGPoint
    let isDragging: Bool
    let progress: Double // Progress for breathing/morphing effects
    
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var breathingScale: CGFloat = 1.0
    @State private var morphingOffset: CGFloat = 0
    @State private var progressRingScale: CGFloat = 0.8
    @State private var energyPulse: CGFloat = 1.0

    private var featherRadius: CGFloat {
        size.radius * 0.15 // 15% of radius for feather effect
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                progressRingView
                energyRingView
                mainCircleView
                innerCircleView
                particleEffectsView
                maskCircleView
                highlightRingView
                crosshairsView
            }
            .drawingGroup() // Use Metal rendering for better performance
            .onAppear {
                startTRAEAnimations()
            }
            .onChange(of: progress) { _, newProgress in
                updateProgressAnimations(newProgress)
            }
        }
    }
    
    private var progressRingView: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                AngularGradient(
                    colors: [
                        .cyan.opacity(0.9),
                        .blue.opacity(0.8),
                        .purple.opacity(0.7),
                        .cyan.opacity(0.9)
                    ],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: size.radius * 2.4, height: size.radius * 2.4)
            .position(position)
            .rotationEffect(.degrees(-90))
            .scaleEffect(progressRingScale * breathingScale)
            .opacity(progress > 0 ? 0.9 : 0.3)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
    }
    
    private var energyRingView: some View {
        Circle()
            .stroke(
                RadialGradient(
                    colors: [
                        .cyan.opacity(0.6),
                        .blue.opacity(0.3),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size.radius * 0.5
                ),
                lineWidth: 2
            )
            .frame(width: size.radius * 2.6, height: size.radius * 2.6)
            .position(position)
            .scaleEffect(energyPulse)
            .opacity(progress > 0.5 ? 0.7 : 0.3)
    }
    
    private var mainCircleView: some View {
        Circle()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .cyan.opacity(0.8),
                        .blue.opacity(0.6),
                        .cyan.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .frame(width: size.radius * 2.2, height: size.radius * 2.2)
            .position(position)
            .rotationEffect(.degrees(rotationAngle))
            .scaleEffect(pulseScale * (1 + morphingOffset * 0.1))
            .opacity(isDragging ? 0.9 : 0.7)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
    
    private var innerCircleView: some View {
        Circle()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.4),
                        .gray.opacity(0.2),
                        .white.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
            .frame(width: size.radius * 2.05, height: size.radius * 2.05)
            .position(position)
            .opacity(isDragging ? 0.6 : 0.8)
    }
    
    @ViewBuilder
    private var particleEffectsView: some View {
        if progress > 0.2 {
            ForEach(0..<8, id: \.self) { index in
                particleView(for: index)
            }
        }
    }
    
    private func particleView(for index: Int) -> some View {
        let particleGradient = LinearGradient(
            colors: [.cyan.opacity(0.8), .blue.opacity(0.4)],
            startPoint: .center,
            endPoint: .trailing
        )
        
        let particleX = position.x + cos(Double(index) * .pi / 4 + morphingOffset) * size.radius * 1.2
        let particleY = position.y + sin(Double(index) * .pi / 4 + morphingOffset) * size.radius * 1.2
        let particleOpacity = 0.6 + sin(morphingOffset + Double(index)) * 0.3
        
        return Circle()
            .fill(particleGradient)
            .frame(width: 4, height: 4)
            .position(x: particleX, y: particleY)
            .opacity(particleOpacity)
    }
    
    private var maskCircleView: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .clear, location: 0.65 - morphingOffset * 0.1),
                        .init(color: .black.opacity(0.2), location: 0.8 - morphingOffset * 0.05),
                        .init(color: .black.opacity(0.6), location: 0.9),
                        .init(color: .black.opacity(0.9), location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size.radius * (1 + morphingOffset * 0.2)
                )
            )
            .frame(width: size.radius * 2, height: size.radius * 2)
            .position(position)
            .scaleEffect(breathingScale)
            .opacity(isDragging ? 0.7 : 0.9)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
    
    private var highlightRingView: some View {
        Circle()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.8),
                        .cyan.opacity(0.3),
                        .white.opacity(0.5),
                        .clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
            .frame(width: size.radius * 1.7, height: size.radius * 1.7)
            .position(position)
            .opacity(isDragging ? 0.4 : 0.7)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
    
    @ViewBuilder
    private var crosshairsView: some View {
        if !isDragging {
            Group {
                // Horizontal crosshair
                Rectangle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: size.radius * 0.6, height: 1)
                    .position(position)
                
                // Vertical crosshair
                Rectangle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: 1, height: size.radius * 0.6)
                    .position(position)
            }
            .opacity(0.8)
            .animation(.easeInOut(duration: 0.3), value: isDragging)
        }
    }
    
    // MARK: - TRAE Animation System Integration
    
    private func startTRAEAnimations() {
        // Continuous rotation animation for periscope effect
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Breathing effect - slower, more organic
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            breathingScale = 1.08
        }
        
        // Morphing offset for dynamic effects
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            morphingOffset = 2 * .pi
        }
        
        // Energy pulse for active states
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            energyPulse = 1.15
        }
        
        // Subtle pulse animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }
    
    private func updateProgressAnimations(_ newProgress: Double) {
        // Scale progress ring based on completion
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            progressRingScale = 0.8 + (newProgress * 0.4)
        }
        
        // Trigger haptic feedback for progress milestones
        if newProgress >= 0.25 && progress < 0.25 {
            TRAEMotionSystem.shared.triggerHaptic(.light)
        } else if newProgress >= 0.5 && progress < 0.5 {
            TRAEMotionSystem.shared.triggerHaptic(.medium)
        } else if newProgress >= 0.75 && progress < 0.75 {
            TRAEMotionSystem.shared.triggerHaptic(.heavy)
        } else if newProgress >= 1.0 && progress < 1.0 {
            TRAEMotionSystem.shared.triggerHaptic(.success)
        }
    }
}

// MARK: - Convenience Initializers

extension CircularMask {
    init(size: LensSize, position: CGPoint, isDragging: Bool) {
        self.size = size
        self.position = position
        self.isDragging = isDragging
        self.progress = 0.0
    }
}

// MARK: - Modifiers

extension CircularMask {
    func withGlow(color: Color = .white, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Supporting Views

struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius)
            .shadow(color: color.opacity(0.2), radius: radius * 0.5)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        CircularMask(
            size: .medium,
            position: CGPoint(x: 200, y: 200),
            isDragging: false
        )
        .withGlow()
    }
}
