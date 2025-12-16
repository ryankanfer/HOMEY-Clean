import SwiftUI

struct PropertyBuildingCard: View {
    let listing: PropertyListing
    let isActive: Bool
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            // Building card frame
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: isActive ? 
                            [Color.white.opacity(0.9), Color.white.opacity(0.7)] :
                            [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(
                    color: isActive ? Color.blue.opacity(0.3) : Color.black.opacity(0.2),
                    radius: isHovered ? 8 : 4,
                    x: 0,
                    y: 2
                )
            
            VStack(spacing: 6) {
                // Property image thumbnail
                AsyncImage(url: URL(string: listing.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "building.2")
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Property details
                VStack(spacing: 2) {
                    Text(listing.formattedPrice)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .primary : .secondary)
                    
                    Text("\(listing.bedrooms)bd \(listing.bathrooms)ba")
                        .font(.caption2)
                        .foregroundColor(isActive ? .secondary : .gray)
                }
                
                // Pin indicator
                Image(listing.isSaved ? "pin_saved" : "pin_default")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundColor(listing.isSaved ? .green : .gray)
            }
            .padding(8)
        }
        .frame(width: 80, height: 100)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .opacity(isActive ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.3), value: isActive)
        .onHover { hovering in
            isHovered = hovering
        }
        .accessibilityLabel("\(listing.formattedPrice) property, \(listing.bedrooms) bedrooms, \(listing.bathrooms) bathrooms")
        .accessibilityHint("Tap to view details")
    }
}

#Preview {
    PropertyBuildingCard(
        listing: PropertyListing.sampleListings[0],
        isActive: true
    )
    .padding()
    .background(Color.black)
}
