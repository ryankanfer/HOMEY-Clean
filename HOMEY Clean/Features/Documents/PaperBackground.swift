import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct PaperBackground: View {
    var tint: Color = .black
    var intensity: Double = 0.08   // Overall grain visibility (0.0 - 1.0)
    var vignette: Double = 0.35    // Edge darkening (0.0 - 1.0)

    var body: some View {
        ZStack {
            // Base subtle gradient to avoid flatness
            LinearGradient(
                colors: [tint.opacity(0.98), tint.opacity(1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle grain overlaid; tuned for dark UI
            NoiseTexture()
                .blendMode(.overlay)
                .opacity(intensity)
                .allowsHitTesting(false)
                .ignoresSafeArea()

            // Soft vignette to add depth
            RadialGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(vignette)],
                center: .center,
                startRadius: 0,
                endRadius: 800
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }
}

private struct NoiseTexture: View {
    @State private var image: Image? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color.clear
                        .onAppear {
                            // Generate once and cache in state
                            image = generateNoiseImage(size: CGSize(width: 512, height: 512))
                        }
                }
            }
        }
    }

    private func generateNoiseImage(size: CGSize) -> Image? {
        let context = CIContext(options: nil)
        let random = CIFilter.randomGenerator()

        guard var output = random.outputImage else { return nil }

        // Crop to a manageable tile size and blur slightly to soften speckles
        let rect = CGRect(origin: .zero, size: size)
        output = output.cropped(to: rect)

        let blur = CIFilter.gaussianBlur()
        blur.inputImage = output
        blur.radius = 0.8
        guard let blurred = blur.outputImage?.cropped(to: rect) else { return nil }

        // Convert to CGImage and wrap in SwiftUI Image
        guard let cg = context.createCGImage(blurred, from: rect) else { return nil }
        return Image(decorative: cg, scale: 1, orientation: .up)
    }
}

extension View {
    /// Convenience to place a paper background behind any view.
    func paperBackground(tint: Color = .black, intensity: Double = 0.08, vignette: Double = 0.35) -> some View {
        background(PaperBackground(tint: tint, intensity: intensity, vignette: vignette))
    }
}
