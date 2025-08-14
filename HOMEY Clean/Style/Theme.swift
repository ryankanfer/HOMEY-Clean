import SwiftUI

/// Typography primitives used throughout the app.
struct Typography {
    /// Font for prominent headers.
    static let header = Font.system(size: 28, weight: .bold)
    /// Font for buttons and smaller labels.
    static let button = Font.system(size: 16, weight: .semibold)
}

/// An animated linear gradient background that flips its colors over time.
struct GradientBackground: View {
    /// Top color of the gradient.
    var top: Color
    /// Bottom color of the gradient.
    var bottom: Color
    @State private var isFlipped = false

    var body: some View {
        LinearGradient(colors: currentColors,
                       startPoint: .top,
                       endPoint: .bottom)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true),
                       value: isFlipped)
            .onAppear { isFlipped.toggle() }
    }

    private var currentColors: [Color] {
        isFlipped ? [bottom, top] : [top, bottom]
    }

    /// Convenience accessor used in tests to verify the initial colors.
    var initialColors: [Color] { [top, bottom] }
    /// Convenience accessor used in tests to verify the toggled colors.
    var toggledColors: [Color] { [bottom, top] }
}

/// Simple header used on hero screens.
struct HeroHeader: View {
    var title: String
    var subtitle: String?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(Typography.header)
            if let subtitle {
                Text(subtitle)
                    .font(Typography.button)
            }
        }
    }
}

#Preview {
    VStack {
        HeroHeader(title: "Welcome", subtitle: "Subtitle")
        GradientBackground(top: .red, bottom: .blue)
    }
}
