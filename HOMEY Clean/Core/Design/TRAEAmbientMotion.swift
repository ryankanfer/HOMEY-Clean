//
//  TRAEAmbientMotion.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Ambient background motion for day/night skyline and flowing ribbons
//

import SwiftUI

// MARK: - Ambient Motion Types

enum TRAEAmbientType {
    case dayNightSkyline
    case flowingRibbons
    case particleField
    case liquidWaves
    case geometricShapes
    case breathingGradient
    case floatingElements
    case energyField
}

// MARK: - Time of Day

enum TRAETimeOfDay {
    case dawn
    case morning
    case afternoon
    case dusk
    case night
    case midnight
    
    var colors: [Color] {
        switch self {
        case .dawn:
            return [.orange.opacity(0.3), .pink.opacity(0.2), .yellow.opacity(0.1)]
        case .morning:
            return [.blue.opacity(0.2), .cyan.opacity(0.15), .white.opacity(0.1)]
        case .afternoon:
            return [.blue.opacity(0.25), .white.opacity(0.2), .cyan.opacity(0.1)]
        case .dusk:
            return [.purple.opacity(0.3), .orange.opacity(0.2), .pink.opacity(0.15)]
        case .night:
            return [.indigo.opacity(0.4), .purple.opacity(0.3), .blue.opacity(0.2)]
        case .midnight:
            return [.black.opacity(0.6), .indigo.opacity(0.4), .purple.opacity(0.2)]
        }
    }
    
    var starOpacity: Double {
        switch self {
        case .dawn, .morning, .afternoon: return 0.0
        case .dusk: return 0.3
        case .night: return 0.7
        case .midnight: return 1.0
        }
    }
}

// MARK: - TRAE Day/Night Skyline

struct TRAEDayNightSkyline: View {
    @State private var currentTime: TRAETimeOfDay = .morning
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 0
    @State private var starTwinkle: Double = 0.5
    @State private var sunMoonPosition: CGFloat = 0.3
    @State private var gradientOffset: CGFloat = 0
    
    let autoTransition: Bool
    let transitionDuration: Double
    
    init(autoTransition: Bool = true, transitionDuration: Double = 30.0) {
        self.autoTransition = autoTransition
        self.transitionDuration = transitionDuration
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky gradient background
                LinearGradient(
                    colors: currentTime.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: gradientOffset)
                
                // Stars (visible at night)
                if currentTime.starOpacity > 0 {
                    ForEach(0..<50, id: \.self) { _ in
                        Circle()
                            .fill(.white)
                            .frame(width: CGFloat.random(in: 1...3))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height * 0.6)
                            )
                            .opacity(currentTime.starOpacity * starTwinkle)
                    }
                }
                
                // Sun/Moon
                Circle()
                    .fill(
                        RadialGradient(
                            colors: currentTime == .night || currentTime == .midnight ?
                                [.white, .gray.opacity(0.8)] :
                                [.yellow, .orange.opacity(0.8)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                    .position(
                        x: geometry.size.width * 0.8,
                        y: geometry.size.height * sunMoonPosition
                    )
                    .shadow(
                        color: currentTime == .night || currentTime == .midnight ? .white.opacity(0.3) : .yellow.opacity(0.5),
                        radius: 20
                    )
                
                // Clouds
                CloudShape()
                    .fill(.white.opacity(0.6))
                    .frame(width: 120, height: 40)
                    .position(
                        x: geometry.size.width * 0.2 + cloudOffset1,
                        y: geometry.size.height * 0.3
                    )
                
                CloudShape()
                    .fill(.white.opacity(0.4))
                    .frame(width: 80, height: 25)
                    .position(
                        x: geometry.size.width * 0.6 + cloudOffset2,
                        y: geometry.size.height * 0.2
                    )
                
                CloudShape()
                    .fill(.white.opacity(0.5))
                    .frame(width: 100, height: 30)
                    .position(
                        x: geometry.size.width * 0.4 + cloudOffset1 * 0.7,
                        y: geometry.size.height * 0.4
                    )
                
                // City silhouette
                CitysilhouetteShape()
                    .fill(
                        LinearGradient(
                            colors: [.black.opacity(0.8), .black.opacity(0.4)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: geometry.size.height * 0.3)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height - (geometry.size.height * 0.15)
                    )
            }
        }
        .onAppear {
            startAmbientAnimations()
            if autoTransition {
                startTimeTransition()
            }
        }
    }
    
    private func startAmbientAnimations() {
        // Cloud movement
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            cloudOffset1 = UIScreen.main.bounds.width
        }
        
        withAnimation(.linear(duration: 80).repeatForever(autoreverses: false)) {
            cloudOffset2 = UIScreen.main.bounds.width
        }
        
        // Star twinkling
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            starTwinkle = 1.0
        }
        
        // Gradient movement
        withAnimation(.linear(duration: 120).repeatForever(autoreverses: true)) {
            gradientOffset = 50
        }
    }
    
    private func startTimeTransition() {
        let timeSequence: [TRAETimeOfDay] = [.dawn, .morning, .afternoon, .dusk, .night, .midnight]
        var currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: transitionDuration, repeats: true) { _ in
            currentIndex = (currentIndex + 1) % timeSequence.count
            
            withAnimation(.easeInOut(duration: 5)) {
                currentTime = timeSequence[currentIndex]
                
                // Adjust sun/moon position based on time
                switch currentTime {
                case .dawn: sunMoonPosition = 0.7
                case .morning: sunMoonPosition = 0.4
                case .afternoon: sunMoonPosition = 0.2
                case .dusk: sunMoonPosition = 0.6
                case .night: sunMoonPosition = 0.3
                case .midnight: sunMoonPosition = 0.2
                }
            }
        }
    }
}

