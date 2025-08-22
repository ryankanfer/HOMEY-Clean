//
//  TickerView.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI

struct TickerView: View {
    @State private var tickerOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var tickerData: [TickerItem] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ticker track background
                tickerTrackBackground

                // Scrolling ticker content
                HStack(spacing: 40) {
                    ForEach(Array(repeating: tickerData, count: 3).flatMap { $0 }, id: \.id) { item in
                        TickerItemView(item: item)
                    }
                }
                .offset(x: tickerOffset)
                .onAppear {
                    setupTickerData()
                    startTickerAnimation(screenWidth: geometry.size.width)
                }
            }
        }
        .frame(height: 120)
        .clipped()
    }

    private var tickerTrackBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.05),
                        Color.black.opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                // Glass highlight with inner glow
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .shadow(color: Color.white.opacity(0.1), radius: 4, x: 0, y: 0)
            )
    }

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

    private func startTickerAnimation(screenWidth: CGFloat) {
        let totalWidth = CGFloat(tickerData.count * 3) * 200 // Approximate width per item
        let duration = totalWidth / 40 // 40 px/sec

        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            tickerOffset = -totalWidth
        }

        // Reset with bounce easing every cycle
        Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
            // Quick fade out
            withAnimation(.easeOut(duration: 0.1)) {
                // Reset position with bounce
                tickerOffset = screenWidth
            }

            // Quick fade in and continue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    tickerOffset = -totalWidth
                }
            }
        }
    }
}

struct TickerItemView: View {
    let item: TickerItem

    var body: some View {
        HStack(spacing: 12) {
            // Symbol
            Text(item.symbol)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            // Price
            Text("$\(item.formattedPrice)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)

            // Change
            HStack(spacing: 4) {
                Image(systemName: item.isPositive ? "arrow.up" : "arrow.down")
                    .font(.system(size: 10, weight: .bold))

                Text(item.formattedChange)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))

                Text("(\(item.formattedChangePercent))")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
            }
            .foregroundColor(item.isPositive ? .green : .red)

            // Separator
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 20)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    TickerView()
        .background(Color.gray.opacity(0.1))
}
