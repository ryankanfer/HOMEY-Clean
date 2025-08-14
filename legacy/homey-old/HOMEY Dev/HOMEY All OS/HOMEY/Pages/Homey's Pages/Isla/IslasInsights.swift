import SwiftUI

struct IslasInsights: View {
    struct Stats: Equatable, Sendable {
        var medianRent: String
        var daysOnMarket: String
        var pricePerSqft: String
    }
    
    var areaName: String
    var areaValues: Stats
    var baselineName: String
    var baselineValues: Stats
    var openInsights: () -> Void = {}
    var openChat: (() -> Void)? = nil   // optional, defaulted
    
    init(
        areaName: String,
        areaValues: Stats,
        baselineName: String,
        baselineValues: Stats,
        openInsights: @escaping () -> Void = {},
        openChat: (() -> Void)? = nil
    ) {
        self.areaName = areaName
        self.areaValues = areaValues
        self.baselineName = baselineName
        self.baselineValues = baselineValues
        self.openInsights = openInsights
        self.openChat = openChat
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Isla’s Insights")
                .font(.title3.bold())

            Text("\(areaName) vs \(baselineName)")
                .font(.headline)

            Grid(horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    metric("Median Rent", areaValues.medianRent, baselineValues.medianRent)
                    metric("Days on Market", areaValues.daysOnMarket, baselineValues.daysOnMarket)
                }
                GridRow {
                    metric("Price per Sqft", areaValues.pricePerSqft, baselineValues.pricePerSqft)
                    Button("More insights", action: openInsights)
                        .buttonStyle(.bordered)
                }
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        
    }
        
        @ViewBuilder
        private func metric(_ title: String, _ area: String, _ base: String) -> some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                HStack {
                    VStack(alignment: .leading) {
                        Text(area).font(.headline)
                        Text(areaName).font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(base).font(.headline)
                        Text(baselineName).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

