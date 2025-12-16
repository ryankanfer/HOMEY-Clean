//
// GlassCard.swift
import SwiftUI

/// Standardized glass card component with consistent styling
public struct GlassCard<Content: View>: View {
    private let content: Content
    private let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padCard()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

/// Convenience view modifier for glass card styling
public extension View {
    func glassCard(cornerRadius: CGFloat = 12) -> some View {
        GlassCard(cornerRadius: cornerRadius) {
            self
        }
    }
}

//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
