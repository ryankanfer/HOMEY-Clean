//
//  TRAECarouselAnimations.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//

import SwiftUI
import UIKit

// MARK: - TRAE Carousel Animation Components

/// Business card-style flip animation for directory carousel
struct TRAEFlippableCard<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    let isFlipped: Bool
    let onFlip: () -> Void
    
    @State private var animationProgress: Double = 0
    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var shadowIntensity: Double = 0.2
    
    init(
        isFlipped: Bool,
        onFlip: @escaping () -> Void = {},
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self.isFlipped = isFlipped
        self.onFlip = onFlip
        self.front = front()
        self.back = back()
    }
    
    var body: some View {
        ZStack {
            // Back side
            back
                .rotation3DEffect(
                    .degrees(180 + animationProgress * 180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(animationProgress > 0.5 ? 1 : 0)
            
            // Front side
            front
                .rotation3DEffect(
                    .degrees(animationProgress * 180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(animationProgress <= 0.5 ? 1 : 0)
        }
        .scaleEffect(cardScale)
        .rotationEffect(.degrees(cardRotation))
        .offset(dragOffset)
        .shadow(
            color: .black.opacity(shadowIntensity),
            radius: 12 + shadowIntensity * 8,
            x: dragOffset.width * 0.1,
            y: 4 + dragOffset.height * 0.1
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { value in
                    handleDragEnded(value)
                }
        )
        .onTapGesture {
            flipCard()
        }
        .onChange(of: isFlipped) { flipped in
            animateToFlippedState(flipped)
        }
        .onAppear {
            if isFlipped {
                animationProgress = 1.0
            }
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        dragOffset = value.translation
        
        // Add realistic card physics
        let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
        let maxDrag: CGFloat = 100
        let normalizedDrag = min(dragDistance / maxDrag, 1.0)
        
        // Rotation based on drag direction
        cardRotation = Double(value.translation.width * 0.1)
        
        // Scale effect
        cardScale = 1.0 + normalizedDrag * 0.05
        
        // Shadow intensity
        shadowIntensity = 0.2 + normalizedDrag * 0.3
        
        // Haptic feedback for drag threshold
        if dragDistance > 50 {
            TRAEHapticManager.shared.trigger(.light)
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
        
        // Flip if dragged far enough
        if dragDistance > 80 {
            flipCard()
        }
        
        // Animate back to original position
        withAnimation(
            .spring(
                response: 0.6,
                dampingFraction: 0.7,
                blendDuration: 0.3
            )
        ) {
            dragOffset = .zero
            cardRotation = 0
            cardScale = 1.0
            shadowIntensity = 0.2
        }
    }
    
    private func flipCard() {
        TRAEHapticManager.shared.trigger(.medium)
        onFlip()
    }
    
    private func animateToFlippedState(_ flipped: Bool) {
        withAnimation(
            .spring(
                response: 0.8,
                dampingFraction: 0.6,
                blendDuration: 0.2
            )
        ) {
            animationProgress = flipped ? 1.0 : 0.0
        }
    }
}

// MARK: - Directory Carousel

struct TRAEDirectoryCarousel<Item: Identifiable, CardContent: View>: View {
    let items: [Item]
    let cardContent: (Item) -> CardContent
    
    @State private var currentIndex = 0
    @State private var flippedCards: Set<Int> = []
    @State private var dragOffset: CGFloat = 0
    @State private var cardSpacing: CGFloat = 20
    
    init(
        items: [Item],
        @ViewBuilder cardContent: @escaping (Item) -> CardContent
    ) {
        self.items = items
        self.cardContent = cardContent
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: cardSpacing) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let isFlipped = flippedCards.contains(index)
                    let offset = CGFloat(index - currentIndex)
                    
                    TRAEFlippableCard(
                        isFlipped: isFlipped,
                        onFlip: {
                            toggleCardFlip(at: index)
                        },
                        front: {
                            cardContent(item)
                                .frame(
                                    width: geometry.size.width * 0.7,
                                    height: geometry.size.height * 0.8
                                )
                        },
                        back: {
                            CardBackView(item: item)
                                .frame(
                                    width: geometry.size.width * 0.7,
                                    height: geometry.size.height * 0.8
                                )
                        }
                    )
                    .scaleEffect(scaleForCard(at: index))
                    .offset(x: offsetForCard(at: index, in: geometry))
                    .zIndex(zIndexForCard(at: index))
                    .opacity(opacityForCard(at: index))
                    .animation(
                        .spring(
                            response: 0.6,
                            dampingFraction: 0.8
                        ),
                        value: currentIndex
                    )
                }
            }
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        handleCarouselDragEnded(value, geometry: geometry)
                    }
            )
        }
        .clipped()
    }
    
    private func scaleForCard(at index: Int) -> CGFloat {
        let distance = abs(index - currentIndex)
        switch distance {
        case 0: return 1.0
        case 1: return 0.85
        default: return 0.7
        }
    }
    
    private func offsetForCard(at index: Int, in geometry: GeometryProxy) -> CGFloat {
        let cardWidth = geometry.size.width * 0.7
        let baseOffset = CGFloat(index - currentIndex) * (cardWidth + cardSpacing)
        
        // Add perspective effect
        let distance = abs(index - currentIndex)
        let perspectiveOffset = CGFloat(distance) * 30
        
        return baseOffset + (index > currentIndex ? perspectiveOffset : -perspectiveOffset)
    }
    
    private func zIndexForCard(at index: Int) -> Double {
        let distance = abs(index - currentIndex)
        return Double(items.count - distance)
    }
    
    private func opacityForCard(at index: Int) -> Double {
        let distance = abs(index - currentIndex)
        switch distance {
        case 0: return 1.0
        case 1: return 0.8
        case 2: return 0.6
        default: return 0.3
        }
    }
    
    private func toggleCardFlip(at index: Int) {
        if flippedCards.contains(index) {
            flippedCards.remove(index)
        } else {
            flippedCards.insert(index)
        }
    }
    
    private func handleCarouselDragEnded(_ value: DragGesture.Value, geometry: GeometryProxy) {
        let threshold = geometry.size.width * 0.2
        
        if value.translation.width > threshold && currentIndex > 0 {
            // Swipe right - go to previous
            currentIndex -= 1
            TRAEMotionSystem.shared.triggerHaptic(.light)
        } else if value.translation.width < -threshold && currentIndex < items.count - 1 {
            // Swipe left - go to next
            currentIndex += 1
            TRAEMotionSystem.shared.triggerHaptic(.light)
        }
        
        // Animate back to position
        withAnimation(
            .spring(
                response: 0.5,
                dampingFraction: 0.7
            )
        ) {
            dragOffset = 0
        }
    }
}

