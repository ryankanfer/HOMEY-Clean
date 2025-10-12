import SwiftUI

public struct LaunchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showContent = false
    @State private var rotation: Double = 0
    
    // Theme accent for subtle animated overlay
    private var themeAccent: Color {
        Theme.primaryAction
    }

    public init() {}

    public var body: some View {
        ZStack {
            // Using the existing themed gradient background for a premium feel
            LinearGradient(colors: [Theme.background, Theme.surface], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Animated, theme-colored angular gradient for subtle motion
            if !reduceMotion {
                AngularGradient(
                    gradient: Gradient(colors: [
                        themeAccent.opacity(0.20),
                        Color.clear,
                        themeAccent.opacity(0.10),
                        Color.clear
                    ]),
                    center: .center
                )
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: rotation)
                .opacity(0.14)
                .ignoresSafeArea()
                .accessibilityHidden(true)
            }

            // Soft vignette for readability
            LinearGradient(
                colors: [Color.black.opacity(0.20), .clear, Color.black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // "HOMEY" text, thin and branded
            Text("H O M E Y")
                .font(.system(size: 48, weight: .thin))
                .kerning(10) // Provides tracking effect
                .foregroundStyle(.white.opacity(0.9))
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.2), value: showContent)
        }
        .onAppear {
            showContent = true
            if !reduceMotion {
                rotation = 360
            }
        }
    }
}