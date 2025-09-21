import SwiftUI

struct LaunchView: View {
    var onFinished: (() -> Void)? = nil
    @State private var bgVisible = false
    @State private var logoVisible = false

    var body: some View {
        ZStack {
            // Background: gradient + time-of-day image
            ZStack {
                AnimatedGradient()
                Image("morning_welcome")
                    .resizable()
                    .scaledToFill()
            }
            .opacity(bgVisible ? 1 : 0)
            .ignoresSafeArea()

            // Centerpiece: Lottie if available, else logo
            VStack(spacing: 16) {
                #if canImport(Lottie)
                    LottieView(name: "homey_sparkle", loopMode: .playOnce, speed: 1.0)
                        .frame(width: 180, height: 180)
                        .accessibilityLabel(Text("HOMEY animation"))
                #else
                    Image("homey_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                #endif

                Text("in your pocket. on your side.")
                    .font(.headline)
                    .opacity(0.9)
            }
            .opacity(logoVisible ? 1 : 0)
            .scaleEffect(logoVisible ? 1 : 0.94)
        }
        .onAppear {
            bgVisible = false
            logoVisible = false
            withAnimation(.easeInOut(duration: 0.8)) { bgVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { logoVisible = true }
            }
            // Short, crisp hand-off
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { onFinished?() }
        }
    }
}
