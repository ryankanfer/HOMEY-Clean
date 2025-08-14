import SwiftUI

public struct GlassFooterItem: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let title: String
    public let imageName: String
    public init(title: String, imageName: String) {
        self.title = title
        self.imageName = imageName
    }
    public var image: Image { Image(imageName) }
}

@MainActor
public enum HomeyFooters {
    public static let items: [GlassFooterItem] = [
        .init(title: "Charlie", imageName: "charlieAvatar"),
        .init(title: "Paige",   imageName: "paigeAvatar"),
        .init(title: "Scout",   imageName: "scoutAvatar"),
        .init(title: "Isla",    imageName: "islaAvatar"),
        .init(title: "Viza",    imageName: "vizaAvatar"),
        .init(title: "Drew",    imageName: "drewAvatar"),
    ]
}

public extension View {
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
