import SwiftUI

struct ActivityInsightsSection: View {
    let router: AppRouter
    
    private let insights = [
        ActivityInsight(
            title: "You've viewed 12 apartments in Williamsburg",
            subtitle: "See similar properties",
            icon: "building.2",
            action: .search
        ),
        ActivityInsight(
            title: "3 saved properties match your budget",
            subtitle: "Review your favorites",
            icon: "heart.fill",
            action: .favorites
        ),
        ActivityInsight(
            title: "New listings in your area",
            subtitle: "5 properties added today",
            icon: "location.fill",
            action: .notifications
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Based on Your Activity")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to activity overview
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // Insights Cards
            VStack(spacing: 12) {
                ForEach(insights, id: \.title) { insight in
                    ActivityInsightCard(insight: insight, router: router)
                }
            }
        }
    }
}

struct ActivityInsight {
    let title: String
    let subtitle: String
    let icon: String
    let action: InsightAction
}

enum InsightAction {
    case search
    case favorites
    case notifications
}

struct ActivityInsightCard: View {
    let insight: ActivityInsight
    let router: AppRouter
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            handleInsightTap()
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: insight.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(insight.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .padding(.horizontal)
    }
    
    private func handleInsightTap() {
        switch insight.action {
        case .search:
            router.route = .search
        case .favorites:
            router.route = .search // Navigate to search for favorites
        case .notifications:
            // Handle notifications navigation
            break
        }
    }
}

#Preview {
    ActivityInsightsSection(router: AppRouter())
        .padding()
}