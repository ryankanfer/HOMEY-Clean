import SwiftUI

// MARK: - 3D Transform System for Immersive Reality Interface

/// Core 3D transformation system providing perspective and depth effects
struct ImmersiveTransformSystem {
    
    // MARK: - 3D Perspective Configuration
    struct PerspectiveConfig {
        let perspective: CGFloat
        let rotationSensitivity: CGFloat
        let maxRotation: CGFloat
        let dampingFactor: CGFloat
        
        static let `default` = PerspectiveConfig(
            perspective: 1000,
            rotationSensitivity: 0.02,
            maxRotation: 15,
            dampingFactor: 0.8
        )
        
        static let subtle = PerspectiveConfig(
            perspective: 1500,
            rotationSensitivity: 0.01,
            maxRotation: 8,
            dampingFactor: 0.9
        )
        
        static let dramatic = PerspectiveConfig(
            perspective: 800,
            rotationSensitivity: 0.03,
            maxRotation: 25,
            dampingFactor: 0.7
        )
    }
    
    // MARK: - 3D Transform Modifiers
    
    /// Creates a 3D perspective transform with mouse/touch tracking
    static func perspective3D(
        config: PerspectiveConfig = .default,
        rotationX: CGFloat = 0,
        rotationY: CGFloat = 0,
        rotationZ: CGFloat = 0,
        translation: CGSize = .zero,
        scale: CGFloat = 1.0
    ) -> some ViewModifier {
        Perspective3DModifier(
            config: config,
            rotationX: rotationX,
            rotationY: rotationY,
            rotationZ: rotationZ,
            translation: translation,
            scale: scale
        )
    }
    
    /// Creates floating animation with physics-based movement
    static func floatingAnimation(
        amplitude: CGFloat = 10,
        duration: Double = 3.0,
        phase: Double = 0
    ) -> some ViewModifier {
        FloatingAnimationModifier(
            amplitude: amplitude,
            duration: duration,
            phase: phase
        )
    }
    
    /// Creates dimensional depth layering
    static func dimensionalDepth(
        layer: Int,
        maxLayers: Int = 5
    ) -> some ViewModifier {
        DimensionalDepthModifier(layer: layer, maxLayers: maxLayers)
    }
}

// MARK: - 3D Perspective Modifier

private struct Perspective3DModifier: ViewModifier {
    let config: ImmersiveTransformSystem.PerspectiveConfig
    let rotationX: CGFloat
    let rotationY: CGFloat
    let rotationZ: CGFloat
    let translation: CGSize
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(rotationX),
                axis: (x: 1, y: 0, z: 0),
                anchor: .center,
                perspective: config.perspective
            )
            .rotation3DEffect(
                .degrees(rotationY),
                axis: (x: 0, y: 1, z: 0),
                anchor: .center,
                perspective: config.perspective
            )
            .rotation3DEffect(
                .degrees(rotationZ),
                axis: (x: 0, y: 0, z: 1),
                anchor: .center,
                perspective: config.perspective
            )
            .offset(translation)
            .scaleEffect(scale)
    }
}

// MARK: - Floating Animation Modifier

private struct FloatingAnimationModifier: ViewModifier {
    let amplitude: CGFloat
    let duration: Double
    let phase: Double
    
    @State private var animationOffset: CGFloat = 0
    @State private var rotationOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: animationOffset)
            .rotation3DEffect(
                .degrees(rotationOffset),
                axis: (x: 0, y: 0, z: 1),
                perspective: 1000
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(phase)
                ) {
                    animationOffset = amplitude
                    rotationOffset = 2
                }
            }
    }
}

// MARK: - Dimensional Depth Modifier

private struct DimensionalDepthModifier: ViewModifier {
    let layer: Int
    let maxLayers: Int
    
    private var depthOffset: CGFloat {
        CGFloat(layer) * 5
    }
    
    private var scaleEffect: CGFloat {
        1.0 - (CGFloat(layer) / CGFloat(maxLayers)) * 0.1
    }
    
