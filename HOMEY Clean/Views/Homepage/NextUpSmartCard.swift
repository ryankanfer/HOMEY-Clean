import SwiftUI

struct NextUpSmartCard: View {
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @State private var currentRecommendations: [NextUpRecommendation] = []
    @State private var currentIndex = 0
    
    private var nextUpSettings: NextUpBehaviorSettings {
        userProfileManager.currentProfile?.preferences.homepageCustomization.nextUpBehaviorSettings ?? NextUpBehaviorSettings()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Up")
                        .font(.title3.bold())
                        .foregroundStyle(Theme.dynamicText())
                    
                    Text("Personalized for you")
                        .font(.caption)
                        .foregroundStyle(Theme.dynamicTextSecondary())
                }
                
                Spacer()
                
                Button {
                    refreshRecommendations()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(Theme.dynamicTextSecondary())
                }
            }
            
            if !currentRecommendations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(currentRecommendations) { recommendation in
                            NextUpRecommendationCard(recommendation: recommendation)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            } else {
                NextUpPlaceholderCard()
            }
        }
        .onAppear {
            loadRecommendations()
        }
    }
    
    private func loadRecommendations() {
        currentRecommendations = generatePersonalizedRecommendations()
    }
    
    private func refreshRecommendations() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRecommendations = generatePersonalizedRecommendations()
        }
    }
    
    private func generatePersonalizedRecommendations() -> [NextUpRecommendation] {
        guard let profile = userProfileManager.currentProfile else {
            return getDefaultRecommendations()
        }
        
        var recommendations: [NextUpRecommendation] = []
        let journeyState = profile.journeyState
        let preferences = profile.preferences
        
        recommendations.append(contentsOf: getPropertyRecommendations(journeyState: journeyState))
        recommendations.append(contentsOf: getJourneyStageRecommendations(profile: profile))
        recommendations.append(contentsOf: getGoalBasedRecommendations(journeyState: journeyState))
        recommendations.append(contentsOf: getNeighborhoodRecommendations(preferences: preferences))
        recommendations.append(contentsOf: getActivityRecommendations(journeyState: journeyState))
        recommendations.append(contentsOf: getTimeBasedRecommendations(journeyState: journeyState))
        
        return Array(recommendations.sorted { $0.priority.sortOrder < $1.priority.sortOrder }.prefix(5))
    }
    
    private func getPropertyRecommendations(journeyState: JourneyState) -> [NextUpRecommendation] {
        var recommendations: [NextUpRecommendation] = []
        
        if !journeyState.savedProperties.isEmpty {
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Updates on Saved Properties",
                subtitle: "\(journeyState.savedProperties.count) properties have new info",
                contentType: .propertyAlert,
                priority: .high,
                icon: "heart.fill",
                color: .red,
                actionText: "Check Updates"
            ))
        }
        
        if journeyState.viewedProperties.count > 5 {
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Similar Properties Found",
                subtitle: "Based on your \(journeyState.viewedProperties.count) viewed properties",
                contentType: .recommendation,
                priority: .medium,
                icon: "sparkles",
                color: .purple,
                actionText: "Explore"
            ))
        }
        
        return recommendations
    }
    
    private func getJourneyStageRecommendations(profile: UserProfile) -> [NextUpRecommendation] {
        var recommendations: [NextUpRecommendation] = []
        
        switch profile.journeyStage {
        case .exploring:
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Market Insights",
                subtitle: "Latest trends in your area",
                contentType: .marketUpdate,
                priority: .medium,
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                actionText: "Learn More"
            ))
        case .researching:
            if let criteria = profile.journeyState.activeSearchCriteria {
                let criteriaText = buildCriteriaText(criteria)
                recommendations.append(NextUpRecommendation(
                    id: UUID(),
                    title: "New Matches Found",
                    subtitle: criteriaText,
                    contentType: .propertyAlert,
                    priority: .high,
                    icon: "magnifyingglass",
                    color: .blue,
                    actionText: "View Matches"
                ))
            }
        case .viewing:
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Schedule Property Tours",
                subtitle: "Book visits for your shortlisted properties",
                contentType: .task,
                priority: .high,
                icon: "calendar",
                color: .orange,
                actionText: "Schedule"
            ))
        case .negotiating:
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Negotiation Tips",
                subtitle: "Expert advice for your current offers",
                contentType: .recommendation,
                priority: .high,
                icon: "handshake.fill",
                color: .blue,
                actionText: "Get Tips"
            ))
        case .closing:
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Closing Checklist",
                subtitle: "Important tasks before closing day",
                contentType: .task,
                priority: .high,
                icon: "checkmark.circle.fill",
                color: .green,
                actionText: "Review"
            ))
        case .settled:
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Home Optimization",
                subtitle: "Make your new space uniquely yours",
                contentType: .recommendation,
                priority: .medium,
                icon: "house.fill",
                color: .purple,
                actionText: "Explore"
            ))
        }
        
        return recommendations
    }
    
    private func getGoalBasedRecommendations(journeyState: JourneyState) -> [NextUpRecommendation] {
        var recommendations: [NextUpRecommendation] = []
        
        for goal in journeyState.currentGoals {
            if goal.lowercased().contains("finance") || goal.lowercased().contains("mortgage") {
                recommendations.append(NextUpRecommendation(
                    id: UUID(),
                    title: "Mortgage Pre-approval",
                    subtitle: "Get pre-approved to strengthen your offers",
                    contentType: .task,
                    priority: .high,
                    icon: "dollarsign.circle.fill",
                    color: .green,
                    actionText: "Start Now"
                ))
            }
        }
        
        return recommendations
    }
    
    private func getNeighborhoodRecommendations(preferences: UserPreferences) -> [NextUpRecommendation] {
        var recommendations: [NextUpRecommendation] = []
        
        if !preferences.savedNeighborhoods.isEmpty {
            let neighborhood = preferences.savedNeighborhoods.first!
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Neighborhood Update",
                subtitle: "New developments in \(neighborhood)",
                contentType: .marketUpdate,
                priority: .medium,
                icon: "building.2.fill",
                color: .teal,
                actionText: "Explore"
            ))
        }
        
        return recommendations
    }
    
    private func getActivityRecommendations(journeyState: JourneyState) -> [NextUpRecommendation] {
        var recommendations: [NextUpRecommendation] = []
        
        if journeyState.sessionCount > 10 {
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Your Progress Report",
                subtitle: "See how far you've come in your journey",
                contentType: .recommendation,
                priority: .low,
                icon: "chart.bar.fill",
                color: .purple,
                actionText: "View Report"
            ))
        }
        
        return recommendations
    }
    
    private func getTimeBasedRecommendations(journeyState: JourneyState) -> [NextUpRecommendation] {
        var recommendations: [NextUpRecommendation] = []
        
        let daysSinceLastActivity = Calendar.current.dateComponents([.day], from: journeyState.lastActivityDate, to: Date()).day ?? 0
        if daysSinceLastActivity > 7 {
            recommendations.append(NextUpRecommendation(
                id: UUID(),
                title: "Welcome Back!",
                subtitle: "Check out what's new since your last visit",
                contentType: .recommendation,
                priority: .medium,
                icon: "hand.wave.fill",
                color: .yellow,
                actionText: "Catch Up"
            ))
        }
        
        return recommendations
    }
    
    private func buildCriteriaText(_ criteria: SearchCriteria) -> String {
        var parts: [String] = []
        
        if let bedrooms = criteria.bedrooms {
            parts.append("\(bedrooms)+ bed")
        }
        if let bathrooms = criteria.bathrooms {
            parts.append("\(bathrooms)+ bath")
        }
        if let minPrice = criteria.minPrice, let maxPrice = criteria.maxPrice {
            parts.append("$\(Int(minPrice/1000))K-$\(Int(maxPrice/1000))K")
        }
        
        return parts.isEmpty ? "Matching your preferences" : parts.joined(separator: ", ")
    }
    
    private func getDefaultRecommendations() -> [NextUpRecommendation] {
        let defaults: [NextUpRecommendation] = [
            NextUpRecommendation(
                id: UUID(),
                title: "Start Your Journey",
                subtitle: "Set up your profile to get personalized recommendations",
                contentType: .task,
                priority: .high,
                icon: "person.circle.fill",
                color: .blue,
                actionText: "Get Started"
            ),
            NextUpRecommendation(
                id: UUID(),
                title: "Explore Properties",
                subtitle: "Browse available homes in your area",
                contentType: .recommendation,
                priority: .medium,
                icon: "house.fill",
                color: .green,
                actionText: "Browse"
            ),
            NextUpRecommendation(
                id: UUID(),
                title: "Market Update",
                subtitle: "Prices up 2.3% this month",
                contentType: .marketUpdate,
                priority: .medium,
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                actionText: "Read More"
            ),
            NextUpRecommendation(
                id: UUID(),
                title: "Document Reminder",
                subtitle: "Upload pre-approval letter",
                contentType: .task,
                priority: .high,
                icon: "doc.badge.plus",
                color: .orange,
                actionText: "Upload"
            ),
            NextUpRecommendation(
                id: UUID(),
                title: "Schedule Tour",
                subtitle: "Available this weekend",
                contentType: .reminder,
                priority: .medium,
                icon: "calendar.badge.plus",
                color: .purple,
                actionText: "Schedule"
            )
        ]
        
        return Array(defaults
            .sorted { $0.priority.sortOrder < $1.priority.sortOrder }
            .prefix(4))
    }
}

