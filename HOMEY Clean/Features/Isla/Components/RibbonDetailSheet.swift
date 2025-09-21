//
//  RibbonDetailSheet.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI

struct RibbonDetailSheet: View {
    let segment: RibbonSegment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with main value
                    VStack(alignment: .leading, spacing: 8) {
                        Text(segment.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(segment.formattedValue)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(segment.trendColor)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: segment.trendIcon)
                                        .foregroundColor(segment.trendColor)
                                    Text(segment.changeText)
                                        .foregroundColor(segment.trendColor)
                                }
                                .font(.headline)
                                
                                Text("vs last period")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Details section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Market Details")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            DetailCard(
                                title: "Category",
                                value: segment.category.displayName,
                                icon: "tag.fill"
                            )
                            
                            DetailCard(
                                title: "Trend",
                                value: segment.trend.displayName,
                                icon: segment.trendIcon
                            )
                            
                            DetailCard(
                                title: "Change",
                                value: segment.changeText,
                                icon: "chart.line.uptrend.xyaxis"
                            )
                            
                            DetailCard(
                                title: "Updated",
                                value: "Just now",
                                icon: "clock.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Market Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Extensions



extension TrendDirection {
    var displayName: String {
        switch self {
        case .up:
            return "Trending Up"
        case .down:
            return "Trending Down"
        case .flat:
            return "Stable"
        }
    }
}

#Preview {
    RibbonDetailSheet(
        segment: RibbonSegment(
            title: "Median Home Price",
            value: 685000,
            change: 15000,
            changePercent: 2.4,
            category: .realEstate,
            trend: .up,
            metadata: ["region": "National"]
        )
    )
}