// MARK: - Cloud Shape

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create cloud shape with multiple circles
        path.addEllipse(in: CGRect(x: 0, y: height * 0.3, width: width * 0.4, height: height * 0.7))
        path.addEllipse(in: CGRect(x: width * 0.2, y: 0, width: width * 0.6, height: height))
        path.addEllipse(in: CGRect(x: width * 0.6, y: height * 0.2, width: width * 0.4, height: height * 0.8))
        
        return path
    }
}

// MARK: - City Silhouette Shape

struct CitysilhouetteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height))
        
        // Create building silhouettes
        let buildings = [
            (width: width * 0.1, height: height * 0.6),
            (width: width * 0.08, height: height * 0.8),
            (width: width * 0.12, height: height * 0.4),
            (width: width * 0.15, height: height * 0.9),
            (width: width * 0.1, height: height * 0.7),
            (width: width * 0.13, height: height * 0.5),
            (width: width * 0.11, height: height * 0.85),
            (width: width * 0.09, height: height * 0.6),
            (width: width * 0.14, height: height * 0.75)
        ]
        
        var currentX: CGFloat = 0
        
        for building in buildings {
            path.addLine(to: CGPoint(x: currentX, y: height - building.height))
            path.addLine(to: CGPoint(x: currentX + building.width, y: height - building.height))
            path.addLine(to: CGPoint(x: currentX + building.width, y: height))
            currentX += building.width
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - TRAE Flowing Ribbons

struct TRAEFlowingRibbons: View {
    @State private var ribbonOffset1: CGFloat = 0
    @State private var ribbonOffset2: CGFloat = 0
    @State private var ribbonOffset3: CGFloat = 0
    @State private var colorPhase: Double = 0
    
    let ribbonCount: Int
    let colors: [Color]
    
    init(ribbonCount: Int = 3, colors: [Color] = [.blue, .purple, .pink]) {
        self.ribbonCount = ribbonCount
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<ribbonCount, id: \.self) { index in
                    RibbonShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    colors[index % colors.count].opacity(0.6),
                                    colors[(index + 1) % colors.count].opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 60)
                        .offset(
                            x: getRibbonOffset(for: index),
                            y: CGFloat(index) * 80 - 40
                        )
                        .rotationEffect(.degrees(Double(index) * 15))
                        .blur(radius: 1)
                }
            }
        }
        .onAppear {
            startRibbonAnimations()
        }
    }
    
    private func getRibbonOffset(for index: Int) -> CGFloat {
        switch index {
        case 0: return ribbonOffset1
        case 1: return ribbonOffset2
        case 2: return ribbonOffset3
        default: return 0
        }
    }
    
    private func startRibbonAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            ribbonOffset1 = UIScreen.main.bounds.width + 200
        }
        
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            ribbonOffset2 = UIScreen.main.bounds.width + 200
        }
        
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            ribbonOffset3 = UIScreen.main.bounds.width + 200
        }
        
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
            colorPhase = 1.0
        }
    }
}

// MARK: - Ribbon Shape

struct RibbonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let waveHeight: CGFloat = height * 0.3
        
        path.move(to: CGPoint(x: 0, y: height / 2))
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4) * waveHeight
            path.addLine(to: CGPoint(x: x, y: height / 2 + sine))
        }
        
        // Create ribbon thickness
        for x in stride(from: width, through: 0, by: -2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4) * waveHeight
            path.addLine(to: CGPoint(x: x, y: height / 2 + sine + 20))
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - TRAE Particle Field

