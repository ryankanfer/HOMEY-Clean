import SwiftUI

public struct GlassCardContent<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder var content: Content

    public init(cornerRadius: CGFloat = 18, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(LinearGradient(
                        colors: [Color.white.opacity(0.28), Color.white.opacity(0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1)
                    .blendMode(.plusLighter)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 0.8)
                    .blendMode(.plusLighter)
            )
            .overlay(
                NoiseOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .opacity(0.05)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
    }
}

private struct NoiseOverlay: View {
    var body: some View {
        LinearGradient(
            colors: [
                .white.opacity(0.6),
                .white.opacity(0.4),
                .white.opacity(0.6),
                .white.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.overlay)
    }
}
