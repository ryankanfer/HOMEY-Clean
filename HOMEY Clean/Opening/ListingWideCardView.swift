import SwiftUI

struct ListingWideCardView: View {
    let listing: Listing
    let isSaved: Bool
    let onToggleSave: () -> Void
    let onTap: (Listing) -> Void
    let onOpenStreetEasy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: ListingWideCardView.imageURL(for: listing))) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.25))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                )
                .overlay(
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text(listing.address)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(listing.neighborhood)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                        Text("Saved via StreetEasy")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(10),
                    alignment: .bottomLeading
                )
                .onTapGesture { onTap(listing) }

                HStack(spacing: 6) {
                    Button(action: onToggleSave) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .foregroundColor(isSaved ? .red : .white)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Menu {
                        Button {
                            onOpenStreetEasy()
                        } label: {
                            Label("View on StreetEasy", systemImage: "link")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(10)
            }

            Text(listing.displayPrice)
                .font(.headline)
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            Button {
                onOpenStreetEasy()
            } label: {
                Label("View on StreetEasy", systemImage: "link")
            }
        }
    }

    static func imageURL(for listing: Listing) -> String {
        let url = listing.thumbnailURL
        if url.lowercased().hasPrefix("http") { return url }
        let seed = listing.id.uuidString
        return "https://picsum.photos/seed/\(seed)/600/360"
    }
}