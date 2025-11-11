import SwiftUI

public struct LaunchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animateScroll = false
    @State private var showMain = false

    // When the marquee finishes (~5s), call this to move on (e.g., present Login)
    private let onFinished: (() -> Void)?

    public init(onFinished: (() -> Void)? = nil) {
        self.onFinished = onFinished
    }

    public var body: some View {
        // Portal-style splash: sources orbit and converge; swipe key unlock
        PortalSplashView(onUnlock: { onFinished?() })
    }
}

// MARK: - Scrolling Background Text

private struct ScrollingBackgroundText: View {
    let text: String
    let containerWidth: CGFloat
    let reduceMotion: Bool
    let animate: Bool
    let duration: Double
    let onComplete: () -> Void

    // Styling based on CSS:
    // font-size: 180px; weight: 900; color: rgba(255,255,255,0.08); letter-spacing: 40px;
    private var font: Font { .system(size: 180, weight: .black, design: .rounded) }
    private let opacity: CGFloat = 0.08
    private let letterSpacing: CGFloat = 40

    // Animation state
    @State private var offsetX: CGFloat = 0
    @State private var introVisible: Bool = false
    @State private var contentWidth: CGFloat = 0
    @State private var hasCompleted = false

    var body: some View {
        // Build a single-line text view and measure its width
        let base = Text(text)
            .font(font)
            .kerning(letterSpacing)
            .foregroundStyle(Color.white.opacity(opacity))
            .fixedSize() // prevent wrapping

        ZStack {
            // Two copies side-by-side for a seamless loop
            HStack(spacing: 0) {
                base
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    contentWidth = proxy.size.width
                                }
                                .onChange(of: proxy.size.width) { _, newValue in
                                    contentWidth = newValue
                                }
                        }
                    )
                base
            }
            .frame(height: contentHeightEstimate, alignment: .center)
            .offset(x: offsetX)
            // Intro fade/slide-in
            .opacity(introVisible ? 1 : 0)
            .offset(y: introVisible ? 0 : 12)
            .animation(.easeOut(duration: 0.6), value: introVisible)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            // Always show intro (no motion blur), but skip continuous scroll if reduceMotion is true
            introVisible = true

            guard !reduceMotion, animate else {
                // No motion: still call completion shortly so we advance
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if !hasCompleted {
                        hasCompleted = true
                        onComplete()
                    }
                }
                return
            }

            // Once we have the measured content width, start the marquee.
            // We animate by contentWidth so the loop is seamless.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                startMarquee()
            }
        }
    }

    private var contentHeightEstimate: CGFloat {
        // A rough estimate to constrain the HStack height so it stays a single row
        // Matches the font size roughly
        180
    }

    private func startMarquee() {
        // If the content width is zero (not measured yet), try again quickly.
        guard contentWidth > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                startMarquee()
            }
            return
        }

        // Single pass: animate exactly one contentWidth to the left.
        offsetX = 0
        withAnimation(.linear(duration: duration)) {
            offsetX = -contentWidth
        }

        // Fire completion at the end of the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if !hasCompleted {
                hasCompleted = true
                onComplete()
            }
        }
    }
}

// MARK: - Color Hex helper

fileprivate extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
