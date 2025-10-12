import SwiftUI

public struct AuthFieldStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                Theme.surface,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        colorScheme == .dark
                        ? Color.white.opacity(0.2)
                        : Color.black.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.2)
                    : Color.black.opacity(0.1),
                radius: colorScheme == .dark ? 8 : 6,
                x: 0,
                y: colorScheme == .dark ? 4 : 3
            )
    }
}

public extension View {
    func authFieldStyle() -> some View { modifier(AuthFieldStyle()) }
}

public struct PrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        let bg = Theme.primaryAction
        let fg = Theme.white
        return configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(fg)
            .background(
                (configuration.isPressed ? bg.opacity(0.9) : bg),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .shadow(color: bg.opacity(0.25), radius: 8, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.96 : 1)
    }
}