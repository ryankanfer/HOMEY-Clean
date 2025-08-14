import SwiftUI

struct ScoutReviewView: View {
    let listings: [Listing]
    var onApprove: (Listing) -> Void = { _ in }
    var onSkip: (Listing) -> Void = { _ in }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(listings, id: \.id) { listing in
                    ListingRow(
                        listing: listing,
                        approve: { onApprove(listing) },
                        skip: { onSkip(listing) }
                    )
                    .padding(.horizontal, 12)   // <- modifier attached to the row
                }
            }
            .padding(.vertical, 12)
        }
        .navigationTitle("Scout Review")
    }
}

private struct ListingRow: View {
    let listing: Listing
    let approve: () -> Void
    let skip: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title).font(.headline)
                Text(listing.subtitle).font(.subheadline).foregroundStyle(.secondary)
                Text(listing.priceFormatted).font(.subheadline.weight(.semibold))
            }
            Spacer()
            VStack(spacing: 8) {
                Button("Approve", action: approve)
                    .buttonStyle(.borderedProminent)
                Button("Skip", action: skip)
                    .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
