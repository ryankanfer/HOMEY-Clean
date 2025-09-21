import SwiftUI
import Theme

public struct SectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    public init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title3).bold()
                Text(subtitle).font(.subheadline).foregroundStyle(Theme.textMuted)
            }
            content
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
