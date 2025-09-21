import SwiftUI

// Alias the nested type so you can keep your existing property types
typealias InsightsSnapshot = IslasInsights.Stats

struct IslasPage: View {
    let areaName: String
    let areaValues: InsightsSnapshot
    let baselineName: String
    let baselineValues: InsightsSnapshot
    let openInsights: () -> Void
    let openChat: () -> Void

    var body: some View {
        IslasInsights(
            areaName: areaName,
            areaValues: areaValues,
            baselineName: baselineName,
            baselineValues: baselineValues,
            openInsights: openInsights,
            openChat: openChat
        )
    }
}
