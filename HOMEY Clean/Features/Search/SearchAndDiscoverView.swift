//
//  SearchAndDiscoverView.swift
//  HOMEY Clean
//
//  Created by Assistant
//  A completely redesigned, two-tab search experience.
//

import SwiftUI
import MapKit

// MARK: - Main View

struct SearchAndDiscoverView: View {
    @StateObject private var viewModel = SearchAndDiscoverViewModel()
    @State private var selectedTab: SearchTab = .discover
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with title
                VStack(spacing: 16) {
                    Text("Search & Discover")
                        .homeyFont(.heading)
                        .foregroundColor(Theme.primaryText)
                        .padding(.top)
                    
                    // Shared conversational search bar
                    ConversationalSearchBar(query: $viewModel.searchQuery)
                }
                
                // Custom tab selector with liquid glass
                HStack(spacing: 0) {
                    ForEach(SearchTab.allCases) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab.title)
                                .homeyFont(.bodyMedium)
                                .foregroundColor(
                                    selectedTab == tab ? 
                                    Theme.primaryText : 
                                    Theme.secondaryText
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    selectedTab == tab ? 
                                    AnyView(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                    ) :
                                    AnyView(Color.clear)
                                )
                        }
                    }
                }
                .padding(4)
                .liquidGlass(cornerRadius: 16)
                .padding(.horizontal)
                .padding(.bottom)
                
                // Content area
                TabView(selection: $selectedTab) {
                    DiscoverView(viewModel: viewModel)
                        .tag(SearchTab.discover)
                    
                    ExploreView(viewModel: viewModel)
                        .tag(SearchTab.explore)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .foregroundColor(Theme.primaryText)
    }
}


// MARK: - View Model

@MainActor
class SearchAndDiscoverViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published fileprivate var recommendedListings: [ListingModel] = ListingModel.mockData().shuffled()
    @Published fileprivate var favoriteListings: [ListingModel] = Array(ListingModel.mockData().prefix(3))
    @Published fileprivate var mapListings: [ListingModel] = ListingModel.mockData()
    
    fileprivate func removeRecommendation(_ listing: ListingModel) {
        recommendedListings.removeAll { $0.id == listing.id }
    }
}


// MARK: - Tabs Enum

private enum SearchTab: CaseIterable, Identifiable {
    case discover, explore
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .discover: return "Discover"
        case .explore: return "Explore"
        }
    }
}


// MARK: - "Discover" Tab (List View)

private struct DiscoverView: View {
    @ObservedObject var viewModel: SearchAndDiscoverViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // "Homes for You" section with Tinder-style swipe
                VStack(alignment: .leading, spacing: 16) {
                    Text("Homes for You")
                        .homeyFont(.title)
                        .foregroundColor(Theme.primaryText)
                        .padding(.horizontal)
                    
                    TinderStyleSwipeView(listings: viewModel.recommendedListings) { listing in
                        viewModel.removeRecommendation(listing)
                    }
                    .frame(height: 400)
                }
                
                // Favorited homes list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Favorited Homes")
                        .homeyFont(.title)
                        .foregroundColor(Theme.primaryText)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.favoriteListings) { listing in
                            FavoriteListingRow(listing: listing)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
}


// MARK: - "Explore" Tab (Map View)

private struct ExploreView: View {
    @ObservedObject var viewModel: SearchAndDiscoverViewModel
    @State private var selectedListing: ListingModel?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: viewModel.mapListings) { listing in
                MapAnnotation(coordinate: listing.coordinate) {
                    Button {
                        selectedListing = listing
                    } label: {
                        Text(listing.displayPrice)
                            .padding(8)
                            .background(Theme.background)
                            .clipShape(Capsule())
                            .foregroundColor(Theme.primaryText)
                    }
                }
            }
            
            if let listing = selectedListing {
                MapListingDetailCard(listing: listing)
            }
        }
    }
}


// MARK: - UI Components

