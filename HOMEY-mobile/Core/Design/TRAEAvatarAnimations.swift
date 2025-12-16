//
//  TRAEAvatarAnimations.swift
//  HOMEY Clean
//
//  Avatar micro-interactions for TRAE Motion Design System
//

import SwiftUI

// MARK: - Animated Avatar Component

struct TRAEAnimatedAvatar: View {
    let imageName: String
    let size: CGFloat
    let enableBlinking: Bool
    let enableBreathing: Bool
    let enablePoseShifting: Bool
    
    @State private var isBlinking = false
    @State private var breathingScale: CGFloat = 1.0
    @State private var poseOffset: CGSize = .zero
    @State private var poseRotation: Double = 0
    @State private var blinkTimer: Timer?
    
    init(
        imageName: String,
        size: CGFloat = 60,
        enableBlinking: Bool = true,
        enableBreathing: Bool = true,
        enablePoseShifting: Bool = true
    ) {
        self.imageName = imageName
        self.size = size
        self.enableBlinking = enableBlinking
        self.enableBreathing = enableBreathing
        self.enablePoseShifting = enablePoseShifting
    }
    
    var body: some View {
        ZStack {
            // Main avatar image
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .scaleEffect(breathingScale)
                .offset(poseOffset)
                .rotationEffect(.degrees(poseRotation))
            
            // Blinking overlay
            if enableBlinking {
                Circle()
                    .fill(.black.opacity(0.8))
                    .frame(width: size, height: size)
                    .opacity(isBlinking ? 1 : 0)
                    .animation(TRAEMotionSystem.Animations.avatarBlink, value: isBlinking)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            stopAnimations()
        }
    }
    
    private func startAnimations() {
        // Start breathing animation
        if enableBreathing {
            withAnimation(TRAEMotionSystem.Animations.avatarBreathe) {
                breathingScale = 1.05
            }
        }
        
        // Start blinking timer
        if enableBlinking {
            startBlinkingTimer()
        }
        
        // Initial pose shift
        if enablePoseShifting {
            performPoseShift()
        }
    }
    
    private func stopAnimations() {
        blinkTimer?.invalidate()
        blinkTimer = nil
    }
    
    private func startBlinkingTimer() {
        // Random blink intervals between 2-6 seconds
        let interval = Double.random(in: 2.0...6.0)
        
        blinkTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            performBlink()
            startBlinkingTimer() // Schedule next blink
        }
    }
    
    private func performBlink() {
        isBlinking = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isBlinking = false
        }
    }
    
    private func performPoseShift() {
        let randomOffset = CGSize(
            width: Double.random(in: -2...2),
            height: Double.random(in: -2...2)
        )
        let randomRotation = Double.random(in: -3...3)
        
        withAnimation(TRAEMotionSystem.Animations.avatarPoseShift) {
            poseOffset = randomOffset
            poseRotation = randomRotation
        }
        
        // Return to center after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(TRAEMotionSystem.Animations.avatarPoseShift) {
                poseOffset = .zero
                poseRotation = 0
            }
        }
    }
    
    // Public method to trigger pose shift on scroll/load events
    func triggerPoseShift() {
        guard enablePoseShifting else { return }
        performPoseShift()
    }
}

// MARK: - Avatar Group Animation

struct TRAEAvatarGroup: View {
    let avatars: [String]
    let size: CGFloat
    let spacing: CGFloat
    
    @State private var animationPhase: Double = 0
    
    init(avatars: [String], size: CGFloat = 50, spacing: CGFloat = -10) {
        self.avatars = avatars
        self.size = size
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(avatars.enumerated()), id: \.offset) { index, avatar in
                TRAEAnimatedAvatar(
                    imageName: avatar,
                    size: size,
                    enableBlinking: true,
                    enableBreathing: true,
                    enablePoseShifting: false // Disable individual pose shifting for group
                )
                .zIndex(Double(avatars.count - index))
                .offset(y: sin(animationPhase + Double(index) * 0.5) * 3)
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                animationPhase = .pi * 2
            }
        }
    }
}

// MARK: - Avatar Hover Effect

struct TRAEHoverableAvatar: View {
    let imageName: String
    let size: CGFloat
    
    @State private var isHovered = false
    @State private var hoverScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.blue.opacity(0.3), .clear],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .opacity(glowOpacity)
            
            // Avatar
            TRAEAnimatedAvatar(
                imageName: imageName,
                size: size,
                enableBlinking: true,
                enableBreathing: !isHovered, // Disable breathing when hovered
                enablePoseShifting: false
            )
            .scaleEffect(hoverScale)
        }
        .onHover { hovering in
            withAnimation(TRAEMotionSystem.Animations.avatarPoseShift) {
                isHovered = hovering
                hoverScale = hovering ? 1.1 : 1.0
                glowOpacity = hovering ? 1.0 : 0
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func traeAvatarAnimation(
        imageName: String,
        size: CGFloat = 60,
        enableBlinking: Bool = true,
        enableBreathing: Bool = true,
        enablePoseShifting: Bool = true
    ) -> some View {
        TRAEAnimatedAvatar(
            imageName: imageName,
            size: size,
            enableBlinking: enableBlinking,
            enableBreathing: enableBreathing,
            enablePoseShifting: enablePoseShifting
        )
    }
}