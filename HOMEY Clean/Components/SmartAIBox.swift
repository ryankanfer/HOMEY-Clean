import SwiftUI

struct SmartAIBox: View {
    @StateObject private var recommendationEngine = RecommendationEngine()
    @State private var currentRecommendation: SmartRecommendation?
    @State private var isAnimating = false
    @State private var currentIndex = 0
    
    let context: RecommendationContext
    
    init(context: RecommendationContext = .dashboard) {
        self.context = context
    }

    var body: some View {
        Button(action: {
            // Handle tap action based on current message type
            handleAIBoxTap()
        }) {
            HStack(spacing: 12) {
                // AI indicator
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }

                // Message text
                VStack(alignment: .leading, spacing: 2) {
                    if let recommendation = currentRecommendation {
                        HStack(spacing: 4) {
                            Text(recommendation.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            // Priority indicator
                            Circle()
                                .fill(recommendation.priorityColor)
                                .frame(width: 6, height: 6)
                        }

                        Text(recommendation.subtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    } else {
                        Text("Loading recommendations...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.4),
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            startPulseAnimation()
            updateCurrentRecommendation()
        }
        .onReceive(recommendationEngine.$recommendations) { _ in
            updateCurrentRecommendation()
        }
    }

    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            isAnimating = true
        }
    }

    private func updateCurrentRecommendation() {
        let contextRecommendations = recommendationEngine.getRecommendationsFor(context: context)
        
        if !contextRecommendations.isEmpty {
            // Cycle through recommendations every 5 seconds
            currentRecommendation = contextRecommendations[currentIndex % contextRecommendations.count]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if !contextRecommendations.isEmpty {
                    currentIndex = (currentIndex + 1) % contextRecommendations.count
                    updateCurrentRecommendation()
                }
            }
        } else {
            // Fallback to any available recommendation
            currentRecommendation = recommendationEngine.recommendations.first
        }
    }

    private func handleAIBoxTap() {
        guard let recommendation = currentRecommendation else { return }
        
        // Mark as viewed
        recommendationEngine.markRecommendationAsViewed(recommendation)
        
        // Handle different recommendation types
        switch recommendation.type {
        case .financial:
            print("Navigate to financial tools - \(recommendation.actionTitle)")
        case .property:
            print("Navigate to property details - \(recommendation.actionTitle)")
        case .market:
            print("Navigate to market insights - \(recommendation.actionTitle)")
        case .task:
            print("Navigate to task management - \(recommendation.actionTitle)")
        case .design:
            print("Navigate to design tools - \(recommendation.actionTitle)")
        case .document:
            print("Navigate to document management - \(recommendation.actionTitle)")
        }
        
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        SmartAIBox()
            .padding()
    }
}
