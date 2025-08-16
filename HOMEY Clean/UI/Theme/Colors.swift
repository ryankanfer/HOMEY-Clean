//
//  ThemeColor.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


// UI/Theme/Colors.swift

import SwiftUI

// Global semantic colors you can use anywhere without caring about the brand
public enum ThemeColor {
    // App chrome
    public static let background = Color("Background", bundle: .main) // optional asset; falls back below
    public static let surface = Color("Surface", bundle: .main)
    public static let separator = Color.black.opacity(0.08)

    // Text
    public static let label = Color.primary
    public static let secondaryLabel = Color.secondary

    // Accents (neutral)
    public static let accentSoft = Color.primary.opacity(0.06)
    public static let accentMedium = Color.primary.opacity(0.12)
}

// Per-Homie palette. Tweak these once, use everywhere.
public struct HomiePalette: Sendable, Equatable {
    public let tint: Color       // buttons, badges, emphasis
    public let pill: Color       // soft backgrounds, chips
    public let onTint: Color     // text/icon on tinted surfaces

    public init(tint: Color, pill: Color, onTint: Color = .white) {
        self.tint = tint
        self.pill = pill
        self.onTint = onTint
    }
}



// Central switchboard: one place to define the brand for each tab
public extension HomeyKind {
    var palette: HomiePalette {
        switch self {
        case .charlie:
            // Calm concierge blue
            return HomiePalette(
                tint: Color(hex: 0x3A7BD5),
                pill: Color(hex: 0x3A7BD5).opacity(0.10)
            )
        case .paige:
            // Paperwork champagne
            return HomiePalette(
                tint: Color(hex: 0xC2A977),
                pill: Color(hex: 0xC2A977).opacity(0.12),
                onTint: .black
            )
        case .scout:
            // Search mint
            return HomiePalette(
                tint: Color(hex: 0x2BB673),
                pill: Color(hex: 0x2BB673).opacity(0.12)
            )
        case .isla:
            // Market coral
            return HomiePalette(
                tint: Color(hex: 0xF26B5B),
                pill: Color(hex: 0xF26B5B).opacity(0.14)
            )
        case .viza:
            // Design rose
            return HomiePalette(
                tint: Color(hex: 0xE6A0A2),
                pill: Color(hex: 0xE6A0A2).opacity(0.16),
                onTint: .black
            )
        case .drew:
            // Vendor slate
            return HomiePalette(
                tint: Color(hex: 0x2F4F4F),
                pill: Color(hex: 0x2F4F4F).opacity(0.12)
            )
        }
    }
}

// MARK: - Handy sugar

public extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
