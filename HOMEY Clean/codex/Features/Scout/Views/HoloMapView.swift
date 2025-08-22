import MapKit
import SwiftUI

struct HoloMapView: View {
    @Bindable var viewModel: ScoutViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7589, longitude: -73.9851), // NYC center
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        NavigationView {
            ZStack {
                // Map layer
                Map(coordinateRegion: $region, annotationItems: viewModel.listings) { listing in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: listing.coordinates.latitude,
                        longitude: listing.coordinates.longitude
                    )) {
                        PropertyPin(listing: listing)
                            .onTapGesture {
                                viewModel.selectedListing = listing
                                viewModel.isShowingPeekCard = true
                            }
                    }
                }
                .ignoresSafeArea()

                // Overlay controls
                VStack {
                    HStack {
                        // Close button
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(.black.opacity(0.6)))
                        }

                        Spacer()

                        // Map style toggle
                        Button(action: toggleMapStyle) {
                            Image(systemName: "map.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(.black.opacity(0.6)))
                        }
                    }
                    .padding()

                    Spacer()

                    // Bottom controls
                    HStack {
                        // Center on user location
                        Button(action: centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(.black.opacity(0.6)))
                        }

                        Spacer()

                        // Lens size controls
                        HStack(spacing: 12) {
                            ForEach([LensSize.small, .medium, .large], id: \.self) { size in
                                Button(action: { viewModel.lensSize = size }) {
                                    Text(size.displayName)
                                        .font(.caption.weight(.medium))
                                        .foregroundColor(viewModel.lensSize == size ? .black : .white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(viewModel.lensSize == size ? .white : .black.opacity(0.6))
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Actions

    private func toggleMapStyle() {
        // TODO: Implement map style toggle (standard, satellite, hybrid)
    }

    private func centerOnUserLocation() {
        // TODO: Implement user location centering
    }
}

// MARK: - Property Pin

struct PropertyPin: View {
    let listing: Listing

    var body: some View {
        VStack(spacing: 4) {
            // Price bubble
            Text(listing.displayPrice)
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.blue)
                        .shadow(radius: 4)
                )

            // Pin point
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - Extensions

extension LensSize {
    var displayName: String {
        switch self {
        case .small: return "S"
        case .medium: return "M"
        case .large: return "L"
        }
    }
}

// MARK: - Preview

#Preview {
    HoloMapView(viewModel: ScoutViewModel())
}
