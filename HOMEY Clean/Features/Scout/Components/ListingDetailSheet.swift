import SwiftUI
import MapKit

struct ListingDetailSheet: View {
    let listing: PropertyListing
    @Environment(\.dismiss) private var dismiss
    @State private var currentImageIndex = 0
    @State private var showingMap = false
    @State private var isSaved = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ImageCarousel(
                    imageURLs: listing.images,
                    currentIndex: $currentImageIndex
                )
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 20) {
                    PropertyHeaderInfo(listing: listing)
                    
                    Divider()
                    
                    PropertyKeyDetails(listing: listing)
                    
                    Divider()
                    
                    if !listing.description.isEmpty {
                        PropertyDescription(description: listing.description)
                        
                        Divider()
                    }
                    
                    if !listing.amenities.isEmpty {
                        PropertyAmenities(amenities: listing.amenities)
                        
                        Divider()
                    }
                    
                    PropertyLocation(
                        listing: listing,
                        showingMap: $showingMap
                    )
                    
                    Divider()
                    
                    PropertyContactInfo(listing: listing)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
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
                Button(action: {
                    isSaved.toggle()
                    // TODO: Save to shortlist
                }) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isSaved ? .blue : .primary)
                }
            }
        }
        .onAppear {
            isSaved = listing.isSaved
        }
    }
}

// MARK: - Image Carousel
struct ImageCarousel: View {
    let imageURLs: [String]
    @Binding var currentIndex: Int
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, imageURL in
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// MARK: - Property Header Info
struct PropertyHeaderInfo: View {
    let listing: PropertyListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(listing.formattedPrice)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                if listing.isNewListing {
                    Text("NEW")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                }
            }
            
            Text(listing.address)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(listing.neighborhood)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Property Key Details
struct PropertyKeyDetails: View {
    let listing: PropertyListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                PropertyDetailItem(icon: "bed", label: "Bedrooms", value: "\(listing.bedrooms)")
                PropertyDetailItem(icon: "bathtub", label: "Bathrooms", value: "\(listing.bathrooms)")
                PropertyDetailItem(icon: "square", label: "Sq Ft", value: "\(listing.squareFootage ?? 0)")
                PropertyDetailItem(icon: "calendar", label: "Available", value: listing.availableDate?.formatted(date: .abbreviated, time: .omitted) ?? "Now")
            }
        }
    }
}

struct PropertyDetailItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Property Description
struct PropertyDescription: View {
    let description: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.body)
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut, value: isExpanded)
            
            if description.count > 150 {
                Button(isExpanded ? "Show Less" : "Show More") {
                    isExpanded.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Property Amenities
struct PropertyAmenities: View {
    let amenities: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amenities")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(amenities, id: \.self) { amenity in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text(amenity)
                            .font(.subheadline)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Property Location
struct PropertyLocation: View {
    let listing: PropertyListing
    @Binding var showingMap: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button(action: {
                showingMap = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(listing.address)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(listing.neighborhood)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "map")
                        .foregroundColor(.blue)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showingMap) {
            PropertyMapView(listing: listing)
        }
    }
}

// MARK: - Property Contact Info
struct PropertyContactInfo: View {
    let listing: PropertyListing
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                // TODO: Schedule tour
            }) {
                Text("Schedule Tour")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Call agent
                }) {
                    HStack {
                        Image(systemName: "phone")
                        Text("Call")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
                
                Button(action: {
                    // TODO: Send message
                }) {
                    HStack {
                        Image(systemName: "message")
                        Text("Message")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
            }
        }
    }
}

// MARK: - Property Map View
struct PropertyMapView: View {
    let listing: PropertyListing
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map {
                Marker(listing.address, coordinate: listing.coordinates.clLocationCoordinate2D)
            }
            .ignoresSafeArea()
            
            HStack {
                Spacer()
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
}

#Preview {
    ListingDetailSheet(listing: PropertyListing.sampleListings[0])
}