struct TRAEParticleField: View {
    @State private var particles: [AmbientParticle] = []
    
    let particleCount: Int
    let colors: [Color]
    
    init(particleCount: Int = 30, colors: [Color] = [.blue, .purple, .pink, .cyan]) {
        self.particleCount = particleCount
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [particle.color, particle.color.opacity(0.3)],
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size / 2
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .blur(radius: particle.blur)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            AmbientParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 2...8),
                color: colors.randomElement() ?? .blue,
                opacity: Double.random(in: 0.2...0.6),
                scale: CGFloat.random(in: 0.5...1.5),
                blur: CGFloat.random(in: 0...2)
            )
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            let duration = Double.random(in: 15...25)
            let delay = Double.random(in: 0...5)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    particles[i].position.x += CGFloat.random(in: -100...100)
                    particles[i].position.y += CGFloat.random(in: -100...100)
                }
                
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    particles[i].opacity = Double.random(in: 0.1...0.8)
                    particles[i].scale = CGFloat.random(in: 0.3...2.0)
                }
            }
        }
    }
}

struct AmbientParticle {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
    var scale: CGFloat
    let blur: CGFloat
}

// MARK: - TRAE Ambient Container

struct TRAEAmbientContainer<Content: View>: View {
    let content: Content
    let ambientType: TRAEAmbientType
    let intensity: Double
    
    init(
        ambientType: TRAEAmbientType = .particleField,
        intensity: Double = 0.5,
        @ViewBuilder content: () -> Content
    ) {
        self.ambientType = ambientType
        self.intensity = intensity
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Ambient background
            Group {
                switch ambientType {
                case .dayNightSkyline:
                    TRAEDayNightSkyline()
                case .flowingRibbons:
                    TRAEFlowingRibbons()
                case .particleField:
                    TRAEParticleField()
                case .liquidWaves:
                    TRAELiquidWaves()
                case .geometricShapes:
                    TRAEGeometricShapes()
                case .breathingGradient:
                    TRAEBreathingGradient()
                case .floatingElements:
                    TRAEFloatingElements()
                case .energyField:
                    TRAEEnergyField()
                }
            }
            .opacity(intensity)
            .allowsHitTesting(false)
            
            // Main content
            content
        }
    }
}

// MARK: - Additional Ambient Types (Simplified)

struct TRAELiquidWaves: View {
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                for y in stride(from: 0, through: height, by: 20) {
                    path.move(to: CGPoint(x: 0, y: y))
                    
                    for x in stride(from: 0, through: width, by: 2) {
                        let wave = sin((x + waveOffset) * 0.01) * 10
                        path.addLine(to: CGPoint(x: x, y: y + wave))
                    }
                }
            }
            .stroke(.blue.opacity(0.2), lineWidth: 1)
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                waveOffset = 1000
            }
        }
    }
}

struct TRAEGeometricShapes: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.purple.opacity(0.3), lineWidth: 2)
                    .frame(width: 60, height: 60)
                    .position(
                        x: geometry.size.width * CGFloat(index) / 5,
                        y: geometry.size.height / 2
                    )
                    .rotationEffect(.degrees(rotation + Double(index) * 72))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct TRAEBreathingGradient: View {
    @State private var breathe: Double = 0.5
    
    var body: some View {
        RadialGradient(
            colors: [.blue.opacity(breathe * 0.3), .purple.opacity(breathe * 0.2)],
            center: .center,
            startRadius: 0,
            endRadius: 300
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                breathe = 1.0
            }
        }
    }
}

struct TRAEFloatingElements: View {
    var body: some View {
        TRAEParticleField(particleCount: 15, colors: [.cyan, .mint, .teal])
    }
}

struct TRAEEnergyField: View {
    var body: some View {
        TRAEFlowingRibbons(ribbonCount: 5, colors: [.yellow, .orange, .red])
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE ambient motion background
    func traeAmbientMotion(
        type: TRAEAmbientType = .particleField,
        intensity: Double = 0.5
    ) -> some View {
        TRAEAmbientContainer(
            ambientType: type,
            intensity: intensity
        ) {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("Ambient Motion Demo")
            .font(.largeTitle)
            .fontWeight(.bold)
        
        Text("Background shows flowing ambient motion")
            .font(.body)
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .traeAmbientMotion(type: .dayNightSkyline, intensity: 0.7)
}