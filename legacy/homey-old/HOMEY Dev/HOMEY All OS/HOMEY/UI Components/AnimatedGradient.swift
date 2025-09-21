import SwiftUI

struct AnimatedGradient: View {
    @State private var idx = 0
    private let palettes: [[Color]] = [
        [.blue, .cyan, .purple, .mint],
        [.purple, .blue, .indigo, .green],
        [.green, .teal, .blue, .red],
        [.red, .pink, .purple, .orange],
        [.blue, .purple, .mint, .yellow],
        [.mint, .green, .blue, .purple],
    ]

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: palettes[idx]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation(.linear(duration: 3).repeatCount(1, autoreverses: true)) {
                    idx = (idx + 1) % palettes.count
                }
            }
        }
    }
}
