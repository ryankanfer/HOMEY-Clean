//
//  PaigeMicroInteractions.swift
//  HOMEY Clean
//
//  Micro-interactions for the Paige Document Vault
//  Enhanced with TRAE Motion Design System
//

import SwiftUI

// MARK: - Confetti Animation

public struct ConfettiView: View {
    @State private var animate = false
    @State private var particles: [ConfettiParticle] = []

    let colors: [Color] = [
        .yellow, .orange, .red, .pink, .purple, .blue, .cyan, .green
    ]

    public var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                let particle = particles[index]

                RoundedRectangle(cornerRadius: 2)
                    .fill(particle.color)
                    .frame(width: particle.size.width, height: particle.size.height)
                    .position(particle.position)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
                    .animation(
                        .easeOut(duration: particle.duration)
                            .delay(particle.delay),
                        value: animate
                    )
            }
        }
        .onAppear {
            generateParticles()
            animate = true

            // Clean up after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                particles.removeAll()
            }
        }
    }

    private func generateParticles() {
        particles = (0 ..< 30).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? .yellow,
                position: CGPoint(
                    x: CGFloat.random(in: 50 ... 300),
                    y: animate ? CGFloat.random(in: 200 ... 400) : CGFloat.random(in: -50 ... 50)
                ),
                size: CGSize(
                    width: CGFloat.random(in: 4 ... 8),
                    height: CGFloat.random(in: 8 ... 16)
                ),
                rotation: animate ? CGFloat.random(in: 0 ... 360) : 0,
                opacity: animate ? 0 : 1,
                duration: Double.random(in: 1.0 ... 2.0),
                delay: Double.random(in: 0 ... 0.5)
            )
        }
    }
}

public struct ConfettiParticle {
    let color: Color
    let position: CGPoint
    let size: CGSize
    let rotation: CGFloat
    let opacity: Double
    let duration: Double
    let delay: Double
}

// MARK: - Enhanced Halo Pulse Animation (TRAE)

struct TRAEDocumentHaloPulse: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0
    @State private var innerPulseScale: CGFloat = 0.8
    @State private var shimmerOffset: Double = -1.0
    @State private var particlePositions: [CGPoint] = []
    
    let isActive: Bool
    let color: Color
    let size: CGFloat
    
    init(isActive: Bool, color: Color = .green, size: CGFloat = 100) {
        self.isActive = isActive
        self.color = color
        self.size = size
    }

    var body: some View {
        ZStack {
            // Outer halo pulse
            Circle()
                .stroke(
                    RadialGradient(
                        colors: [
                            color.opacity(0.8),
                            color.opacity(0.4),
                            color.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size/2
                    ),
                    lineWidth: 4
                )
                .frame(width: size, height: size)
                .scaleEffect(pulseScale)
                .opacity(pulseOpacity)
            
            // Inner pulse ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.6), color.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size * 0.7, height: size * 0.7)
                .scaleEffect(innerPulseScale)
                .opacity(pulseOpacity * 0.8)
            
            // Shimmer effect
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    LinearGradient(
                        colors: [.clear, color.opacity(0.9), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: size * 0.85, height: size * 0.85)
                .rotationEffect(.degrees(shimmerOffset * 360))
                .opacity(pulseOpacity)
            
            // Verification particles
            ForEach(particlePositions.indices, id: \.self) { index in
                Circle()
                    .fill(color.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .position(particlePositions[index])
                    .opacity(pulseOpacity)
            }
        }
        .onAppear {
            if isActive {
                startEnhancedPulsing()
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startEnhancedPulsing()
            } else {
                stopPulsing()
            }
        }
    }

    private func startEnhancedPulsing() {
        generateParticles()
        
        // Main pulse animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
            pulseOpacity = 0.9
        }
        
        // Inner pulse with offset timing
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.2)) {
            innerPulseScale = 1.1
        }
        
        // Shimmer rotation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.0
        }
        
        // Trigger haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.success)
    }

    private func stopPulsing() {
        withAnimation(.easeOut(duration: 0.5)) {
            pulseScale = 1.0
            pulseOpacity = 0.0
            innerPulseScale = 0.8
            shimmerOffset = -1.0
        }
    }
    
    private func generateParticles() {
        particlePositions = (0..<8).map { index in
            let angle = Double(index) * (2 * .pi / 8)
            let radius = size * 0.4
            return CGPoint(
                x: cos(angle) * radius + size/2,
                y: sin(angle) * radius + size/2
            )
        }
    }
}

// MARK: - Paige Avatar Animation

struct PaigeAvatarAnimation: View {
    @State private var showAvatar = false
    @State private var avatarOffset: CGFloat = -200
    @State private var showCaption = false
    @State private var captionOpacity: Double = 0

