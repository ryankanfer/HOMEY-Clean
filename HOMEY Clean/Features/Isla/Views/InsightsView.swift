//
//  InsightsView.swift
//  HOMEY Clean
//
//  Created by Assistant
//  A new, curated feed of data-driven insights.
//

import SwiftUI

// MARK: - Main View

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Market Insights")
                            .homeyFont(.heading)
                            .foregroundColor(Theme.primaryText)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Theme.accent)
                        }
                    }
                    
                    Text("Real-time data and AI-powered market analysis")
                        .homeyFont(.body)
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.horizontal)
                
                // Hero section with enhanced heat map
                HeatmapHeroView()
                
                // Quick Stats Section
                QuickStatsSection()
                
                // A curated feed of data-driven story cards
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.insightCards) { card in
                        InsightCardView(card: card)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}


// MARK: - View Model

@MainActor
class InsightsViewModel: ObservableObject {
    @Published var insightCards: [InsightCardModel] = []
    
    init() {
        loadInsights()
    }
    
    func loadInsights() {
        // In a real app, this data would come from an API.
        self.insightCards = InsightCardModel.mockData()
    }
}


// MARK: - UI Components

private struct QuickStatsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .homeyFont(.title)
                .foregroundColor(Theme.primaryText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickStatCard(
                        title: "Avg. Price",
                        value: "$1.2M",
                        change: "+3.2%",
                        isPositive: true,
                        icon: "dollarsign.circle.fill"
                    )
                    
                    QuickStatCard(
                        title: "Days on Market",
                        value: "18",
                        change: "-2 days",
                        isPositive: true,
                        icon: "calendar.circle.fill"
                    )
                    
                    QuickStatCard(
                        title: "Inventory",
                        value: "2.1M",
                        change: "-5.8%",
                        isPositive: false,
                        icon: "house.circle.fill"
                    )
                    
                    QuickStatCard(
                        title: "Interest Rate",
                        value: "6.8%",
                        change: "+0.2%",
                        isPositive: false,
                        icon: "percent.circle.fill"
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct QuickStatCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.accent)
                Spacer()
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(isPositive ? .green : .red)
                    .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .homeyFont(.largeTitle)
                    .foregroundColor(Theme.primaryText)
                
                Text(title)
                    .homeyFont(.caption)
                    .foregroundColor(Theme.secondaryText)
                
                Text(change)
                    .homeyFont(.caption)
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding()
        .frame(width: 140, height: 120)
        .liquidGlass()
    }
}

private struct HeatmapHeroView: View {
    @State private var animateGradient = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Market Temperature")
                        .homeyFont(.title)
                        .foregroundColor(Theme.primaryText)
                    
                    Text("🔥 Hot Market")
                        .homeyFont(.body)
                        .foregroundColor(Theme.accent)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("87°")
                        .homeyFont(.largeTitle)
                        .foregroundColor(Theme.primaryText)
                    
                    Text("+5° this week")
                        .homeyFont(.caption)
                        .foregroundColor(.green)
                }
            }
            
            // Enhanced heat map visualization
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: animateGradient ? 
                                [.red, .orange, .yellow, .blue] : 
                                [.blue, .purple, .red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
                
                // Overlay grid pattern for heat map effect
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 8), spacing: 2) {
                    ForEach(0..<32, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                            .frame(height: 18)
                    }
                }
                .padding(8)
            }
            .liquidGlass(tintColor: .white.opacity(0.1))
        }
        .padding()
        .liquidGlass()
        .onAppear {
            animateGradient = true
        }
    }
}

private struct InsightCardView: View {
    let card: InsightCardModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card Header
            HStack {
                Image(systemName: card.icon)
                    .foregroundColor(Theme.accent)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .homeyFont(.title)
                        .foregroundColor(Theme.primaryText)
                    
                    Text(card.category)
                        .homeyFont(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.secondaryText)
                        .font(.caption)
                }
            }
            
            // Main Content
            switch card.type {
            case .keyMetric(let value, let change):
                KeyMetricView(value: value, change: change)
            case .trend(let dataPoints):
                TrendChartView(dataPoints: dataPoints)
            case .heatMap(let regions):
                HeatMapView(regions: regions)
            }
            
            // AI-Generated Summary
            Text(card.summary)
                .homeyFont(.body)
                .foregroundColor(Theme.secondaryText)
                .lineLimit(3)
        }
        .padding()
        .liquidGlass()
    }
}

