//
//  SearchComponents.swift
//  HOMEY Clean
//
//  Extracted search components from ClientTabView
//

import SwiftUI

// MARK: - Search View

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedFilters: Set<String> = []
    @State private var showingFilters = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Search Properties")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button {
                            showingFilters.toggle()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundStyle(Theme.primary)
                        }
                    }
                    
                    Text("Find your perfect property")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Search Input Card
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        TextField("Search by location, property type...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.body)
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Filter chips
                    if !selectedFilters.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedFilters), id: \.self) { filter in
                                    FilterChip(filter: SearchFilter(
                                        type: .neighborhood,
                                        displayName: filter,
                                        priceRange: nil,
                                        bedrooms: nil,
                                        bathrooms: nil,
                                        neighborhood: filter,
                                        amenities: nil
                                    )) {
                                        selectedFilters.remove(filter)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Quick Actions Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        QuickActionButton(
                            icon: "location.fill",
                            title: "Nearby Properties",
                            color: .blue
                        ) {
                            // Handle nearby search
                        }
                        
                        QuickActionButton(
                            icon: "clock.fill",
                            title: "Recently Viewed",
                            color: .green
                        ) {
                            // Handle recent properties
                        }
                        
                        QuickActionButton(
                            icon: "bookmark.fill",
                            title: "Saved Searches",
                            color: .orange
                        ) {
                            // Handle saved searches
                        }
                        
                        QuickActionButton(
                            icon: "bell.fill",
                            title: "Price Alerts",
                            color: .purple
                        ) {
                            // Handle price alerts
                        }
                    }
                }
                .padding(20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingFilters) {
            // TODO: Integrate with the original SearchFiltersView from Features/Search
            Text("Filters coming soon")
        }
    }
}

// FilterChip moved to SearchTabView.swift to avoid duplication

// QuickActionButton moved to QuickActionsRow.swift to avoid duplication

// SearchFiltersView moved to Features/Search/SearchFiltersView.swift to avoid duplication

// MARK: - Filter Toggle Button

struct FilterToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.primary : Color(.systemGray6))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}