//
//  AnalyticsTilesGrid.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI

struct AnalyticsTilesGrid: View {
    let topMovers: TopMoversData?
    let rentVsBuy: RentVsBuyData?
    let forecast: ForecastData?
    let affordability: AffordabilityData?
    let onTileTap: (AnalyticTileType) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            // Top Movers Tile
            AnalyticGridTileCard(
                tileType: .topMovers,
                data: topMovers,
                onTap: { onTileTap(.topMovers) }
            )
            
            // Rent vs Buy Tile
            AnalyticGridTileCard(
                tileType: .rentBuy,
                data: rentVsBuy,
                onTap: { onTileTap(.rentBuy) }
            )
            
            // Forecast Tile
            AnalyticGridTileCard(
                tileType: .forecast,
                data: forecast,
                onTap: { onTileTap(.forecast) }
            )
            
            // Affordability Tile
            AnalyticGridTileCard(
                tileType: .affordability,
                data: affordability,
                onTap: { onTileTap(.affordability) }
            )
        }
    }
}

struct AnalyticGridTileCard: View {
    let tileType: AnalyticTileType
    let data: Any?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: tileType.iconName)
                        .font(.title2)
                        .foregroundColor(tileType.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tileType.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(tileType.subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                
                // Content based on tile type
                VStack(alignment: .leading, spacing: 8) {
                    switch tileType {
                    case .topMovers:
                        if let topMovers = data as? TopMoversData {
                            Text("Gainers: \(topMovers.gainers.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            Text("Losers: \(topMovers.losers.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        } else {
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                    case .rentBuy:
                        if let rentVsBuy = data as? RentVsBuyData {
                            Text("Break-even: \(String(format: "%.1f", rentVsBuy.breakEvenYears)) years")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            if let recommendation = rentVsBuy.recommendation {
                                Text(recommendation)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                    case .forecast:
                        if let forecast = data as? ForecastData {
                            Text("Trend: \(forecast.trend.capitalized)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("Confidence: \(Int(forecast.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.purple)
                        } else {
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                    case .affordability:
                        if let affordability = data as? AffordabilityData {
                            Text("Index: \(Int(affordability.index * 100))/100")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("Median: $\(Int(affordability.medianPrice / 1000))K")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else {
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension AnalyticTileType {
    var iconName: String {
        switch self {
        case .topMovers:
            return "chart.line.uptrend.xyaxis"
        case .rentBuy:
            return "house.and.flag"
        case .forecast:
            return "crystal.ball"
        case .affordability:
            return "dollarsign.circle"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .topMovers:
            return .green
        case .rentBuy:
            return .blue
        case .forecast:
            return .purple
        case .affordability:
            return .orange
        }
    }
    
    var subtitle: String {
        switch self {
        case .topMovers:
            return "This Week"
        case .rentBuy:
            return "Break-even Analysis"
        case .forecast:
            return "6-Month Outlook"
        case .affordability:
            return "Market Index"
        }
    }
}

#Preview {
    AnalyticsTilesGrid(
        topMovers: TopMoversData(gainers: ["AAPL", "NVDA"], losers: ["TSLA"]),
        rentVsBuy: RentVsBuyData(rentAdvantage: 0.3, buyAdvantage: 0.7, breakEvenYears: 5.2),
        forecast: ForecastData(trend: "bullish", confidence: 0.78, timeframe: "6M"),
        affordability: AffordabilityData(index: 0.65, medianIncome: 85000, medianPrice: 650000),
        onTileTap: { _ in }
    )
    .background(Color.black)
    .padding()
}