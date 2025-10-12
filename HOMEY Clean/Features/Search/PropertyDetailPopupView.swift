import SwiftUI

// A mock listing model for preview purposes.
struct MockListing {
    var title: String
    var neighborhood: String
    var price: String
    var details: String
    var photoCount: Int
}

struct PropertyDetailPopupView: View {
    // The listing to display. Using a default mock object for now.
    let listing: MockListing = MockListing(
        title: "Loft with skyline views",
        neighborhood: "Williamsburg",
        price: "$1.2M",
        details: "2 bed • 2 bath • 850 sq ft • Incredible Manhattan views from private roof deck",
        photoCount: 4
    )

    @State private var locationQuery: String = ""
    @State private var queryResponse: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Drag handle
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            // Header Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(listing.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(listing.neighborhood)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(listing.price)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                // Photo Buttons
                HStack(spacing: 10) {
                    ForEach(1...listing.photoCount, id: \.self) { index in
                        Button(action: {}) {
                            Text("Photo \(index)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.accentColor.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }

                Text(listing.details)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

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


            // Action Buttons
            HStack(spacing: 12) {
                Button("Close") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
                .fontWeight(.semibold)

                Button("View Details") {
                    // Action for viewing full details
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }

    private func submitQuery() {
        handleQuery(locationQuery)
    }

    private func handleQuery(_ query: String) {
        // Simple placeholder logic
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

struct SuggestionChip: View {
    let text: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray4))
                .foregroundColor(.primary)
                .cornerRadius(12)
        }
    }
}

#Preview {
    PropertyDetailPopupView()
}