// MARK: - Card Back View

struct CardBackView<Item>: View {
    let item: Item
    
    var body: some View {
        ZStack {
            // Background with glassmorphism
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            
            // Content
            VStack(spacing: 16) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Additional information about this item")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Stack Card Animation

struct TRAEStackedCards<Item: Identifiable, CardContent: View>: View {
    let items: [Item]
    let cardContent: (Item) -> CardContent
    
    @State private var expandedIndex: Int? = nil
    @State private var dragStates: [CGSize] = []
    
    init(
        items: [Item],
        @ViewBuilder cardContent: @escaping (Item) -> CardContent
    ) {
        self.items = items
        self.cardContent = cardContent
        self._dragStates = State(initialValue: Array(repeating: .zero, count: items.count))
    }
    
    var body: some View {
        ZStack {
            ForEach(items.indices.reversed(), id: \.self) { index in
                let item = items[index]
                let isExpanded = expandedIndex == index
                
                cardContent(item)
                    .frame(width: 280, height: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .shadow(
                                color: .black.opacity(0.2),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                    .scaleEffect(isExpanded ? 1.1 : stackScale(for: index))
                    .offset(
                        x: isExpanded ? 0 : stackOffset(for: index).width + dragStates[index].width,
                        y: isExpanded ? 0 : stackOffset(for: index).height + dragStates[index].height
                    )
                    .zIndex(isExpanded ? Double(items.count) : Double(index))
                    .animation(
                        .spring(
                            response: 0.6,
                            dampingFraction: 0.7
                        ),
                        value: expandedIndex
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragStates[index] = value.translation
                            }
                            .onEnded { value in
                                handleCardDragEnded(at: index, with: value)
                            }
                    )
                    .onTapGesture {
                        toggleExpansion(at: index)
                    }
            }
        }
    }
    
    private func stackScale(for index: Int) -> CGFloat {
        let position = items.count - 1 - index
        return 1.0 - CGFloat(position) * 0.05
    }
    
    private func stackOffset(for index: Int) -> CGSize {
        let position = items.count - 1 - index
        return CGSize(
            width: CGFloat(position) * 8,
            height: CGFloat(position) * -12
        )
    }
    
    private func toggleExpansion(at index: Int) {
        withAnimation(
            .spring(
                response: 0.6,
                dampingFraction: 0.7
            )
        ) {
            if expandedIndex == index {
                expandedIndex = nil
            } else {
                expandedIndex = index
            }
        }
        
        TRAEHapticManager.shared.trigger(.medium)
    }
    
    private func handleCardDragEnded(at index: Int, with value: DragGesture.Value) {
        let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
        
        if dragDistance > 100 {
            // Card was dragged far enough - could trigger an action
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        
        // Animate back to position
        withAnimation(
            .spring(
                response: 0.5,
                dampingFraction: 0.7
            )
        ) {
            dragStates[index] = .zero
        }
    }
}

// MARK: - Carousel Indicator

struct TRAECarouselIndicator: View {
    let totalItems: Int
    let currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalItems, id: \.self) { index in
                Circle()
                    .fill(
                        index == currentIndex
                            ? Color.white
                            : Color.white.opacity(0.4)
                    )
                    .frame(
                        width: index == currentIndex ? 12 : 8,
                        height: index == currentIndex ? 12 : 8
                    )
                    .animation(
                        .spring(
                            response: 0.4,
                            dampingFraction: 0.6
                        ),
                        value: currentIndex
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE flippable card animation
    func traeFlippableCard<Back: View>(
        isFlipped: Bool,
        onFlip: @escaping () -> Void = {},
        @ViewBuilder back: () -> Back
    ) -> some View {
        TRAEFlippableCard(
            isFlipped: isFlipped,
            onFlip: onFlip,
            front: { self },
            back: back
        )
    }
    
    /// Apply TRAE carousel physics
    func traeCarouselPhysics(
        dragOffset: CGSize,
        isActive: Bool = true
    ) -> some View {
        self
            .scaleEffect(isActive ? 1.02 : 1.0)
            .rotationEffect(.degrees(Double(dragOffset.width * 0.05)))
            .shadow(
                color: .black.opacity(isActive ? 0.3 : 0.1),
                radius: isActive ? 12 : 4,
                x: dragOffset.width * 0.1,
                y: 2 + dragOffset.height * 0.1
            )
    }
}