    let isActive: Bool
    let caption: String

    var body: some View {
        ZStack {
            if showAvatar {
                HStack(spacing: 12) {
                    // Paige Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "2ECC71"),
                                    Color(hex: "27AE60")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("P")
                                .font(.custom("PlayfairDisplay-Bold", size: 18))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)

                    // Caption
                    if showCaption {
                        Text(caption)
                            .font(.custom("Lato-Regular", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .opacity(captionOpacity)
                    }

                    Spacer()
                }
                .offset(x: avatarOffset)
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        showAvatar = true

        // Avatar slides in from left
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            avatarOffset = 20
        }

        // Caption appears after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCaption = true
            withAnimation(.easeInOut(duration: 0.4)) {
                captionOpacity = 1.0
            }
        }

        // Everything slides out after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                avatarOffset = UIScreen.main.bounds.width + 100
                captionOpacity = 0
            }

            // Clean up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showAvatar = false
                showCaption = false
                avatarOffset = -200
            }
        }
    }
}

// MARK: - Paige Static Sticker (Reduce Motion)

struct PaigeStaticSticker: View {
    @State private var showSticker = false
    @State private var stickerOpacity: Double = 0

    let isActive: Bool
    let caption: String

    var body: some View {
        VStack(spacing: 8) {
            if showSticker {
                // Static Paige Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "2ECC71"),
                                Color(hex: "27AE60")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("P")
                            .font(.custom("PlayfairDisplay-Bold", size: 22))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)

                // Caption
                Text(caption)
                    .font(.custom("Lato-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
        }
        .opacity(stickerOpacity)
        .onChange(of: isActive) { active in
            if active {
                showSticker = true

                withAnimation(.easeInOut(duration: 0.4)) {
                    stickerOpacity = 1.0
                }

                // Hide after 2 seconds
                // Clean up after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        stickerOpacity = 0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showSticker = false
                    }
                }
            }
        }
    }
}

// MARK: - Document Upload Success Animation

struct DocumentUploadSuccessAnimation: View {
    @State private var plateScale: CGFloat = 0.8
    @State private var plateOpacity: Double = 0
    @State private var plateOffset = CGPoint(x: 0, y: 100)
    @State private var glowIntensity: Double = 0
    @State private var showCheckmark = false

    let documentType: DocumentUploadType
    let isActive: Bool

    var body: some View {
        ZStack {
            // Glowing plate
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            documentType.color.opacity(0.8),
                            documentType.color.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(
                    color: documentType.color.opacity(glowIntensity),
                    radius: 20,
                    x: 0,
                    y: 0
                )
                .scaleEffect(plateScale)
                .opacity(plateOpacity)
                .offset(x: plateOffset.x, y: plateOffset.y)

            // Document icon
            Image(systemName: documentType.icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .scaleEffect(plateScale)
                .opacity(plateOpacity)
                .offset(x: plateOffset.x, y: plateOffset.y)

            // Success checkmark
            if showCheckmark {
                Circle()
                    .fill(.green)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 35, y: -35)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        // Initial glow and scale up
        withAnimation(.easeOut(duration: 0.3)) {
            plateScale = 1.0
            plateOpacity = 1.0
            glowIntensity = 0.8
        }

        // Slide into position
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                plateOffset = CGPoint(x: 0, y: 0)
            }
        }

        // Show success checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showCheckmark = true
            }

            // Haptic feedback
            HapticManager.shared.notification(.success)
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                plateOpacity = 0
                glowIntensity = 0
                showCheckmark = false
            }

            // Reset for next use
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                plateScale = 0.8
                plateOffset = CGPoint(x: 0, y: 100)
            }
        }
    }
}

// MARK: - Progress Ring Tick Animation

struct ProgressRingTickAnimation: View {
    @State private var tickScale: CGFloat = 1.0
    @State private var tickOpacity: Double = 0
    @State private var ringPulse: CGFloat = 1.0

    let progress: Double
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            // Progress ring with pulse
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .scaleEffect(ringPulse)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

            // Tick mark at progress end
            if tickOpacity > 0 {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(tickScale)
                    .opacity(tickOpacity)
                    .offset(y: -50) // Radius of the circle
                    .rotationEffect(.degrees(360 * progress - 90))
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startTickAnimation()
            }
        }
    }

    private func startTickAnimation() {
        // Ring pulse
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            ringPulse = 1.1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                ringPulse = 1.0
            }
        }

        // Tick mark animation
        tickOpacity = 1.0
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            tickScale = 1.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                tickScale = 1.0
            }
        }

        // Fade out tick
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                tickOpacity = 0
            }
        }
    }
}