struct NextUpRecommendation: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let contentType: NextUpContentType
    let priority: ContentPriority
    let icon: String
    let color: Color
    let actionText: String
}

struct NextUpRecommendationCard: View {
    let recommendation: NextUpRecommendation
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        Button {
            handleRecommendationTap()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(recommendation.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: recommendation.icon)
                        .font(.headline)
                        .foregroundColor(recommendation.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Theme.dynamicText())
                        .lineLimit(1)
                    
                    Text(recommendation.subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.dynamicTextSecondary())
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(recommendation.actionText)
                    .font(.caption.bold())
                    .foregroundColor(recommendation.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(recommendation.color.opacity(0.2))
                    )
            }
            .padding(16)
            .frame(width: 280)
            .dayModeAwareLiquidGlass()
        }
        .buttonStyle(.plain)
    }
    
    private func handleRecommendationTap() {
        switch recommendation.contentType {
        case .propertyAlert:
            router.route = .discover
        case .marketUpdate:
            router.route = .insights
        case .task:
            router.route = .documents
        case .reminder:
            break
        case .recommendation:
            break
        case .milestone:
            break
        }
    }
}

struct NextUpPlaceholderCard: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.dynamicSurface())
                    .frame(width: 40, height: 40)
                
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(Theme.dynamicTextSecondary())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Getting your recommendations...")
                    .font(.subheadline.bold())
                    .foregroundStyle(Theme.dynamicText())
                
                Text("Personalizing based on your activity")
                    .font(.caption)
                    .foregroundStyle(Theme.dynamicTextSecondary())
            }
            
            Spacer()
        }
        .padding(16)
        .frame(height: 72)
        .dayModeAwareLiquidGlass()
    }
}

#Preview {
    NextUpSmartCard()
        .environmentObject(UserProfileManager.shared)
        .environmentObject(AppRouter())
        .background(Theme.dynamicBackground())
        .padding()
}