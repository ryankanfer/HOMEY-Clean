//
//  MarketDataModels.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import Foundation
import SwiftUI

// MARK: - Market Data Response Models

struct MarketDataResponse: Codable {
    let status: String
    let data: MarketData
    let timestamp: Date
}

struct MarketData: Codable {
    let marketStatus: MarketStatusData
    let tickerItems: [TickerItemData]
    let ribbonSegments: [RibbonSegmentData]
    let analytics: AnalyticsData
}

struct MarketStatusData: Codable {
    let status: String // "open", "closed", "pre_market", "after_hours"
    let nextOpen: Date?
    let nextClose: Date?
    let timezone: String
    
    init(status: String, nextOpen: Date?, nextClose: Date?, timezone: String = "EST") {
        self.status = status
        self.nextOpen = nextOpen
        self.nextClose = nextClose
        self.timezone = timezone
    }
}

struct TickerItemData: Codable {
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    let volume: Int64
    let marketCap: Double?
    let sector: String?
    let lastUpdated: Date
}

struct RibbonSegmentData: Codable {
    let id: String
    let title: String
    let value: Double
    let change: Double
    let changePercent: Double
    let category: RibbonCategory
    let trend: TrendDirection
    let metadata: [String: String]
}

enum RibbonCategory: String, Codable, CaseIterable {
    case realEstate = "real_estate"
    case mortgage = "mortgage"
    case market = "market"
    case economic = "economic"
    
    var displayName: String {
        switch self {
        case .realEstate: return "Real Estate"
        case .mortgage: return "Mortgage"
        case .market: return "Market"
        case .economic: return "Economic"
        }
    }
    
    var color: Color {
        switch self {
        case .realEstate: return .blue
        case .mortgage: return .green
        case .market: return .orange
        case .economic: return .purple
        }
    }
}

enum TrendDirection: String, Codable {
    case up, down, flat
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .flat: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .flat: return "minus"
        }
    }
}

struct AnalyticsData: Codable {
    let topMovers: TopMoversData
    let rentVsBuy: RentVsBuyData
    let forecast: ForecastData
    let affordability: AffordabilityData
}

struct TopMoversData: Codable {
    let gainers: [String]
    let losers: [String]
    let mostActive: [String]?
    let lastUpdated: Date?
    
    init(gainers: [String], losers: [String], mostActive: [String]? = nil, lastUpdated: Date? = nil) {
        self.gainers = gainers
        self.losers = losers
        self.mostActive = mostActive
        self.lastUpdated = lastUpdated ?? Date()
    }
}

struct PropertyMover: Codable, Identifiable {
    let id: String
    let address: String
    let neighborhood: String
    let priceChange: Double
    let priceChangePercent: Double
    let currentPrice: Double
    let daysOnMarket: Int
    let propertyType: String
}

struct RentVsBuyData: Codable {
    let rentAdvantage: Double
    let buyAdvantage: Double
    let breakEvenYears: Double
    let recommendation: String?
    let lastUpdated: Date?
    
    init(rentAdvantage: Double, buyAdvantage: Double, breakEvenYears: Double, recommendation: String? = nil, lastUpdated: Date? = nil) {
        self.rentAdvantage = rentAdvantage
        self.buyAdvantage = buyAdvantage
        self.breakEvenYears = breakEvenYears
        self.recommendation = recommendation
        self.lastUpdated = lastUpdated ?? Date()
    }
}

struct ForecastData: Codable {
    let trend: String
    let confidence: Double
    let timeframe: String
    let lastUpdated: Date?
    
    init(trend: String, confidence: Double, timeframe: String, lastUpdated: Date? = nil) {
        self.trend = trend
        self.confidence = confidence
        self.timeframe = timeframe
        self.lastUpdated = lastUpdated ?? Date()
    }
}

struct PriceProjection: Codable {
    let timeframe: String // "3_months", "6_months", "1_year"
    let projectedChange: Double
    let projectedChangePercent: Double
    let range: PriceRange
}

struct PriceRange: Codable {
    let low: Double
    let high: Double
}

struct MarketTrend: Codable, Identifiable {
    let id: String
    let name: String
    let direction: TrendDirection
    let strength: Double // 0.0 to 1.0
    let description: String
}

struct RiskFactor: Codable, Identifiable {
    let id: String
    let name: String
    let severity: RiskSeverity
    let probability: Double // 0.0 to 1.0
    let description: String
}

enum RiskSeverity: String, Codable {
    case low, medium, high, critical
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct AffordabilityData: Codable {
    let index: Double // 0.0 to 1.0
    let medianIncome: Double
    let medianPrice: Double
    let lastUpdated: Date?
    
    init(index: Double, medianIncome: Double, medianPrice: Double, lastUpdated: Date? = nil) {
        self.index = index
        self.medianIncome = medianIncome
        self.medianPrice = medianPrice
        self.lastUpdated = lastUpdated ?? Date()
    }
}

struct AffordabilityTrend: Codable, Identifiable {
    let id: String
    let period: String
    let index: Double
    let change: Double
}

// MARK: - UI Models (converted from API models)

struct TickerItem: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    let volume: Int64
    let marketCap: Double?
    let sector: String?
    let lastUpdated: Date

