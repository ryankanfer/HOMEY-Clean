import SwiftUI

/// A scaffold that places content above a glass-like footer bar.
struct GlassScaffold<Content: View>: View {
    let footerItems: [GlassFooterItem]
    let content: Content

    init(footerItems: [GlassFooterItem], @ViewBuilder content: () -> Content) {
        self.footerItems = footerItems
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
            HStack {
                ForEach(footerItems) { item in
                    VStack {
                        Image(systemName: item.systemImage)
                        Text(item.title)
                            .font(Typography.button)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.white.opacity(0.3))
        }
    }
}

extension View {
    /// Wraps the view in a `GlassScaffold` with the given footer items.
    func withGlassScaffold(_ items: [GlassFooterItem]) -> GlassScaffold<Self> {
        GlassScaffold(footerItems: items) { self }
    }
}
