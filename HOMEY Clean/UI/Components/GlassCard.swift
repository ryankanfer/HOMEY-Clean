//
//  GlassCard.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI

/// A reusable "glass" card container with configurable styling.
/// Defaults preserve the earlier look: 18pt padding, 18pt radius, thin material, soft shadow.
public struct GlassCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let background: AnyShapeStyle
    private let shadowColor: Color
    private let shadowRadius: CGFloat
    private let shadowY: CGFloat
    private let fillWidth: Bool
    private let alignment: Alignment

    /// Create a GlassCard with configurable styling.
    /// - Parameters:
    ///   - padding: Content padding. Default 18.
    ///   - cornerRadius: Corner radius. Default 18.
    ///   - background: Background shape style (e.g. `.thinMaterial`, `Color`, gradients). Default `.thinMaterial`.
    ///   - shadowColor: Shadow color. Default `.black.opacity(0.06)`.
    ///   - shadowRadius: Shadow blur radius. Default `12`.
    ///   - shadowY: Vertical shadow offset. Default `6`.
    ///   - fillWidth: If `true`, expands to `maxWidth: .infinity`. Default `false`.
    ///   - alignment: Frame alignment when `fillWidth` is true. Default `.center`.
    public init(
        padding: CGFloat = 18,
        cornerRadius: CGFloat = 18,
        background: AnyShapeStyle = AnyShapeStyle(.thinMaterial),
        shadowColor: Color = .black.opacity(0.06),
        shadowRadius: CGFloat = 12,
        shadowY: CGFloat = 6,
        fillWidth: Bool = false,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.background = background
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
        self.fillWidth = fillWidth
        self.alignment = alignment
    }

    public var body: some View {
        let base = content
            .padding(padding)
            .background(background, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)

        if fillWidth {
            base.frame(maxWidth: .infinity, alignment: alignment)
        } else {
            base
        }
    }
}
