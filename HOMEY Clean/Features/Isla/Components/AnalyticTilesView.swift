//
//  AnalyticTilesView.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI

struct AnalyticTilesView: View {
    @ObservedObject var viewModel: IslaViewModel
    @State private var hoveredTile: AnalyticTileType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(AnalyticTileType.allCases, id: \.self) { tileType in
                    AnalyticTileCard(
                        tileType: tileType,
                        isSelected: viewModel.selectedTile == tileType,
                        isHovered: hoveredTile == tileType,
                        onTap: {
                            viewModel.selectTile(tileType)
                        },
                        onHover: { isHovering in
                            hoveredTile = isHovering ? tileType : nil
                        }
                    )
                    .opacity(viewModel.isDetailViewPresented && viewModel.selectedTile != tileType ? 0.6 : 1.0)
                    .scaleEffect(
                        viewModel.isDetailViewPresented && viewModel.selectedTile == tileType ? 1.1 : 1.0
                    )
                    .zIndex(viewModel.isDetailViewPresented && viewModel.selectedTile == tileType ? 1 : 0)
                }
            }
            .padding(.horizontal, 20)
        }
        .animation(.easeOutBack(duration: 0.4), value: viewModel.selectedTile)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isDetailViewPresented)
    }
}

struct AnalyticTileCard: View {
    let tileType: AnalyticTileType
    let isSelected: Bool
    let isHovered: Bool
    let onTap: () -> Void
    let onHover: (Bool) -> Void

    @State private var rippleOffset: CGPoint = .zero
    @State private var rippleOpacity: Double = 0
    @State private var rippleScale: CGFloat = 0
    @State private var glowOpacity: Double = 0.6

    var body: some View {
        ZStack {
            // Main tile content
            tileContent

            // Ripple effect overlay
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 100, height: 100)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)
                .position(rippleOffset)
                .allowsHitTesting(false)
        }
        .frame(width: 800, height: 520)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .onHover { hovering in
            onHover(hovering)
            withAnimation(.easeOutBack(duration: 0.3)) {
                glowOpacity = hovering ? 1.0 : 0.6
            }
        }
        .onTapGesture { location in
            triggerRipple(at: location)
            onTap()
        }
        .onAppear {
            startIdleGlow()
        }
    }

    private var tileContent: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.blue.opacity(0.05),
                        Color.white.opacity(0.08)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // Tile content
                VStack(spacing: 16) {
                    // Placeholder for tile image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.3),
                                    Color.purple.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: iconForTileType(tileType))
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))

                                Text(tileType.rawValue)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        )

                    // Description
                    Text(tileType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                    Spacer(minLength: 0)
                }
                .padding(20)
            )
            .overlay(
                // Glow effect
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.blue.opacity(0.3),
                                Color.white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .shadow(
                        color: Color.white.opacity(glowOpacity * 0.3),
                        radius: 12,
                        x: 0,
                        y: 0
                    )
            )
    }

    private func iconForTileType(_ type: AnalyticTileType) -> String {
        switch type {
        case .topMovers: return "chart.line.uptrend.xyaxis"
        case .rentBuy: return "house.and.flag"
        case .forecast: return "crystal.ball"
        case .affordability: return "dollarsign.circle"
        }
    }

    private func triggerRipple(at location: CGPoint) {
        rippleOffset = location
        rippleOpacity = 1.0
        rippleScale = 0

        withAnimation(.easeOut(duration: 0.3)) {
            rippleScale = 3.0
            rippleOpacity = 0
        }
    }

    private func startIdleGlow() {
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            glowOpacity = 0.9
        }
    }
}

// MARK: - Animation Extensions

extension Animation {
    static func easeOutBack(duration: Double) -> Animation {
        .timingCurve(0.34, 1.56, 0.64, 1, duration: duration)
    }
}

#Preview {
    AnalyticTilesView(viewModel: IslaViewModel())
        .background(Color.black.opacity(0.1))
}
