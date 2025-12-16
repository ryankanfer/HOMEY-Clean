import SwiftUI

extension Theme {
    public static func heroGradient(for kind: HomeyKind) -> LinearGradient {
        let theme = heroTheme(for: kind)
        return LinearGradient(
            colors: [theme.top, theme.bottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}