import SwiftUI

struct MatchmakerFiltersView: View {
    @Binding var filters: MatchmakerFilters
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFilters: MatchmakerFilters
    
    init(filters: Binding<MatchmakerFilters>, onApply: @escaping () -> Void) {
        self._filters = filters
        self.onApply = onApply
        self._tempFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Price Range Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Price Range")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("$2,000")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$6,000")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Price range slider would go here
                            // For now, we'll use buttons for common ranges
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(priceRangeOptions, id: \.self) { range in
                                    Button {
                                        if tempFilters.priceRange == range {
                                            tempFilters.priceRange = nil
                                        } else {
                                            tempFilters.priceRange = range
                                        }
                                    } label: {
                                        Text("$\(Int(range.lowerBound))K - $\(Int(range.upperBound))K")
                                            .font(.subheadline)
                                            .foregroundColor(tempFilters.priceRange == range ? .white : .primary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(tempFilters.priceRange == range ? Color.blue : Color(.systemGray6))
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    
                    // Bedrooms Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Minimum Bedrooms")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...4, id: \.self) { bedrooms in
                                Button {
                                    if tempFilters.minBedrooms == bedrooms {
                                        tempFilters.minBedrooms = nil
                                    } else {
                                        tempFilters.minBedrooms = bedrooms
                                    }
                                } label: {
                                    Text("\(bedrooms)+")
                                        .font(.subheadline.bold())
                                        .foregroundColor(tempFilters.minBedrooms == bedrooms ? .white : .primary)
                                        .frame(width: 50, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(tempFilters.minBedrooms == bedrooms ? Color.blue : Color(.systemGray6))
                                        )
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    
                    // Bathrooms Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Minimum Bathrooms")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...3, id: \.self) { bathrooms in
                                Button {
                                    if tempFilters.minBathrooms == bathrooms {
                                        tempFilters.minBathrooms = nil
                                    } else {
                                        tempFilters.minBathrooms = bathrooms
                                    }
                                } label: {
                                    Text("\(bathrooms)+")
                                        .font(.subheadline.bold())
                                        .foregroundColor(tempFilters.minBathrooms == bathrooms ? .white : .primary)
                                        .frame(width: 50, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(tempFilters.minBathrooms == bathrooms ? Color.blue : Color(.systemGray6))
                                        )
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    
                    // Neighborhoods Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Neighborhoods")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(neighborhoodOptions, id: \.self) { neighborhood in
                                Button {
                                    if tempFilters.neighborhoods.contains(neighborhood) {
                                        tempFilters.neighborhoods.removeAll { $0 == neighborhood }
                                    } else {
                                        tempFilters.neighborhoods.append(neighborhood)
                                    }
                                } label: {
                                    Text(neighborhood)
                                        .font(.subheadline)
                                        .foregroundColor(tempFilters.neighborhoods.contains(neighborhood) ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(tempFilters.neighborhoods.contains(neighborhood) ? Color.blue : Color(.systemGray6))
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    
                    // Amenities Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Must-Have Amenities")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(amenityOptions, id: \.self) { amenity in
                                Button {
                                    if tempFilters.mustHaveAmenities.contains(amenity) {
                                        tempFilters.mustHaveAmenities.removeAll { $0 == amenity }
                                    } else {
                                        tempFilters.mustHaveAmenities.append(amenity)
                                    }
                                } label: {
                                    Text(amenity)
                                        .font(.subheadline)
                                        .foregroundColor(tempFilters.mustHaveAmenities.contains(amenity) ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(tempFilters.mustHaveAmenities.contains(amenity) ? Color.blue : Color(.systemGray6))
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        filters = tempFilters
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Clear All") {
                        tempFilters.clearAll()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Filter Options
    
    private var priceRangeOptions: [ClosedRange<Double>] {
        [
            2000...3000,
            3000...4000,
            4000...5000,
            5000...6000
        ]
    }
    
    private var neighborhoodOptions: [String] {
        [
            "Brooklyn Heights",
            "DUMBO",
            "Cobble Hill",
            "Carroll Gardens",
            "Red Hook",
            "Greenpoint",
            "Williamsburg",
            "Fort Greene",
            "Boerum Hill",
            "Prospect Heights",
            "Park Slope",
            "Gowanus"
        ]
    }
    
    private var amenityOptions: [String] {
        [
            "Pet Friendly",
            "Gym",
            "Rooftop",
            "Doorman",
            "Laundry",
            "Parking",
            "Balcony",
            "Dishwasher",
            "AC",
            "Elevator"
        ]
    }
}

#Preview {
    MatchmakerFiltersView(
        filters: .constant(MatchmakerFilters()),
        onApply: {}
    )
}