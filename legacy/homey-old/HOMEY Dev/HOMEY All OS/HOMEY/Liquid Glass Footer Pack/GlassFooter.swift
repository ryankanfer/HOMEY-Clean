import SwiftUI

public struct GlassFooter: View {
    public var title: String
    public var ctaTitle: String
    public var items: [GlassFooterItem]
    public var selectedTitle: String?
    public var showBackground: Bool
    public var bottomPadding: CGFloat
    public var onSelectItem: (GlassFooterItem) -> Void
    public var onLongPressItem: ((GlassFooterItem) -> Void)?
    public var onTapCTA: () -> Void

    public init(
        title: String = "Ask",
        ctaTitle: String = "Ask Charlie",
        items: [GlassFooterItem],
        selectedTitle: String? = nil,
        showBackground: Bool = true,
        bottomPadding: CGFloat = 8,
        onSelectItem: @escaping (GlassFooterItem) -> Void,
        onLongPressItem: ((GlassFooterItem) -> Void)? = nil,
        onTapCTA: @escaping () -> Void
    ) {
        self.title = title
        self.ctaTitle = ctaTitle
        self.items = items
        self.selectedTitle = selectedTitle
        self.showBackground = showBackground
        self.bottomPadding = bottomPadding
        self.onSelectItem = onSelectItem
        self.onLongPressItem = onLongPressItem
        self.onTapCTA = onTapCTA
    }

    public var body: some View {
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
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(isSelected ? Color.accentColor : Color.white.opacity(0.14),
                                                lineWidth: isSelected ? 2 : 1)
                                )
                                .shadow(color: isSelected ? .accentColor.opacity(0.25) : .black.opacity(0.08),
                                        radius: isSelected ? 12 : 8, x: 0, y: 4)
                                .scaleEffect(isSelected ? 1.06 : 1.0)
                                .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isSelected)

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
