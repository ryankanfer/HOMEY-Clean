//
//  MarketTicker.swift
//  HOMEY Clean
//
//  Created by Assistant on Isla Rebuild
//

import SwiftUI

struct MarketTicker: View {
    let tickerData: [TickerItem]
    let offset: CGFloat
    let isPaused: Bool
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ticker track background
                Image("ticker_track")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                
                // Scrolling ticker content
                HStack(spacing: 40) {
                    ForEach(tickerData) { item in
                        MarketTickerItemView(item: item)
                    }
                    
                    // Duplicate for seamless loop
                    ForEach(tickerData) { item in
                        MarketTickerItemView(item: item)
                    }
                }
                .offset(x: offset)
                .animation(isPaused ? .none : .linear(duration: 30).repeatForever(autoreverses: false), value: offset)
                
                // Pause indicator
                if isPaused {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "pause.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Paused")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 8)
                    }
                }
            }
            .background(
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            Color.black.opacity(0.8),
                            Color.blue.opacity(0.2),
                            Color.black.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct MarketTickerItemView: View {
    let item: TickerItem
    
    var body: some View {
        HStack(spacing: 8) {
            // Symbol
            Text(item.symbol)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                )
            
            // Price
            Text(item.formattedPrice)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // Change
            HStack(spacing: 2) {
                Image(systemName: item.changeIcon)
                    .font(.caption2)
                    .foregroundColor(item.changeColor)
                
                Text(item.formattedChange)
                    .font(.caption2)
                    .foregroundColor(item.changeColor)
            }
            
            // Volume indicator
            Rectangle()
                .fill(item.volumeColor)
                .frame(width: 2, height: item.volumeHeight)
                .opacity(0.8)
        }
    }
}

#Preview {
    MarketTicker(
        tickerData: TickerItem.sampleData,
        offset: 0,
        isPaused: false,
        onTap: {}
    )
    .frame(height: 60)
    .padding()
    .background(Color.black)
}