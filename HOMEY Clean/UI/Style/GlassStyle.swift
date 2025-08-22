//
//  GlassStyle.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/19/25.
//

import SwiftUI

public struct GlassSurface: ViewModifier {
    var corner: CGFloat = 22
    public func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 0.8)
                    .blendMode(.plusLighter)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
    }
}

public extension View { func glassCard(corner: CGFloat = 22) -> some View { modifier(GlassSurface(corner: corner)) } }
