//
//  RecommendationEngine.swift
//  HOMEY Clean
//
//  AI-Powered Recommendation Engine
//  Created by Trae AI on 1/27/25.
//

import SwiftUI
import Combine

// MARK: - Recommendation Engine
class RecommendationEngine: ObservableObject {
    @Published var recommendations: [SmartRecommendation] = []
    @Published var isLoading = false
    @Published var personalizedInsights: [PersonalizedInsight] = []
    @Published var marketTrends: [RecommendationMarketTrend] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        generateInitialRecommendations()
        startRealtimeUpdates()
    }
    
    // MARK: - Public Methods
    
    func refreshRecommendations() {
        isLoading = true
        
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.generatePersonalizedRecommendations()
            self.updateMarketInsights()
            self.isLoading = false
        }
    }
    
    func getRecommendationsFor(context: RecommendationContext) -> [SmartRecommendation] {
        return recommendations.filter { $0.context == context }
    }
    
    func markRecommendationAsViewed(_ recommendation: SmartRecommendation) {
        if let index = recommendations.firstIndex(where: { $0.id == recommendation.id }) {
            recommendations[index].isViewed = true
        }
    }
    
    // MARK: - Private Methods
    
    private func generateInitialRecommendations() {
        recommendations = [
            SmartRecommendation(
                title: "Perfect Timing for Pre-Approval",
                subtitle: "Interest rates dropped 0.2% this week",
                type: .financial,
                context: .dashboard,
                priority: .high,
                aiAvatar: .charlie,
                actionTitle: "Get Pre-Approved",
                insights: ["Rates at 6-month low", "Save $200/month on payments"]
            ),
            SmartRecommendation(
                title: "3 New Listings Match Your Criteria",
                subtitle: "Properties in Williamsburg under $800K",
                type: .property,
                context: .search,
                priority: .high,
                aiAvatar: .scout,
                actionTitle: "View Properties",
                insights: ["20% below market average", "Recently renovated"]
            ),
            SmartRecommendation(
                title: "Market Opportunity Alert",
                subtitle: "Inventory increased 15% in your target area",
                type: .market,
                context: .insights,
                priority: .medium,
                aiAvatar: .isla,
                actionTitle: "View Analysis",
                insights: ["More negotiation power", "Seasonal trend"]
            )
        ]
    }
    
    private func generatePersonalizedRecommendations() {
        // Simulate AI-generated personalized recommendations
        let newRecommendations = [
            SmartRecommendation(
                title: "Board Interview Prep Reminder",
                subtitle: "Your interview is in 3 days - let's prepare",
                type: .task,
                context: .dashboard,
                priority: .urgent,
                aiAvatar: .paige,
                actionTitle: "Start Prep",
                insights: ["Documents ready", "Practice questions available"]
            ),
            SmartRecommendation(
                title: "Staging Suggestions Ready",
                subtitle: "AI-powered room optimization for your space",
                type: .design,
                context: .visualization,
                priority: .medium,
                aiAvatar: .viza,
                actionTitle: "See Suggestions",
                insights: ["Increase appeal by 25%", "Budget-friendly options"]
            )
        ]
        
        recommendations.append(contentsOf: newRecommendations)
    }
    
    private func updateMarketInsights() {
        marketTrends = [
            RecommendationMarketTrend(
                title: "Inventory Surge",
                description: "15% more listings this month",
                impact: .positive,
                confidence: 0.87
            ),
            RecommendationMarketTrend(
                title: "Rate Stabilization",
                description: "Mortgage rates holding steady",
                impact: .neutral,
                confidence: 0.92
            )
        ]
    }
    
    private func startRealtimeUpdates() {
        // Simulate real-time updates every 30 seconds
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateRealtimeInsights()
            }
            .store(in: &cancellables)
    }
    
    private func updateRealtimeInsights() {
        // Add new insights periodically
        let realtimeInsight = PersonalizedInsight(
            title: "Market Update",
            message: "New opportunity detected in your search area",
            timestamp: Date(),
            type: .market
        )
        
        personalizedInsights.insert(realtimeInsight, at: 0)
        
        // Keep only last 10 insights
        if personalizedInsights.count > 10 {
            personalizedInsights = Array(personalizedInsights.prefix(10))
        }
    }
}

// MARK: - Models

struct SmartRecommendation: Identifiable, Codable {
    let id = UUID()
    let title: String
    let subtitle: String
    let type: RecommendationType
    let context: RecommendationContext
    let priority: RecommendationPriority
    let aiAvatar: AIAvatarType
    let actionTitle: String
    let insights: [String]
    var isViewed: Bool = false
    let timestamp: Date = Date()
    
    var priorityColor: Color {
        switch priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .blue
        case .low: return .gray
        }
    }
    
    var typeIcon: String {
        switch type {
        case .financial: return "dollarsign.circle.fill"
        case .property: return "house.fill"
        case .market: return "chart.line.uptrend.xyaxis"
        case .task: return "checkmark.circle.fill"
        case .design: return "paintbrush.fill"
        case .document: return "doc.fill"
        }
    }
}

struct PersonalizedInsight: Identifiable, Codable {
    let id = UUID()
    let title: String
    let message: String
    let timestamp: Date
    let type: PersonalizedInsightType
    
    enum PersonalizedInsightType: String, Codable {
        case market = "market"
        case financial = "financial"
        case property = "property"
        case task = "task"
    }
}

struct RecommendationMarketTrend: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let impact: TrendImpact
    let confidence: Double
    
    enum TrendImpact: String, Codable {
        case positive = "positive"
        case negative = "negative"
        case neutral = "neutral"
        
        var color: Color {
            switch self {
            case .positive: return .green
            case .negative: return .red
            case .neutral: return .gray
            }
        }
    }
}

enum RecommendationType: String, Codable, CaseIterable {
    case financial = "financial"
    case property = "property"
    case market = "market"
    case task = "task"
    case design = "design"
    case document = "document"
}

enum RecommendationContext: String, Codable, CaseIterable {
    case dashboard = "dashboard"
    case search = "search"
    case insights = "insights"
    case visualization = "visualization"
    case documents = "documents"
}

enum RecommendationPriority: String, Codable, CaseIterable {
    case urgent = "urgent"
    case high = "high"
    case medium = "medium"
    case low = "low"
}

enum AIAvatarType: String, Codable, CaseIterable {
    case charlie = "charlie"
    case scout = "scout"
    case isla = "isla"
    case viza = "viza"
    case paige = "paige"
    case drew = "drew"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var accentColor: Color {
        switch self {
        case .charlie: return .blue
        case .scout: return .green
        case .isla: return .purple
        case .viza: return .pink
        case .paige: return .orange
        case .drew: return .teal
        }
    }
}