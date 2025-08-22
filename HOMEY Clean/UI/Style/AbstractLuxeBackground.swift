//
//  AbstractLuxeBackground.swift
//  HOMEY Clean
//
//  Updated to animated abstract‑luxe with moving color washes.
//

import SwiftUI

public struct AbstractLuxeBackground: View {
    /// Speed multiplier for ambient motion (0 = static).
    private let speed: Double
    /// Overall intensity of color washes.
    private let washOpacity: Double

    @State private var time: Double = 0

    public init(speed: Double = 0.25, washOpacity: Double = 0.16) {
        self.speed = speed
        self.washOpacity = washOpacity
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate * speed

            ZStack {
                // Base slate → champagne gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.16, blue: 0.20), // slate
                        Color(red: 0.95, green: 0.91, blue: 0.85) // champagne/ivory
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Ambient moving washes (pool blue, martini gold, blush coral)
                movingWash(
                    color: Color(red: 0.44, green: 0.72, blue: 0.77), // pool tile blue
                    radius: 260,
                    phase: 0.0,
                    t: t
                )
                movingWash(
                    color: Color(red: 0.83, green: 0.69, blue: 0.39), // martini gold
                    radius: 220,
                    phase: 1.7,
                    t: t
                )
                movingWash(
                    color: Color(red: 0.90, green: 0.55, blue: 0.51), // blush coral
                    radius: 240,
                    phase: 3.1,
                    t: t
                )
            }
            .overlay(.ultraThinMaterial.opacity(0.02)) // subtle veil
        }
    }

    /// A softly blurred, drifting radial wash.
    @ViewBuilder
    private func movingWash(color: Color, radius: CGFloat, phase: Double, t: Double) -> some View {
        let x = cos(t + phase)
        let y = sin(t * 0.9 + phase * 0.7)
        Circle()
            .fill(color.opacity(washOpacity))
            .frame(width: radius, height: radius)
            .blur(radius: radius / 2.8)
            .offset(x: x * radius * 0.6, y: y * radius * 0.6)
            .allowsHitTesting(false)
    }
}
