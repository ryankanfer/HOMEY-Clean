import SwiftUI

struct SubwayProgressView: View {
    let stations: [String]
    let currentIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ForEach(stations.indices, id: \.self) { i in
                    Circle()
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .strokeBorder(strokeColor(for: i), lineWidth: 2)
                        )
                        .background(
                            (i <= currentIndex ? Color.primary.opacity(0.9) : Color.clear)
                                .clipShape(Circle())
                        )

                    if i < stations.count - 1 {
                        Rectangle()
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                            .opacity(i < currentIndex ? 0.9 : 0.25)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            HStack {
                Text(stations.indices.contains(currentIndex) ? stations[currentIndex] : "…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(min(currentIndex + 1, stations.count))/\(stations.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // Explicit Color avoids 'some ShapeStyle' inference hell
    private func strokeColor(for index: Int) -> Color {
        index <= currentIndex ? Color.primary.opacity(0.9) : Color.secondary.opacity(0.3)
    }
}
