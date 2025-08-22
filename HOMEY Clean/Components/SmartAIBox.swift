import SwiftUI

struct SmartAIBox: View {
    @State private var currentMessage: AIMessage = .defaultMessage
    @State private var isAnimating = false

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
                    Text(currentMessage.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(currentMessage.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
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
            updateMessageBasedOnState()
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

    private func updateMessageBasedOnState() {
        // This would be connected to app state in a real implementation
        // For now, we'll cycle through different message types
        let messages: [AIMessage] = [
            .boardInterview,
            .missingTaxReturn,
            .documentReady,
            .marketUpdate
        ]

        currentMessage = messages.randomElement() ?? .defaultMessage
    }

    private func handleAIBoxTap() {
        // Handle different actions based on message type
        switch currentMessage.type {
        case .boardInterview:
            // Navigate to preparation checklist
            break
        case .missingDocument:
            // Navigate to document upload
            break
        case .documentReady:
            // Show document status
            break
        case .marketUpdate:
            // Navigate to market pulse
            break
        case .default:
            // Show general help
            break
        }
    }
}

// MARK: - AI Message Model

struct AIMessage {
    let title: String
    let subtitle: String
    let type: AIMessageType

    static let defaultMessage = AIMessage(
        title: "Ready to help",
        subtitle: "Tap here for personalized guidance",
        type: .default
    )

    static let boardInterview = AIMessage(
        title: "Board interview prep",
        subtitle: "Time to prep for that board interview — tap here.",
        type: .boardInterview
    )

    static let missingTaxReturn = AIMessage(
        title: "Missing documents",
        subtitle: "Still missing that tax return — tap to upload.",
        type: .missingDocument
    )

    static let documentReady = AIMessage(
        title: "Documents complete",
        subtitle: "Your package is ready for review.",
        type: .documentReady
    )

    static let marketUpdate = AIMessage(
        title: "Market insights",
        subtitle: "New opportunities in your area — explore now.",
        type: .marketUpdate
    )
}

enum AIMessageType {
    case boardInterview
    case missingDocument
    case documentReady
    case marketUpdate
    case `default`
}

#Preview {
    ZStack {
        Color.black
        SmartAIBox()
            .padding()
    }
}
