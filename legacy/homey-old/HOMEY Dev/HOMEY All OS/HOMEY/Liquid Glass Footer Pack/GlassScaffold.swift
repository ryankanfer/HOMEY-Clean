import SwiftUI

public struct GlassScaffold<Content: View>: View {
    let items: [GlassFooterItem]
    let selectedTitle: String?
    let showFooterBackground: Bool
    let footerBottomPadding: CGFloat
    var onSelectPersona: (GlassFooterItem) -> Void
    var onLongPressPersona: ((GlassFooterItem) -> Void)?
    var onAskCTA: () -> Void
    @ViewBuilder var content: Content

    public init(
        items: [GlassFooterItem],
        selectedTitle: String? = nil,
        showFooterBackground: Bool = true,
        footerBottomPadding: CGFloat = 8,
        onSelectPersona: @escaping (GlassFooterItem) -> Void = { _ in },
        onLongPressPersona: ((GlassFooterItem) -> Void)? = nil,
        onAskCTA: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.items = items
        self.selectedTitle = selectedTitle
        self.showFooterBackground = showFooterBackground
        self.footerBottomPadding = footerBottomPadding
        self.onSelectPersona = onSelectPersona
        self.onLongPressPersona = onLongPressPersona
        self.onAskCTA = onAskCTA
        self.content = content()
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                content
                    .padding(.bottom, 12)

                GlassFooter(
                    title: "Ask",
                    ctaTitle: "Ask \(selectedTitle ?? "Charlie")",
                    items: items,
                    selectedTitle: selectedTitle,
                    showBackground: showFooterBackground,
                    bottomPadding: footerBottomPadding,
                    onSelectItem: onSelectPersona,
                    onLongPressItem: onLongPressPersona,
                    onTapCTA: onAskCTA
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
