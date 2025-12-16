import SwiftUI

struct ViewportMargins: ViewModifier {
    @Environment(\.horizontalSizeClass) private var hClass
    @Environment(\.dynamicTypeSize) private var type

    func body(content: Content) -> some View {
        let base: CGFloat = (hClass == .compact) ? 16 : 24
        let extra: CGFloat = (type > .xxxLarge) ? 6 : 0
        let inset = base + extra

        content
            .safeAreaPadding(.horizontal, inset)
    }
}

extension View {
    func homeyViewportMargins() -> some View {
        modifier(ViewportMargins())
    }
}
