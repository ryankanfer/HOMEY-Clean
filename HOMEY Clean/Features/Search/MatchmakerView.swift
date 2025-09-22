import SwiftUI

struct MatchmakerView: View {
    @StateObject private var viewModel = MatchmakerViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentCardIndex = 0
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground(for: .matchmaker)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ZStack {
                    ForEach(Array(viewModel.properties.enumerated()), id: \.offset) { index, property in
                        if index >= currentCardIndex && index < currentCardIndex + 3 {
                            PropertySwipeCard(
                                property: property,
                                isTopCard: index == currentCardIndex,
                                cardIndex: index - currentCardIndex,
                                onSwipe: { direction in
                                    handleSwipe(direction: direction, property: property)
                                }
                            )
                            .zIndex(Double(viewModel.properties.count - index))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                
                actionButtonsView
                    .padding(.bottom, 20)
            }
        }
        .navigationTitle("Matchmaker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showFilters = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .onAppear {
            ThemeManager.shared.setCurrentPage(.matchmaker)
            viewModel.loadProperties()
        }
        .sheet(isPresented: $viewModel.showFilters) {
            MatchmakerFiltersView(
                filters: $viewModel.filters,
                onApply: {
                    viewModel.applyFilters()
                }
            )
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Find Your Hive")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text("Swipe right to save • Swipe up to tour • Swipe left to pass")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 40) {
            Button {
                if currentCardIndex < viewModel.properties.count {
                    handleSwipe(direction: .left, property: viewModel.properties[currentCardIndex])
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Button {
                if currentCardIndex < viewModel.properties.count {
                    handleSwipe(direction: .up, property: viewModel.properties[currentCardIndex])
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("Unlock")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Button {
                if currentCardIndex < viewModel.properties.count {
                    handleSwipe(direction: .right, property: viewModel.properties[currentCardIndex])
                }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                    .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func handleSwipe(direction: SwipeDirection, property: Property) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            switch direction {
            case .left:
                viewModel.passProperty(property)
            case .right:
                viewModel.saveProperty(property)
            case .up:
                viewModel.requestTour(property)
            }
            
            currentCardIndex += 1
            
            if currentCardIndex >= viewModel.properties.count - 2 {
                viewModel.loadMoreProperties()
            }
        }
    }
}

struct PropertySwipeCard: View {
    let property: Property
    let isTopCard: Bool
    let cardIndex: Int
    let onSwipe: (SwipeDirection) -> Void
    
    @State private var localDragOffset = CGSize.zero
    @State private var rotation: Double = 0
    
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: property.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "house.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
                .frame(height: 300)
                .clipped()
                .cornerRadius(20, corners: [.topLeft, .topRight])
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(property.price)
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if property.id == "agent_exclusive" {
                            Text("Invite-Only")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                )
                        }
                    }
                    
                    Text("\(property.bedrooms) bed • \(property.bathrooms) bath • \(property.sqft) sqft")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        StatBadge(icon: "figure.walk", text: "8 min walk")
                        StatBadge(icon: "train.side.front.car", text: "2 min to subway")
                        StatBadge(icon: "pawprint.fill", text: "Pet friendly")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .scaleEffect(isTopCard ? 1.0 : 0.95 - (CGFloat(cardIndex) * 0.05))
        .offset(x: isTopCard ? localDragOffset.width : 0, y: isTopCard ? localDragOffset.height : CGFloat(cardIndex) * 10)
        .rotationEffect(.degrees(isTopCard ? rotation : 0))
        .opacity(cardIndex < 3 ? 1.0 - (CGFloat(cardIndex) * 0.1) : 0)
        .gesture(
            isTopCard ? DragGesture()
                .onChanged { value in
                    localDragOffset = value.translation
                    rotation = Double(value.translation.width / 20)
                }
                .onEnded { value in
                    let swipeDirection = determineSwipeDirection(translation: value.translation)
                    
                    if let direction = swipeDirection {
                        onSwipe(direction)
                    } else {
                        withAnimation(.spring()) {
                            localDragOffset = .zero
                            rotation = 0
                        }
                    }
                } : nil
        )
        .overlay(alignment: .topLeading) {
            if isTopCard && localDragOffset.width > 50 {
                SwipeIndicator(type: .save)
                    .padding()
            }
        }
        .overlay(alignment: .topTrailing) {
            if isTopCard && localDragOffset.width < -50 {
                SwipeIndicator(type: .pass)
                    .padding()
            }
        }
        .overlay(alignment: .top) {
            if isTopCard && localDragOffset.height < -50 {
                SwipeIndicator(type: .tour)
                    .padding()
            }
        }
    }
    
    private func determineSwipeDirection(translation: CGSize) -> SwipeDirection? {
        if abs(translation.width) > swipeThreshold {
            return translation.width > 0 ? .right : .left
        } else if translation.height < -swipeThreshold {
            return .up
        }
        return nil
    }
}

struct StatBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
}

struct SwipeIndicator: View {
    let type: SwipeType
    
    enum SwipeType {
        case save, pass, tour
        
        var color: Color {
            switch self {
            case .save: return .green
            case .pass: return .red
            case .tour: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .save: return "heart.fill"
            case .pass: return "xmark"
            case .tour: return "calendar.badge.plus"
            }
        }
        
        var text: String {
            switch self {
            case .save: return "SAVE"
            case .pass: return "PASS"
            case .tour: return "TOUR"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: type.icon)
                .font(.title2.bold())
            Text(type.text)
                .font(.headline.bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(type.color)
        )
        .shadow(color: type.color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

enum SwipeDirection {
    case left, right, up
}

#Preview {
    MatchmakerView()
}