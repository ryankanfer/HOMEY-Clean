import SwiftUI

struct SwipeablePropertyCard: View {
    let property: PropertyListing
    let onSwipeLeft: () -> Void  // Dislike
    let onSwipeRight: () -> Void // Like
    let onTap: () -> Void        // View details
    
    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var isPressed = false
    @State private var showingActionIndicator = false
    @State private var actionType: SwipeAction = .none
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    
    var body: some View {
        ZStack {
            // Main card content
            cardContent
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .rotationEffect(.degrees(rotationAngle))
                .offset(dragOffset)
                .opacity(abs(dragOffset.width) > swipeThreshold * 1.5 ? 0.3 : 1.0)
                .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: isPressed)
            
            // Swipe action indicators
            if showingActionIndicator {
                swipeActionOverlay
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = value.translation
                        rotationAngle = Double(value.translation.width / 10)
                        
                        // Show action indicators
                        if abs(value.translation.width) > 50 {
                            showingActionIndicator = true
                            actionType = value.translation.width > 0 ? .like : .dislike
                        } else {
                            showingActionIndicator = false
                            actionType = .none
                        }
                    }
                }
                .onEnded { value in
                    let swipeDistance = value.translation.width
                    
                    if abs(swipeDistance) > swipeThreshold {
                        // Complete the swipe
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragOffset.width = swipeDistance > 0 ? 1000 : -1000
                            rotationAngle = swipeDistance > 0 ? maxRotation : -maxRotation
                        }
                        
                        // Trigger action after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if swipeDistance > 0 {
                                onSwipeRight()
                            } else {
                                onSwipeLeft()
                            }
                        }
                    } else {
                        // Snap back to center
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
                            dragOffset = .zero
                            rotationAngle = 0
                            showingActionIndicator = false
                            actionType = .none
                        }
                    }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    onTap()
                }
        )
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var cardContent: some View {
        VStack(spacing: 0) {
            // Property image
            AsyncImage(url: URL(string: property.imageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.3))
                    )
            }
            .frame(height: 280)
            .clipped()
            
            // Property details
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(property.formattedPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(property.address)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Property specs
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(property.bedrooms)bd • \(property.bathrooms)ba")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(property.neighborhood)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Property features
                if !property.amenities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(property.amenities.prefix(3)), id: \.self) { amenity in
                                Text(amenity)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.2))
                                    )
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
            .padding(16)
        }
        .background(
            ZStack {
                // Base glass material
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                // Glass chip texture overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        Image("glass_chip")
                            .resizable(resizingMode: .tile)
                            .opacity(0.15)
                            .blendMode(.overlay)
                    )
                
                // Futuristic border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .cyan.opacity(0.4),
                                .blue.opacity(0.2),
                                .cyan.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .opacity(0.6)
                
                // Inner highlight
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.2),
                                .clear,
                                .white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(1)
            }
        )
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        .shadow(color: .cyan.opacity(0.1), radius: 25, x: 0, y: 0)
    }
    
    private var swipeActionOverlay: some View {
        ZStack {
            // Action indicator background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    actionType == .like ?
                        Color.green.opacity(0.3) :
                        Color.red.opacity(0.3)
                )
            
            // Action icon and text
            VStack(spacing: 8) {
                Image(systemName: actionType == .like ? "heart.fill" : "xmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(
                        actionType == .like ? .green : .red
                    )
                
                Text(actionType == .like ? "LIKE" : "PASS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(
                        actionType == .like ? .green : .red
                    )
            }
        }
        .opacity(showingActionIndicator ? 0.8 : 0)
        .animation(.easeInOut(duration: 0.2), value: showingActionIndicator)
    }
}

// MARK: - Supporting Types

enum SwipeAction {
    case none
    case like
    case dislike
}

// MARK: - Preview

#Preview {
    SwipeablePropertyCard(
        property: PropertyListing.sampleListings.first!,
        onSwipeLeft: { print("Disliked") },
        onSwipeRight: { print("Liked") },
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.black)
}