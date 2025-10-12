import SwiftUI

struct NotificationsSheet: View {
    @Binding var isPresented: Bool
    let notifications: [ProfileNotification]
    @State private var animationRotation: Double = 0
    @State private var pulseAnimation: Double = 0.5
    @State private var shimmerAnimation: Double = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Professional cinematic background
                CinematicBackground(for: .profile, intensity: 0.8)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(notifications, id: \.id) { notification in
                            NotificationCard(notification: notification)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            animationRotation = 360
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseAnimation = 1.0
        }
        
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            shimmerAnimation = 1.0
        }
    }
}

struct NotificationCard: View {
    let notification: ProfileNotification
    @State private var cardHover: Bool = false
    @State private var activityAnimation: Double = 0.3
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                notification.color.opacity(0.3),
                                notification.color.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                    .scaleEffect(cardHover ? 1.2 : 1.0)
                
                // Icon
                Image(systemName: notification.iconName)
                    .font(.title2)
                    .foregroundColor(notification.color)
                    .scaleEffect(cardHover ? 1.1 : 1.0)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Activity indicator
                    Circle()
                        .fill(notification.isRead ? Color.gray.opacity(0.3) : notification.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(notification.isRead ? 1.0 : (activityAnimation + 0.7))
                }
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            ZStack {
                // Base layer
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                notification.color.opacity(0.1),
                                Color.clear,
                                notification.color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        AngularGradient(
                            colors: [
                                notification.color.opacity(0.6),
                                Color.clear,
                                notification.color.opacity(0.3),
                                Color.clear,
                                notification.color.opacity(0.6)
                            ],
                            center: .center
                        ),
                        lineWidth: 1
                    )
            }
        )
        .scaleEffect(cardHover ? 1.02 : 1.0)
        .rotation3DEffect(
            .degrees(cardHover ? 2 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cardHover.toggle()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                activityAnimation = 0.8
            }
        }
    }
}

#Preview {
    NotificationsSheet(
        isPresented: .constant(true),
        notifications: [
            ProfileNotification(
                id: "1",
                title: "Document Approved",
                message: "Your pay stub has been approved by your agent",
                timestamp: Date().addingTimeInterval(-3600),
                iconName: "checkmark.circle.fill",
                color: .green,
                isRead: false
            ),
            ProfileNotification(
                id: "2",
                title: "Tour Scheduled",
                message: "Your tour for 123 Main St is confirmed for tomorrow at 2 PM",
                timestamp: Date().addingTimeInterval(-7200),
                iconName: "calendar.circle.fill",
                color: .blue,
                isRead: true
            )
        ]
    )
}