    private var opacityEffect: Double {
        1.0 - (Double(layer) / Double(maxLayers)) * 0.2
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleEffect)
            .opacity(opacityEffect)
            .blur(radius: CGFloat(layer) * 0.5)
    }
}

// MARK: - Interactive 3D Card View

struct Interactive3DCard<Content: View>: View {
    let content: Content
    let config: ImmersiveTransformSystem.PerspectiveConfig
    
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    @State private var isHovered: Bool = false
    @State private var dragOffset: CGSize = .zero
    
    init(
        config: ImmersiveTransformSystem.PerspectiveConfig = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.config = config
        self.content = content()
    }
    
    var body: some View {
        content
            .modifier(
                ImmersiveTransformSystem.perspective3D(
                    config: config,
                    rotationX: rotationX,
                    rotationY: rotationY,
                    translation: dragOffset,
                    scale: isHovered ? 1.05 : 1.0
                )
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: rotationX)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: rotationY)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovered)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
            .onHover { hovering in
                isHovered = hovering
                if !hovering {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                        rotationX = 0
                        rotationY = 0
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newRotationY = value.translation.width * config.rotationSensitivity
                        let newRotationX = -value.translation.height * config.rotationSensitivity
                        
                        rotationY = max(-config.maxRotation, min(config.maxRotation, newRotationY))
                        rotationX = max(-config.maxRotation, min(config.maxRotation, newRotationX))
                        
                        dragOffset = CGSize(
                            width: value.translation.width * 0.1,
                            height: value.translation.height * 0.1
                        )
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                            rotationX = 0
                            rotationY = 0
                            dragOffset = .zero
                        }
                    }
            )
    }
}

// MARK: - Holographic Border Effect

struct HolographicBorder: View {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    
    @State private var rotation: Double = 0
    
    init(cornerRadius: CGFloat = 16, lineWidth: CGFloat = 2) {
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                AngularGradient(
                    colors: [
                        .cyan.opacity(0.8),
                        .purple.opacity(0.8),
                        .pink.opacity(0.8),
                        .blue.opacity(0.8),
                        .cyan.opacity(0.8)
                    ],
                    center: .center,
                    angle: .degrees(rotation)
                ),
                lineWidth: lineWidth
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 3.0)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Applies 3D perspective transformation
    func perspective3D(
        config: ImmersiveTransformSystem.PerspectiveConfig = .default,
        rotationX: CGFloat = 0,
        rotationY: CGFloat = 0,
        rotationZ: CGFloat = 0,
        translation: CGSize = .zero,
        scale: CGFloat = 1.0
    ) -> some View {
        self.modifier(
            ImmersiveTransformSystem.perspective3D(
                config: config,
                rotationX: rotationX,
                rotationY: rotationY,
                rotationZ: rotationZ,
                translation: translation,
                scale: scale
            )
        )
    }
    
    /// Applies floating animation
    func floatingAnimation(
        amplitude: CGFloat = 10,
        duration: Double = 3.0,
        phase: Double = 0
    ) -> some View {
        self.modifier(
            ImmersiveTransformSystem.floatingAnimation(
                amplitude: amplitude,
                duration: duration,
                phase: phase
            )
        )
    }
    
    /// Applies dimensional depth layering
    func dimensionalDepth(layer: Int, maxLayers: Int = 5) -> some View {
        self.modifier(
            ImmersiveTransformSystem.dimensionalDepth(
                layer: layer,
                maxLayers: maxLayers
            )
        )
    }
    
    /// Wraps content in an interactive 3D card
    func interactive3DCard(
        config: ImmersiveTransformSystem.PerspectiveConfig = .default
    ) -> some View {
        Interactive3DCard(config: config) {
            self
        }
    }
    
    /// Adds holographic border effect
    func holographicBorder(
        cornerRadius: CGFloat = 16,
        lineWidth: CGFloat = 2
    ) -> some View {
        self.overlay(
            HolographicBorder(
                cornerRadius: cornerRadius,
                lineWidth: lineWidth
            )
        )
    }
}