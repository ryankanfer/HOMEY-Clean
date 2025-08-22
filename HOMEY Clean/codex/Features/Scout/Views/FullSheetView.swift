import MapKit
import SwiftUI

struct FullSheetView: View {
    @Bindable var viewModel: ScoutViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImageIndex = 0
    @State private var showingImageGallery = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7589, longitude: -73.9851),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        if let listing = viewModel.selectedListing {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Image gallery
                        imageGallery(for: listing)

                        VStack(alignment: .leading, spacing: 16) {
                            // Property header
                            propertyHeader(for: listing)

                            // Key details
                            keyDetails(for: listing)

                            // Features
                            featuresSection(for: listing)

                            // Map section
                            mapSection(for: listing)

                            // Detailed stats
                            detailedStats(for: listing)

                            // Action buttons
                            actionButtons(for: listing)
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            viewModel.isShowingFullSheet = false
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { shareProperty(listing) }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        } else {
            EmptyView()
        }
    }

    // MARK: - Image Gallery

    private func imageGallery(for listing: Listing) -> some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(Array(listing.imageURLs.enumerated()), id: \.offset) { index, imageURL in
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.secondary.opacity(0.2))
                }
                .frame(height: 300)
                .clipped()
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 300)
        .onTapGesture {
            showingImageGallery = true
        }
        .sheet(isPresented: $showingImageGallery) {
            ImageGalleryView(imageURLs: listing.imageURLs, selectedIndex: $selectedImageIndex)
        }
    }

    // MARK: - Property Header

    private func propertyHeader(for listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.address)
                .font(.title.bold())

            Text(listing.neighborhood)
                .font(.title2)
                .foregroundColor(.secondary)

            HStack {
                Text(listing.displayPrice)
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                Spacer()

                if listing.isNewToMarket {
                    Text("NEW")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                }

                if listing.hasOpenHouse {
                    Text("OPEN HOUSE")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(4)
                }
            }
        }
    }

    // MARK: - Key Details

    private func keyDetails(for listing: Listing) -> some View {
        HStack(spacing: 24) {
            DetailItem(icon: "bed.double.fill", title: "Bedrooms", value: "\(listing.bedrooms)")
            DetailItem(icon: "shower.fill", title: "Bathrooms", value: "\(Int(listing.bathrooms))")
            DetailItem(icon: "square.fill", title: "Sq Ft", value: listing.squareFootage.map { "\(Int($0))" } ?? "N/A")
            DetailItem(icon: "house.fill", title: "Type", value: listing.listingType.rawValue)
        }
    }

    // MARK: - Features Section

    private func featuresSection(for listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 8) {
                ForEach(listing.features, id: \.self) { feature in
                    HStack {
                        Image(systemName: feature.icon)
                            .foregroundColor(.blue)
                        Text(feature.name)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Map Section

    private func mapSection(for listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)

            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: listing.coordinates.latitude,
                    longitude: listing.coordinates.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )), annotationItems: [listing]) { listing in
                MapPin(coordinate: CLLocationCoordinate2D(
                    latitude: listing.coordinates.latitude,
                    longitude: listing.coordinates.longitude
                ), tint: .blue)
            }
            .frame(height: 200)
            .cornerRadius(12)
            .onTapGesture {
                openInMaps(listing)
            }
        }
    }

    // MARK: - Detailed Stats

    private func detailedStats(for listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Neighborhood Stats")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 16) {
                StatCard(title: "Walk Score", value: "\(listing.walkScore)", subtitle: "Very Walkable")
                StatCard(title: "Transit Score", value: "\(listing.transitScore)", subtitle: "Excellent Transit")
                StatCard(title: "School Rating", value: "\(listing.schoolRating)", subtitle: "Great Schools")
                StatCard(title: "Sun Hours", value: "\(listing.sunHours)", subtitle: "Daily Average")
                StatCard(
                    title: "Noise Level",
                    value: listing.noiseLevel?.displayName ?? "N/A",
                    subtitle: "Ambient Sound"
                )

                if let monthlyFees = listing.monthlyFees {
                    StatCard(title: "Monthly Fees", value: "$\(monthlyFees.total)", subtitle: "HOA + Utilities")
                }
            }
        }
    }

    // MARK: - Action Buttons

    private func actionButtons(for listing: Listing) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { saveToShortlist(listing) }) {
                    HStack {
                        Image(systemName: viewModel.shortlist.contains { $0.id == listing.id } ? "star.fill" : "star")
                        Text(viewModel.shortlist.contains { $0.id == listing.id } ? "Saved" : "Save")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: { addToTour(listing) }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Add to Tour")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button(action: { compareListing(listing) }) {
                    HStack {
                        Image(systemName: "square.stack")
                        Text("Compare")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: { contactAgent(listing) }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Contact Agent")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.bottom, 32)
    }
}

// MARK: - Supporting Views

struct DetailItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2.bold())

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ImageGalleryView: View {
    let imageURLs: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, imageURL in
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Actions

extension FullSheetView {
    private func saveToShortlist(_ listing: Listing) {
        if let entry = viewModel.shortlist.first(where: { $0.listing.id == listing.id }) {
            viewModel.removeFromShortlist(entry)
        } else {
            viewModel.addToShortlist(listing)
        }
    }

    private func shareProperty(_ listing: Listing) {
        // TODO: Implement share functionality
        print("Sharing property: \(listing.address)")
    }

    private func compareListing(_ listing: Listing) {
        // TODO: Implement compare functionality
        print("Comparing listing: \(listing.address)")
    }

    private func addToTour(_ listing: Listing) {
        // TODO: Implement add to tour functionality
        print("Adding to tour: \(listing.address)")
    }

    private func contactAgent(_ listing: Listing) {
        // TODO: Implement contact agent functionality
        print("Contacting agent for: \(listing.address)")
    }

    private func openInMaps(_ listing: Listing) {
        // TODO: Implement open in maps functionality
        print("Opening in maps: \(listing.address)")
    }
}

// MARK: - Extensions

extension ListingFeature {
    var name: String {
        switch self {
        case .petFriendly: return "Pet Friendly"
        case .elevator: return "Elevator"
        case .doorman: return "Doorman"
        case .washerDryer: return "Washer/Dryer"
        case .outdoor: return "Outdoor Space"
        case .parking: return "Parking"
        case .gym: return "Gym"
        case .rooftop: return "Rooftop"
        case .storage: return "Storage"
        case .dishwasher: return "Dishwasher"
        case .inUnitLaundry: return "In-Unit Laundry"
        case .patio: return "Patio"
        case .pool: return "Pool"
        case .rooftopAccess: return "Rooftop Access"
        }
    }
}

// MARK: - Preview
