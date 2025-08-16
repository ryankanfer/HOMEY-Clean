import SwiftUI

public struct AuthFieldStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        content
            .padding(14)
            .background(ThemeColor.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(
                color: (colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.05)),
                radius: 8,
                y: 2
            )
    }
}

public extension View {
    func authFieldStyle() -> some View { modifier(AuthFieldStyle()) }
}

public struct PrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(Color.white)
            .background(configuration.isPressed ? Theme.primary.opacity(0.85) : Theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}
