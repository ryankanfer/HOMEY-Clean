import SwiftUI

public struct LiquidGlassBackground: View {
    public init() {}
    public var body: some View { Color.clear.ignoresSafeArea() }
}

public struct GlossyGradient: View {
    public init() {}
    public var body: some View {
        LinearGradient(
            colors: [.white.opacity(0.12), .white.opacity(0.02)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

public struct GlassGroupBox<Content: View>: View {
    private let title: String
    @ViewBuilder private let content: Content

    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline).opacity(0.9)
            content
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

public struct GlassField: View {
    private let title: String
    @Binding private var text: String
    private let placeholder: String
    private let keyboard: UIKeyboardType

    public init(title: String, text: Binding<String>, placeholder: String = "", keyboard: UIKeyboardType = .default) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboard = keyboard
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).opacity(0.8)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

public struct GlassSecureField: View {
    private let title: String
    @Binding private var text: String
    private let placeholder: String

    public init(title: String, text: Binding<String>, placeholder: String = "") {
        self.title = title
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).opacity(0.8)
            SecureField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
