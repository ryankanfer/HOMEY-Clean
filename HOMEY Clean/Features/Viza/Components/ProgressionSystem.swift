//
//  ProgressionSystem.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI

struct ProgressionSystem: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    @State private var animationPhase: Double = 0
    @State private var runwayLights: [Bool] = Array(repeating: false, count: 12)
    @State private var domeProjectionOpacity: Double = 0
    @State private var celebrationParticles: [ParticleEffect] = []
    
    var body: some View {
        ZStack {
            if viewModel.showingProgressionMoment,
               let moment = viewModel.currentProgressionMoment {
                
                // Background overlay
                progressionBackground
                
                // Main content
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Dome projection effect
                    domeProjectionView(for: moment)
                    
                    // Main text content
                    progressionContent(for: moment)
                    
                    // Runway lights
                    runwayLightsView
                    
                    Spacer()
                    
                    // Continue button
                    continueButton
                }
                .scaleEffect(viewModel.showingProgressionMoment ? 1.0 : 0.8)
                .opacity(viewModel.showingProgressionMoment ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: viewModel.showingProgressionMoment)
                
                // Celebration particles
                ForEach(celebrationParticles.indices, id: \.self) { index in
                    if index < celebrationParticles.count {
                        ParticleView(particle: celebrationParticles[index])
                    }
                }
            }
        }
        .onAppear {
            if viewModel.showingProgressionMoment {
                startProgressionAnimation()
            }
        }
        .onChange(of: viewModel.showingProgressionMoment) { isShowing in
            if isShowing {
                startProgressionAnimation()
            } else {
                resetAnimation()
            }
        }
    }
    
    // MARK: - Background
    
    private var progressionBackground: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            // Animated gradient
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.2),
                    Color.black.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(animationPhase * 60))
            .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: animationPhase)
        }
    }
    
    // MARK: - Dome Projection
    
    private func domeProjectionView(for moment: ProgressionMoment) -> some View {
        ZStack {
            // Dome shape
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            moment.accentColor.opacity(0.4),
                            moment.accentColor.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .opacity(domeProjectionOpacity)
                .scaleEffect(1.0 + sin(animationPhase * 2) * 0.1)
            
            // Projected text/icon
            VStack(spacing: 8) {
                Image(systemName: moment.icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(moment.accentColor)
                
                Text(moment.projectionText)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .opacity(domeProjectionOpacity)
            .scaleEffect(0.8 + sin(animationPhase * 3) * 0.1)
            
            // Rotating ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            moment.accentColor,
                            moment.accentColor.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(animationPhase * 45))
                .opacity(domeProjectionOpacity * 0.8)
        }
    }
    
    // MARK: - Content
    
    private func progressionContent(for moment: ProgressionMoment) -> some View {
        VStack(spacing: 16) {
            // Main title
            Text(moment.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: moment.accentColor.opacity(0.5), radius: 8, x: 0, y: 4)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text(moment.subtitle)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Achievement details
            if !moment.achievementDetails.isEmpty {
                VStack(spacing: 8) {
                    ForEach(moment.achievementDetails, id: \.self) { detail in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(moment.accentColor)
                            
                            Text(detail)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 60)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Runway Lights
    
    private var runwayLightsView: some View {
        HStack(spacing: 12) {
            ForEach(0..<runwayLights.count, id: \.self) { index in
                Circle()
                    .fill(
                        runwayLights[index] ?
                        LinearGradient(
                            colors: [Color.white, Color.yellow],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 8)
                    .shadow(
                        color: runwayLights[index] ? .yellow.opacity(0.8) : .clear,
                        radius: runwayLights[index] ? 4 : 0
                    )
                    .scaleEffect(runwayLights[index] ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.3).delay(Double(index) * 0.1),
                        value: runwayLights[index]
                    )
            }
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        Button {
            dismissProgression()
        } label: {
            HStack {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(1.0 + sin(animationPhase * 4) * 0.05)
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animationPhase)
    }
    
    // MARK: - Animation Control
    
    private func startProgressionAnimation() {
        // Start main animation timer
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            animationPhase = 1.0
        }
        
        // Fade in dome projection
        withAnimation(.easeInOut(duration: 1.5)) {
            domeProjectionOpacity = 1.0
        }
        
        // Animate runway lights in sequence
        animateRunwayLights()
        
        // Generate celebration particles
        generateCelebrationParticles()
    }
    
    private func animateRunwayLights() {
        for index in 0..<runwayLights.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                runwayLights[index] = true
            }
        }
        
        // Create wave effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            createRunwayWave()
        }
    }
    
    private func createRunwayWave() {
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            if !viewModel.showingProgressionMoment {
                timer.invalidate()
                return
            }
            
            // Turn off all lights
            runwayLights = Array(repeating: false, count: runwayLights.count)
            
            // Turn on lights in wave pattern
            for index in 0..<runwayLights.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) {
                    if index < runwayLights.count {
                        runwayLights[index] = true
                    }
                }
            }
        }
    }
    
    private func generateCelebrationParticles() {
        guard let moment = viewModel.currentProgressionMoment else { return }
        
        celebrationParticles.removeAll()
        
        for _ in 0..<20 {
            let particle = ParticleEffect(
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...600)
                ),
                velocity: CGPoint(
                    x: CGFloat.random(in: -50...50),
                    y: CGFloat.random(in: -100...(-20))
                ),
                color: moment.accentColor,
                size: CGFloat.random(in: 2...6),
                lifetime: Double.random(in: 2...4)
            )
            celebrationParticles.append(particle)
        }
    }
    
    private func resetAnimation() {
        animationPhase = 0
        domeProjectionOpacity = 0
        runwayLights = Array(repeating: false, count: runwayLights.count)
        celebrationParticles.removeAll()
    }
    
    private func dismissProgression() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.showingProgressionMoment = false
            viewModel.currentProgressionMoment = nil
        }
    }
}

