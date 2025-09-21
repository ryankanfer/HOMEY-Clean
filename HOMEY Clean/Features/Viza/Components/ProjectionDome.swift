//
//  ProjectionDome.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI

struct ProjectionDome: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var ambientGlow: CGFloat = 0.5
    @State private var reflectionOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Base dome structure
            baseDome
            
            // Environmental overlays
            environmentalOverlays
            
            // Lighting effects
            lightingEffects
             
            // Reflection patterns
            reflectionPatterns
            
            // Content projections
            contentProjections
            
            // Transition effects
            transitionEffects
        }
        .frame(width: 200, height: 120)
        .onAppear {
            startAmbientAnimations()
        }
        .onChange(of: viewModel.currentDomeEffect) { _ in
            triggerTransition()
        }
    }
    
    // MARK: - Base Dome Structure
    
    private var baseDome: some View {
        ZStack {
            // Main dome shape
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.clear,
                            Color.black.opacity(0.2)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
            
            // Dome rim
            Ellipse()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            
            // Inner dome surface
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            viewModel.currentDomeEffect?.ambientColor.opacity(0.3) ?? Color.clear,
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .scaleEffect(pulseScale)
        }
    }
    
    // MARK: - Environmental Overlays
    
    private var environmentalOverlays: some View {
        ZStack {
            if let domeEffect = viewModel.currentDomeEffect {
                // Scene-specific overlay
                environmentalOverlay(for: domeEffect)
                
                // Atmospheric effects
                atmosphericEffects(for: domeEffect)
            }
        }
        .opacity(viewModel.domeTransitionProgress)
    }
    
    private func environmentalOverlay(for effect: DomeEffect) -> some View {
        Group {
            switch effect.lightingEffect {
            case .cool:
                industrialOverlay
            case .natural:
                minimalistOverlay
            case .warm:
                cozyLuxeOverlay
            case .dramatic:
                industrialOverlay
            }
        }
    }
    
    private var industrialOverlay: some View {
        ZStack {
            // Geometric patterns
            ForEach(0..<6, id: \.self) { index in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 2, height: 40)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(index) * 30 + rotationAngle))
            }
            
            // Industrial glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    )
                )
                .scaleEffect(0.8)
        }
    }
    
    private var minimalistOverlay: some View {
        ZStack {
            // Clean lines
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                .scaleEffect(0.6)
            
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                .scaleEffect(0.8)
            
            // Minimal glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 15,
                        endRadius: 60
                    )
                )
        }
    }
    
    private var cozyLuxeOverlay: some View {
        ZStack {
            // Warm particles
            ForEach(0..<12, id: \.self) { index in
                let angle = Double(index) * .pi / 6 + rotationAngle * .pi / 180
                let xOffset = cos(angle) * 30
                let yOffset = sin(angle) * 15
                
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 3, height: 3)
                    .offset(x: xOffset, y: yOffset)
            }
            
            // Luxe glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.4),
                            Color.yellow.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 70
                    )
                )
        }
    }
    
    private func atmosphericEffects(for effect: DomeEffect) -> some View {
        ZStack {
            // Ambient particles
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * .pi / 4 + rotationAngle * .pi / 360
                let xOffset = cos(angle) * 40
                let yOffset = sin(angle) * 20
                
                Circle()
                    .fill(effect.ambientColor.opacity(0.2))
                    .frame(width: 2, height: 2)
                    .offset(x: xOffset, y: yOffset)
                    .opacity(ambientGlow)
            }
        }
    }
    
    // MARK: - Lighting Effects
    
    private var lightingEffects: some View {
        ZStack {
            if let lightingEffect = viewModel.currentDomeEffect?.lightingEffect {
                lightingOverlay(for: lightingEffect)
            }
        }
    }
    
    private func lightingOverlay(for lighting: LightingEffect) -> some View {
        Group {
            switch lighting {
            case .warm:
                softLightEffect
            case .cool:
                ambientLightEffect
            case .dramatic:
                dramaticLightEffect
            case .natural:
                ambientLightEffect
            }
        }
    }
    
    private var spotlightEffect: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.6),
                        Color.white.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 5,
                    endRadius: 40
                )
            )
            .scaleEffect(0.7)
            .blur(radius: 1)
    }
    
    private var ambientLightEffect: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.2),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: 3)
    }
    
    private var dramaticLightEffect: some View {
        ZStack {
            // Sharp light rays
            ForEach(0..<4, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1, height: 60)
                    .rotationEffect(.degrees(Double(index) * 45 + rotationAngle))
            }
        }
    }
    
    private var softLightEffect: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 90
                )
            )
            .blur(radius: 5)
    }
    
    // MARK: - Reflection Patterns
    
    private var reflectionPatterns: some View {
        ZStack {
            // Surface reflections
            ForEach(0..<3, id: \.self) { index in
                Ellipse()
                    .stroke(
                        Color.white.opacity(reflectionOpacity * 0.3),
                        lineWidth: 1
                    )
                    .scaleEffect(0.3 + Double(index) * 0.2)
                    .opacity(reflectionOpacity)
            }
            
            // Dynamic reflections based on palette
            if let palette = viewModel.selectedPalette {
                paletteReflections(for: palette)
            }
        }
    }
    
    private func paletteReflections(for palette: ColorPalette) -> some View {
        ZStack {
            // Primary color reflection
            Circle()
                .stroke(
                    palette.primaryColor.opacity(0.3),
                    lineWidth: 2
                )
                .scaleEffect(0.4)
                .rotationEffect(.degrees(rotationAngle))
            
            // Accent color highlights
            ForEach(0..<6, id: \.self) { index in
                let angle = Double(index) * .pi / 3 + rotationAngle * .pi / 180
                let xOffset = cos(angle) * 25
                let yOffset = sin(angle) * 12
                
                Circle()
                    .fill(palette.accentColor.opacity(0.2))
                    .frame(width: 2, height: 2)
                    .offset(x: xOffset, y: yOffset)
            }
        }
    }
    
    // MARK: - Content Projections
    
    private var contentProjections: some View {
        ZStack {
            // Progression moment projections
            if viewModel.showingProgressionMoment,
               let moment = viewModel.currentProgressionMoment {
                progressionProjection(for: moment)
            }
            
            // Scene preset indicators
            if let preset = viewModel.selectedPreset {
                presetIndicator(for: preset)
            }
        }
    }
    
    private func progressionProjection(for moment: ProgressionMoment) -> some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            moment.celebrationColor.opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .scaleEffect(viewModel.showingProgressionMoment ? 1.2 : 0.8)
            
            // Text projection
            Text(moment.domeProjection)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                .scaleEffect(viewModel.showingProgressionMoment ? 1.0 : 0.5)
                .opacity(viewModel.showingProgressionMoment ? 1.0 : 0.0)
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: viewModel.showingProgressionMoment)
    }
    
    private func presetIndicator(for preset: ScenePreset) -> some View {
        Image(systemName: preset.vision.icon)
            .font(.title2)
            .foregroundColor(.white.opacity(0.4))
            .scaleEffect(0.8)
            .opacity(0.6)
    }
    
    // MARK: - Transition Effects
    
    private var transitionEffects: some View {
        ZStack {
            if viewModel.isTransitioning {
                // Crossfade overlay
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .scaleEffect(viewModel.isTransitioning ? 2.0 : 0.0)
                    .opacity(viewModel.isTransitioning ? 0.3 : 0.0)
                    .animation(.easeInOut(duration: 1.5), value: viewModel.isTransitioning)
            }
        }
    }
    
    // MARK: - Animation Methods
    
    private func startAmbientAnimations() {
        // Continuous rotation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
        
        // Ambient glow variation
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            ambientGlow = 0.8
        }
        
        // Reflection opacity variation
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            reflectionOpacity = 0.6
        }
    }
    
    private func triggerTransition() {
        // Smooth crossfade transition
        withAnimation(.easeInOut(duration: 1.5)) {
            viewModel.isTransitioning = true
        }
        
        // Reset transition state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                viewModel.isTransitioning = false
            }
        }
    }
}

// MARK: - Dome Effect Extensions

// MARK: - Supporting Extensions

extension DomeStyle {
    var icon: String {
        switch self {
        case .ambient:
            return "cloud.fill"
        case .dramatic:
            return "bolt.fill"
        case .cozy:
            return "house.fill"
        case .industrial:
            return "building.2"
        case .minimal:
            return "circle"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        ProjectionDome(viewModel: VizaVisionViewModel())
        
        // Different states preview
        HStack(spacing: 20) {
            ProjectionDome(viewModel: {
                let vm = VizaVisionViewModel()
                vm.currentDomeEffect = DomeEffect(
                    name: "Industrial",
                    lightingEffect: .dramatic,
                    ambientColor: .blue,
                    intensity: 0.8
                )
                return vm
            }())
            .frame(width: 120, height: 80)
            
            ProjectionDome(viewModel: {
                let vm = VizaVisionViewModel()
                vm.currentDomeEffect = DomeEffect(
                    name: "Cozy Luxe",
                    lightingEffect: .warm,
                    ambientColor: .orange,
                    intensity: 0.6
                )
                return vm
            }())
            .frame(width: 120, height: 80)
        }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
