//
//  IslaViewModel.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import Combine
import SwiftUI

class IslaViewModel: ObservableObject {
    @Published var selectedTile: AnalyticTileType?
    @Published var isDetailViewPresented = false
    @Published var tickerData: [TickerItem] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupTickerData()
        startTickerUpdates()
    }

    // MARK: - Tile Management

    func selectTile(_ tile: AnalyticTileType) {
        selectedTile = tile
        isDetailViewPresented = true
    }

    func dismissDetailView() {
        isDetailViewPresented = false
        selectedTile = nil
    }

    // MARK: - Ticker Data

    private func setupTickerData() {
        tickerData = [
            TickerItem(symbol: "AAPL", price: 175.43, change: 2.15, changePercent: 1.24),
            TickerItem(symbol: "MSFT", price: 378.85, change: -1.42, changePercent: -0.37),
            TickerItem(symbol: "GOOGL", price: 142.56, change: 3.28, changePercent: 2.35),
            TickerItem(symbol: "TSLA", price: 248.42, change: -5.67, changePercent: -2.23),
            TickerItem(symbol: "NVDA", price: 875.28, change: 12.45, changePercent: 1.44),
            TickerItem(symbol: "AMZN", price: 151.94, change: 0.87, changePercent: 0.58),
            TickerItem(symbol: "META", price: 484.20, change: -2.15, changePercent: -0.44),
            TickerItem(symbol: "NFLX", price: 487.83, change: 8.92, changePercent: 1.86)
        ]
    }

    private func startTickerUpdates() {
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTickerData()
            }
            .store(in: &cancellables)
    }

    private func updateTickerData() {
        for i in tickerData.indices {
            let randomChange = Double.random(in: -2.0 ... 2.0)
            let newPrice = max(tickerData[i].price + randomChange, 1.0)
            let change = newPrice - tickerData[i].price
            let changePercent = (change / tickerData[i].price) * 100

            tickerData[i] = TickerItem(
                symbol: tickerData[i].symbol,
                price: newPrice,
                change: change,
                changePercent: changePercent
            )
        }
    }
}

// MARK: - Supporting Models

struct TickerItem: Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: Double

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
}
