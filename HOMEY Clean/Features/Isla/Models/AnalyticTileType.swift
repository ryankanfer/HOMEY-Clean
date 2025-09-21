//
//  AnalyticTileType.swift
//  HOMEY Clean
//
//  Created by Trae AI
//

import Foundation

/// Represents different types of analytic tiles available in Isla
enum AnalyticTileType: String, CaseIterable, Hashable {
    case topMovers = "Top Movers"
    case rentBuy = "Rent vs Buy"
    case forecast = "Market Forecast"
    case affordability = "Affordability Index"

    var description: String {
        switch self {
        case .topMovers:
            return "Properties with the highest price changes and market activity"
        case .rentBuy:
            return "Compare rental costs versus buying in your target areas"
        case .forecast:
            return "Predictive analytics for market trends and pricing"
        case .affordability:
            return "Affordability analysis based on income and market conditions"
        }
    }
}
