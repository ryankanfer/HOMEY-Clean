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
}
