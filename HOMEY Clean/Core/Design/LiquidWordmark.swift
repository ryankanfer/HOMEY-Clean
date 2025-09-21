//
//  LiquidWordmark.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Fluid brand transitions for startup and persona handoff
//

import SwiftUI

// MARK: - Liquid Wordmark Component

struct LiquidWordmark: View {
    let text: String
    let persona: PersonaType?
    let isStartup: Bool
    let isVisible: Bool
    
    @State private var liquidOffset: CGFloat = 0
    @State private var morphingScale: CGFloat = 1.0
    @State private var fluidOpacity: Double = 0
    @State private var particlePositions: [CGPoint] = []
    @State private var brandColorPhase: Double = 0
    @State private var letterSpacing: CGFloat = 0
    @State private var glowIntensity: Double = 0
    
    private var brandColors: [Color] {
        if let persona = persona {
            return persona.brandColors
        }
        return [.blue, .cyan, .purple]
    }
    
    var body: some View {
        ZStack {
            // Background liquid flow
            if isVisible {
                LiquidFlowBackground(
                    colors: brandColors,
                    offset: liquidOffset,
                    opacity: fluidOpacity * 0.3
                )
            }
            
            // Main wordmark with liquid morphing
            Text(text)
                .font(.custom("PlayfairDisplay-Bold", size: 48))
                .tracking(letterSpacing)
                .foregroundStyle(
                    LinearGradient(
                        colors: brandColors.map { $0.opacity(0.9) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Liquid shimmer effect
                    Text(text)
                        .font(.custom("PlayfairDisplay-Bold", size: 48))
                        .tracking(letterSpacing)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.8),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.clear, Color.black, Color.clear],
                                        startPoint: .init(x: liquidOffset - 0.3, y: 0),
                                        endPoint: .init(x: liquidOffset + 0.3, y: 0)
                                    )
                                )
                        )
                )
                .scaleEffect(morphingScale)
                .opacity(fluidOpacity)
                .shadow(
                    color: brandColors.first?.opacity(glowIntensity) ?? .clear,
                    radius: 20,
                    x: 0,
                    y: 0
                )
            
            // Floating brand particles
            if isVisible && !particlePositions.isEmpty {
                ForEach(particlePositions.indices, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    brandColors[index % brandColors.count].opacity(0.8),
                                    brandColors[index % brandColors.count].opacity(0.2)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: 6, height: 6)
                        .position(particlePositions[index])
                        .opacity(fluidOpacity * 0.7)
                }
            }
        }
        .onAppear {
            if isStartup {
                startStartupAnimation()
            } else {
                startPersonaHandoffAnimation()
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                if isStartup {
                    startStartupAnimation()
                } else {
                    startPersonaHandoffAnimation()
                }
            } else {
                fadeOut()
            }
        }
        .onChange(of: persona) { _, newPersona in
            if newPersona != nil {
                startPersonaTransition()
            }
        }
    }
    
    // MARK: - TRAE Animation System Integration
    
    private func startStartupAnimation() {
        // Generate particle positions
        generateParticles()
        
        // Startup sequence with TRAE timing
        withAnimation(.easeOut(duration: 0.8)) {
            fluidOpacity = 1.0
            morphingScale = 1.0
        }
        
        // Letter spacing animation
        withAnimation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.3)) {
            letterSpacing = 2.0
        }
        
        // Liquid shimmer sweep
        withAnimation(.easeInOut(duration: 2.0).delay(0.5)) {
            liquidOffset = 1.3
        }
        
        // Glow pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.0)) {
            glowIntensity = 0.6
        }
        
        // Continuous liquid flow
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false).delay(1.5)) {
            brandColorPhase = 2 * .pi
        }
        
        // Haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.medium)
    }
    
    private func startPersonaHandoffAnimation() {
        // Generate particle positions
        generateParticles()
        
        // Persona handoff sequence
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            fluidOpacity = 1.0
            morphingScale = 1.05
        }
        
        // Quick shimmer for persona change
        withAnimation(.easeInOut(duration: 1.0)) {
            liquidOffset = 1.0
        }
        
        // Settle into persona colors
        withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
            morphingScale = 1.0
            glowIntensity = 0.4
        }
        
        // Haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.light)
    }
    
    private func startPersonaTransition() {
        // Morphing transition between personas
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            morphingScale = 1.1
            letterSpacing = 4.0
        }
        
        // Liquid color transition
        withAnimation(.easeInOut(duration: 1.2)) {
            liquidOffset = 0
            brandColorPhase += .pi
        }
        
        // Settle back
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.5)) {
            morphingScale = 1.0
            letterSpacing = 2.0
            liquidOffset = 1.0
        }
        
        // Regenerate particles with new colors
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            generateParticles()
        }
        
        // Haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.medium)
    }
    
    private func fadeOut() {
        withAnimation(.easeOut(duration: 0.6)) {
            fluidOpacity = 0
            morphingScale = 0.95
            glowIntensity = 0
        }
    }
    
    private func generateParticles() {
        let particleCount = 12
        var positions: [CGPoint] = []
        
        for i in 0..<particleCount {
            let angle = (Double(i) / Double(particleCount)) * 2 * .pi
            let radius = CGFloat.random(in: 80...150)
            let x = cos(angle) * radius + 200
            let y = sin(angle) * radius + 100
            positions.append(CGPoint(x: x, y: y))
        }
        
        withAnimation(.easeInOut(duration: 0.8)) {
            particlePositions = positions
        }
    }
}

// MARK: - Liquid Flow Background

struct LiquidFlowBackground: View {
    let colors: [Color]
    let offset: CGFloat
    let opacity: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    LiquidWaveShape(
                        offset: offset + Double(index) * 0.3,
                        amplitude: 20 + CGFloat(index) * 10,
                        frequency: 1.5 + Double(index) * 0.5
                    )
                    .fill(
                        LinearGradient(
                            colors: [
                                colors[index % colors.count].opacity(0.3),
                                colors[(index + 1) % colors.count].opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(opacity)
                }
            }
        }
    }
}

// MARK: - Liquid Wave Shape

struct LiquidWaveShape: Shape {
    let offset: Double
    let amplitude: CGFloat
    let frequency: Double
    
    var animatableData: Double {
        get { offset }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let sine = sin(offset + relativeX * .pi * frequency)
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Persona Type Extension

extension PersonaType {
    var brandColors: [Color] {
        switch self {
        case .paige:
            return [Color(hex: "2ECC71"), Color(hex: "27AE60"), Color(hex: "1ABC9C")]
        case .drew:
            return [Color(hex: "3498DB"), Color(hex: "2980B9"), Color(hex: "1ABC9C")]
        case .charlie:
            return [Color(hex: "E74C3C"), Color(hex: "C0392B"), Color(hex: "E67E22")]
        case .viza:
            return [Color(hex: "9B59B6"), Color(hex: "8E44AD"), Color(hex: "3498DB")]
        case .scout:
            return [Color(hex: "F39C12"), Color(hex: "E67E22"), Color(hex: "D35400")]
        }
    }
}

// MARK: - Persona Type Definition

enum PersonaType: String, CaseIterable {
    case paige = "Paige"
    case drew = "Drew"
    case charlie = "Charlie"
    case viza = "Viza"
    case scout = "Scout"
}



// MARK: - Preview

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            LiquidWordmark(
                text: "HOMEY",
                persona: .paige,
                isStartup: true,
                isVisible: true
            )
            
            LiquidWordmark(
                text: "Paige",
                persona: .paige,
                isStartup: false,
                isVisible: true
            )
        }
    }
}