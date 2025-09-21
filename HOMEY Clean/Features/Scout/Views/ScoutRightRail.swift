import SwiftUI

struct ScoutRightRail: View {
    @Bindable var viewModel: ScoutViewModel
    @StateObject private var accessibilityService = AccessibilityService.shared
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                if isExpanded {
                    Text("Shortlist")
                        .font(.title2.bold())
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trail")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text("\(viewModel.shortlistedProperties.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Collapse/Expand toggle
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.right" : "chevron.left")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.primary.opacity(0.1))
                        )
                }
                .accessibilityLabel(isExpanded ? "Collapse shortlist" : "Expand shortlist")

                if isExpanded && !viewModel.shortlistedProperties.isEmpty {
                    Button(action: {
                        accessibilityService.playNotificationHaptic(.success)
                        accessibilityService.announce("Starting trail with \(viewModel.shortlistedProperties.count) properties")
                        viewModel.startTrail()
                    }) {
                        Label("Start Trail", systemImage: "map.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Start trail with \(viewModel.shortlistedProperties.count) properties")
                    .accessibilityHint("Begin touring your saved properties")
                }
            }
            .padding(.horizontal)

            if isExpanded {
                if viewModel.shortlistedProperties.isEmpty {
                    emptyState
                } else {
                    shortlistStack
                }
            }
        }
        .frame(width: isExpanded ? 320 : 80)
        .background(.ultraThinMaterial)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No saved properties")
                .font(.headline)

            Text("Use the lens to discover and save properties you're interested in viewing.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }

    private var shortlistStack: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.shortlistedProperties) { listing in
                    shortlistCardView(for: listing)
                }
                .onMove(perform: moveItems)
            }
            .padding()
        }
    }

    private func shortlistCardView(for listing: PropertyListing) -> some View {
        ShortlistCard(listing: listing)
            .onTapGesture {
                accessibilityService.playHaptic(.light)
                viewModel.showPeekCard(for: listing)
            }
            .contextMenu {
                Button(action: { viewModel.removeFromShortlist(listing) }) {
                    Label("Remove", systemImage: "trash")
                }

                Button(action: { shareProperty(listing) }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Remove", role: .destructive) {
                    accessibilityService.playNotificationHaptic(.warning)
                    accessibilityService.announce("Removed \(listing.address) from shortlist")
                    withAnimation {
                        viewModel.removeFromShortlist(listing)
                    }
                }
                .tint(.red)
                .accessibilityLabel("Remove \(listing.address) from shortlist")
            }
            .swipeActions(edge: .leading) {
                Button("Share") {
                    accessibilityService.playHaptic(.light)
                    accessibilityService.announce("Sharing \(listing.address)")
                    shareProperty(listing)
                }
                .tint(.blue)
                .accessibilityLabel("Share \(listing.address)")
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(listing.address) in \(listing.neighborhood), \(listing.formattedPrice)"
            )
            .accessibilityHint("Tap to view details, swipe left for actions")
            .accessibilityAddTraits(.isButton)
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        accessibilityService.playSelectionHaptic()
        withAnimation {
            // TODO: Implement reorder functionality for PropertyListing array
            // viewModel.reorderShortlist(from: source, to: destination)
        }

        // Announce the reorder for accessibility
        if let sourceIndex = source.first {
            let movedProperty = viewModel.shortlistedProperties[sourceIndex]
            accessibilityService.announce("Moved \(movedProperty.address) to position \(destination + 1)")
        }
    }
    
    private func shareProperty(_ listing: PropertyListing) {
        // TODO: Implement share functionality
        print("Sharing property: \(listing.address)")
    }
}

// MARK: - ShortlistCard

struct ShortlistCard: View {
    let listing: PropertyListing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Property image
            AsyncImage(url: URL(string: listing.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.secondary.opacity(0.2))
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Property details
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.address)
                    .font(.headline)
                    .lineLimit(1)

                Text(listing.neighborhood)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text(listing.formattedPrice)
                        .font(.subheadline.bold())

                    Spacer()

                    Text("\(listing.bedrooms) bed • \(Int(listing.bathrooms)) bath")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 8, y: 4)
        )
    }
}

// MARK: - Accessibility

extension ScoutRightRail {
    private func configureAccessibility() {
        // TODO: Implement accessibility configuration
    }
}

// MARK: - Preview

#Preview {
    ScoutRightRail(viewModel: ScoutViewModel())
}
