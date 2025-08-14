import SwiftUI

struct GlassRootOverlay<Content: View>: View {
    @ViewBuilder var content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        ZStack {
            GlassBackground()
            content
        }
    }
}
