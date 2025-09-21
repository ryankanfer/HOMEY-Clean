import SwiftUI

struct SwipeablePropertyStack: View {
    @Bindable var viewModel: ScoutViewModel
    @State private var currentIndex = 0
    @State private var swipeOffset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    private let maxCards = 3
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            cardStackView
            actionButtonsView
        }
        .padding(.vertical, 20)
        .onAppear {
            loadMorePropertiesIfNeeded()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Discover Homes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Swipe to find your perfect match")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Swipe indicators
            HStack(spacing: 8) {
                Image(systemName: "hand.thumbsdown.fill")
                    .foregroundColor(.red.opacity(0.6))
                    .font(.caption)
                
                Text("Swipe")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundColor(.green.opacity(0.6))
                    .font(.caption)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var cardStackView: some View {
        ZStack {
            ForEach(Array(visibleProperties.enumerated()), id: \.offset) { index, property in
                SwipeablePropertyCard(
                    property: property,
                    onSwipeLeft: { handleDislike(property) },
                    onSwipeRight: { handleLike(property) },
                    onTap: { viewModel.selectedListing = property }
                )
                .scaleEffect(scaleForCard(at: index))
                .offset(y: offsetForCard(at: index))
                .zIndex(Double(maxCards - index))
                .opacity(opacityForCard(at: index))
                .rotationEffect(.degrees(index == 0 ? rotation : 0))
                .offset(index == 0 ? swipeOffset : .zero)
                .gesture(
                    index == 0 ? dragGesture : nil
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: swipeOffset)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
            }
        }
        .frame(height: 400)
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 40) {
            // Dislike button
            Button(action: { handleDislike(currentProperty) }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.red.opacity(0.6), .red.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
            .disabled(currentProperty == nil)
            
            // Like button
            Button(action: { handleLike(currentProperty) }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.green.opacity(0.6), .green.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .disabled(currentProperty == nil)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Computed Properties
    
    private var visibleProperties: [PropertyListing] {
        let startIndex = currentIndex
        let endIndex = min(startIndex + maxCards, viewModel.listings.count)
        return Array(viewModel.listings[startIndex..<endIndex])
    }
    
    private var currentProperty: PropertyListing? {
        guard currentIndex < viewModel.listings.count else { return nil }
        return viewModel.listings[currentIndex]
    }
    
    // MARK: - Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                swipeOffset = value.translation
                rotation = Double(value.translation.width / 10)
                
                // Scale effect based on drag distance
                let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                scale = max(0.95, 1.0 - dragDistance / 1000)
            }
            .onEnded { value in
                let swipeDistance = value.translation.width
                
                if abs(swipeDistance) > swipeThreshold {
                    // Determine swipe direction
                    if swipeDistance > 0 {
                        handleLike(currentProperty)
                    } else {
                        handleDislike(currentProperty)
                    }
                } else {
                    // Snap back
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        swipeOffset = .zero
                        rotation = 0
                        scale = 1.0
                    }
                }
            }
    }
    
    // MARK: - Card Positioning
    
    private func scaleForCard(at index: Int) -> CGFloat {
        let baseScale: CGFloat = 1.0 - (CGFloat(index) * 0.05)
        return index == 0 ? baseScale * scale : baseScale
    }
    
    private func offsetForCard(at index: Int) -> CGFloat {
        return CGFloat(index) * 8
    }
    
    private func opacityForCard(at index: Int) -> Double {
        return index < maxCards ? 1.0 - (Double(index) * 0.2) : 0
    }
    
    // MARK: - Actions
    
    private func handleLike(_ property: PropertyListing?) {
        guard let property = property else { return }
        
        // Add to user preferences/liked properties
        viewModel.likeProperty(property)
        
        // Animate card away
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            swipeOffset = CGSize(width: 500, height: -100)
            rotation = 15
        }
        
        // Move to next card after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            nextCard()
        }
    }
    
    private func handleDislike(_ property: PropertyListing?) {
        guard let property = property else { return }
        
        // Add to disliked properties
        viewModel.dislikeProperty(property)
        
        // Animate card away
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            swipeOffset = CGSize(width: -500, height: -100)
            rotation = -15
        }
        
        // Move to next card after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            nextCard()
        }
    }
    
    private func nextCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentIndex += 1
            swipeOffset = .zero
            rotation = 0
            scale = 1.0
        }
        
        loadMorePropertiesIfNeeded()
    }
    
    private func loadMorePropertiesIfNeeded() {
        // Load more properties when we're near the end
        if currentIndex >= viewModel.listings.count - 2 {
            viewModel.loadMoreListings()
        }
    }
}

#Preview {
    SwipeablePropertyStack(viewModel: ScoutViewModel())
        .background(Color.black)
}