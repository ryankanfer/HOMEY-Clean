//
//  CharlieUpdateBox.swift
//  HOMEY Clean
//
//  Charlie update box component positioned below hero section
//

import SwiftUI

/// Charlie update box with market insights and personalized updates
struct CharlieUpdateBox: View {
    @State private var isVisible = false
    @State private var animationOffset: CGFloat = 30
    @State private var currentUpdateIndex = 0
    
    // Sample updates - in real app this would come from a data source
    private let updates = [
        CharlieUpdate(
            title: "Market Intelligence",
            message: "Charlie just asked me: 'Isla, this user needs market insights for their NYC search. Can you analyze the current trends and opportunities?'",
            timestamp: "2 min ago",
            type: .market,
            actionTitle: "View Full Report",
            marketData: CharlieMarketData(
                avgRent: "$3,250",
                available: "1250",
                daysOnMarket: "28"
            )
        ),
        CharlieUpdate(
            title: "Document Ready",
            message: "Your pre-approval documents are ready for review. Everything looks good to go!",
            timestamp: "1 hour ago",
            type: .document,
            actionTitle: "Review Docs",
            marketData: nil
        ),
        CharlieUpdate(
            title: "New Recommendations",
            message: "I found 3 new properties that match your criteria in Brooklyn Heights.",
            timestamp: "3 hours ago",
            type: .recommendation,
            actionTitle: "View Properties",
            marketData: nil
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Charlie's avatar
            headerSection
            
            // Update content
            updateContent
            
            // Action buttons
            actionButtons
        }
        .background(
            // Charlie-specific translucent glass design
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(0.15),
                            Color.cyan.opacity(0.08),
                            Color.white.opacity(0.05)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.blue.opacity(0.3),
                                    Color.cyan.opacity(0.2),
                                    Color.white.opacity(0.4)
                                ],
                                center: .center
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: Color.blue.opacity(0.1),
                    radius: 20,
                    x: 0,
                    y: 10
                )
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 40,
                    x: 0,
                    y: 20
                )
        )
        .padding(.horizontal, 20)
        .offset(y: animationOffset)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            startAnimations()
            // Removed automatic update rotation - now shows static content
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            // Charlie's static avatar with enhanced glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.4), .cyan.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 15,
                            endRadius: 45
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image("charlieAvatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Charlie")
                    .font(.custom("JosefinSans-SemiBold", size: 18))
                    .foregroundColor(.white)

                Text("Your HOMEY Concierge")
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: isVisible
                    )
                
                Text("Active")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var updateContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Update type badge
            HStack {
                updateTypeBadge(for: updates[currentUpdateIndex].type)

                Spacer()

                Text(updates[currentUpdateIndex].timestamp)
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Update title
            Text(updates[currentUpdateIndex].title)
                .font(.custom("JosefinSans-SemiBold", size: 16))
                .foregroundColor(.white)
            
            // Update message
            Text(updates[currentUpdateIndex].message)
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Market data cards (if available)
            if let marketData = updates[currentUpdateIndex].marketData {
                marketDataSection(marketData)
            }
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.5), value: currentUpdateIndex)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Primary action
            Button {
                // Handle primary action
            } label: {
                Text(updates[currentUpdateIndex].actionTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.opacity(0.8))
                    )
            }
            
            Spacer()
            
            // Navigation dots
            HStack(spacing: 6) {
                ForEach(0..<updates.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentUpdateIndex ? .white : .white.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentUpdateIndex)
                }
            }
            
            // Dismiss button
            Button {
                // Handle dismiss
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private func updateTypeBadge(for type: CharlieUpdateType) -> some View {
        HStack(spacing: 6) {
            Image(systemName: type.iconName)
                .font(.system(size: 10, weight: .semibold))
            Text(type.displayName)
                .font(.custom("JosefinSans-Medium", size: 12))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(type.color.opacity(0.8))
        )
    }
    
    @ViewBuilder
    private func marketDataSection(_ marketData: CharlieMarketData) -> some View {
        VStack(spacing: 12) {
            // Market data cards
            HStack(spacing: 12) {
                marketDataCard(title: "Avg Rent", value: marketData.avgRent, subtitle: "-2%")
                marketDataCard(title: "Available", value: marketData.available, subtitle: "+12%")
                marketDataCard(title: "Days on Market", value: marketData.daysOnMarket, subtitle: "+5%")
            }
            
            // View Full Report button
            Button {
                // Handle view full report action
            } label: {
                HStack(spacing: 8) {
                    Text("View Full Report")
                        .font(.custom("JosefinSans-SemiBold", size: 14))
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.teal.opacity(0.8))
                )
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func marketDataCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.custom("JosefinSans-Bold", size: 18))
                .foregroundColor(.white)

            Text(title)
                .font(.custom("PlayfairDisplay-Regular", size: 12))
                .foregroundColor(.white.opacity(0.8))

            Text(subtitle)
                .font(.custom("PlayfairDisplay-Regular", size: 10))
                .foregroundColor(.green.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            isVisible = true
            animationOffset = 0
        }
    }
    
    // Removed startUpdateRotation function - Charlie's box now shows static content
    // Users can manually navigate through updates using the pagination dots if needed
}

// MARK: - Supporting Models

struct CharlieUpdate {
    let title: String
    let message: String
    let timestamp: String
    let type: CharlieUpdateType
    let actionTitle: String
    let marketData: CharlieMarketData?
}

struct CharlieMarketData {
    let avgRent: String
    let available: String
    let daysOnMarket: String
}

enum CharlieUpdateType {
    case market
    case document
    case recommendation
    case reminder
    case insight
    
    var displayName: String {
        switch self {
        case .market: return "Market"
        case .document: return "Document"
        case .recommendation: return "Recommendation"
        case .reminder: return "Reminder"
        case .insight: return "Insight"
        }
    }
    
    var iconName: String {
        switch self {
        case .market: return "chart.line.uptrend.xyaxis"
        case .document: return "doc.text"
        case .recommendation: return "star.fill"
        case .reminder: return "bell.fill"
        case .insight: return "lightbulb.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .market: return .green
        case .document: return .blue
        case .recommendation: return .orange
        case .reminder: return .purple
        case .insight: return .yellow
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.black, .blue.opacity(0.3), .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            CharlieUpdateBox()
            
            Spacer()
        }
    }
}