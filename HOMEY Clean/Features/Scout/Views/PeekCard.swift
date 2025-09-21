import SwiftUI

struct PeekCard: View {
    @Bindable var viewModel: ScoutViewModel
    @StateObject private var accessibilityService = AccessibilityService.shared

    @State private var cardOffset: CGFloat = 1000
    @State private var isDragging = false

    var body: some View {
        if let listing = viewModel.selectedListing {
            VStack(spacing: 0) {
                // Drag handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.vertical, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Hero image
                        AsyncImage(url: URL(string: listing.images.first ?? listing.thumbnailURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(.secondary.opacity(0.2))
                        }
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .accessibilityLabel("Property image for \(listing.address)")
                        .accessibilityAddTraits(.isImage)

                        // Property details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(listing.address)
                                .font(.title2.bold())
                                .accessibilityAddTraits(.isHeader)

                            Text(listing.neighborhood)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 16) {
                                Label("$\(listing.price)", systemImage: "dollarsign.circle.fill")
                                Label("\(listing.bedrooms) beds", systemImage: "bed.double.fill")
                                Label("\(Int(listing.bathrooms)) baths", systemImage: "shower.fill")
                            }
                            .font(.subheadline)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(
                                "Price $\(listing.price), \(listing.bedrooms) bedrooms, \(Int(listing.bathrooms)) bathrooms"
                            )
                        }

                        // Quick stats
                        statsGrid(for: listing)

                        // Action buttons
                        actionButtons(for: listing)
                    }
                    .padding()
                }
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .offset(y: cardOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let translation = value.translation.height
                        cardOffset = translation
                    }
                    .onEnded { value in
                        isDragging = false
                        let translation = value.translation.height
                        if translation > 100 {
                            withAnimation(.spring()) {
                                viewModel.isShowingPeekCard = false
                            }
                        } else {
                            withAnimation(.spring()) {
                                cardOffset = 0
                            }
                        }
                    }
            )
            .onAppear {
                withAnimation(.spring()) {
                    cardOffset = 0
                }
            }
        } else {
            EmptyView()
        }
    }

    private func statsGrid(for listing: PropertyListing) -> some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 16) {
            StatItem(title: "Bedrooms", value: "\(listing.bedrooms)")
            StatItem(title: "Bathrooms", value: "\(listing.bathrooms)")
            StatItem(title: "Sq Ft", value: "\(listing.squareFootage ?? 0)")
            StatItem(title: "Type", value: listing.propertyType.displayName)
            StatItem(title: "Amenities", value: "\(listing.amenities.count)")
            if listing.isNewListing {
                StatItem(title: "Status", value: "New")
            }
        }
        .padding(.vertical)
    }

    private func actionButtons(for listing: PropertyListing) -> some View {
        HStack(spacing: 16) {
            Button(action: { saveToShortlist(listing) }) {
                Label("Save", systemImage: viewModel.shortlist.contains { $0.id == listing.id } ? "star.fill" : "star")
            }
            .buttonStyle(.borderedProminent)

            Button(action: { shareListing(listing) }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)

            Button(action: { compareListing(listing) }) {
                Label("Compare", systemImage: "square.stack")
            }
            .buttonStyle(.bordered)

            Button(action: { addToTour(listing) }) {
                Label("Tour", systemImage: "map.fill")
            }
            .buttonStyle(.bordered)

            Button(action: { openInMaps(listing) }) {
                Label("Maps", systemImage: "location.fill")
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Actions

extension PeekCard {
    private func saveToShortlist(_ listing: PropertyListing) {
        let isCurrentlySaved = viewModel.shortlist.contains { $0.id == listing.id }

        if isCurrentlySaved {
            viewModel.removeFromShortlist(listing)
            accessibilityService.playNotificationHaptic(.success)
            accessibilityService.announce("Removed \(listing.address) from shortlist")
        } else {
            viewModel.addToShortlist(listing)
            accessibilityService.playNotificationHaptic(.success)
            accessibilityService.announce("Added \(listing.address) to shortlist")
        }
    }

    private func shareListing(_ listing: PropertyListing) {
        accessibilityService.playHaptic(.light)
        accessibilityService.announce("Sharing \(listing.address)")
        // TODO: Implement share functionality
        print("Sharing listing: \(listing.address)")
    }

    private func compareListing(_ listing: PropertyListing) {
        accessibilityService.playHaptic(.light)
        accessibilityService.announce("Added \(listing.address) to comparison")
        // TODO: Implement compare functionality
        print("Comparing listing: \(listing.address)")
    }

    private func addToTour(_ listing: PropertyListing) {
        accessibilityService.playHaptic(.medium)
        accessibilityService.announce("Added \(listing.address) to tour")
        // TODO: Implement add to tour functionality
        print("Adding to tour: \(listing.address)")
    }

    private func openInMaps(_ listing: PropertyListing) {
        accessibilityService.playHaptic(.light)
        accessibilityService.announce("Opening \(listing.address) in maps")
        // TODO: Implement open in maps functionality
        print("Opening in maps: \(listing.address)")
    }
}

// MARK: - Accessibility

extension PeekCard {
    private func configureAccessibility() {
        // TODO: Implement accessibility configuration
    }
}

// MARK: - Preview
