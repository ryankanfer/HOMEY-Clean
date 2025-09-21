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
    @Published var ribbonData: [RibbonSegment] = []
    @Published var marketStatus: MarketStatus = .closed
    @Published var currentTime: String = ""
    @Published var isLoading = false
    @Published var error: IslaError?
    
    // Analytics data
    @Published var topMovers: TopMoversData?
    @Published var rentVsBuyData: RentVsBuyData?
    @Published var forecastData: ForecastData?
    @Published var affordabilityData: AffordabilityData?
    
    // Detail view states
    @Published var selectedRibbonSegment: RibbonSegment?
    @Published var showingRibbonDetail = false
    @Published var showingTileDetail = false

    private let dataService: IslaDataService
    private var cancellables = Set<AnyCancellable>()
    private var timeUpdateTimer: Timer?

    init(dataService: IslaDataService = IslaDataService.shared) {
        self.dataService = dataService
        setupBindings()
        loadInitialData()
        startTimeUpdates()
    }
    
    deinit {
        timeUpdateTimer?.invalidate()
    }

    // MARK: - Public Methods
    
    func refreshData() {
        dataService.refreshMarketData()
    }
    
    func clearError() {
        error = nil
        dataService.clearError()
    }

    // MARK: - Tile Management

    func selectTile(_ tile: AnalyticTileType) {
        selectedTile = tile
        isDetailViewPresented = true
        showingTileDetail = true
    }

    func dismissDetailView() {
        isDetailViewPresented = false
        showingTileDetail = false
        showingRibbonDetail = false
        selectedTile = nil
        selectedRibbonSegment = nil
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Bind to data service loading state
        dataService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        // Bind to data service error state
        dataService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
        
        // Bind to market data updates
        dataService.$marketData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketData in
                self?.updateFromMarketData()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        dataService.loadMarketData()
    }
    
    private func updateFromMarketData() {
        // Update ticker data
        tickerData = dataService.getTickerData()
        
        // Update ribbon segments
        ribbonData = dataService.getRibbonSegments()
        
        // Update market status
        marketStatus = dataService.getMarketStatus()
        
        // Update analytics data
        topMovers = dataService.getAnalyticsData(for: .topMovers) as? TopMoversData
        rentVsBuyData = dataService.getAnalyticsData(for: .rentBuy) as? RentVsBuyData
        forecastData = dataService.getAnalyticsData(for: .forecast) as? ForecastData
        affordabilityData = dataService.getAnalyticsData(for: .affordability) as? AffordabilityData
    }
    
    private func startTimeUpdates() {
        updateCurrentTime()
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }
    }
    
    private func updateCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a z"
        currentTime = formatter.string(from: Date())
    }
}
