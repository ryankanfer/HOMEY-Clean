//
//  SmartRecommendationView.swift
//  HOMEY Clean
//
//  Smart AI Recommendation Display Component
//  Created by Trae AI on 1/27/25.
//

import SwiftUI

struct SmartRecommendationView: View {
    let recommendation: SmartRecommendation
    @StateObject private var recommendationEngine = RecommendationEngine()
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with avatar and priority
            HStack(spacing: 12) {
                // AI Avatar indicator
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [recommendation.aiAvatar.accentColor.opacity(0.8), recommendation.aiAvatar.accentColor.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: recommendation.typeIcon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(recommendation.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Priority badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(recommendation.priorityColor)
                                .frame(width: 6, height: 6)
                            
                            Text(recommendation.priority.rawValue.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(recommendation.priorityColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(recommendation.priorityColor.opacity(0.2))
                        )
                    }
                    
                    Text(recommendation.subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(isExpanded ? nil : 2)
                }
                
                Spacer()
                
                // Expand/collapse button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Insights (shown when expanded)
            if isExpanded && !recommendation.insights.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Insights")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    ForEach(recommendation.insights, id: \.self) { insight in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(recommendation.aiAvatar.accentColor)
                                .frame(width: 4, height: 4)
                            
                            Text(insight)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            // Action button
            Button(action: {
                handleRecommendationAction()
            }) {
                HStack(spacing: 8) {
                    Text(recommendation.actionTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [recommendation.aiAvatar.accentColor, recommendation.aiAvatar.accentColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
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
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
        )
    }
    
    private func handleRecommendationAction() {
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
        LinearGradient(
            colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        SmartRecommendationView(
            recommendation: SmartRecommendation(
                title: "Perfect Timing for Pre-Approval",
                subtitle: "Interest rates dropped 0.2% this week - now's the perfect time to secure your pre-approval",
                type: .financial,
                context: .dashboard,
                priority: .high,
                aiAvatar: .charlie,
                actionTitle: "Get Pre-Approved",
                insights: ["Rates at 6-month low", "Save $200/month on payments", "Lock in rate for 90 days"]
            )
        )
        .padding()
    }
}