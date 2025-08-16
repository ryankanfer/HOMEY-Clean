import SwiftUI

public struct ThemeGradient {
    public let background: AnyShapeStyle   // for large backgrounds
    public let accent: AnyShapeStyle       // for pills, cards, headers

    public init(background: some ShapeStyle, accent: some ShapeStyle) {
        self.background = AnyShapeStyle(background)
        self.accent = AnyShapeStyle(accent)
    }
}

public extension HomeyKind {
    var gradients: ThemeGradient {
        switch self {
        case .charlie:
            return ThemeGradient(
                background: LinearGradient(
                    colors: [Color(hex: 0xE6F0FF), Color(hex: 0xF6FAFF)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                accent: LinearGradient(
                    colors: [Color(hex: 0x3A7BD5), Color(hex: 0x6FB7C5)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
        case .paige:
            return ThemeGradient(
                background: LinearGradient(
                    colors: [Color(hex: 0xFFF7E6), Color(hex: 0xFFFDF7)],
                    startPoint: .top, endPoint: .bottom
                ),
                accent: LinearGradient(
                    colors: [Color(hex: 0xC2A977), Color(hex: 0xE4D6B5)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
        case .scout:
            return ThemeGradient(
                background: LinearGradient(
                    colors: [Color(hex: 0xE9FFF4), Color(hex: 0xF7FFFB)],
                    startPoint: .top, endPoint: .bottom
                ),
                accent: LinearGradient(
                    colors: [Color(hex: 0x2BB673), Color(hex: 0x7FE0B1)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
        case .isla:
            return ThemeGradient(
                background: LinearGradient(
                    colors: [Color(hex: 0xFFF0EC), Color(hex: 0xFFF7F5)],
                    startPoint: .top, endPoint: .bottom
                ),
                accent: LinearGradient(
                    colors: [Color(hex: 0xF26B5B), Color(hex: 0xFFC0B9)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
        case .viza:
            return ThemeGradient(
                background: LinearGradient(
                    colors: [Color(hex: 0xFFF2F3), Color(hex: 0xFFF9FA)],
                    startPoint: .top, endPoint: .bottom
                ),
                accent: LinearGradient(
                    colors: [Color(hex: 0xE6A0A2), Color(hex: 0xF4C8A6)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
        case .drew:
            return ThemeGradient(
                background: LinearGradient(
                    colors: [Color(hex: 0xEEF3F3), Color(hex: 0xF8FBFB)],
                    startPoint: .top, endPoint: .bottom
                ),
                accent: LinearGradient(
                    colors: [Color(hex: 0x2F4F4F), Color(hex: 0x7A9A9A)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
        }
    }
}

public extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
