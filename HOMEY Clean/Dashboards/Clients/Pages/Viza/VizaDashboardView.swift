import SwiftUI

public struct VizaDashboardView: View {
    private let items = (1 ... 12).map { "mood_\($0)" }
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    public init() {}

    public var body: some View {
        ZStack {
            RoomVibeBackground(kind: .viza)
            ScrollView {
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(items, id: \.self) { name in
                        RoundedCard { CatalogImage(name: name) }
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                    }
                }
                .padScreen()

                Button("✨ Open Visuals") {}
                    .buttonStyle(.borderedProminent)
                    .tint(HomeyKind.viza.gradients.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .navigationTitle("Viza — Moodboard")
        }
    }
}
