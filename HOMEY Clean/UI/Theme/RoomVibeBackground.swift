import SwiftUI

public struct RoomVibeBackground: View {
    public let kind: HomeyKind
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(kind: HomeyKind) { self.kind = kind }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let speed = reduceMotion ? 0.0 : 0.22

            let points = movingPoints(t: t, speed: speed)

            ZStack {
                LinearGradient(
                    colors: palette(for: kind),
                    startPoint: points.start,
                    endPoint: points.end
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [Color.white.opacity(0.16), Color.clear],
                    center: .init(
                        x: 0.55 + 0.1 * sin(t * speed * 0.9),
                        y: 0.45 + 0.08 * cos(t * speed * 0.7)
                    ),
                    startRadius: 20,
                    endRadius: 540
                )
                .blendMode(.plusLighter)
                .ignoresSafeArea()

                LinearGradient(
                    colors: [Color.black.opacity(0.08), Color.clear, Color.black.opacity(0.10)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }

    private func palette(for kind: HomeyKind) -> [Color] {
        switch kind {
        case .charlie:
            return [
                Color(red: 1.00, green: 0.96, blue: 0.88),
                Color(red: 1.00, green: 0.92, blue: 0.78),
                Color(red: 0.98, green: 0.98, blue: 0.96)
            ]
        case .paige:
            return [
                Color(red: 0.98, green: 0.97, blue: 0.94),
                Color(red: 0.95, green: 0.96, blue: 0.99),
                Color(red: 0.98, green: 0.98, blue: 1.00)
            ]
        case .scout:
            return [
                Color(red: 0.86, green: 0.97, blue: 0.94),
                Color(red: 0.80, green: 0.94, blue: 0.90),
                Color(red: 0.93, green: 1.00, blue: 0.98)
            ]
        case .isla:
            return [
                Color(red: 0.98, green: 0.92, blue: 0.94),
                Color(red: 0.97, green: 0.86, blue: 0.90),
                Color(red: 0.99, green: 0.96, blue: 0.98)
            ]
        case .viza:
            return [
                Color(red: 0.99, green: 0.90, blue: 0.88),
                Color(red: 0.98, green: 0.86, blue: 0.92),
                Color(red: 1.00, green: 0.96, blue: 0.95)
            ]
        case .drew:
            return [
                Color(red: 0.90, green: 0.94, blue: 0.98),
                Color(red: 0.86, green: 0.90, blue: 0.96),
                Color(red: 0.94, green: 0.97, blue: 0.99)
            ]
        }
    }

    private func movingPoints(t: TimeInterval, speed: Double) -> (start: UnitPoint, end: UnitPoint) {
        let sx = 0.2 + 0.15 * sin(t * speed * 0.8)
        let sy = 0.1 + 0.12 * cos(t * speed * 0.7)
        let ex = 0.8 + 0.12 * cos(t * speed * 0.9)
        let ey = 0.9 + 0.10 * sin(t * speed * 0.6)
        return (start: UnitPoint(x: sx, y: sy), end: UnitPoint(x: ex, y: ey))
    }
}
