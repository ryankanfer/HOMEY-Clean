//
//  TRAEPageTransitions.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Page transition system for smooth navigation between Homey dashboards
//

import SwiftUI

// MARK: - Transition Types

enum TRAETransitionType {
    case fade
    case slide(direction: TRAESlideDirection)
    case push(direction: TRAESlideDirection)
    case scale
    case flip
    case cube
    case liquid
    case morphing
    
    var duration: Double {
        switch self {
        case .fade: return 0.4
        case .slide: return 0.5
        case .push: return 0.6
        case .scale: return 0.4
        case .flip: return 0.7
        case .cube: return 0.8
        case .liquid: return 0.9
        case .morphing: return 1.0
        }
    }
}

enum TRAESlideDirection {
    case left, right, up, down
    
    var offset: CGSize {
        switch self {
        case .left: return CGSize(width: -UIScreen.main.bounds.width, height: 0)
        case .right: return CGSize(width: UIScreen.main.bounds.width, height: 0)
        case .up: return CGSize(width: 0, height: -UIScreen.main.bounds.height)
        case .down: return CGSize(width: 0, height: UIScreen.main.bounds.height)
        }
    }
}

// MARK: - Dashboard Types

enum TRAEDashboardType: String, CaseIterable {
    case paige = "Paige"
    case charlie = "Charlie"
    case drew = "Drew"
    case viza = "Viza"
    case insights = "Insights"
    case settings = "Settings"
    
    var color: Color {
        switch self {
        case .paige: return .blue
        case .charlie: return .green
        case .drew: return .orange
        case .viza: return .purple
        case .insights: return .pink
        case .settings: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .paige: return "doc.text.fill"
        case .charlie: return "house.fill"
        case .drew: return "person.2.fill"
        case .viza: return "eye.fill"
        case .insights: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - TRAE Page Transition Container

struct TRAEPageTransitionContainer<Content: View>: View {
    let content: Content
    let transitionType: TRAETransitionType
    let isPresented: Bool
    
    @State private var animationProgress: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0
    @State private var blur: CGFloat = 0
    @State private var liquidOffset: CGFloat = 0
    @State private var morphingScale: CGFloat = 1.0
    
    init(
        transitionType: TRAETransitionType = .fade,
        isPresented: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.transitionType = transitionType
        self.isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(scale)
            .offset(offset)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation), anchor: .center)
            .blur(radius: blur)
            .overlay(
                // Liquid transition overlay
                Group {
                    if case .liquid = transitionType {
                        LiquidTransitionOverlay(progress: animationProgress)
                    } else {
                        EmptyView()
                    }
                }
            )
            .overlay(
                // Morphing particles
                Group {
                    if case .morphing = transitionType {
                        MorphingParticlesOverlay(progress: animationProgress)
                    } else {
                        EmptyView()
                    }
                }
            )
            .onAppear {
                if isPresented {
                    startEnterAnimation()
                } else {
                    startExitAnimation()
                }
            }
            .onChange(of: isPresented) { presented in
                if presented {
                    startEnterAnimation()
                } else {
                    startExitAnimation()
                }
            }
    }
    
    // MARK: - Animation Methods
    
    private func startEnterAnimation() {
        // Set initial state
        setInitialState()
        
        // Trigger haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.light)
        
        // Animate to final state
        withAnimation(.spring(response: transitionType.duration, dampingFraction: 0.8)) {
            setFinalState()
            animationProgress = 1.0
        }
    }
    
    private func startExitAnimation() {
        withAnimation(.spring(response: transitionType.duration * 0.8, dampingFraction: 0.9)) {
            setExitState()
            animationProgress = 0.0
        }
    }
    
    private func setInitialState() {
        switch transitionType {
        case .fade:
            opacity = 0.0
            
        case .slide(let direction):
            offset = direction.offset
            
        case .push(let direction):
            offset = direction.offset
            scale = 0.9
            
        case .scale:
            scale = 0.1
            opacity = 0.0
            
        case .flip:
            rotation = 90
            scale = 0.8
            
        case .cube:
            rotation = -90
            offset = CGSize(width: -100, height: 0)
            
        case .liquid:
            liquidOffset = -200
            opacity = 0.3
            
        case .morphing:
            morphingScale = 0.1
            blur = 10
        }
    }
    
    private func setFinalState() {
        opacity = 1.0
        scale = 1.0
        offset = .zero
        rotation = 0
        blur = 0
        liquidOffset = 0
        morphingScale = 1.0
    }
    
    private func setExitState() {
        switch transitionType {
        case .fade:
            opacity = 0.0
            
        case .slide(let direction):
            let exitDirection = TRAESlideDirection.right // Opposite direction
            offset = exitDirection.offset
            
        case .push(let direction):
            let exitDirection = TRAESlideDirection.right
            offset = exitDirection.offset
            scale = 1.1
            
        case .scale:
            scale = 1.2
            opacity = 0.0
            
        case .flip:
            rotation = -90
            scale = 0.8
            
        case .cube:
            rotation = 90
            offset = CGSize(width: 100, height: 0)
            
        case .liquid:
            liquidOffset = 200
            opacity = 0.3
            
        case .morphing:
            morphingScale = 0.1
            blur = 10
        }
    }
}

// MARK: - Liquid Transition Overlay

struct LiquidTransitionOverlay: View {
    let progress: Double
    
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let waveHeight: CGFloat = 30
                let waveLength: CGFloat = width / 2
                
