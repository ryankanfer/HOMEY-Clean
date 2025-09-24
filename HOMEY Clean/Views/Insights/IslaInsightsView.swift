import SwiftUI

struct IslaInsightsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = IslaInsightsViewModel()
    @State private var selectedInsightType: InsightType = .analytics
    @State private var showingDetailView = false
    @State private var selectedInsight: InsightItem?
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground(for: .homey)
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.25), .clear, Color.black.opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    heroSection
                    
                    // Insight Type Selector
                    insightTypeSelector
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Main Insights Grid
                    insightsGridSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // AI Recommendations
                    aiRecommendationsSection
                    
                    // HOMEY Footer
                    HomeyFooter()
                        .padding(.top, 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadInsights()
        }
        .sheet(isPresented: $showingDetailView) {
            if let insight = selectedInsight {
                InsightDetailView(insight: insight)
                    .environmentObject(themeManager)
            }
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Isla Insights")
                        .font(.custom("PlayfairDisplay-Bold", size: 32))
                        .foregroundColor(.white)
                    
                    Text("Discover patterns and optimize your journey")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshInsights()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                }
            }
            
            // Insight Summary Cards
            HStack(spacing: 12) {
                InsightSummaryCard(
                    title: "Total Insights",
                    value: "\(viewModel.totalInsights)",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                InsightSummaryCard(
                    title: "New Today",
                    value: "\(viewModel.newInsightsToday)",
                    icon: "sparkles",
                    color: .green
                )
                
                InsightSummaryCard(
                    title: "Accuracy",
                    value: "\(Int(viewModel.accuracyScore))%",
                    icon: "target",
                    color: .orange
                )
            }
        }
    }
    
    private var insightTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InsightType.allCases, id: \.self) { type in
                    InsightTypeButton(
                        type: type,
                        isSelected: selectedInsightType == type,
                        action: {
                            selectedInsightType = type
                            viewModel.filterInsights(by: type)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(viewModel.quickStats, id: \.id) { stat in
                    QuickStatCard(stat: stat)
                }
            }
        }
    }
    
    private var insightsGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Insights")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full insights list
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(viewModel.filteredInsights.prefix(6), id: \.id) { insight in
                    InsightCard(insight: insight) {
                        selectedInsight = insight
                        showingDetailView = true
                    }
                }
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(viewModel.recentActivities.prefix(5), id: \.id) { activity in
                    RecentActivityRow(activity: activity)
                }
            }
        }
    }
    
    private var aiRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("AI Recommendations")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.aiRecommendations, id: \.id) { recommendation in
                    AIRecommendationCard(recommendation: recommendation)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct InsightSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct InsightTypeButton: View {
    let type: InsightType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(type.title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? .white : .white.opacity(0.2))
            )
        }
    }
}

