//
//  DrewDashboardView.swift
//  HOMEY Clean
//

import SwiftUI

public struct DrewDashboardView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(HomeyKind.drew.gradients.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Drew")
                        .font(.title2.bold())
                        .foregroundStyle(HomeyKind.drew.palette.tint)

                    Text("Trusted pros")
                        .foregroundStyle(.secondary)

                    // Drop legacy Drew UI here
                    Label("Lenders", systemImage: "banknote.fill")
                    Label("Inspectors", systemImage: "stethoscope")
                    Label("Movers", systemImage: "truck.box.fill")
                }
                .padding()
            }
        }
    }
}
