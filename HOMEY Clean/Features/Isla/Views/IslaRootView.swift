//
//  IslaRootView.swift
//  HOMEY Clean
//
//  Created by Assistant on Isla Rebuild
//

import SwiftUI

struct IslaRootView: View {
    @StateObject private var dataService = IslaDataService()
    @StateObject private var viewModel: IslaViewModel
    @State private var tickerOffset: CGFloat = 0
    @State private var isTickerPaused = false
    
    init() {
        let service = IslaDataService()
        self._dataService = StateObject(wrappedValue: service)
        self._viewModel = StateObject(wrappedValue: IslaViewModel(dataService: service))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                AnimatedGradientBackground(for: .homey)
                    .ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            // Immersive Hero Banner - Edge to Edge
                            HeroVideoView(
                                character: .isla,
                                title: "Isla says Hi",
                                subtitle: "Your HOMEY Teammate",
                                onContinue: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo("isla.contentStart", anchor: .top)
                                    }
                                }
                            )
                            
                            // Anchor for hero continue action
                            Color.clear
                                .frame(height: 1)
                                .id("isla.contentStart")
                            
                            // Charlie's Update Box
                            CharlieUpdateBox()
                            
                            VStack(spacing: 0) {
                    
                    // Header: "Market Pulse"
                    IslaHeaderView(
                        marketStatus: viewModel.marketStatus,
                        currentTime: viewModel.currentTime,
                        onProfileTap: {
                            // Handle profile tap
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Hero: Flowing Data Ribbon
                    DataRibbon(
                        marketData: viewModel.ribbonData,
                        onSegmentTap: { segment in
                            viewModel.selectedRibbonSegment = segment
                            viewModel.showingRibbonDetail = true
                        }
                    )
                    .frame(height: 200)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    
                    // Ticker: Horizontal price and DOM band
                    MarketTicker(
                        tickerData: viewModel.tickerData,
                        offset: tickerOffset,
                        isPaused: isTickerPaused,
                        onTap: {
                            isTickerPaused.toggle()
                        }
                    )
                    .frame(height: 60)
                    .padding(.horizontal, 20)
                    
                    // Analytics Tiles Grid
                    AnalyticsTilesGrid(
                        topMovers: viewModel.topMovers,
                        rentVsBuy: viewModel.rentVsBuyData,
                        forecast: viewModel.forecastData,
                        affordability: viewModel.affordabilityData,
                        onTileTap: { tileType in
                            viewModel.selectedTile = tileType
                            viewModel.showingTileDetail = true
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                            }
                        }
                    }
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView("Loading market data...")
                        .foregroundColor(.white)
                        .scaleEffect(1.2)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingRibbonDetail) {
            if let segment = viewModel.selectedRibbonSegment {
                RibbonDetailSheet(segment: segment)
            }
        }
        .sheet(isPresented: $viewModel.showingTileDetail) {
            if let tileType = viewModel.selectedTile {
                TileDetailSheet(tileType: tileType, data: dataService.getAnalyticsData(for: tileType))
            }
        }
        .onAppear {
            viewModel.refreshData()
            startTickerAnimation()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("Retry") {
                viewModel.refreshData()
            }
            Button("Dismiss") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func startTickerAnimation() {
        guard !isTickerPaused else { return }
        
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            tickerOffset = -1000
        }
    }
}

// MARK: - Removed duplicate IslaHeaderView struct - using the one from Components/IslaHeaderView.swift
// MARK: - Removed duplicate DataRibbon struct - using the one from Components/DataRibbon.swift

#Preview {
    IslaRootView()
}