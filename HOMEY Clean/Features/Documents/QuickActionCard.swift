import SwiftUI

struct QuickActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var iconBounce = false
    
    var body: some View {
        Button(action: {
            // Trigger icon bounce animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                iconBounce = true
            }
            
            // Reset bounce after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                iconBounce = false
            }
            
            // Haptic feedback for better user experience
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        // Warm gradient background for icon
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.3),
                                        color.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                            .scaleEffect(iconBounce ? 1.2 : 1.0)
                            .shadow(color: color.opacity(0.3), radius: iconBounce ? 8 : 4, x: 0, y: 2)
                        
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(color)
                            .scaleEffect(iconBounce ? 1.1 : 1.0)
                    }
                    
                    Spacer()
                    
                    // Subtle arrow indicator
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(color.opacity(0.6))
                        .opacity(isHovered ? 1.0 : 0.5)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
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
                                        color.opacity(isPressed ? 0.6 : 0.3),
                                        color.opacity(isPressed ? 0.4 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isPressed ? 2 : 1
                            )
                    )
                    .shadow(
                        color: color.opacity(isPressed ? 0.3 : 0.1),
                        radius: isPressed ? 12 : 6,
                        x: 0,
                        y: isPressed ? 6 : 3
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        QuickActionCard(
            title: "Auto-Scan",
            description: "Scan documents with AI",
            icon: "doc.text.viewfinder",
            color: .green
        ) {
            print("Auto-scan tapped")
        }
        
        QuickActionCard(
            title: "Smart Upload",
            description: "Upload & categorize",
            icon: "icloud.and.arrow.up",
            color: .blue
        ) {
            print("Smart upload tapped")
        }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}