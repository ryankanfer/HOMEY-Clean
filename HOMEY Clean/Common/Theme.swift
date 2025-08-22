//
//  Theme.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/16/25.
//

import SwiftUI

// Theme.swift (ensure tokens exist)
public enum Theme {
    // Core tokens
    public static let primary = Color("Primary")
    public static let text = Color("PrimaryText")
    public static let background = Color("Background")
    public static let accent = Color("Accent") // for TabBar tint
    public static let ctaBg = Color("CTABackground") // CTA background
    public static let ctaFg = Color("CTAForeground") // CTA foreground

    // Derived tokens
    public static let textMuted = text.opacity(0.6)

    // Back-compat for older references
    public static let primaryText = text
    public static let bg = background
}

public extension View {
    func themedCardBackground() -> some View {
        background(Theme.background)
    }

    func themedText() -> some View {
        foregroundStyle(Theme.text)
    }

    func themedMuted() -> some View {
        foregroundStyle(Theme.textMuted)
    }

    /// Tight padding for chips/pills (optional)
    func padPill() -> some View {
        padding(.horizontal, 8)
            .padding(.vertical, 4)
    }
}
