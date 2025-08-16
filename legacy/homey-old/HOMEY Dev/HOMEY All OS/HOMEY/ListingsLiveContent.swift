import SwiftUI

struct ListingsLiveContent: View {
    @State private var listingImages = [
        Color.red, Color.orange, Color.yellow.opacity(0.8),
        Color.green.opacity(0.7), Color.blue.opacity(0.7), Color.purple.opacity(0.7)
    ]
    @State private var stats = [("Active", 12), ("Pending", 5), ("Sold", 3)]

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(listingImages.indices, id: \.self) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(listingImages[$0])
                            .frame(width: 70, height: 50)
                    }
                }
            }

            HStack(spacing: 20) {
                ForEach(stats, id: \.0) { stat in
                    VStack {
                        Text("\(stat.1)")
                            .font(.footnote.bold())
                            .foregroundColor(.accentColor)
                        Text(stat.0)
                            .font(.caption2)
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                Spacer()
            }
        }
    }
}
