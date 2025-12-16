import SwiftUI

struct ScoutShortlistRail: View {
    let shortlistedProperties: [PropertyListing]
    let onPropertyTap: (PropertyListing) -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trail")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("\(shortlistedProperties.count) saved")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.left" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Shortlist stack
            if !shortlistedProperties.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(shortlistedProperties.enumerated()), id: \.element.id) { index, property in
                            ShortlistPropertyCard(
                                property: property,
                                index: index,
                                isExpanded: isExpanded,
                                onTap: {
                                    onPropertyTap(property)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: isExpanded ? 400 : 200)
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "bookmark")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No saved properties")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Text("Tap buildings to start your trail")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            }
            
            // Progress indicator
            if !shortlistedProperties.isEmpty {
                ProgressionIndicator(
                    savedCount: shortlistedProperties.count
                )
                .padding(.top, 8)
            }
        }
        .frame(width: isExpanded ? 280 : 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
    }
}

// MARK: - Shortlist Property Card
struct ShortlistPropertyCard: View {
    let property: PropertyListing
    let index: Int
    let isExpanded: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Property thumbnail
                AsyncImage(url: URL(string: property.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "building.2")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: isExpanded ? 50 : 40, height: isExpanded ? 40 : 32)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                if isExpanded {
                    // Expanded details
                    VStack(alignment: .leading, spacing: 2) {
                        Text(property.formattedPrice)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(property.neighborhood)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                        
                        Text("\(property.bedrooms)bd • \(property.bathrooms)ba")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                } else {
                    // Collapsed - just index number
                    Text("\(index + 1)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(isExpanded ? 8 : 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isHovered ? 
                            Color.white.opacity(0.2) : 
                            Color.white.opacity(0.1)
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .accessibilityLabel("\(property.formattedPrice) property in \(property.neighborhood)")
        .accessibilityHint("Tap to view details")
    }
}

// MARK: - Progression Indicator
struct ProgressionIndicator: View {
    let savedCount: Int
    
    private var progressLevel: ProgressLevel {
        switch savedCount {
        case 0:
            return .none
        case 1...4:
            return .started
        case 5...9:
            return .exploring
        case 10...19:
            return .neighborhood
        default:
            return .expert
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 3)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressLevel.progress, height: 3)
                        .animation(.easeInOut(duration: 0.5), value: progressLevel.progress)
                }
            }
            .frame(height: 3)
            .clipShape(Capsule())
            
            // Progress label
            Text(progressLevel.title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - Progress Level
enum ProgressLevel {
    case none, started, exploring, neighborhood, expert
    
    var title: String {
        switch self {
        case .none: return "Start exploring"
        case .started: return "Trail started"
        case .exploring: return "Exploring"
        case .neighborhood: return "Neighborhood unlocked"
        case .expert: return "Scout expert"
        }
    }
    
    var progress: CGFloat {
        switch self {
        case .none: return 0.0
        case .started: return 0.2
        case .exploring: return 0.5
        case .neighborhood: return 0.8
        case .expert: return 1.0
        }
    }
}

#Preview {
    ScoutShortlistRail(
        shortlistedProperties: PropertyListing.sampleListings,
        onPropertyTap: { _ in }
    )
    .padding()
    .background(Color.black)
}