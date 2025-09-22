import SwiftUI

struct SearchFiltersView: View {
    @Binding var filters: SearchFilters
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFilters: SearchFilters
    
    init(filters: Binding<SearchFilters>, onApply: @escaping () -> Void) {
        self._filters = filters
        self.onApply = onApply
        self._tempFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Price Range Section
                    priceRangeSection
                    
                    Divider()
                    
                    // Bedrooms & Bathrooms Section
                    bedroomsBathroomsSection
                    
                    Divider()
                    
                    // Neighborhoods Section
                    neighborhoodsSection
                    
                    Divider()
                    
                    // Amenities Section
                    amenitiesSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
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
    
    // MARK: - Price Range Section
    
    private var priceRangeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Text("$1,000")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$8,000+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let range = tempFilters.priceRange {
                    Text("$\(Int(range.lowerBound)) - $\(Int(range.upperBound)) per month")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                } else {
                    Text("Any budget")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Price range slider would go here
                // For now, using preset buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(priceRangeOptions, id: \.label) { option in
                        Button {
                            if tempFilters.priceRange == option.range {
                                tempFilters.priceRange = nil
                            } else {
                                tempFilters.priceRange = option.range
                            }
                        } label: {
                            Text(option.label)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(tempFilters.priceRange == option.range ? Color.blue : Color(.systemGray6))
                                )
                                .foregroundColor(tempFilters.priceRange == option.range ? .white : .primary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Bedrooms & Bathrooms Section
    
    private var bedroomsBathroomsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bedrooms & Bathrooms")
                .font(.headline)
            
            VStack(spacing: 16) {
                bedroomsSection
                bathroomsSection
            }
        }
    }
    
    private var bedroomsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Minimum Bedrooms")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                ForEach(0...4, id: \.self) { count in
                    bedroomButton(for: count)
                }
            }
        }
    }
    
    private func bedroomButton(for count: Int) -> some View {
        Button {
            tempFilters.minBedrooms = tempFilters.minBedrooms == count ? nil : count
        } label: {
            Text(count == 0 ? "Studio" : "\(count)") // swiftlint:disable:this empty_count
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 50, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tempFilters.minBedrooms == count ? Color.blue : Color(.systemGray6))
                )
                .foregroundColor(tempFilters.minBedrooms == count ? .white : .primary)
        }
    }
    
    private var bathroomsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Minimum Bathrooms")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                ForEach(1...3, id: \.self) { count in
                    bathroomButton(for: count)
                }
            }
        }
    }
    
    private func bathroomButton(for count: Int) -> some View {
        Button {
            tempFilters.minBathrooms = tempFilters.minBathrooms == count ? nil : count
        } label: {
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 50, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tempFilters.minBathrooms == count ? Color.blue : Color(.systemGray6))
                )
                .foregroundColor(tempFilters.minBathrooms == count ? .white : .primary)
        }
    }
    
    // MARK: - Neighborhoods Section
    
    private var neighborhoodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Neighborhoods")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(popularNeighborhoods, id: \.self) { neighborhood in
                    Button {
                        if tempFilters.neighborhoods.contains(neighborhood) {
                            tempFilters.neighborhoods.removeAll { $0 == neighborhood }
                        } else {
                            tempFilters.neighborhoods.append(neighborhood)
                        }
                    } label: {
                        Text(neighborhood)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(tempFilters.neighborhoods.contains(neighborhood) ? Color.blue : Color(.systemGray6))
                            )
                            .foregroundColor(tempFilters.neighborhoods.contains(neighborhood) ? .white : .primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Amenities Section
    
    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Must-Have Amenities")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(commonAmenities, id: \.self) { amenity in
                    Button {
                        if tempFilters.amenities.contains(amenity) {
                            tempFilters.amenities.removeAll { $0 == amenity }
                        } else {
                            tempFilters.amenities.append(amenity)
                        }
                    } label: {
                        Text(amenity)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(tempFilters.amenities.contains(amenity) ? Color.blue : Color(.systemGray6))
                            )
                            .foregroundColor(tempFilters.amenities.contains(amenity) ? .white : .primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Data
    
    private let priceRangeOptions: [(label: String, range: ClosedRange<Double>)] = [
        ("Under $2K", 1000...2000),
        ("$2K - $3K", 2000...3000),
        ("$3K - $4K", 3000...4000),
        ("$4K - $5K", 4000...5000),
        ("$5K - $6K", 5000...6000),
        ("$6K+", 6000...8000)
    ]
    
    private let popularNeighborhoods = [
        "Brooklyn Heights", "Park Slope", "Williamsburg", "DUMBO",
        "Carroll Gardens", "Cobble Hill", "Fort Greene", "Prospect Heights",
        "Greenpoint", "Red Hook", "Boerum Hill", "Gowanus"
    ]
    
    private let commonAmenities = [
        "Pet Friendly", "Parking", "Laundry", "Gym",
        "Doorman", "Elevator", "Balcony", "Dishwasher",
        "Air Conditioning", "Outdoor Space", "Storage", "Bike Storage"
    ]
}

#Preview {
    SearchFiltersView(
        filters: .constant(SearchFilters()),
        onApply: {}
    )
}