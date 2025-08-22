import SwiftUI

struct ScoutRightRail: View {
    @Bindable var viewModel: ScoutViewModel
    @StateObject private var accessibilityService = AccessibilityService.shared

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Shortlist")
                    .font(.title2.bold())

                Spacer()

                if !viewModel.shortlist.isEmpty {
                    Button(action: {
                        accessibilityService.playNotificationHaptic(.success)
                        accessibilityService.announce("Starting trail with \(viewModel.shortlist.count) properties")
                        viewModel.startTrail()
                    }) {
                        Label("Start Trail", systemImage: "map.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Start trail with \(viewModel.shortlist.count) properties")
                    .accessibilityHint("Begin touring your saved properties")
                }
            }
            .padding(.horizontal)

            if viewModel.shortlist.isEmpty {
                emptyState
            } else {
                shortlistStack
            }
        }
        .frame(width: 320)
        .background(.ultraThinMaterial)
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
        .frame(maxHeight: .infinity)
    }

    private var shortlistStack: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.shortlist) { entry in
                    shortlistCardView(for: entry)
                }
                .onMove(perform: moveItems)
            }
            .padding()
        }
    }

    private func shortlistCardView(for entry: ShortlistEntry) -> some View {
        ShortlistCard(entry: entry)
            .onTapGesture {
                accessibilityService.playHaptic(.light)
                viewModel.showPeekCard(for: entry.listing)
            }
            .contextMenu {
                Button(action: { viewModel.removeFromShortlist(entry) }) {
                    Label("Remove", systemImage: "trash")
                }

                Button(action: { viewModel.shareProperty(entry) }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Remove", role: .destructive) {
                    accessibilityService.playNotificationHaptic(.warning)
                    accessibilityService.announce("Removed \(entry.listing.address) from shortlist")
                    withAnimation {
                        viewModel.removeFromShortlist(entry)
                    }
                }
                .tint(.red)
                .accessibilityLabel("Remove \(entry.listing.address) from shortlist")
            }
            .swipeActions(edge: .leading) {
                Button("Share") {
                    accessibilityService.playHaptic(.light)
                    accessibilityService.announce("Sharing \(entry.listing.address)")
                    viewModel.shareProperty(entry)
                }
                .tint(.blue)
                .accessibilityLabel("Share \(entry.listing.address)")
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(entry.listing.address) in \(entry.listing.neighborhood), \(entry.listing.displayPrice)"
            )
            .accessibilityHint("Tap to view details, swipe left for actions")
            .accessibilityAddTraits(.isButton)
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        accessibilityService.playSelectionHaptic()
        withAnimation {
            viewModel.reorderShortlist(from: source, to: destination)
        }

        // Announce the reorder for accessibility
        if let sourceIndex = source.first {
            let movedProperty = viewModel.shortlist[sourceIndex]
            accessibilityService.announce("Moved \(movedProperty.listing.address) to position \(destination + 1)")
        }
    }
}

// MARK: - ShortlistCard

struct ShortlistCard: View {
    let entry: ShortlistEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Property image
            AsyncImage(url: URL(string: entry.listing.thumbnailURL)) { image in
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
                Text(entry.listing.address)
                    .font(.headline)
                    .lineLimit(1)

                Text(entry.listing.neighborhood)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text(entry.listing.displayPrice)
                        .font(.subheadline.bold())

                    Spacer()

                    Text("\(entry.listing.bedrooms) bed • \(entry.listing.bathrooms) bath")
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
