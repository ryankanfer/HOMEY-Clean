//
//  CelebrationAnimations.swift
//  HOMEY Clean
//
//  Created by Assistant for visual design warmth and progress celebrations
//

import SwiftUI

// MARK: - Milestone Celebration View

struct MilestoneCelebrationView: View {
    let milestone: String
    let isVisible: Bool
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = 0
    @State private var particles: [CelebrationParticle] = []
    @State private var sparkleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Celebration background
            Theme.Celebration.milestoneGradient
                .ignoresSafeArea()
                .opacity(isVisible ? 0.9 : 0)
            
            VStack(spacing: 24) {
                // Celebration icon with animation
                ZStack {
                    Circle()
                        .fill(Theme.Celebration.gold)
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }
                
                // Milestone text
                VStack(spacing: 8) {
                    Text("🎉 Milestone Achieved!")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .opacity(isVisible ? 1 : 0)
                    
                    Text(milestone)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(isVisible ? 1 : 0)
                }
                
                // Sparkle effects
                HStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundColor(Theme.Celebration.sparkle)
                            .opacity(sparkleOpacity)
                            .scaleEffect(Double.random(in: 0.8...1.2))
                    }
                }
            }
            
            // Confetti particles
            ForEach(particles.indices, id: \.self) { index in
                if index < particles.count {
                    Circle()
                        .fill(particles[index].color)
                        .frame(width: particles[index].size, height: particles[index].size)
                        .position(particles[index].position)
                        .opacity(particles[index].opacity)
                        .scaleEffect(particles[index].scale)
                }
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                startCelebration()
            }
        }
    }
    
    private func startCelebration() {
        // Scale and rotation animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
        }
        
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Sparkle animation
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            sparkleOpacity = 1.0
        }
        
        // Generate confetti
        generateConfetti()
        
        // Auto-dismiss after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 0.1
                sparkleOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
        }
    }
    
    private func generateConfetti() {
        particles = (0..<20).map { _ in
            CelebrationParticle(
                color: Theme.Celebration.confetti.randomElement() ?? .pink,
                position: CGPoint(
                    x: Double.random(in: 50...350),
                    y: Double.random(in: 200...600)
                ),
                size: Double.random(in: 4...12),
                opacity: 1.0,
                scale: 1.0
            )
        }
        
        // Animate particles
        withAnimation(.easeOut(duration: 2.0)) {
            particles = particles.map { particle in
                var newParticle = particle
                newParticle.position.y += Double.random(in: 100...300)
                newParticle.opacity = 0
                newParticle.scale = 0.1
                return newParticle
            }
        }
    }
}

// MARK: - Progress Celebration Bar

struct ProgressCelebrationBar: View {
    let progress: Double
    let isHighProgress: Bool
    
    @State private var animatedProgress: Double = 0
    @State private var glowIntensity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                
                // Progress fill with celebration gradient
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isHighProgress ? 
                        Theme.Celebration.milestoneGradient :
                        Theme.Warm.progressGradient
                    )
                    .frame(width: geometry.size.width * animatedProgress)
                    .overlay(
                        // Glow effect for high progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.Celebration.gold.opacity(glowIntensity))
                            .blur(radius: 4)
                            .opacity(isHighProgress ? 1 : 0)
                    )
                
                // Sparkle overlay for celebrations
                if isHighProgress {
                    HStack(spacing: 8) {
                        ForEach(0..<Int(geometry.size.width / 30), id: \.self) { _ in
                            Image(systemName: "sparkles")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .opacity(glowIntensity)
                        }
                    }
                    .frame(width: geometry.size.width * animatedProgress)
                    .clipped()
                }
            }
        }
        .onAppear {
            animateProgress()
        }
        .onChange(of: progress) { _, _ in
            animateProgress()
        }
    }
    
    private func animateProgress() {
        withAnimation(.easeInOut(duration: 1.5)) {
            animatedProgress = progress
        }
        
        if isHighProgress {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
        }
    }
}

// MARK: - Warm Button Style

struct WarmButtonStyle: ButtonStyle {
    let isHighlighted: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isHighlighted ? 
                        Theme.Warm.celebrationGradient :
                        Theme.Warm.progressGradient
                    )
                    .shadow(
                        color: Theme.Warm.coral.opacity(0.3),
                        radius: configuration.isPressed ? 2 : 8,
                        y: configuration.isPressed ? 1 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Supporting Models

struct CelebrationParticle {
    let color: Color
    var position: CGPoint
    let size: Double
    var opacity: Double
    var scale: Double
}

// MARK: - View Extensions

extension View {
    func warmButtonStyle(highlighted: Bool = false) -> some View {
        self.buttonStyle(WarmButtonStyle(isHighlighted: highlighted))
    }
    
    func celebrationProgress(progress: Double) -> some View {
        self.overlay(
            ProgressCelebrationBar(
                progress: progress,
                isHighProgress: progress > 0.8
            )
            .frame(height: 8)
        )
    }
}