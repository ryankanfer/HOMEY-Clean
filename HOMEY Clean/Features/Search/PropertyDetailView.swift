import SwiftUI

struct PropertyDetailView: View {
    let listing: Listing
    @Environment(\.dismiss) private var dismiss
    @State private var locationQuery: String = ""
    @State private var queryResponse: String?
    @State private var showingFullPhotos = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Photo Gallery
                    PhotoGalleryView(imageURLs: listing.imageURLs)
                        .frame(height: 300)
                        .onTapGesture {
                            showingFullPhotos = true
                        }
                    
                    // Property Details
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(listing.address)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(listing.neighborhood)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(listing.displayPrice)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Text(listing.bedroomBathroomText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let sqft = listing.squareFootage {
                                Text("\(sqft) sq ft")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Features
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Features")
                                .font(.headline)
                            
                            PropertyFeaturesFlowLayoutView(items: listing.features) { feature in
                                HStack(spacing: 4) {
                                    Image(systemName: feature.icon)
                                        .font(.caption)
                                    Text(feature.displayName)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                        }
                        
                        Divider()
                        
                        // Additional Details
                        if listing.monthlyFees != nil || listing.sunHours != nil || listing.noiseLevel != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Additional Details")
                                    .font(.headline)
                                
                                if let fees = listing.monthlyFees {
                                    HStack {
                                        Text("Monthly Fees:")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("$\(fees.total)")
                                    }
                                }
                                
                                if let sunHours = listing.sunHours {
                                    HStack {
                                        Text("Sun Hours:")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(sunHours) hours/day")
                                    }
                                }
                                
                                if let noiseLevel = listing.noiseLevel {
                                    HStack {
                                        Text("Noise Level:")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text(noiseLevel.displayName)
                                            .foregroundColor(noiseLevel.color)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Location Query Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ask about this location")
                                .font(.headline)
                            
                            TextField("e.g., closest train station, nearest Whole Foods...", text: $locationQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit(submitQuery)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    SuggestionChip(text: "Closest train") { handleQuery("Closest train") }
                                    SuggestionChip(text: "Whole Foods") { handleQuery("Whole Foods") }
                                    SuggestionChip(text: "Distance to SoHo") { handleQuery("Distance to SoHo") }
                                    SuggestionChip(text: "Restaurants") { handleQuery("Restaurants") }
                                }
                            }
                            
                            if let response = queryResponse {
                                Text(response)
                                    .font(.footnote)
                                    .padding(.top, 8)
                                    .transition(.opacity)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .animation(.default, value: queryResponse)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Property Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingFullPhotos) {
                PhotoGalleryFullScreenView(imageURLs: listing.imageURLs, selectedIndex: $selectedImageIndex)
            }
        }
    }
    
    private func submitQuery() {
        handleQuery(locationQuery)
    }
    
    private func handleQuery(_ query: String) {
        // Simple placeholder logic - in a real app, this would call an AI service
        switch query.lowercased() {
        case "closest train":
            queryResponse = "The L train at Bedford Ave is a 5-minute walk away."
        case "whole foods":
            queryResponse = "The nearest Whole Foods is on Bedford Ave, about a 7-minute walk."
        case "distance to soho":
            queryResponse = "SoHo is approximately a 15-minute subway ride or a 20-minute drive."
        case "restaurants":
            queryResponse = "This area is known for great restaurants! Popular spots include Lilia, L'Artusi, and Joe's Pizza."
        default:
            queryResponse = "I can't answer that right now, but I'm always learning!"
        }
        // Clear the response after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            queryResponse = nil
        }
    }
}

// MARK: - Photo Gallery Components

struct PhotoGalleryView: View {
    let imageURLs: [String]
    
    var body: some View {
        GeometryReader { geometry in
            if !imageURLs.isEmpty {
                TabView {
                    ForEach(imageURLs.indices, id: \.self) { index in
                        // In a real app, this would load actual images
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Text("Image \(index + 1)")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text("No Images Available")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }
        }
    }
}

struct PhotoGalleryFullScreenView: View {
    let imageURLs: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(imageURLs.indices, id: \.self) { index in
                // In a real app, this would load actual images
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                    
                    Text("Full Screen Image \(index + 1)")
                        .foregroundColor(.white)
                        .font(.title)
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Flow Layout for Features

struct PropertyFeaturesFlowLayoutView<Content: View>: View {
    let items: [ListingFeature]
    let content: (ListingFeature) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PropertyFeaturesFlowLayout(items: items, itemSpacing: 8, rowSpacing: 8, content: content)
        }
    }
}

struct PropertyFeaturesFlowLayout<Content: View>: View {
    let items: [ListingFeature]
    let itemSpacing: CGFloat
    let rowSpacing: CGFloat
    let content: (ListingFeature) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            content(for: geometry.size)
        }
    }
    
    private func content(for size: CGSize) -> some View {
        var rows = [Row]()
        var currentRow = Row()
        
        for item in items {
            let itemWidth = content(item).getSize().width + itemSpacing
            if currentRow.width + itemWidth > size.width && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }
            currentRow.items.append(item)
            currentRow.width += itemWidth
        }
        rows.append(currentRow)
        
        return VStack(alignment: .leading, spacing: rowSpacing) {
            ForEach(0..<rows.count, id: \.self) { index in
                HStack(spacing: itemSpacing) {
                    ForEach(rows[index].items, id: \.self) { item in
                        content(item)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }
}

extension View {
    func getSize() -> CGSize {
        let view = UIHostingController(rootView: self)
        return view.view.intrinsicContentSize
    }
}

private struct Row {
    var items: [ListingFeature] = []
    var width: CGFloat = 0
}

#Preview {
    NavigationStack {
        PropertyDetailView(listing: Listing.sampleListings[0])
    }
}