                let progressHeight = height * (1 - progress)
                
                path.move(to: CGPoint(x: 0, y: progressHeight))
                
                for x in stride(from: 0, through: width, by: 1) {
                    let relativeX = x / waveLength
                    let sine = sin(relativeX * .pi * 2 + waveOffset)
                    let y = progressHeight + sine * waveHeight * progress
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                waveOffset = .pi * 2
            }
        }
    }
}

// MARK: - Morphing Particles Overlay

struct MorphingParticlesOverlay: View {
    let progress: Double
    
    @State private var particles: [MorphingParticle] = []
    
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
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<20).map { _ in
            MorphingParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 4...12),
                color: [.blue, .purple, .pink, .orange].randomElement() ?? .blue,
                opacity: Double.random(in: 0.3...0.8),
                scale: CGFloat.random(in: 0.5...1.5)
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            for i in particles.indices {
                particles[i].position.x += CGFloat.random(in: -50...50)
                particles[i].position.y += CGFloat.random(in: -50...50)
                particles[i].scale = CGFloat.random(in: 0.3...1.8)
                particles[i].opacity = Double.random(in: 0.2...0.9)
            }
        }
    }
}

struct MorphingParticle {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
    var scale: CGFloat
}

// MARK: - TRAE Navigation Controller

class TRAENavigationController: ObservableObject {
    @Published var currentDashboard: TRAEDashboardType = .paige
    @Published var isTransitioning: Bool = false {
        didSet {
            if isTransitioning != oldValue {
                coordinateHeroAndTransition()
            }
        }
    }
    @Published var transitionType: TRAETransitionType = .slide(direction: .right)
    @Published var isHeroDisplaying: Bool = false { // Hero-safe mode flag
        didSet {
            if isHeroDisplaying != oldValue {
                coordinateHeroAndTransition()
            }
        }
    }
    
    private var transitionHistory: [TRAEDashboardType] = []
    
    // MARK: - State Coordination
    private func coordinateHeroAndTransition() {
        // Ensure hero and transition states are properly coordinated
        if isHeroDisplaying && isTransitioning {
            // Prioritize hero display over complex transitions
            transitionType = .fade
        }
    }
    
    func navigateTo(
        _ dashboard: TRAEDashboardType,
        transition: TRAETransitionType = .slide(direction: .right)
    ) {
        guard !isTransitioning else { return }
        
        // Use simplified transition if hero is displaying
        let safeTransition = isHeroDisplaying ? .fade : transition
        
        // Add current dashboard to history
        transitionHistory.append(currentDashboard)
        
        // Set transition type
        transitionType = safeTransition
        
        // Start transition
        isTransitioning = true
        
        // Trigger haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.medium)
        
        // Update current dashboard after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.currentDashboard = dashboard
        }
        
