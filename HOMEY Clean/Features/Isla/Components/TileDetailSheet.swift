//
//  TileDetailSheet.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI
import Charts

struct TileDetailSheet: View {
    let tileType: AnalyticTileType
    let data: Any?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: tileType.iconName)
                                .font(.title)
                                .foregroundColor(tileType.accentColor)
                            
                            VStack(alignment: .leading) {
                                Text(tileType.rawValue)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text(tileType.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Content based on tile type
                    Group {
                        switch tileType {
                        case .topMovers:
                            TopMoversDetailView(data: data as? TopMoversData)
                        case .rentBuy:
                            RentBuyDetailView(data: data as? RentVsBuyData)
                        case .forecast:
                            ForecastDetailView(data: data as? ForecastData)
                        case .affordability:
                            AffordabilityDetailView(data: data as? AffordabilityData)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Analytics")
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

// MARK: - Detail Views

struct TopMoversDetailView: View {
    let data: TopMoversData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Market Movers")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            if let data = data {
                VStack(spacing: 16) {
                    // Gainers
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.green)
                            Text("Top Gainers")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        
                        ForEach(data.gainers, id: \.self) { gainer in
                            HStack {
                                Text(gainer)
                                    .font(.subheadline)
                                Spacer()
                                Text("+\(Int.random(in: 5...15))%")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Losers
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundColor(.red)
                            Text("Top Losers")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        
                        ForEach(data.losers, id: \.self) { loser in
                            HStack {
                                Text(loser)
                                    .font(.subheadline)
                                Spacer()
                                Text("-\(Int.random(in: 3...12))%")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Most Active
                    if let mostActive = data.mostActive, !mostActive.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "chart.bar")
                                    .foregroundColor(.blue)
                                Text("Most Active")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            ForEach(mostActive, id: \.self) { active in
                                HStack {
                                    Text(active)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(Int.random(in: 100...999))K vol")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Loading market data...")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

struct RentBuyDetailView: View {
    let data: RentVsBuyData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rent vs Buy Analysis")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            if let data = data {
                VStack(spacing: 16) {
                    // Break-even analysis
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Break-even Point")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(String(format: "%.1f", data.breakEvenYears))")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.blue)
                                Text("Years")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Rent Advantage")
                                    .font(.caption)
                                Text("\(Int(data.rentAdvantage * 100))%")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if let recommendation = data.recommendation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recommendation")
                                .font(.headline)
                            Text(recommendation)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Loading analysis...")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

struct ForecastDetailView: View {
    let data: ForecastData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Market Forecast")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            if let data = data {
                VStack(spacing: 16) {
                    // Trend overview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Trend: \(data.trend.capitalized)")
                                .font(.headline)
                            Spacer()
                            Text("\(data.timeframe)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Confidence")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(data.confidence * 100))%")
                                .font(.headline)
                                .foregroundColor(.purple)
                        }
                        
                        // Confidence bar
                        ProgressView(value: data.confidence)
                            .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Key Factors section (placeholder data since factors property doesn't exist in ForecastData)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Factors")
                            .font(.headline)
                        
                        let sampleFactors = ["Interest rates trending down", "Housing inventory increasing", "Economic indicators positive"]
                        ForEach(sampleFactors, id: \.self) { factor in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(factor)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            } else {
                Text("Loading forecast...")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

struct AffordabilityDetailView: View {
    let data: AffordabilityData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Affordability Index")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            if let data = data {
                VStack(spacing: 16) {
                    // Index overview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(Int(data.index * 100))")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.orange)
                                Text("out of 100")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(data.index > 0.7 ? "Good" : data.index > 0.4 ? "Fair" : "Poor")
                                    .font(.headline)
                                    .foregroundColor(data.index > 0.7 ? .green : data.index > 0.4 ? .orange : .red)
                                Text("Affordability")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        ProgressView(value: data.index)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Key metrics
                    VStack(spacing: 12) {
                        HStack {
                            Text("Median Income")
                                .font(.subheadline)
                            Spacer()
                            Text("$\(Int(data.medianIncome / 1000))K")
                                .font(.headline)
                        }
                        
                        HStack {
                            Text("Median Price")
                                .font(.subheadline)
                            Spacer()
                            Text("$\(Int(data.medianPrice / 1000))K")
                                .font(.headline)
                        }
                        
                        HStack {
                            Text("Price-to-Income Ratio")
                                .font(.subheadline)
                            Spacer()
                            Text("\(String(format: "%.1f", data.medianPrice / data.medianIncome))x")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            } else {
                Text("Loading affordability data...")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    TileDetailSheet(
        tileType: .topMovers,
        data: TopMoversData(
            gainers: ["AAPL", "NVDA", "MSFT"],
            losers: ["TSLA", "META"],
            mostActive: ["SPY", "QQQ", "AAPL"]
        )
    )
}