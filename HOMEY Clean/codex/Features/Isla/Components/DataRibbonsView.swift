//
//  DataRibbonsView.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI

struct DataRibbonsView: View {
    @State private var ribbon1Offset: CGFloat = 0
    @State private var ribbon2Offset: CGFloat = 0
    @State private var ribbon3Offset: CGFloat = 0

    @State private var ribbon1Opacity: Double = 0.8
    @State private var ribbon2Opacity: Double = 0.8
    @State private var ribbon3Opacity: Double = 0.8

    @State private var oscillationPhase: Double = 0
    @State private var isVisible = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Ribbon 3 (Farthest - 70% speed)
                RibbonLayer(
                    imageName: "ribbon_03",
                    offset: ribbon3Offset,
                    opacity: ribbon3Opacity,
                    oscillation: sin(oscillationPhase * 0.7) * 15,
                    depth: 0.7
                )
                .zIndex(1)

                // Ribbon 2 (Middle - 90% speed)
                RibbonLayer(
                    imageName: "ribbon_02",
                    offset: ribbon2Offset,
                    opacity: ribbon2Opacity,
                    oscillation: sin(oscillationPhase * 0.9 + 2.1) * 20,
                    depth: 0.9
                )
                .zIndex(2)

                // Ribbon 1 (Nearest - 110% speed)
                RibbonLayer(
                    imageName: "ribbon_01",
                    offset: ribbon1Offset,
                    opacity: ribbon1Opacity,
                    oscillation: sin(oscillationPhase * 1.1 + 4.2) * 25,
                    depth: 1.1
                )
                .zIndex(3)
            }
        }
        .onAppear {
            isVisible = true

            guard !reduceMotion else { return }

            // Ribbon 1 - Left to right at 12 px/sec (110% speed)
            withAnimation(.linear(duration: 250).repeatForever(autoreverses: false)) {
                ribbon1Offset = 3000
            }

            // Ribbon 2 - Right to left at 8 px/sec (90% speed)
            withAnimation(.linear(duration: 350).repeatForever(autoreverses: false)) {
                ribbon2Offset = -2800
            }

            // Ribbon 3 - Left to right at 5 px/sec (70% speed)
            withAnimation(.linear(duration: 560).repeatForever(autoreverses: false)) {
                ribbon3Offset = 2800
            }

            // Oscillation animation
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: false)) {
                oscillationPhase = .pi * 4
            }

            // Alpha shimmer animations with delays
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                guard isVisible else { return }
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    ribbon1Opacity = 1.0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard isVisible else { return }
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    ribbon2Opacity = 1.0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                guard isVisible else { return }
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    ribbon3Opacity = 1.0
                }
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

struct RibbonLayer: View {
    let imageName: String
    let offset: CGFloat
    let opacity: Double
    let oscillation: Double
    let depth: Double

    @State private var sparkles: [SparkleParticle] = []

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Ribbon image (placeholder with gradient for now)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.blue.opacity(0.05),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 3000, height: 80)
                    .overlay(
                        // Glass highlight effect
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear,
                                        Color.white.opacity(0.2)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .opacity(opacity)
                    .offset(
                        x: offset,
                        y: oscillation
                    )
                    .scaleEffect(depth)

                // Sparkle particles
                ForEach(sparkles) { sparkle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: sparkle.size, height: sparkle.size)
                        .opacity(sparkle.opacity)
                        .position(sparkle.position)
                        .scaleEffect(sparkle.scale)
                }
            }
        }
        .onAppear {
            startSparkleAnimation()
        }
    }

    private func startSparkleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.33, repeats: true) { _ in
            addSparkle()
        }
    }

    private func addSparkle() {
        let newSparkle = SparkleParticle(
            position: CGPoint(
                x: CGFloat.random(in: 100 ... 2900),
                y: CGFloat.random(in: -40 ... 40)
            ),
            size: CGFloat.random(in: 2 ... 4),
            opacity: 0,
            scale: 0.5
        )

        sparkles.append(newSparkle)

        // Animate sparkle in
        withAnimation(.easeIn(duration: 0.3)) {
            if let index = sparkles.firstIndex(where: { $0.id == newSparkle.id }) {
                sparkles[index].opacity = 1.0
                sparkles[index].scale = 1.0
            }
        }

        // Animate sparkle out and remove
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                if let index = sparkles.firstIndex(where: { $0.id == newSparkle.id }) {
                    sparkles[index].opacity = 0
                    sparkles[index].scale = 0.5
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                sparkles.removeAll { $0.id == newSparkle.id }
            }
        }
    }
}

struct SparkleParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
}
