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
            .opacity(configuration.isPressed ? 0.85 : 1)
            .shadow(radius: 8, y: 2)
    }
}
