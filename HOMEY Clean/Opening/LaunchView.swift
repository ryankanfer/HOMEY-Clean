import SwiftUI

public struct LaunchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appear = false
    @State private var showWordmark = false

    public init() {}

    public var body: some View {
        ZStack {
            Image("welcome_sunset")
                .resizable()
                .scaledToFill()
                .scaleEffect(reduceMotion ? 1.0 : (appear ? 1.08 : 1.02))
                .opacity(appear ? 1 : 0.6)
                .animation(reduceMotion ? .none : .easeInOut(duration: 1.2), value: appear)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
        }
        .onAppear {
            appear = true
            withAnimation(reduceMotion ? .none : .spring(response: 0.7, dampingFraction: 0.85)) {
                showWordmark = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HOMEY launching")
    }
}

private struct GlassWordmark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let text: String
    var visible: Bool

    var body: some View {
        let mark = Text(text)
            .font(.playfairDisplayBold(56))
            .tracking(2)
            .minimumScaleFactor(0.7)
            .lineLimit(1)

        return ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(mark)
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)

            LinearGradient(
                colors: [Color.white.opacity(0.95), Color.white.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .mask(mark)
            .opacity(0.65)
        }
        .opacity(visible ? 1 : 0)
        .scaleEffect(visible ? 1.0 : 0.96)
        .blur(radius: visible || reduceMotion ? 0 : 1.5)
        .animation(reduceMotion ? .none : .easeOut(duration: 0.5).delay(0.1), value: visible)
    }
}
