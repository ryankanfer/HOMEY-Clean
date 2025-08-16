//
//  IslaDashboardView.swift
//  HOMEY Clean
//

import SwiftUI

public struct IslaDashboardView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(HomeyKind.isla.gradients.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Isla")
                        .font(.title2.bold())
                        .foregroundStyle(HomeyKind.isla.palette.tint)

                    Text("Neighborhood stats")
                        .foregroundStyle(.secondary)

                    // Drop legacy Isla UI here
                    Label("Area vs baseline metrics", systemImage: "chart.line.uptrend.xyaxis")
                    Label("More insights", systemImage: "chart.bar.fill")
                }
                .padding()
            }
        }
    }
}