private struct ConversationalSearchBar: View {
    @Binding var query: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.secondaryText)
                .font(.system(size: 18, weight: .medium))
            
            TextField("e.g., '2 bed soho, elevator only'", text: $query)
                .homeyFont(.bodyMedium)
                .foregroundColor(Theme.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 16)
        .padding(.horizontal)
    }
}

private struct TinderStyleSwipeView: View {
    let listings: [ListingModel]
    let onRemove: (ListingModel) -> Void
    
    var body: some View {
        ZStack {
            ForEach(listings) { listing in
                TinderCard(listing: listing)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if abs(value.translation.width) > 100 {
                                    onRemove(listing)
                                }
                            }
                    )
            }
        }
    }
}

private struct TinderCard: View {
    let listing: ListingModel
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            AsyncImage(url: URL(string: listing.thumbnailURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Theme.surface)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(Theme.secondaryText)
                            .font(.largeTitle)
                    )
            }
            .clipped()
            
            // Gradient overlay for text readability
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Property info
            VStack(alignment: .leading, spacing: 8) {
                Text(listing.displayPrice)
                    .homeyFont(.title)
                    .foregroundColor(.white)
                
                Text(listing.address)
                    .homeyFont(.bodyMedium)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(listing.neighborhood)
                    .homeyFont(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
        }
        .frame(height: 380)
        .liquidGlass(cornerRadius: 20)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .scaleEffect(1.0 - abs(offset.width) / 1000)
        .opacity(1.0 - abs(offset.width) / 500.0)
    }
}

private struct FavoriteListingRow: View {
    let listing: ListingModel
    
    var body: some View {
        HStack {
            Image(listing.thumbnailURL)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .liquidGlass()
            
            VStack(alignment: .leading) {
                Text(listing.address)
                    .homeyFont(.h3)
                Text(listing.displayPrice)
                    .homeyFont(.body)
            }
        }
        .padding(.horizontal)
    }
}

private struct MapListingDetailCard: View {
    let listing: ListingModel
    @State private var distanceFromQuery: String = ""
    
    var body: some View {
        VStack {
            TabView {
                ForEach(0..<3) { _ in // Placeholder for image carousel
                    Image(listing.thumbnailURL)
                        .resizable()
                        .scaledToFill()
                }
            }
            .tabViewStyle(.page)
            .frame(height: 200)
            
            HStack {
                Text(listing.displayPrice)
                    .homeyFont(.h2)
                Text(listing.bedroomBathroomText)
                    .homeyFont(.body)
            }
            
            // "Distance From" search bar
            TextField("Distance from: Whole Foods", text: $distanceFromQuery)
                .homeyFont(.body)
                .padding()
                .liquidGlass(cornerRadius: 12)
        }
        .padding()
        .liquidGlass()
    }
}


// MARK: - Mock Data & Preview

fileprivate struct ListingModel: Identifiable {
    let id = UUID()
    let address: String
    let neighborhood: String
    let displayPrice: String
    let bedroomBathroomText: String
    let thumbnailURL: String
    let coordinate: CLLocationCoordinate2D
    
    static func mockData() -> [ListingModel] {
        [
            .init(address: "123 Main St", neighborhood: "SoHo", displayPrice: "$2.5M", bedroomBathroomText: "2 Bed, 2 Bath", thumbnailURL: "charlie", coordinate: .init(latitude: 40.7218, longitude: -74.0018)),
            .init(address: "456 Broadway", neighborhood: "SoHo", displayPrice: "$3.1M", bedroomBathroomText: "3 Bed, 2.5 Bath", thumbnailURL: "viza", coordinate: .init(latitude: 40.7258, longitude: -73.9988)),
            .init(address: "789 Mercer St", neighborhood: "Williamsburg", displayPrice: "$1.8M", bedroomBathroomText: "1 Bed, 1 Bath", thumbnailURL: "isla", coordinate: .init(latitude: 40.7145, longitude: -73.9565)),
        ]
    }
}

#if DEBUG
struct SearchAndDiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        SearchAndDiscoverView()
    }
}
#endif