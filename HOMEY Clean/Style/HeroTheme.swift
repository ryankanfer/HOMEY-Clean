import SwiftUI

// A separate “hero” theme for gradient-heavy headers and backgrounds.
// This keeps clear separation from the core Theme color tokens.
public struct HeroTheme: Sendable, Equatable {
    public let top: Color
    public let bottom: Color
    public let accent: Color

    public init(top: Color, bottom: Color, accent: Color) {
        self.top = top
        self.bottom = bottom
        self.accent = accent
    }
}

// Map each Homie to a gradient pair used by big headers or hero sections.
public func heroTheme(for kind: HomeyKind) -> HeroTheme {
    switch kind {
    case .charlie:
        return HeroTheme(
            top: Color(hex: 0xE6F0FF),
            bottom: Color(hex: 0xF6FAFF),
            accent: Color(hex: 0x3A7BD5)
        )
    case .paige:
        return HeroTheme(
            top: Color(hex: 0xFFF7E6),
            bottom: Color(hex: 0xFFFDF7),
            accent: Color(hex: 0xC2A977)
        )
    case .scout:
        return HeroTheme(
            top: Color(hex: 0xE9FFF4),
            bottom: Color(hex: 0xF7FFFB),
            accent: Color(hex: 0x2BB673)
        )
    case .isla:
        return HeroTheme(
            top: Color(hex: 0xFFF0EC),
            bottom: Color(hex: 0xFFF7F5),
            accent: Color(hex: 0xF26B5B)
        )
    case .viza:
        return HeroTheme(
            top: Color(hex: 0xFFF2F3),
            bottom: Color(hex: 0xFFF9FA),
            accent: Color(hex: 0xE6A0A2)
        )
    case .drew:
        return HeroTheme(
            top: Color(hex: 0xEEF3F3),
            bottom: Color(hex: 0xF8FBFB),
            accent: Color(hex: 0x2F4F4F)
        )
    }
}

// A convenience view that paints a full-bleed gradient using a HeroTheme.
public struct GradientBackground: View {
    public let theme: HeroTheme

    public init(theme: HeroTheme) {
        self.theme = theme
    }

    public var body: some View {
        LinearGradient(
            colors: [theme.top, theme.bottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// Tiny hex helper so we don’t write RGB fractions like maniacs.
public extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
