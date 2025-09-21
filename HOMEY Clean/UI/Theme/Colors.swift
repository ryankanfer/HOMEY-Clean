import SwiftUI

// Global semantic colors derived from Theme tokens
public enum ThemeColor {
    // App chrome
    public static let background = Theme.background
    public static let surface = Color("Surface", bundle: .main)
    public static let separator = Color.black.opacity(0.08)

    // Text
    public static let label = Theme.text
    public static let secondaryLabel = Theme.textMuted

    // Accents (neutral)
    public static let accentSoft = Theme.primary.opacity(0.06)
    public static let accentMedium = Theme.primary.opacity(0.12)
    
    // Persona accent colors
    public static let charlieAccent = Color(hex: 0x3A7BD5)
    public static let paigeAccent = Color(hex: 0xC2A977)
    public static let scoutAccent = Color(hex: 0x2BB673)
    public static let islaAccent = Color(hex: 0xF26B5B)
    public static let vizaAccent = Color(hex: 0xE6A0A2)
    public static let drewAccent = Color(hex: 0x2F4F4F)
}

// MARK: - HomeyKind Color Extensions
public extension HomeyKind {
    /// Primary accent color for this persona
    var accentColor: Color {
        switch self {
        case .charlie: return ThemeColor.charlieAccent
        case .paige: return ThemeColor.paigeAccent
        case .scout: return ThemeColor.scoutAccent
        case .isla: return ThemeColor.islaAccent
        case .viza: return ThemeColor.vizaAccent
        case .drew: return ThemeColor.drewAccent
        }
    }
}
