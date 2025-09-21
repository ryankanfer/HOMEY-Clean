//
//  IslaDataService.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import Foundation
import Combine
import SwiftUI

/// Main data service for Isla market data and analytics
class IslaDataService: ObservableObject {
    static let shared = IslaDataService()
    
    @Published var marketData: MarketData?
    @Published var isLoading = false
    @Published var error: IslaError?
    
    private let apiClient: APIClient
    private let cacheManager: CacheManager
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    
    // Market data refresh interval (30 seconds)
    private let refreshInterval: TimeInterval = 30.0
    
    init(apiClient: APIClient = APIClient.shared, cacheManager: CacheManager = CacheManager.shared) {
        self.apiClient = apiClient
        self.cacheManager = cacheManager
        setupPeriodicRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Load initial market data with caching
    func loadMarketData() {
        // Try to load from cache first
        if let cachedData = loadCachedMarketData() {
            self.marketData = cachedData
        }
        
        // Always fetch fresh data
        fetchMarketData()
    }
    
    /// Refresh market data manually
    func refreshMarketData() {
        fetchMarketData()
    }
    
    /// Get ticker data for market ticker component
    func getTickerData() -> [TickerItem] {
        return marketData?.tickerItems.map { tickerData in
            TickerItem(
                symbol: tickerData.symbol,
                name: tickerData.name,
                price: tickerData.price,
                change: tickerData.change,
                changePercent: tickerData.changePercent,
                volume: tickerData.volume,
                marketCap: tickerData.marketCap,
                sector: tickerData.sector,
                lastUpdated: tickerData.lastUpdated
            )
        } ?? TickerItem.sampleData
    }
    
    /// Get ribbon segments for data ribbon component
    func getRibbonSegments() -> [RibbonSegment] {
        return marketData?.ribbonSegments.map { ribbonData in
            RibbonSegment(
                title: ribbonData.title,
                value: ribbonData.value,
                change: ribbonData.change,
                changePercent: ribbonData.changePercent,
                category: ribbonData.category,
                trend: ribbonData.trend,
                metadata: ribbonData.metadata
            )
        } ?? RibbonSegment.sampleData
    }
    
    /// Get analytics data for specific tile type
    func getAnalyticsData(for tileType: AnalyticTileType) -> Any? {
        guard let analytics = marketData?.analytics else { return nil }
        
        switch tileType {
        case .topMovers:
            return analytics.topMovers
        case .rentBuy:
            return analytics.rentVsBuy
        case .forecast:
            return analytics.forecast
        case .affordability:
            return analytics.affordability
        }
    }
    
    /// Get current market status
    func getMarketStatus() -> MarketStatus {
        guard let statusData = marketData?.marketStatus else {
            return .closed
        }
        
        switch statusData.status.lowercased() {
        case "open":
            return .open
        case "closed":
            return .closed
        case "pre_market":
            return .preMarket
        case "after_hours":
            return .afterHours
        default:
            return .closed
        }
    }
    
    /// Clear any existing errors
    func clearError() {
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func fetchMarketData() {
        isLoading = true
        error = nil
        
        // Simulate API endpoint - replace with real endpoint
        let endpoint = "/api/v1/market/data"
        
        apiClient.request(
            endpoint: endpoint,
            method: .GET
        )
        .decode(type: MarketDataResponse.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.error = .networkError(error)
                    // Fallback to sample data on error
                    self?.loadSampleData()
                }
            },
            receiveValue: { [weak self] response in
                self?.marketData = response.data
                self?.cacheMarketData(response.data)
            }
        )
        .store(in: &cancellables)
    }
    
    private func loadCachedMarketData() -> MarketData? {
        return cacheManager.get(CacheManager.Keys.marketData, type: MarketData.self)
    }
    
    private func cacheMarketData(_ data: MarketData) {
        cacheManager.set(data, forKey: CacheManager.Keys.marketData, expiration: 300)
    }
    
    private func setupPeriodicRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.fetchMarketData()
        }
    }
    
    /// Load sample data as fallback
    private func loadSampleData() {
        let sampleMarketData = MarketData(
            marketStatus: MarketStatusData(
                status: "open",
                nextOpen: Date().addingTimeInterval(86400),
                nextClose: Date().addingTimeInterval(3600)
            ),
            tickerItems: [
                TickerItemData(
                    symbol: "AAPL", name: "Apple Inc.", price: 175.43, change: 2.15, changePercent: 1.24,
                    volume: 45_678_900, marketCap: 2_800_000_000_000, sector: "Technology", lastUpdated: Date()
                ),
                TickerItemData(
                    symbol: "MSFT", name: "Microsoft Corp.", price: 378.85, change: -1.42, changePercent: -0.37,
                    volume: 23_456_789, marketCap: 2_500_000_000_000, sector: "Technology", lastUpdated: Date()
                ),
                TickerItemData(
                    symbol: "GOOGL", name: "Alphabet Inc.", price: 142.56, change: 3.28, changePercent: 2.35,
                    volume: 34_567_890, marketCap: 1_800_000_000_000, sector: "Technology", lastUpdated: Date()
                ),
                TickerItemData(
                    symbol: "TSLA", name: "Tesla Inc.", price: 248.42, change: -5.67, changePercent: -2.23,
                    volume: 67_890_123, marketCap: 800_000_000_000, sector: "Automotive", lastUpdated: Date()
                ),
                TickerItemData(
                    symbol: "NVDA", name: "NVIDIA Corp.", price: 875.28, change: 12.45, changePercent: 1.44,
                    volume: 56_789_012, marketCap: 2_200_000_000_000, sector: "Technology", lastUpdated: Date()
                )
            ],
            ribbonSegments: [
                RibbonSegmentData(id: "1", title: "Median Home Price", value: 685000, change: 15000, changePercent: 2.24, category: .realEstate, trend: .up, metadata: ["region": "National"]),
                RibbonSegmentData(id: "2", title: "30Y Mortgage Rate", value: 7.12, change: 0.15, changePercent: 2.15, category: .mortgage, trend: .up, metadata: ["type": "Fixed"]),
                RibbonSegmentData(id: "3", title: "Housing Inventory", value: 1234567, change: -45000, changePercent: -3.52, category: .market, trend: .down, metadata: ["units": "available"])
            ],
            analytics: AnalyticsData(
                topMovers: TopMoversData(
                    gainers: ["AAPL", "NVDA", "GOOGL"],
                    losers: ["TSLA", "MSFT"]
                ),
                rentVsBuy: RentVsBuyData(
                    rentAdvantage: 0.15,
                    buyAdvantage: 0.85,
                    breakEvenYears: 7.2
                ),
                forecast: ForecastData(
                    trend: "bullish",
                    confidence: 0.78,
                    timeframe: "6M"
                ),
                affordability: AffordabilityData(
                    index: 0.65,
                    medianIncome: 85000,
                    medianPrice: 650000
                )
            )
        )
        
        self.marketData = sampleMarketData
    }
}

// MarketStatus enum is defined in MarketDataModels.swift