import SwiftUI

/// Legacy-style launch screen (purely visual). No auth/session logic here.
public struct LaunchView: View {
    @State private var showMark = false
    @State private var fadeOut = false

    public init() {}

    public var body: some View {
        ZStack {
            // Soft gradient backdrop (tweak to match your legacy art direction)
            LinearGradient(
                colors: [
                    Color(.sRGB, red: 0.93, green: 0.96, blue: 0.99, opacity: 1.0),
                    Color(.sRGB, red: 0.84, green: 0.93, blue: 0.97, opacity: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                // App mark / wordmark. Replace with your asset names.
                Image("homey_logo")       // 64–96pt glyph
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                    .opacity(showMark ? 1 : 0)
                    .scaleEffect(showMark ? 1 : 0.82)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.05), value: showMark)

                Image("homey_logo")   // lockup text
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                    .opacity(showMark ? 1 : 0)
                    .offset(y: showMark ? 0 : 6)
                    .animation(.easeOut(duration: 0.35).delay(0.18), value: showMark)

                Text("in your pocket. on your side.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .opacity(showMark ? 1 : 0)
                    .offset(y: showMark ? 0 : 8)
                    .animation(.easeOut(duration: 0.35).delay(0.28), value: showMark)
            }
            .padding(.horizontal, 28)
            .opacity(fadeOut ? 0 : 1)
        }
        .onAppear {
            showMark = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HOMEY launching")
    }
}