    var isPositive: Bool {
        change >= 0
    }

    var formattedPrice: String {
        String(format: "%.2f", price)
    }

    var formattedChange: String {
        let sign = isPositive ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))"
    }

    var formattedChangePercent: String {
        let sign = isPositive ? "+" : ""
        return "\(sign)\(String(format: "%.2f", changePercent))%"
    }
    
    var formattedVolume: String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", Double(volume) / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", Double(volume) / 1_000)
        } else {
            return String(volume)
        }
    }
    
    // UI Properties for MarketTicker
    var changeIcon: String {
        isPositive ? "arrow.up" : "arrow.down"
    }
    
    var changeColor: Color {
        isPositive ? .green : .red
    }
    
    var volumeColor: Color {
        if volume >= 50_000_000 {
            return .red // High volume
        } else if volume >= 20_000_000 {
            return .orange // Medium volume
        } else {
            return .gray // Low volume
        }
    }
    
    var volumeHeight: CGFloat {
        let normalizedVolume = min(Double(volume) / 100_000_000.0, 1.0) // Normalize to 0-1
        return CGFloat(normalizedVolume * 20 + 5) // Height between 5-25 points
    }
}

struct RibbonSegment: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    let change: Double
    let changePercent: Double
    let category: RibbonCategory
    let trend: TrendDirection
    let metadata: [String: String]
    
    var formattedValue: String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.1fK", value / 1_000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
    
    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", changePercent))%"
    }
    
    var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .flat: return .gray
        }
    }
    
    var trendIcon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .flat: return "minus"
        }
    }
    
    var changeText: String {
        return formattedChange
    }
}

// MARK: - Market Status

enum MarketStatus {
    case open, closed, preMarket, afterHours
    
    var displayText: String {
        switch self {
        case .open: return "Markets Open"
        case .closed: return "Markets Closed"
        case .preMarket: return "Pre-Market"
        case .afterHours: return "After Hours"
        }
    }
    
    var color: Color {
        switch self {
        case .open: return .green
        case .closed: return .red
        case .preMarket: return .orange
        case .afterHours: return .blue
        }
    }
}

// MARK: - Error Types

enum IslaError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case dataParsingError
    case apiKeyMissing
    case rateLimitExceeded
    case marketClosed
    case serviceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from market data service"
        case .dataParsingError:
            return "Failed to parse market data"
        case .apiKeyMissing:
            return "Market data API key is missing"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .marketClosed:
            return "Market is currently closed"
        case .serviceUnavailable:
            return "Market data service is temporarily unavailable"
        }
    }
}

// MARK: - Sample Data Extensions

extension TickerItem {
    static let sampleData: [TickerItem] = [
        TickerItem(symbol: "AAPL", name: "Apple Inc.", price: 175.43, change: 2.15, changePercent: 1.24, 
                   volume: 45_678_900, marketCap: 2_800_000_000_000, sector: "Technology", lastUpdated: Date()),
        TickerItem(symbol: "MSFT", name: "Microsoft Corp.", price: 378.85, change: -1.42, changePercent: -0.37, 
                   volume: 23_456_789, marketCap: 2_500_000_000_000, sector: "Technology", lastUpdated: Date()),
        TickerItem(symbol: "GOOGL", name: "Alphabet Inc.", price: 142.56, change: 3.28, changePercent: 2.35, 
                   volume: 34_567_890, marketCap: 1_800_000_000_000, sector: "Technology", lastUpdated: Date()),
        TickerItem(symbol: "TSLA", name: "Tesla Inc.", price: 248.42, change: -5.67, changePercent: -2.23, 
                   volume: 67_890_123, marketCap: 800_000_000_000, sector: "Automotive", lastUpdated: Date()),
        TickerItem(symbol: "NVDA", name: "NVIDIA Corp.", price: 875.28, change: 12.45, changePercent: 1.44, 
                   volume: 56_789_012, marketCap: 2_200_000_000_000, sector: "Technology", lastUpdated: Date())
    ]
}

extension RibbonSegment {
    static let sampleData: [RibbonSegment] = [
        RibbonSegment(title: "Median Home Price", value: 685_000, change: 15_000, changePercent: 2.24, category: RibbonCategory.realEstate, trend: TrendDirection.up, metadata: ["region": "National"]),
        RibbonSegment(title: "30Y Mortgage Rate", value: 7.12, change: 0.15, changePercent: 2.15, category: RibbonCategory.mortgage, trend: TrendDirection.up, metadata: ["type": "Fixed"]),
        RibbonSegment(title: "Housing Inventory", value: 1_234_567, change: -45_000, changePercent: -3.52, 
                      category: RibbonCategory.market, trend: TrendDirection.down, metadata: ["units": "available"]),
        RibbonSegment(title: "Price-to-Income", value: 5.8, change: 0.2, changePercent: 3.57, category: RibbonCategory.economic, trend: TrendDirection.up, metadata: ["ratio": "national"])
    ]
}