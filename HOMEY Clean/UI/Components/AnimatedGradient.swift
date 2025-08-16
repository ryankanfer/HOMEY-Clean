//
//  AnimatedGradient.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


import SwiftUI

public struct AnimatedGradient: View {
    @State private var t: CGFloat = 0
    public init() {}
    public var body: some View {
        TimelineView(.animation) { timeline in
            let _ = t = CGFloat(timeline.date.timeIntervalSinceReferenceDate).truncatingRemainder(dividingBy: 20)
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.96, blue: 1.0),
                    Color(red: 0.86, green: 0.93, blue: 0.98),
                    Color(red: 0.95, green: 0.98, blue: 0.96)
                ],
                startPoint: UnitPoint(x: 0.2 + 0.1 * sin(t/3), y: 0),
                endPoint: UnitPoint(x: 0.8 + 0.1 * cos(t/4), y: 1)
            )
        }
    }
}