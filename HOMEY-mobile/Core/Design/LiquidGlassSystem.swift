//
//  LiquidGlassSystem.swift
//  HOMEY Clean
//
//  Liquid Glass Design System, updated to integrate with the centralized Theme.
//  Created by Trae AI on 1/27/25.
//

import SwiftUI

// MARK: - Liquid Glass View Modifier

/// A modifier that applies a "liquid glass" effect to any view.
/// It uses a translucent material, a soft tint, a subtle border, and an optional shadow.
struct LiquidGlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tintColor: Color
    let shadowEnabled: Bool

    /// Initializes the modifier with specific styling options.
    /// - Parameters:
    ///   - cornerRadius: The corner radius for the glass surface.
    ///   - tintColor: A color to gently tint the glass. Defaults to the theme's surface color.
    ///   - shadowEnabled: A boolean to control the visibility of the drop shadow.
    init(
        cornerRadius: CGFloat = 20,
        tintColor: Color = Theme.surface,
        shadowEnabled: Bool = true
    ) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.shadowEnabled = shadowEnabled
    }

    func body(content: Content) -> some View {
        content
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                // A subtle, shimmering gradient overlay to add depth.
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.1),
                                .clear,
                                .black.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                // The soft, glowing border that defines the glass edge.
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: shadowEnabled ? .black.opacity(0.1) : .clear,
                radius: shadowEnabled ? 10 : 0,
                x: 0,
                y: shadowEnabled ? 4 : 0
            )
    }
}

// MARK: - View Extension for Easy Application

extension View {
    
    /// Applies the standard HOMEY liquid glass effect to the view.
    /// - Parameters:
    ///   - cornerRadius: The corner radius for the.
    ///   - tintColor: A color to gently tint the glass.
    ///   - shadowEnabled: A boolean to control the visibility of the drop shadow.
    /// - Returns: A view with the liquid glass effect applied.
    func liquidGlass(
        cornerRadius: CGFloat = 20,
        tintColor: Color = Theme.surface,
        shadowEnabled: Bool = true
    ) -> some View {
        self.modifier(
            LiquidGlassModifier(
                cornerRadius: cornerRadius,
                tintColor: tintColor,
                shadowEnabled: shadowEnabled
            )
        )
    }
}

// MARK: - Liquid Glass Card Component

/// A reusable card component that applies the liquid glass effect to its content.
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let tintColor: Color

    /// Initializes the card with content and styling options.
    /// - Parameters:
    ///   - cornerRadius: The corner radius for the glass surface.
    ///   - tintColor: A color to gently tint the glass.
    ///   - content: The view builder for the card's content.
    init(
        cornerRadius: CGFloat = 20,
        tintColor: Color = Theme.surface,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
    }

    var body: some View {
        content
            .padding()
            .liquidGlass(
                cornerRadius: cornerRadius,
                tintColor: tintColor
            )
    }
}

// MARK: - Preview Provider

#if DEBUG
struct LiquidGlassSystem_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // A gradient background to showcase the transparency.
            LinearGradient(
                colors: [Theme.skyBlue, Theme.slateGray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                
                // Example using the LiquidGlassCard component.
                LiquidGlassCard() {
                    VStack {
                        Text("Welcome to HOMEY")
                            .homeyFont(.h2)
                            .foregroundColor(Theme.primaryText)
                        Text("Your personal concierge.")
                            .homeyFont(.body)
                            .foregroundColor(Theme.secondaryText)
                    }
                }
                
                // Example applying the modifier directly.
                Text("A Standalone Button")
                    .homeyFont(.button)
                    .foregroundColor(Theme.primaryText)
                    .padding()
                    .liquidGlass(
                        cornerRadius: 16,
                        tintColor: Theme.primaryAction.opacity(0.2)
                    )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
#endif