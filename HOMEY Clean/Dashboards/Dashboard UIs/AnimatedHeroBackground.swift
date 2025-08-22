//
//  AnimatedHeroBackground.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/17/25.
//
import SwiftUI

// AnimatedHeroBackground.swift
public struct AnimatedHeroBackground: View {
    public let theme: HeroTheme
    @State private var t: CGFloat = 0

    public init(theme: HeroTheme) { self.theme = theme }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            let speed = 0.35
            let phase = CGFloat(sin(seconds * speed))
            let phase2 = CGFloat(cos(seconds * speed * 0.8))

            LinearGradient(
                colors: [
                    theme.top.opacity(0.95),
                    theme.bottom.opacity(0.95),
                    theme.top.opacity(0.92)
                ],
                startPoint: UnitPoint(x: 0.15 + 0.15 * phase, y: 0.0),
                endPoint: UnitPoint(x: 0.85 + 0.10 * phase2, y: 1.0)
            )
            .ignoresSafeArea()
        }
    }
}