private struct KeyMetricView: View {
    let value: String
    let change: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Text(value)
                .homeyFont(.largeTitle)
                .foregroundColor(Theme.primaryText)
            
            HStack(spacing: 4) {
                Image(systemName: change.hasPrefix("+") ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(change.hasPrefix("+") ? .green : .red)
                    .font(.caption)
                
                Text(change)
                    .homeyFont(.body)
                    .foregroundColor(change.hasPrefix("+") ? .green : .red)
            }
            
            Spacer()
        }
    }
}

private struct TrendChartView: View {
    let dataPoints: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Trend Analysis")
                    .homeyFont(.caption)
                    .foregroundColor(Theme.secondaryText)
                Spacer()
                Text("Last 30 days")
                    .homeyFont(.caption)
                    .foregroundColor(Theme.secondaryText)
            }
            
            // Enhanced chart visualization
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(dataPoints.indices, id: \.self) { index in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.accent, Theme.accent.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 8, height: max(4, dataPoints[index] * 80))
                    }
                }
            }
            .frame(height: 80)
        }
    }
}

private struct HeatMapView: View {
    let regions: [RegionData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regional Activity")
                .homeyFont(.caption)
                .foregroundColor(Theme.secondaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 4) {
                ForEach(regions, id: \.id) { region in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(heatColor(for: region.intensity))
                        .frame(height: 20)
                        .overlay(
                            Text(region.name)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
    
    private func heatColor(for intensity: Double) -> Color {
        switch intensity {
        case 0.8...1.0: return .red
        case 0.6..<0.8: return .orange
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .green
        default: return .blue
        }
    }
}


// MARK: - Data Models & Mock Data

struct RegionData: Identifiable {
    let id = UUID()
    let name: String
    let intensity: Double
}

struct InsightCardModel: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let icon: String
    let summary: String
    let type: InsightType
    
    enum InsightType {
        case keyMetric(value: String, change: String)
        case trend(dataPoints: [Double])
        case heatMap(regions: [RegionData])
    }
    
    static func mockData() -> [InsightCardModel] {
        [
            .init(
                title: "Median Sale Price",
                category: "Market Analysis",
                icon: "dollarsign.circle.fill",
                summary: "Prices in your target neighborhoods are up 3% this month, indicating a strong seller's market with increased competition.",
                type: .keyMetric(value: "$1.2M", change: "+3.2%")
            ),
            .init(
                title: "Days on Market",
                category: "Velocity Trends",
                icon: "calendar.circle.fill",
                summary: "Properties are selling faster than ever. The average time on market has decreased significantly over the last 90 days.",
                type: .trend(dataPoints: [0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.35, 0.4, 0.45, 0.5])
            ),
            .init(
                title: "Regional Activity",
                category: "Geographic Insights",
                icon: "map.circle.fill",
                summary: "Heat map showing market activity across different neighborhoods. Red indicates high activity, blue shows cooler markets.",
                type: .heatMap(regions: [
                    RegionData(name: "DT", intensity: 0.9),
                    RegionData(name: "WE", intensity: 0.7),
                    RegionData(name: "NO", intensity: 0.5),
                    RegionData(name: "SO", intensity: 0.8),
                    RegionData(name: "EA", intensity: 0.3),
                    RegionData(name: "NW", intensity: 0.6),
                    RegionData(name: "SW", intensity: 0.4),
                    RegionData(name: "NE", intensity: 0.2),
                    RegionData(name: "SE", intensity: 0.9),
                    RegionData(name: "CT", intensity: 0.7),
                    RegionData(name: "UP", intensity: 0.5),
                    RegionData(name: "LO", intensity: 0.8)
                ])
            )
        ]
    }
}

// MARK: - Preview

#if DEBUG
struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
#endif