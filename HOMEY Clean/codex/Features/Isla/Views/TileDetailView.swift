//
//  TileDetailView.swift
//  Isla - Trading Floor Reimagined
//
//  Created by Trae AI
//

import SwiftUI

struct TileDetailView: View {
    let tileType: AnalyticTileType
    @ObservedObject var viewModel: IslaViewModel
    @State private var contentOpacity: Double = 0
    @State private var contentScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.dismissDetailView()
                }

            // Detail content
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tileType.rawValue)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text(tileType.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.dismissDetailView()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Content area
                ScrollView {
                    VStack(spacing: 20) {
                        detailContent(for: tileType)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
            .frame(maxWidth: 800, maxHeight: 600)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(contentScale)
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeOutBack(duration: 0.5)) {
                contentOpacity = 1.0
                contentScale = 1.0
            }
        }
    }

    @ViewBuilder
    private func detailContent(for tileType: AnalyticTileType) -> some View {
        switch tileType {
        case .topMovers:
            topMoversContent
        case .rentBuy:
            rentBuyContent
        case .forecast:
            forecastContent
        case .affordability:
            affordabilityContent
        }
    }

    private var topMoversContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Market Movers")
                .font(.title2)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(0 ..< 6) { index in
                    PropertyMoverCard(
                        address: "\(123 + index * 10) Market St",
                        priceChange: Double.random(in: -50000 ... 100_000),
                        percentChange: Double.random(in: -15 ... 25)
                    )
                }
            }
        }
    }

    private var rentBuyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rent vs Buy Analysis")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ComparisonRow(label: "Monthly Payment", rentValue: "$3,200", buyValue: "$4,850")
                ComparisonRow(label: "Down Payment", rentValue: "$6,400", buyValue: "$120,000")
                ComparisonRow(label: "5-Year Cost", rentValue: "$192,000", buyValue: "$411,000")
                ComparisonRow(label: "Equity Built", rentValue: "$0", buyValue: "$89,000")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private var forecastContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Market Forecast")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 16) {
                ForecastCard(
                    period: "Next 3 Months",
                    prediction: "+2.3%",
                    confidence: 0.85,
                    trend: .up
                )

                ForecastCard(
                    period: "Next 6 Months",
                    prediction: "+4.7%",
                    confidence: 0.78,
                    trend: .up
                )

                ForecastCard(
                    period: "Next 12 Months",
                    prediction: "+8.2%",
                    confidence: 0.72,
                    trend: .up
                )
            }
        }
    }

    private var affordabilityContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Affordability Index")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 16) {
                AffordabilityMetric(
                    title: "Median Income Required",
                    value: "$125,000",
                    subtitle: "For median home price"
                )

                AffordabilityMetric(
                    title: "Price-to-Income Ratio",
                    value: "6.2x",
                    subtitle: "Above national average of 4.5x"
                )

                AffordabilityMetric(
                    title: "Affordability Score",
                    value: "42/100",
                    subtitle: "Below average affordability"
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct PropertyMoverCard: View {
    let address: String
    let priceChange: Double
    let percentChange: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(address)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            HStack {
                Text(priceChange >= 0 ? "+$\(Int(priceChange))" : "-$\(Int(abs(priceChange)))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(priceChange >= 0 ? .green : .red)

                Spacer()

                Text("\(percentChange >= 0 ? "+" : "")\(String(format: "%.1f", percentChange))%")
                    .font(.caption2)
                    .foregroundColor(percentChange >= 0 ? .green : .red)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ComparisonRow: View {
    let label: String
    let rentValue: String
    let buyValue: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Rent: \(rentValue)")
                    .font(.caption)
                    .foregroundColor(.blue)

                Text("Buy: \(buyValue)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
}

struct ForecastCard: View {
    let period: String
    let prediction: String
    let confidence: Double
    let trend: TrendDirection

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(period)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Confidence: \(Int(confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: trend == .up ? "arrow.up" : "arrow.down")
                    .foregroundColor(trend == .up ? .green : .red)

                Text(prediction)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(trend == .up ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct AffordabilityMetric: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

enum TrendDirection {
    case up, down
}

#Preview {
    TileDetailView(tileType: .topMovers, viewModel: IslaViewModel())
}
