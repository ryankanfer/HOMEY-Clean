//
//  CTAButtonStyle.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/17/25.
//

// CTAButtonStyle.swift
import SwiftUI

public struct CTAButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Theme.ctaBg, in: Capsule())
            .foregroundStyle(Theme.ctaFg)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.3 : 0.2),
                radius: configuration.isPressed ? 4 : 8,
                y: configuration.isPressed ? 1 : 2
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    TRAEMotionSystem.shared.triggerHaptic(.medium)
                }
            }
    }
}
