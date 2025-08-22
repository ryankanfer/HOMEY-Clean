//
//  DrewDashboardView.swift
//  HOMEY Clean
//

import SwiftUI

public struct DrewDashboardView: View {
    public init() {}
    public var body: some View {
        ZStack {
            RoomVibeBackground(kind: .drew)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Drew").font(.largeTitle.bold()).foregroundStyle(HomeyKind.drew.gradients.accent)
                    Text("Trusted pros").foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        VendorCard(title: "Lenders", icon: "banknote.fill")
                        VendorCard(title: "Inspectors", icon: "stethoscope")
                        VendorCard(title: "Movers", icon: "truck.box.fill")
                        VendorCard(title: "Attorneys", icon: "scales")
                    }

                    DisclosureGroup("More Vendors") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Contractors", systemImage: "hammer.fill")
                            Label("Cleaners", systemImage: "broom")
                            Label("Storage", systemImage: "shippingbox.fill")
                        }
                        .padding(.top, 6)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.12), lineWidth: 1))

                    Button("✨ View Directory") {}
                        .buttonStyle(.borderedProminent)
                        .tint(HomeyKind.drew.gradients.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .padScreen()
            }
        }
        .navigationTitle("Drew")
    }
}

private struct VendorCard: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3.weight(.semibold)).frame(width: 32)
            Text(title).font(.headline)
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.12), lineWidth: 1))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}
