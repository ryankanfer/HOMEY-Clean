//
//  TRAEProgressAnimations.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//

import SwiftUI

// MARK: - TRAE Progress Animation Components

/// Liquid filling progress ring with TRAE animations
struct TRAELiquidProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let colors: [Color]
    let animationDuration: Double
    
    @State private var animatedProgress: Double = 0
    @State private var waveOffset: Double = 0
    @State private var shimmerOffset: Double = -1
    
    init(
        progress: Double,
        size: CGFloat = 120,
        lineWidth: CGFloat = 12,
        colors: [Color] = [Color.blue, Color.cyan],
        animationDuration: Double = 1.5
    ) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.colors = colors
        self.animationDuration = animationDuration
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Liquid progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .overlay(
                    // Shimmer effect
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.clear, Color.white.opacity(0.6), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(
                                lineWidth: lineWidth / 2,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .rotationEffect(.degrees(shimmerOffset * 360))
                )
            
            // Wave effect at progress end
            if animatedProgress > 0 {
                Circle()
                    .fill(colors.first ?? .blue)
                    .frame(width: lineWidth * 1.5, height: lineWidth * 1.5)
                    .offset(
                        x: cos(animatedProgress * 2 * .pi - .pi / 2) * (size / 2 - lineWidth / 2),
                        y: sin(animatedProgress * 2 * .pi - .pi / 2) * (size / 2 - lineWidth / 2)
                    )
                    .scaleEffect(1 + sin(waveOffset) * 0.2)
                    .opacity(0.8)
            }
            
            // Progress percentage text
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: size * 0.15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimations()
        }
        .onChange(of: progress) { _, newProgress in
            animateToProgress(newProgress)
        }
    }
    
    private func startAnimations() {
        // Animate progress
        animateToProgress(progress)
        
        // Start wave animation
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            waveOffset = .pi * 2
        }
        
        // Start shimmer animation
        withAnimation(
            Animation.linear(duration: 2.5)
                .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 1
        }
    }
    
    private func animateToProgress(_ newProgress: Double) {
        withAnimation(
            .easeInOut(duration: animationDuration)
        ) {
            animatedProgress = newProgress
        }
    }
}

// MARK: - Liquid Progress Bar

struct TRAELiquidProgressBar: View {
    let progress: Double
    let height: CGFloat
    let cornerRadius: CGFloat
    let colors: [Color]
    
    @State private var animatedProgress: Double = 0
    @State private var waveOffset: Double = 0
    @State private var bubblePositions: [CGPoint] = []
    
    init(
        progress: Double,
        height: CGFloat = 20,
        cornerRadius: CGFloat = 10,
        colors: [Color] = [Color.blue, Color.cyan]
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.cornerRadius = cornerRadius
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                
                // Liquid fill with wave effect
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress)
                    .mask(
                        WaveShape(offset: waveOffset, amplitude: height * 0.1)
                            .fill(Color.black)
                    )
                
                // Floating bubbles
                ForEach(bubblePositions.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                        .position(bubblePositions[index])
                }
                
                // Progress text
                HStack {
                    Spacer()
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: height * 0.6, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
        .frame(height: height)
        .onAppear {
            startAnimations()
        }
        .onChange(of: progress) { _, newProgress in
            animateToProgress(newProgress)
        }
    }
    
    private func startAnimations() {
        // Animate progress
        animateToProgress(progress)
        
        // Start wave animation
        withAnimation(
            Animation.linear(duration: 3.0)
                .repeatForever(autoreverses: false)
        ) {
            waveOffset = .pi * 4
        }
        
        // Generate bubble positions
        generateBubbles()
    }
    
    private func animateToProgress(_ newProgress: Double) {
        withAnimation(
            .easeInOut(duration: 1.5)
        ) {
            animatedProgress = newProgress
        }
    }
    
    private func generateBubbles() {
        bubblePositions = (0..<5).map { _ in
            CGPoint(
                x: Double.random(in: 0...200),
                y: Double.random(in: 5...(height - 5))
            )
        }
        
        // Animate bubbles
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2.0)) {
                bubblePositions = bubblePositions.map { _ in
                    CGPoint(
                        x: Double.random(in: 0...200),
                        y: Double.random(in: 5...(height - 5))
                    )
                }
            }
        }
    }
}

// MARK: - Wave Shape

struct WaveShape: Shape {
    let offset: Double
    let amplitude: Double
    
    var animatableData: Double {
        get { offset }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let waveHeight = amplitude
        
        path.move(to: CGPoint(x: 0, y: height / 2))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(offset + relativeX * .pi * 4)
            let y = height / 2 + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Circular Progress with Particles

struct TRAEParticleProgressRing: View {
    let progress: Double
    let size: CGFloat
    let particleCount: Int
    
    @State private var animatedProgress: Double = 0
    @State private var particles: [ParticleData] = []
    
    init(
        progress: Double,
        size: CGFloat = 120,
        particleCount: Int = 20
    ) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.particleCount = particleCount
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [Color.blue, Color.purple, Color.pink],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Animated particles
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(particles[index].color)
                    .frame(width: particles[index].size, height: particles[index].size)
                    .position(particles[index].position)
                    .opacity(particles[index].opacity)
            }
            
            // Center text
            VStack {
                Text("\(Int(animatedProgress * 100))")
                    .font(.system(size: size * 0.2, weight: .bold))
                Text("%")
                    .font(.system(size: size * 0.1, weight: .medium))
                    .opacity(0.7)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimations()
        }
        .onChange(of: progress) { _, newProgress in
            animateToProgress(newProgress)
        }
    }
    
    private func startAnimations() {
        animateToProgress(progress)
        generateParticles()
        animateParticles()
    }
    
    private func animateToProgress(_ newProgress: Double) {
        withAnimation(.easeInOut(duration: 2.0)) {
            animatedProgress = newProgress
        }
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            ParticleData(
                position: CGPoint(x: size/2, y: size/2),
                color: [Color.blue, Color.purple, Color.pink].randomElement() ?? .blue,
                size: Double.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                for index in particles.indices {
                    let angle = Double.random(in: 0...(2 * .pi))
                    let radius = Double.random(in: 20...(Double(size)/2.0 - 10.0))
                    
                    particles[index].position = CGPoint(
                        x: size/2 + cos(angle) * radius,
                        y: size/2 + sin(angle) * radius
                    )
                    
                    particles[index].opacity = Double.random(in: 0.2...0.8)
                }
            }
        }
    }
}

// MARK: - Particle Data Model

struct ParticleData {
    var position: CGPoint
    var color: Color
    var size: Double
    var opacity: Double
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE liquid progress animation
    func traeLiquidProgress(
        progress: Double,
        colors: [Color] = [Color.blue, Color.cyan]
    ) -> some View {
        self.overlay(
            TRAELiquidProgressRing(
                progress: progress,
                colors: colors
            )
        )
    }
    
    /// Apply TRAE particle progress animation
    func traeParticleProgress(
        progress: Double,
        size: CGFloat = 120
    ) -> some View {
        self.overlay(
            TRAEParticleProgressRing(
                progress: progress,
                size: size
            )
        )
    }
}