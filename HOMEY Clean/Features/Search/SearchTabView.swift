import SwiftUI

struct SearchTabView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showMatchmaker = false
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var showEducationCenter = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Conversational Search Header
                ConversationalSearchView(
                    searchText: $searchText,
                    isSearchFocused: $isSearchFocused,
                    onSearch: { query in
                        viewModel.performSearch(query: query)
                    }
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Quick Filters
                if !viewModel.activeFilters.isEmpty || !searchText.isEmpty {
                    FilterChipsView(
                        filters: viewModel.activeFilters,
                        onRemoveFilter: { filter in
                            viewModel.removeFilter(filter)
                        },
                        onClearAll: {
                            viewModel.clearAllFilters()
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                
                // Main Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Matchmaker Entry Point
                        MatchmakerEntryCard(
                            onTap: {
                                showMatchmaker = true
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Search Results or Recommendations
                        if viewModel.isSearching {
                            SearchLoadingView()
                                .padding(.horizontal)
                        } else if !viewModel.searchResults.isEmpty {
                            SearchResultsSection(
                                results: viewModel.searchResults,
                                onPropertyTap: { property in
                                    viewModel.recordEvent(.listingView(listingId: property.id, source: "search"))
                                },
                                onSave: { property in
                                    viewModel.saveProperty(property)
                                },
                                onTourRequest: { property in
                                    viewModel.requestTour(property)
                                }
                            )
                            .padding(.horizontal)
                        } else {
                            RecommendationsSection(
                                recommendations: viewModel.recommendations,
                                onPropertyTap: { property in
                                    viewModel.recordEvent(.listingView(listingId: property.id, source: "search"))
                                },
                                onSave: { property in
                                    viewModel.saveProperty(property)
                                },
                                onTourRequest: { property in
                                    viewModel.requestTour(property)
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100) // Bottom padding for tab bar
                    }
                }
                .refreshable {
                    await viewModel.refreshRecommendations()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showEducationCenter = true
                    }) {
                        HStack(spacing: 6) {
                            Text("💡")
                                .font(.caption)
                            Text("Tips")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showFilters = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                viewModel.loadRecommendations()
            }
            .sheet(isPresented: $showMatchmaker) {
                MatchmakerView()
            }
            .sheet(isPresented: $viewModel.showFilters) {
                SearchFiltersView(
                    filters: $viewModel.filters,
                    onApply: {
                        viewModel.applyFilters()
                    }
                )
            }
            .sheet(isPresented: $showEducationCenter) {
                LearningCenterView(cards: LearningCard.sampleCards)
            }
        }
    }
}

// MARK: - Conversational Search View

struct ConversationalSearchView: View {
    @Binding var searchText: String
    @Binding var isSearchFocused: Bool
    let onSearch: (String) -> Void
    
    @State private var showingSuggestions = false
    @State private var emotionalContext: EmotionalContext = .neutral
    @FocusState private var textFieldFocused: Bool
    
    private let conversationalPrompts = [
        "Find me a cozy 2BR near good schools",
        "Show pet-friendly places under $3000 with parking",
        "I need a quiet studio with natural light",
        "Looking for vibrant nightlife and walkable streets"
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Emotional Context Selector
            EmotionalContextPicker(selectedContext: $emotionalContext)
                .padding(.horizontal)
            
            // Search Input
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    TextField("Ask me anything about your search...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            if !searchText.isEmpty {
                                onSearch(searchText)
                                isSearchFocused = false
                                textFieldFocused = false
                            }
                        }
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
                
                // Voice search button
                Button {
                    // Voice search functionality
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                }
            }
            
            // Conversational Prompts
            if searchText.isEmpty && !textFieldFocused {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(conversationalPrompts, id: \.self) { prompt in
                            Button {
                                searchText = prompt
                                onSearch(prompt)
                            } label: {
                                Text(prompt)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.1))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onChange(of: textFieldFocused) { focused in
            isSearchFocused = focused
            showingSuggestions = focused && !searchText.isEmpty
        }
        .onChange(of: searchText) { text in
            showingSuggestions = textFieldFocused && !text.isEmpty
        }
    }
}

// MARK: - Filter Chips View

struct FilterChipsView: View {
    let filters: [SearchFilter]
    let onRemoveFilter: (SearchFilter) -> Void
    let onClearAll: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.id) { filter in
                    FilterChip(
                        filter: filter,
                        onRemove: {
                            onRemoveFilter(filter)
                        }
                    )
                }
                
                if !filters.isEmpty {
                    Button("Clear All") {
                        onClearAll()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let filter: SearchFilter
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(filter.displayName)
                .font(.caption)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
                .stroke(Color.blue, lineWidth: 1)
        )
        .foregroundColor(.blue)
    }
}

// MARK: - Matchmaker Entry Card

struct MatchmakerEntryCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Matchmaker")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Swipe through personalized recommendations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
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

// MARK: - Search Results Section

struct SearchResultsSection: View {
    let results: [Property]
    let onPropertyTap: (Property) -> Void
    let onSave: (Property) -> Void
    let onTourRequest: (Property) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search Results")
                .font(.title2.bold())
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(results) { property in
                    PropertyCard(
                        property: property,
                        onTap: { onPropertyTap(property) },
                        onSave: { onSave(property) },
                        onTourRequest: { onTourRequest(property) }
                    )
                }
            }
        }
    }
}

// MARK: - Recommendations Section

struct RecommendationsSection: View {
    let recommendations: [Property]
    let onPropertyTap: (Property) -> Void
    let onSave: (Property) -> Void
    let onTourRequest: (Property) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended for You")
                .font(.title2.bold())
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(recommendations) { property in
                    PropertyCard(
                        property: property,
                        onTap: { onPropertyTap(property) },
                        onSave: { onSave(property) },
                        onTourRequest: { onTourRequest(property) }
                    )
                }
            }
        }
    }
}

// MARK: - Property Card

struct PropertyCard: View {
    let property: Property
    let onTap: () -> Void
    let onSave: () -> Void
    let onTourRequest: () -> Void
    
    @State private var isSaved = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Property Image
                AsyncImage(url: URL(string: property.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "house.fill")
                                .foregroundColor(.secondary)
                        )
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                .overlay(alignment: .topTrailing) {
                    Button {
                        isSaved.toggle()
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
                        Text(property.price)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Tour") {
                            onTourRequest()
                        }
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                    }
                    
                    Text("\(property.bedrooms) bed • \(property.bathrooms) bath • \(property.sqft) sqft")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(property.address)
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

// MARK: - Search Loading View

struct SearchLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Searching for your perfect match...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    SearchTabView()
}