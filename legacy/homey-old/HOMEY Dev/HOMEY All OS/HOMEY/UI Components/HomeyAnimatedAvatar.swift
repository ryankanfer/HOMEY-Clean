import SwiftUI

/// Lightweight avatar view. Uses your `HomeyKind` model but doesn’t assume any API.
struct HomeyAnimatedAvatar: View {
    enum Size { case tiny, small, medium, large }

    let homey: HomeyKind
    let size: Size
    var lottieNameOverride: String?

    init(homey: HomeyKind, size: Size = .medium, lottieName: String? = nil) {
        self.homey = homey
        self.size = size
        self.lottieNameOverride = lottieName
    }

    private var dimension: CGFloat {
        switch size {
        case .tiny:   return 28
        case .small:  return 40
        case .medium: return 56
        case .large:  return 80
        }
    }

    var body: some View {
        ZStack {
            // Glassy token
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle().stroke(
                        LinearGradient(colors: [.white.opacity(0.7), .cyan.opacity(0.45), .clear],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                )
                .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)

            // Placeholder glyph—swap for Lottie or a custom image when ready.
            Image(systemName: "person.fill")
                .font(.system(size: dimension * 0.45, weight: .semibold))
                .opacity(0.9)
        }
        .frame(width: dimension, height: dimension)
        .contentShape(Circle())
    }
}
