import SwiftUI

struct AnimatedGradient: View {
    let colors: [Color]
    let speed: Double
    
    @State private var animationOffset: CGFloat = 0
    @State private var timer: Timer?
    
    init(colors: [Color], speed: Double = 1.0) {
        self.colors = colors
        self.speed = speed
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            ForEach(0..<3, id: \.self) { index in
                AnimatedGradientLayer(
                    colors: colors,
                    offset: animationOffset + CGFloat(index) * 120,
                    opacity: 0.3 - Double(index) * 0.1
                )
            }
        }
        .onAppear { startAnimation() }
        .onDisappear { stopAnimation() }
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                animationOffset += CGFloat(speed * 2)
                if animationOffset > 360 {
                    animationOffset = 0
                }
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

struct AnimatedGradientLayer: View {
    let colors: [Color]
    let offset: CGFloat
    let opacity: Double
    
    var body: some View {
        LinearGradient(
            colors: colors.map { $0.opacity(opacity) },
            startPoint: UnitPoint(
                x: 0.5 + cos(offset * .pi / 180) * 0.5,
                y: 0.5 + sin(offset * .pi / 180) * 0.5
            ),
            endPoint: UnitPoint(
                x: 0.5 - cos(offset * .pi / 180) * 0.5,
                y: 0.5 - sin(offset * .pi / 180) * 0.5
            )
        )
        .blendMode(.overlay)
    }
}

// MARK: - Theme Extensions

extension ThemeManager {
    var currentTheme: GradientTheme {
        GradientTheme.default
    }
}

struct GradientTheme {
    let gradientColors: [Color]
    
    static let `default` = GradientTheme(
        gradientColors: [
            Color(red: 0.2, green: 0.4, blue: 0.8),
            Color(red: 0.4, green: 0.2, blue: 0.8),
            Color(red: 0.8, green: 0.2, blue: 0.6),
            Color(red: 0.8, green: 0.4, blue: 0.2)
        ]
    )
    
    static let ocean = GradientTheme(
        gradientColors: [
            Color(red: 0.1, green: 0.3, blue: 0.7),
            Color(red: 0.2, green: 0.5, blue: 0.8),
            Color(red: 0.3, green: 0.7, blue: 0.9),
            Color(red: 0.1, green: 0.4, blue: 0.6)
        ]
    )
    
    static let sunset = GradientTheme(
        gradientColors: [
            Color(red: 0.9, green: 0.4, blue: 0.2),
            Color(red: 0.8, green: 0.3, blue: 0.4),
            Color(red: 0.7, green: 0.2, blue: 0.6),
            Color(red: 0.9, green: 0.5, blue: 0.3)
        ]
    )
    
    static let forest = GradientTheme(
        gradientColors: [
            Color(red: 0.2, green: 0.6, blue: 0.3),
            Color(red: 0.3, green: 0.7, blue: 0.2),
            Color(red: 0.1, green: 0.5, blue: 0.4),
            Color(red: 0.4, green: 0.8, blue: 0.3)
        ]
    )
    
    static let aurora = GradientTheme(
        gradientColors: [
            Color(red: 0.2, green: 0.8, blue: 0.6),
            Color(red: 0.4, green: 0.6, blue: 0.9),
            Color(red: 0.6, green: 0.4, blue: 0.8),
            Color(red: 0.3, green: 0.9, blue: 0.7)
        ]
    )
}

// MARK: - Backdrop Modifier

#if os(iOS)
import UIKit

struct BackdropBlurView: UIViewRepresentable {
    let radius: CGFloat
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
#else
struct BackdropBlurView: View {
    let radius: CGFloat
    var body: some View { Color.black.opacity(0.05) }
}
#endif

extension View {
    func backdrop(blur radius: CGFloat) -> some View {
        self.background(BackdropBlurView(radius: radius))
    }
}

#Preview {
    AnimatedGradient(
        colors: GradientTheme.default.gradientColors,
        speed: 1.0
    )
    .ignoresSafeArea()
}