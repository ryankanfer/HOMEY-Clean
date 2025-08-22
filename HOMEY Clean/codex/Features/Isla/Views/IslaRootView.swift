//
//  IslaRootView.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI

struct IslaRootView: View {
    @StateObject private var viewModel = IslaViewModel()

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Trading floor gradient background
                tradingFloorBackground

                // Data ribbons layer (background)
                DataRibbonsView()
                    .zIndex(1)

                // Main content area
                VStack(spacing: 0) {
                    Spacer()

                    // Analytic tiles center stage
                    AnalyticTilesView(viewModel: viewModel)
                        .padding(.horizontal, 40)
                        .zIndex(3)

                    Spacer(minLength: 120)

                    // Ticker at bottom
                    TickerView()
                        .zIndex(2)
                }

                // Tile detail view overlay
                if viewModel.isDetailViewPresented, let selectedTile = viewModel.selectedTile {
                    TileDetailView(tileType: selectedTile, viewModel: viewModel)
                        .zIndex(10)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.8)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .ignoresSafeArea()
    }

    private var tradingFloorBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "6FB7C5"), // Teal-blue
                Color(hex: "F4F4F0") // Cream
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Subtle top-down glow
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white.opacity(0.1), location: 0),
                    .init(color: Color.clear, location: 0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
