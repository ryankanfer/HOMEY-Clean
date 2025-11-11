import SwiftUI

struct SavedHomesSection: View {
    let isLoading: Bool
    let savedListings: [Listing]
    let savedLinks: [SavedListingLink]
    let savedIDs: Set<UUID>
    let onToggleSave: (Listing) -> Void
    let onTap: (Listing) -> Void
    let onOpenStreetEasy: (Listing) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved homes")
                .font(.title3.weight(.semibold))

            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading homes…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            } else {
                if savedListings.isEmpty && savedLinks.isEmpty {
                    ContentUnavailableView(
                        "No saved homes yet",
                        systemImage: "house",
                        description: Text("When you save a place from StreetEasy to HOMEY, it’ll show up here with your notes.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 140)
                } else {
                    VStack(spacing: 16) {
                        // StreetEasy saved links (external)
                        ForEach(savedLinks) { link in
                            Button {
                                StreetEasyDeepLinkBuilder.open(url: link.url)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "link.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(LinearGradient(colors: [Theme.primaryAction, .white.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(link.title ?? link.url.host ?? "StreetEasy Listing")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        Text(link.url.absoluteString)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .imageScale(.medium)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(LinearGradient(colors: [Theme.primaryAction.opacity(0.25), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        ForEach(savedListings) { listing in
                            ListingWideCardView(
                                listing: listing,
                                isSaved: savedIDs.contains(listing.id),
                                onToggleSave: { onToggleSave(listing) },
                                onTap: { tapped in onTap(tapped) },
                                onOpenStreetEasy: { onOpenStreetEasy(listing) }
                            )
                        }
                    }
                }
            }
        }
    }
}