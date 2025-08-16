//
//  VizaDashboardView.swift
//  HOMEY Clean
//

import SwiftUI

public struct VizaDashboardView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(HomeyKind.viza.gradients.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Viza")
                        .font(.title2.bold())
                        .foregroundStyle(HomeyKind.viza.palette.tint)

                    Text("Design & vibes")
                        .foregroundStyle(.secondary)

                    // Drop legacy Viza UI here
                    Label("Design inspiration", systemImage: "paintpalette.fill")
                    Label("Chat with Viza", systemImage: "message.fill")
                    Label("Upload photo", systemImage: "photo.fill.on.rectangle.fill")
                }
                .padding()
            }
        }
    }
}
