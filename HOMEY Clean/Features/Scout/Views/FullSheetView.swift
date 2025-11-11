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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    imageGallery(for: listing)

                    VStack(alignment: .leading, spacing: 16) {
                        propertyHeader(for: listing)
                        keyDetails(for: listing)
                        featuresSection(for: listing)
                        mapSection(for: listing)
                        detailedStats(for: listing)
                        actionButtons(for: listing)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if let listing = viewModel.selectedListing {
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
    private func imageGallery(for listing: PropertyListing) -> some View {
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
    private func propertyHeader(for listing: PropertyListing) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.address)
                .font(.title.bold())

            Text(listing.neighborhood)
                .font(.title2)
                .foregroundColor(.secondary)

            HStack {
                Text(listing.formattedPrice)
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                Spacer()

                if listing.isNewListing {
                    Text("NEW")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                }

                // Open house info not available in PropertyListing
                if false {
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
    private func keyDetails(for listing: PropertyListing) -> some View {
        HStack(spacing: 24) {
            DetailItem(icon: "bed.double.fill", title: "Bedrooms", value: "\(listing.bedrooms)")
            DetailItem(icon: "shower.fill", title: "Bathrooms", value: "\(Int(listing.bathrooms))")
            DetailItem(icon: "square.fill", title: "Sq Ft", value: listing.squareFootage.map { "\(Int($0))" } ?? "N/A")
            DetailItem(icon: "house.fill", title: "Type", value: listing.propertyType.displayName)
        }
    }

    // MARK: - Features Section
    private func featuresSection(for listing: PropertyListing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 8) {
                ForEach(listing.amenities, id: \.self) { amenity in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                        Text(amenity)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Map Section
    private func mapSection(for listing: PropertyListing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)

            Map {
                Marker(listing.address, coordinate: listing.coordinates.clLocationCoordinate2D)
            }
            .frame(height: 200)
            .cornerRadius(12)
            .onAppear {
                region.center = listing.coordinates.clLocationCoordinate2D
            }
        }
    }

    // MARK: - Detailed Stats
    private func detailedStats(for listing: PropertyListing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Neighborhood Stats")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 16) {
                PropertyStatCard(title: "Square Footage", value: "\(listing.squareFootage ?? 0)", subtitle: "sq ft")
                PropertyStatCard(title: "Bedrooms", value: "\(listing.bedrooms)", subtitle: listing.bedroomText)
                PropertyStatCard(title: "Bathrooms", value: "\(listing.bathrooms)", subtitle: listing.bathroomText)
                PropertyStatCard(title: "Property Type", value: listing.propertyType.displayName, subtitle: "Type")
                PropertyStatCard(title: "Neighborhood", value: listing.neighborhood, subtitle: "Location")
            }
        }
    }

    // MARK: - Action Buttons
    private func actionButtons(for listing: PropertyListing) -> some View {
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

struct PropertyStatCard: View {
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
        ZStack(alignment: .topTrailing) {
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
            
            Button("Done") {
                dismiss()
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .padding()
        }
    }
}

// MARK: - Actions

extension FullSheetView {
    private func saveToShortlist(_ listing: PropertyListing) {
        if viewModel.shortlistedProperties.contains(where: { $0.id == listing.id }) {
            viewModel.removeFromShortlist(listing)
        } else {
            viewModel.addToShortlist(listing)
        }
    }

    private func shareProperty(_ listing: PropertyListing) {
        // TODO: Implement share functionality
        print("Sharing property: \(listing.address)")
    }

    private func compareListing(_ listing: PropertyListing) {
        // TODO: Implement compare functionality
        print("Comparing listing: \(listing.address)")
    }

    private func addToTour(_ listing: PropertyListing) {
        // TODO: Implement add to tour functionality
        print("Adding to tour: \(listing.address)")
    }

    private func contactAgent(_ listing: PropertyListing) {
        // TODO: Implement contact agent functionality
        print("Contacting agent for: \(listing.address)")
    }

    private func openInMaps(_ listing: PropertyListing) {
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
