//
//  TRAEVisualAssets.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Copyright © 2024 HOMEY. All rights reserved.
//

import SwiftUI

// MARK: - Visual Assets and Effects

/// TRAE Glassmorphism Effects
struct TRAEGlassmorphism {
    
    /// Standard glassmorphism background
    static func background(
        opacity: Double = 0.1,
        blur: CGFloat = 20,
        cornerRadius: CGFloat = 16
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(opacity),
                        Color.white.opacity(opacity * 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
                    .background(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    /// Premium glassmorphism with enhanced effects
    static func premium(
        cornerRadius: CGFloat = 20,
        shadowRadius: CGFloat = 30
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
                    .background(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.2),
                                Color.white.opacity(0.4)
                            ],
                            center: .center
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: shadowRadius,
                x: 0,
                y: 15
            )
    }
    
    /// Floating glassmorphism card
    static func floatingCard(
        cornerRadius: CGFloat = 24
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
                    .background(.thickMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.clear,
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 15)
    }
}

/// TRAE Frosted Gradient Effects
struct TRAEFrostedGradients {
    
    /// Primary brand frosted gradient
    static var primary: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.6),
                Color.pink.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Secondary frosted gradient
    static var secondary: LinearGradient {
        LinearGradient(
            colors: [
                Color.teal.opacity(0.7),
                Color.blue.opacity(0.5),
                Color.indigo.opacity(0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Warm frosted gradient
    static var warm: RadialGradient {
        RadialGradient(
            colors: [
                Color.orange.opacity(0.6),
                Color.red.opacity(0.4),
                Color.pink.opacity(0.2)
            ],
            center: .center,
            startRadius: 0,
            endRadius: 150
        )
    }
    
    /// Cool frosted gradient
    static var cool: AngularGradient {
        AngularGradient(
            colors: [
                Color.cyan.opacity(0.6),
                Color.blue.opacity(0.4),
                Color.purple.opacity(0.3),
                Color.cyan.opacity(0.6)
            ],
            center: .center
        )
    }
    
    /// Subtle background gradient
    static var subtleBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.blue.opacity(0.02),
                Color.purple.opacity(0.01)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Dynamic gradient that changes based on time
    static func dynamic(phase: Double = 0) -> AngularGradient {
        AngularGradient(
            colors: [
                Color.blue.opacity(0.6 + sin(phase) * 0.2),
                Color.purple.opacity(0.4 + cos(phase * 1.2) * 0.2),
                Color.pink.opacity(0.3 + sin(phase * 0.8) * 0.2),
                Color.blue.opacity(0.6 + sin(phase) * 0.2)
            ],
            center: .center,
            startAngle: .degrees(phase * 30),
            endAngle: .degrees(360 + phase * 30)
        )
    }
}

/// TRAE Soft Shadow System
struct TRAESoftShadows {
    
    /// Subtle elevation shadow
    static func subtle(
        color: Color = Color.black,
        opacity: Double = 0.05,
        radius: CGFloat = 8,
        x: CGFloat = 0,
        y: CGFloat = 4
    ) -> some View {
        EmptyView()
            .shadow(
                color: color.opacity(opacity),
                radius: radius,
                x: x,
                y: y
            )
    }
    
    /// Medium elevation shadow
    static func medium(
        color: Color = Color.black,
        opacity: Double = 0.1,
        radius: CGFloat = 16,
        x: CGFloat = 0,
        y: CGFloat = 8
    ) -> some View {
        EmptyView()
            .shadow(
                color: color.opacity(opacity * 0.5),
                radius: radius * 0.5,
                x: x,
                y: y * 0.5
            )
            .shadow(
                color: color.opacity(opacity),
                radius: radius,
                x: x,
                y: y
            )
    }
    
    /// Strong elevation shadow
    static func strong(
        color: Color = Color.black,
        opacity: Double = 0.15,
        radius: CGFloat = 24,
        x: CGFloat = 0,
        y: CGFloat = 12
    ) -> some View {
        EmptyView()
            .shadow(
                color: color.opacity(opacity * 0.3),
                radius: radius * 0.3,
                x: x,
                y: y * 0.3
            )
            .shadow(
                color: color.opacity(opacity * 0.6),
                radius: radius * 0.6,
                x: x,
                y: y * 0.6
            )
            .shadow(
                color: color.opacity(opacity),
                radius: radius,
                x: x,
                y: y
            )
    }
    
    /// Floating shadow for cards
    static var floating: some View {
        EmptyView()
            .shadow(
                color: Color.black.opacity(0.03),
                radius: 4,
                x: 0,
                y: 2
            )
            .shadow(
                color: Color.black.opacity(0.06),
                radius: 12,
                x: 0,
                y: 6
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 24,
                x: 0,
                y: 12
            )
    }
    
    /// Pressed/inset shadow
    static var pressed: some View {
        EmptyView()
            .shadow(
                color: Color.black.opacity(0.2),
                radius: 4,
                x: 0,
                y: 1
            )
    }
    
    /// Glow effect shadow
    static func glow(
        color: Color = Color.blue,
        intensity: Double = 0.3,
        radius: CGFloat = 20
    ) -> some View {
        EmptyView()
            .shadow(
                color: color.opacity(intensity * 0.3),
                radius: radius * 0.3,
                x: 0,
                y: 0
            )
            .shadow(
                color: color.opacity(intensity * 0.6),
                radius: radius * 0.6,
                x: 0,
                y: 0
            )
            .shadow(
                color: color.opacity(intensity),
                radius: radius,
                x: 0,
                y: 0
            )
    }
}

/// TRAE Texture Generators
struct TRAETextures {
    
    /// Noise texture overlay
    static func noise(
        opacity: Double = 0.05,
        scale: CGFloat = 1.0
    ) -> some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            
            // Generate noise pattern
            for x in stride(from: 0, to: size.width, by: 2 * scale) {
                for y in stride(from: 0, to: size.height, by: 2 * scale) {
                    let randomOpacity = Double.random(in: 0...opacity)
                    let point = CGPoint(x: x, y: y)
                    let rect = CGRect(x: x, y: y, width: 2 * scale, height: 2 * scale)
                    
                    context.fill(
                        Path(rect),
                        with: .color(Color.white.opacity(randomOpacity))
                    )
                }
            }
        }
    }
    
    /// Grain texture
    static func grain(
        density: Int = 100,
        opacity: Double = 0.03
    ) -> some View {
        Canvas { context, size in
            for _ in 0..<density {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let radius = CGFloat.random(in: 0.5...1.5)
                let grainOpacity = Double.random(in: 0...opacity)
                
                let circle = Path(ellipseIn: CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
                
                context.fill(
                    circle,
                    with: .color(Color.white.opacity(grainOpacity))
                )
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE glassmorphism background
    func traeGlass(
        style: TRAEGlassStyle = .standard,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self.background(
            Group {
                switch style {
                case .standard:
                    TRAEGlassmorphism.background(cornerRadius: cornerRadius)
                case .premium:
                    TRAEGlassmorphism.premium(cornerRadius: cornerRadius)
                case .floating:
                    TRAEGlassmorphism.floatingCard(cornerRadius: cornerRadius)
                }
            }
        )
    }
    
    /// Apply TRAE soft shadow
    func traeShadow(
        style: TRAEShadowStyle = .medium
    ) -> some View {
        self.background(
            Group {
                switch style {
                case .subtle:
                    TRAESoftShadows.subtle()
                case .medium:
                    TRAESoftShadows.medium()
                case .strong:
                    TRAESoftShadows.strong()
                case .floating:
                    TRAESoftShadows.floating
                case .pressed:
                    TRAESoftShadows.pressed
                }
            }
        )
    }
    
    /// Apply TRAE frosted gradient overlay
    func traeFrosted(
        gradient: TRAEGradientStyle = .primary,
        opacity: Double = 0.1
    ) -> some View {
        self.overlay(
            Group {
                switch gradient {
                case .primary:
                    TRAEFrostedGradients.primary.opacity(opacity)
                case .secondary:
                    TRAEFrostedGradients.secondary.opacity(opacity)
                case .warm:
                    TRAEFrostedGradients.warm.opacity(opacity)
                case .cool:
                    TRAEFrostedGradients.cool.opacity(opacity)
                }
            }
        )
    }
    
    /// Apply TRAE texture overlay
    func traeTexture(
        type: TRAETextureStyle = .noise,
        opacity: Double = 0.05
    ) -> some View {
        self.overlay(
            Group {
                switch type {
                case .noise:
                    TRAETextures.noise(opacity: opacity)
                case .grain:
                    TRAETextures.grain(opacity: opacity)
                }
            }
        )
    }
}

// MARK: - Style Enums

enum TRAEGlassStyle {
    case standard
    case premium
    case floating
}

enum TRAEShadowStyle {
    case subtle
    case medium
    case strong
    case floating
    case pressed
}

enum TRAEGradientStyle {
    case primary
    case secondary
    case warm
    case cool
}

enum TRAETextureStyle {
    case noise
    case grain
}