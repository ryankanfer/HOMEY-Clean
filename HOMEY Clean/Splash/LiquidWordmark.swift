import SwiftUI

public struct LiquidWordmark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var expand: Bool
    var text: String

    public init(text: String, expand: Binding<Bool>) {
        _expand = expand
        self.text = text
    }

    public var body: some View {
        ZStack {
            if reduceMotion {
                Text(text)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
            } else {
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in
                        ctx.blendMode = .plusLighter
                        ctx.addFilter(.blur(radius: 24))

                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let baseR: CGFloat = min(size.width, size.height) * 0.18
                        let count = 6
                        for i in 0 ..< count {
                            let phase = CGFloat(i) * .pi * 2 / CGFloat(count)
                            let rx = baseR * (1.0 + 0.25 * CGFloat(sin(t / 1.8 + Double(i))))
                            let ry = baseR * (1.0 + 0.25 * CGFloat(cos(t / 2.2 + Double(i))))
                            let angle = CGFloat(t / 1.6) + phase
                            let r = min(size.width, size.height) * 0.28
                            let px = center.x + r * cos(angle)
                            let py = center.y + r * sin(angle)
                            let blobRect = CGRect(x: px - rx, y: py - ry, width: rx * 2, height: ry * 2)
                            let color = Color.white.opacity(0.55 + 0.15 * Double(i % 2))
                            ctx.fill(Path(ellipseIn: blobRect), with: .color(color))
                        }
                    }
                    .compositingGroup()
                    .mask(
                        Text(text)
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .tracking(2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    )
                }
            }
        }
        .scaleEffect(expand ? 3.0 : 1.0)
        .opacity(expand ? 0 : 1)
    }
}