        // End transition
        DispatchQueue.main.asyncAfter(deadline: .now() + safeTransition.duration) {
            self.isTransitioning = false
        }
    }
    
    // MARK: - Hero Safe Mode
    func setHeroDisplaying(_ displaying: Bool) {
        isHeroDisplaying = displaying
        
        // Coordinate with transition state
        if displaying && isTransitioning {
            // If hero starts displaying during transition, simplify transition
            transitionType = .fade
        }
    }
    
    func safeNavigateTo(_ dashboard: TRAEDashboardType, transition: TRAETransitionType = .slide(direction: .right)) {
         // Coordinate states before navigation
         coordinateHeroAndTransition()
         navigateTo(dashboard, transition: transition)
     }
    
    func goBack() {
        guard let previousDashboard = transitionHistory.popLast() else { return }
        
        navigateTo(
            previousDashboard,
            transition: .slide(direction: .left)
        )
    }
    
    func canGoBack() -> Bool {
        return !transitionHistory.isEmpty
    }
}

// MARK: - TRAE Dashboard Container

struct TRAEDashboardContainer<Content: View>: View {
    @StateObject private var navigationController = TRAENavigationController()
    let content: (TRAEDashboardType) -> Content
    
    init(@ViewBuilder content: @escaping (TRAEDashboardType) -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            // Background gradient based on current dashboard
            LinearGradient(
                colors: [
                    navigationController.currentDashboard.color.opacity(0.1),
                    navigationController.currentDashboard.color.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Dashboard content with transition
            TRAEPageTransitionContainer(
                transitionType: navigationController.isHeroDisplaying ? .fade : navigationController.transitionType,
                isPresented: !navigationController.isTransitioning
            ) {
                content(navigationController.currentDashboard)
            }
            
            // Navigation overlay
            VStack {
                HStack {
                    if navigationController.canGoBack() {
                        Button(action: navigationController.goBack) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(navigationController.currentDashboard.color)
                        }
                        .traeInteractive(type: .button)
                    }
                    
                    Spacer()
                    
                    Text(navigationController.currentDashboard.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(navigationController.currentDashboard.color)
                    
                    Spacer()
                    
                    // Dashboard switcher
                    Menu {
                        ForEach(TRAEDashboardType.allCases, id: \.rawValue) { dashboard in
                            Button(dashboard.rawValue) {
                                let direction: TRAESlideDirection = dashboard.rawValue > navigationController.currentDashboard.rawValue ? .right : .left
                                navigationController.navigateTo(
                                    dashboard,
                                    transition: .slide(direction: direction)
                                )
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(navigationController.currentDashboard.color)
                    }
                    .traeInteractive(type: .button)
                }
                .padding()
                
                Spacer()
            }
        }
        .environmentObject(navigationController)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE page transition
    func traePageTransition(
        type: TRAETransitionType = .fade,
        isPresented: Bool = true
    ) -> some View {
        TRAEPageTransitionContainer(
            transitionType: type,
            isPresented: isPresented
        ) {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    TRAEDashboardContainer { dashboard in
        VStack(spacing: 20) {
            Image(systemName: dashboard.icon)
                .font(.system(size: 60))
                .foregroundColor(dashboard.color)
            
            Text("\(dashboard.rawValue) Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This is the \(dashboard.rawValue.lowercased()) dashboard with TRAE transitions.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Sample transition buttons
            VStack(spacing: 12) {
                Button("Fade Transition") {
                    // Demo transition
                }
                .traeButtonStyle()
                
                Button("Slide Transition") {
                    // Demo transition
                }
                .traeButtonStyle()
                
                Button("Liquid Transition") {
                    // Demo transition
                }
                .traeButtonStyle()
            }
        }
        .padding()
    }
}