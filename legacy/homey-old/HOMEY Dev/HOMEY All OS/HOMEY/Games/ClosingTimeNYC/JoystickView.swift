
import SwiftUI

struct JoystickView: View {
    @Binding var vector: CGVector

    @State private var knobOffset = CGSize.zero

    var body: some View {
        GeometryReader { geo in
            let R = min(geo.size.width, geo.size.height) / 2
            ZStack {
                Circle().fill(.ultraThinMaterial).overlay(
                    Circle().stroke(.white.opacity(0.15), lineWidth: 1)
                )
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: R * 0.9, height: R * 0.9)

                Circle()
                    .fill(.white.opacity(0.9))
                    .frame(width: R * 0.5, height: R * 0.5)
                    .offset(knobOffset)
                    .shadow(radius: 6, y: 3)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                let p = g.location
                                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                                var dx = p.x - center.x
                                var dy = p.y - center.y
                                let dist = hypot(dx, dy)
                                let maxR = R * 0.6
                                if dist > maxR {
                                    let k = maxR / dist
                                    dx *= k; dy *= k
                                }
                                knobOffset = CGSize(width: dx, height: dy)
                                vector = CGVector(dx: dx / maxR, dy: dy / maxR)
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    knobOffset = .zero
                                }
                                vector = .zero
                            }
                    )
            }
        }
    }
}
