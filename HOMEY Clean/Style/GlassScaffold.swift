import SwiftUI

struct GlassScaffold<Content: View>: View {
    let items: [GlassFooterItem]
    let selectedTitle: String?
    let showFooterBackground: Bool
    let footerBottomPadding: CGFloat
    var onSelectPersona: (GlassFooterItem) -> Void
    var onLongPressPersona: ((GlassFooterItem) -> Void)?
    var onAskCTA: () -> Void
    private let iconSize: CGFloat = 34
    @ViewBuilder var content: Content

    init(
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

    var body: some View {
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

private struct GlassFooter: View {
    var title: String
    var ctaTitle: String
    var items: [GlassFooterItem]
    var selectedTitle: String?
    var showBackground: Bool
    var bottomPadding: CGFloat
    var onSelectItem: (GlassFooterItem) -> Void
    var onLongPressItem: ((GlassFooterItem) -> Void)?
    var onTapCTA: () -> Void
    private let iconSize: CGFloat = 34

    var body: some View {
        VStack(spacing: 14) {
            Capsule().fill(Color.primary.opacity(0.12))
                .frame(width: 36, height: 4)
                .padding(.top, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 28) {
                    ForEach(items) { item in
                        let isSelected = (item.title == selectedTitle)
                        VStack(spacing: 6) {
                            item.image
                                .resizable().scaledToFit()
                                .frame(width: iconSize, height: iconSize)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(
                                            isSelected ? Color.accentColor : Color.white.opacity(0.14),
                                            lineWidth: isSelected ? 2 : 1
                                        )
                                )
                                .shadow(radius: 0)
                                .scaleEffect(isSelected ? 1.04 : 1.0)
                                .animation(.spring(response: 0.28, dampingFraction: 0.85), value: isSelected)

                            Text(item.title)
                                .font(.footnote.weight(isSelected ? .semibold : .regular))
                                .opacity(0.9)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { onSelectItem(item) }
                        .onLongPressGesture(minimumDuration: 0.4) { onLongPressItem?(item) }
                    }
                }
                .padding(.horizontal, 20)
            }

            Button(action: onTapCTA) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(ctaTitle).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.bottom, bottomPadding)
        }
        .background(showBackground ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .ignoresSafeArea(edges: .bottom)
    }
}
