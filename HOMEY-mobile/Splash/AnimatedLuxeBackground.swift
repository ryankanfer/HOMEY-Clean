import SwiftUI

public struct AnimatedLuxeBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.14, blue: 0.18),
                        Color(red: 0.08, green: 0.10, blue: 0.12),
                        Color(red: 0.12, green: 0.16, blue: 0.20)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )

                Canvas { ctx, size in
                    ctx.addFilter(.blur(radius: 30))
                    ctx.addFilter(.colorMultiply(.white.opacity(0.25)))

                    let w = size.width, h = size.height
                    let speed = reduceMotion ? 0.0 : 0.35
                    for i in 0 ..< 5 {
                        let p = CGFloat(i) / 5.0
                        let x = w * (0.2 + 0.6 * CGFloat(sin(p * 6.28 + speed * t)))
                        let y = h * (0.2 + 0.6 * CGFloat(cos(p * 6.28 + speed * 1.2 * t)))
                        let r = min(w, h) * (0.25 + 0.1 * CGFloat(cos(p * 8 + speed * 0.8 * t)))
                        let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                        let color = Color(
                            hue: Double(0.58 + 0.08 * p),
                            saturation: 0.42,
                            brightness: 0.9,
                            opacity: 0.25
                        )
                        ctx.fill(Path(ellipseIn: rect), with: .color(color))
                    }
                }
                .blendMode(.plusLighter)
                .ignoresSafeArea()

                Color.black.opacity(0.20) // luxe depth
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
    }
}
