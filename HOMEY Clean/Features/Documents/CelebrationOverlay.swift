import SwiftUI

struct CelebrationOverlay: View {
    @Binding var showCelebration: Bool
    @Binding var celebrationScale: CGFloat
    @Binding var confettiOffset: CGFloat
    @Binding var sparkleRotation: Double
    
    var body: some View {
        ZStack {
            // Confetti particles
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(randomColor)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: confettiOffset + CGFloat.random(in: -50...50)
                    )
                    .opacity(showCelebration ? 1 : 0)
            }
            
            // Success icon and message
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(celebrationScale)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(sparkleRotation))
                }
                
                Text("Document Uploaded! 🎉")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .scaleEffect(celebrationScale)
            }
        }
        .allowsHitTesting(false)
    }
    
    private var randomColor: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}