// MARK: - Shelf Pulse Animation

struct ShelfPulseAnimation: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0

    let isActive: Bool
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        color.opacity(0.6),
                        color.opacity(0.3),
                        color.opacity(0.1)
                    ],
                    startPoint: .center,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
            .scaleEffect(pulseScale)
            .opacity(pulseOpacity)
            .onChange(of: isActive) { active in
                if active {
                    startPulse()
                }
            }
    }

    private func startPulse() {
        withAnimation(.easeOut(duration: 0.6)) {
            pulseScale = 1.05
            pulseOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.4)) {
                pulseScale = 1.0
                pulseOpacity = 0
            }
        }
    }
}

// MARK: - Scanner Line Animation

// MARK: - Enhanced Scanner Animation (TRAE)

struct TRAEDocumentScanner: View {
    @State private var scannerOffset: CGFloat = -100
    @State private var scannerOpacity: Double = 0
    @State private var scanLineIntensity: Double = 0.5
    @State private var gridOpacity: Double = 0
    @State private var scanProgress: Double = 0
    @State private var particleTrail: [CGPoint] = []

    let isActive: Bool
    let width: CGFloat
    let height: CGFloat
    let onScanComplete: () -> Void
    
    init(isActive: Bool, width: CGFloat, height: CGFloat = 60, onScanComplete: @escaping () -> Void = {}) {
        self.isActive = isActive
        self.width = width
        self.height = height
        self.onScanComplete = onScanComplete
    }

    var body: some View {
        ZStack {
            // Scanning grid overlay
            Rectangle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .cyan.opacity(0.1),
                            .cyan.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 0.5, dash: [2, 4])
                )
                .frame(width: width, height: height)
                .opacity(gridOpacity)
            
            // Main scanner beam
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .cyan.opacity(0.3),
                            .cyan.opacity(scanLineIntensity),
                            .cyan,
                            .cyan.opacity(scanLineIntensity),
                            .cyan.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 8, height: height)
                .opacity(scannerOpacity)
                .offset(x: scannerOffset)
                .shadow(color: .cyan.opacity(0.6), radius: 4, x: 0, y: 0)
            
            // Particle trail effect
            ForEach(particleTrail.indices, id: \.self) { index in
                Circle()
                    .fill(.cyan.opacity(0.4 - Double(index) * 0.1))
                    .frame(width: 2, height: 2)
                    .position(particleTrail[index])
            }
            
            // Progress indicator
            HStack {
                Spacer()
                VStack {
                    Text("\(Int(scanProgress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.cyan)
                        .opacity(scannerOpacity)
                    
                    Rectangle()
                        .fill(.cyan.opacity(0.3))
                        .frame(width: 30, height: 2)
                        .overlay(
                            Rectangle()
                                .fill(.cyan)
                                .frame(width: 30 * scanProgress, height: 2),
                            alignment: .leading
                        )
                        .opacity(scannerOpacity)
                }
                .padding(.trailing, 8)
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startEnhancedScanning()
            } else {
                stopScanning()
            }
        }
    }

    private func startEnhancedScanning() {
        // Reset state
        scannerOffset = -100
        scannerOpacity = 0
        scanProgress = 0
        particleTrail = []
        
        // Show grid and scanner
        withAnimation(.easeIn(duration: 0.3)) {
            gridOpacity = 1.0
            scannerOpacity = 1.0
        }
        
        // Animate scanner line intensity
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            scanLineIntensity = 1.0
        }
        
        // Main scanning animation
        withAnimation(.easeInOut(duration: 2.5)) {
            scannerOffset = width + 100
            scanProgress = 1.0
        }
        
        // Create particle trail
        createParticleTrail()
        
        // Trigger haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.light)
        
        // Complete scan
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            completeScan()
        }
    }
    
    private func stopScanning() {
        withAnimation(.easeOut(duration: 0.3)) {
            scannerOpacity = 0
            gridOpacity = 0
            scanLineIntensity = 0.5
        }
    }
    
    private func createParticleTrail() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if scannerOpacity > 0 && scannerOffset < width {
                let newParticle = CGPoint(x: scannerOffset, y: height/2)
                particleTrail.append(newParticle)
                
                // Keep only last 5 particles
                if particleTrail.count > 5 {
                    particleTrail.removeFirst()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func completeScan() {
        // Success haptic
        TRAEMotionSystem.shared.triggerHaptic(.success)
        
        // Fade out
        withAnimation(.easeOut(duration: 0.5)) {
            scannerOpacity = 0
            gridOpacity = 0
        }
        
        onScanComplete()
    }
}
