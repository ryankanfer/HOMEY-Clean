import SwiftUI

struct GlassFooterItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let title: String
    let imageName: String

    init(title: String, imageName: String) {
        self.title = title
        self.imageName = imageName
    }

    var image: Image { Image(systemName: imageName) }
}

enum HomeyFooters {
    static let items: [GlassFooterItem] = [
        .init(title: "Charlie", imageName: "person.crop.circle"),
        .init(title: "Paige",   imageName: "person.crop.circle.fill"),
        .init(title: "Scout",   imageName: "person.2.crop.circle"),
        .init(title: "Isla",    imageName: "person.2.crop.circle.fill"),
        .init(title: "Viza",    imageName: "person.crop.square"),
        .init(title: "Drew",    imageName: "person.crop.square.fill"),
    ]
}

extension View {
    func withGlassScaffold(
        items: [GlassFooterItem] = HomeyFooters.items,
        selectedTitle: String? = nil,
        showFooterBackground: Bool = true,
        footerBottomPadding: CGFloat = 8,
        onSelectPersona: @escaping (GlassFooterItem) -> Void = { _ in },
        onLongPressPersona: ((GlassFooterItem) -> Void)? = nil,
        onAskCTA: @escaping () -> Void = {}
    ) -> some View {
        GlassScaffold(
            items: items,
            selectedTitle: selectedTitle,
            showFooterBackground: showFooterBackground,
            footerBottomPadding: footerBottomPadding,
            onSelectPersona: onSelectPersona,
            onLongPressPersona: onLongPressPersona,
            onAskCTA: onAskCTA
        ) { self }
    }
}