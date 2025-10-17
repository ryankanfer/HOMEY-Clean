import SwiftUI

@available(*, deprecated, message: "This view has been replaced by the new SearchAndDiscoverView. Please use that instead.")
struct SearchTabView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var selectedListing: Listing?
    @State private var showDetailSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Simple Search Header
            SearchHeaderView(
                searchText: $searchText,
                isSearchFocused: $isSearchFocused
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Main Content
            if viewModel.isLoading {
                ProgressView("Loading properties...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Property Listings
                        ForEach(viewModel.listings) { listing in
                            ListingCardView(
                                listing: listing,
                                isSaved: viewModel.savedListingIDs.contains(listing.id),
                                onTap: {
                                    selectedListing = listing
                                    showDetailSheet = true
                                },
                                onSave: {
                                    viewModel.toggleSave(for: listing)
                                }
                            )
                        }
                        
                        Spacer(minLength: 100) // Bottom padding for tab bar
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Filter functionality could be added here
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showDetailSheet) {
            if let listing = selectedListing {
                PropertyDetailView(listing: listing)
            }
        }
        .onAppear {
            viewModel.loadInitialData()
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Search Header View

struct SearchHeaderView: View {
    @Binding var searchText: String
    @Binding var isSearchFocused: Bool
    
    @FocusState private var textFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search properties...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($textFieldFocused)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(textFieldFocused ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .onChange(of: textFieldFocused) { focused in
            isSearchFocused = focused
        }
    }
}

// MARK: - Property Card

struct ListingCardView: View {
    let listing: Listing
    let isSaved: Bool
    let onTap: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Property Image Placeholder
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "house.fill")
                            .foregroundColor(.secondary)
                    )
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            onSave()
                        } label: {
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .foregroundColor(isSaved ? .red : .white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        .padding(8)
                    }
                
                // Property Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(listing.displayPrice)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text(listing.bedroomBathroomText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let sqft = listing.squareFootage {
                        Text("\(sqft) sq ft")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(listing.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.horizontal, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SearchTabView()
    }
}