// MARK: - Particle Effect

struct ParticleEffect {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    let color: Color
    let size: CGFloat
    var lifetime: Double
    let createdAt = Date()
}

struct ParticleView: View {
    let particle: ParticleEffect
    @State private var currentPosition: CGPoint
    @State private var opacity: Double = 1.0
    
    init(particle: ParticleEffect) {
        self.particle = particle
        self._currentPosition = State(initialValue: particle.position)
    }
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .position(currentPosition)
            .opacity(opacity)
            .onAppear {
                animateParticle()
            }
    }
    
    private func animateParticle() {
        withAnimation(.linear(duration: particle.lifetime)) {
            currentPosition.x += particle.velocity.x
            currentPosition.y += particle.velocity.y
            opacity = 0.0
        }
    }
}

// MARK: - Progression Moment Extensions

extension ProgressionMoment {
    var accentColor: Color {
        switch type {
        case .firstSave:
            return .blue
        case .threeStyles:
            return .purple
        case .firstExport:
            return .green
        case .tenSaves:
            return .orange
        case .masterStylist:
            return .pink
        }
    }
    
    var icon: String {
        switch type {
        case .firstSave:
            return "bookmark.fill"
        case .threeStyles:
            return "crown.fill"
        case .firstExport:
            return "square.and.arrow.up.fill"
        case .tenSaves:
            return "star.fill"
        case .masterStylist:
            return "wand.and.stars"
        }
    }
    
    var projectionText: String {
        switch type {
        case .firstSave:
            return "STYLED"
        case .threeStyles:
            return "COLLECTION"
        case .firstExport:
            return "SHARED"
        case .tenSaves:
            return "CURATOR"
        case .masterStylist:
            return "MASTER"
        }
    }
    
    var achievementDetails: [String] {
        switch type {
        case .firstSave:
            return ["First look saved", "Vision journey begins"]
        case .threeStyles:
            return ["3 unique styles created", "Collection unlocked", "Runway lights activated"]
        case .firstExport:
            return ["First moodboard exported", "Ready to share"]
        case .tenSaves:
            return ["10 looks in collection", "Vision curator status", "Advanced features unlocked"]
        case .masterStylist:
            return ["Master visionary achieved", "All features unlocked", "Vision legend status"]
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ProgressionSystem(viewModel: {
            let vm = VizaVisionViewModel()
            vm.showingProgressionMoment = true
            vm.currentProgressionMoment = ProgressionMoment(
                type: .threeStyles,
                title: "Collection Unlocked!",
                subtitle: "You've created 3 unique styles. The runway lights are now yours to command.",
                domeProjection: "COLLECTION"
            )
            return vm
        }())
    }
    .preferredColorScheme(.dark)
}