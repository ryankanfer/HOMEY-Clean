import SwiftUI

struct CircularMask: View {
    let size: LensSize
    let position: CGPoint
    let isDragging: Bool

    private var featherRadius: CGFloat {
        size.radius * 0.15 // 15% of radius for feather effect
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Main circular mask with feathered edge
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .clear, location: 0.7),
                                .init(color: .black.opacity(0.3), location: 0.85),
                                .init(color: .black.opacity(0.8), location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.radius
                        )
                    )
                    .frame(width: size.radius * 2, height: size.radius * 2)
                    .position(position)
                    .opacity(isDragging ? 0.7 : 0.9)
                    .animation(.easeInOut(duration: 0.2), value: isDragging)

                // Inner glow ring
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.2),
                                .clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size.radius * 1.8, height: size.radius * 1.8)
                    .position(position)
                    .opacity(isDragging ? 0.5 : 0.8)
                    .animation(.easeInOut(duration: 0.2), value: isDragging)
            }
            .drawingGroup() // Use Metal rendering for better performance
        }
    }
}

// MARK: - Modifiers

extension CircularMask {
    func withGlow(color: Color = .white, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Supporting Views

struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius)
            .shadow(color: color.opacity(0.2), radius: radius * 0.5)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        CircularMask(
            size: .medium,
            position: CGPoint(x: 200, y: 200),
            isDragging: false
        )
        .withGlow()
    }
}