struct QuickStatCard: View {
    let stat: QuickStat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: stat.icon)
                    .font(.title3)
                    .foregroundColor(stat.color)
                
                Spacer()
                
                Text(stat.trend)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(stat.trendColor)
            }
            
            Text(stat.value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(stat.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct InsightCard: View {
    let insight: InsightItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: insight.icon)
                        .font(.title3)
                        .foregroundColor(insight.color)
                    
                    Spacer()
                    
                    Text(insight.priority.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(insight.priorityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(insight.priorityColor.opacity(0.2))
                        )
                }
                
                Text(insight.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(insight.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(insight.category)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(insight.timeAgo)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentActivityRow: View {
    let activity: RecentActivity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(activity.color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(activity.color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(activity.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct AIRecommendationCard: View {
    let recommendation: AIRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recommendation.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(recommendation.confidence))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Text(recommendation.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
            
            HStack {
                Button("Apply") {
                    // Apply recommendation
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white)
                )
                
                Button("Learn More") {
                    // Show more details
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct HomeyFooter: View {
    var body: some View {
        VStack(spacing: 16) {
            Divider()
                .background(.white.opacity(0.3))
            
            HStack {
                Text("HOMEY")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button("Privacy") { }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button("Terms") { }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button("Support") { }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Text("© 2024 HOMEY. All rights reserved.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
}

// MARK: - Data Models

enum InsightType: String, CaseIterable {
    case analytics = "analytics"
    case patterns = "patterns"
    case predictions = "predictions"
    case optimization = "optimization"
    
    var title: String {
        switch self {
        case .analytics: return "Analytics"
        case .patterns: return "Patterns"
        case .predictions: return "Predictions"
        case .optimization: return "Optimization"
        }
    }
    
    var icon: String {
        switch self {
        case .analytics: return "chart.bar.fill"
        case .patterns: return "waveform.path"
        case .predictions: return "crystal.ball.fill"
        case .optimization: return "speedometer"
        }
    }
}

struct InsightItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let icon: String
    let color: Color
    let priority: Priority
    let timeAgo: String
    
    var priorityColor: Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    enum Priority: String {
        case high = "high"
        case medium = "medium"
        case low = "low"
    }
}

struct QuickStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String
    let trendColor: Color
}

struct RecentActivity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let timeAgo: String
}

struct AIRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let confidence: Double
}

// MARK: - View Model

class IslaInsightsViewModel: ObservableObject {
    @Published var insights: [InsightItem] = []
    @Published var filteredInsights: [InsightItem] = []
    @Published var quickStats: [QuickStat] = []
    @Published var recentActivities: [RecentActivity] = []
    @Published var aiRecommendations: [AIRecommendation] = []
    
    @Published var totalInsights = 0
    @Published var newInsightsToday = 0
    @Published var accuracyScore = 0.0
    
    func loadInsights() {
        // Mock data - replace with actual API calls
        insights = [
            InsightItem(
                title: "Peak Usage Pattern",
                description: "Your app usage peaks at 2 PM daily",
                category: "Usage",
                icon: "clock.fill",
                color: .blue,
                priority: .high,
                timeAgo: "2h ago"
            ),
            InsightItem(
                title: "Efficiency Opportunity",
                description: "Optimize workflow to save 30 minutes daily",
                category: "Productivity",
                icon: "speedometer",
                color: .green,
                priority: .medium,
                timeAgo: "4h ago"
            ),
            InsightItem(
                title: "Trend Analysis",
                description: "25% increase in engagement this week",
                category: "Analytics",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange,
                priority: .low,
                timeAgo: "1d ago"
            )
        ]
        
        filteredInsights = insights
        totalInsights = insights.count
        newInsightsToday = 3
        accuracyScore = 94.5
        
        loadQuickStats()
        loadRecentActivities()
        loadAIRecommendations()
    }
    
    func filterInsights(by type: InsightType) {
        // Filter logic based on type
        filteredInsights = insights
    }
    
    func refreshInsights() {
        loadInsights()
    }
    
    private func loadQuickStats() {
        quickStats = [
            QuickStat(
                title: "Active Sessions",
                value: "1,247",
                icon: "person.3.fill",
                color: .blue,
                trend: "+12%",
                trendColor: .green
            ),
            QuickStat(
                title: "Completion Rate",
                value: "89%",
                icon: "checkmark.circle.fill",
                color: .green,
                trend: "+5%",
                trendColor: .green
            )
        ]
    }
    
    private func loadRecentActivities() {
        recentActivities = [
            RecentActivity(
                title: "New Pattern Detected",
                description: "Weekly usage pattern identified",
                icon: "waveform.path",
                color: .purple,
                timeAgo: "1h ago"
            ),
            RecentActivity(
                title: "Insight Generated",
                description: "Performance optimization suggestion",
                icon: "lightbulb.fill",
                color: .yellow,
                timeAgo: "3h ago"
            )
        ]
    }
    
    private func loadAIRecommendations() {
        aiRecommendations = [
            AIRecommendation(
                title: "Optimize Daily Routine",
                description: "Based on your patterns, shifting your main tasks to 10 AM could improve productivity by 23%.",
                confidence: 87.5
            ),
            AIRecommendation(
                title: "Enable Smart Notifications",
                description: "Reduce interruptions by 40% with AI-powered notification scheduling.",
                confidence: 92.1
            )
        ]
    }
}

struct InsightDetailView: View {
    let insight: InsightItem
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradient(
                    colors: themeManager.currentTheme.gradientColors,
                    speed: 0.8
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: insight.icon)
                                    .font(.title)
                                    .foregroundColor(insight.color)
                                
                                Spacer()
                                
                                Text(insight.priority.rawValue.uppercased())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(insight.priorityColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(insight.priorityColor.opacity(0.2))
                                    )
                            }
                            
                            Text(insight.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(insight.description)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Detailed content would go here
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Detailed Analysis")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("This insight provides detailed information about the identified pattern or recommendation. Additional charts, graphs, and actionable steps would be displayed here.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.1))
                                .backdrop(blur: 10)
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    IslaInsightsView()
        .environmentObject(ThemeManager())
}