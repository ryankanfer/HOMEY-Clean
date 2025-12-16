//
//  TRAESearchAnimations.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Copyright © 2024 HOMEY. All rights reserved.
//

import SwiftUI

// MARK: - Search Interface Animations
// Note: ScrollOffsetPreferenceKey is defined in Style/GlassScaffold.swift

/// Animated search lens with shimmer and distortion effects
struct TRAESearchLens: View {
    @State private var shimmerOffset: CGFloat = -200
    @State private var isSearching: Bool = false
    @State private var lensScale: CGFloat = 1.0
    @State private var distortionAmount: CGFloat = 0
    @Binding var searchText: String
    
    let onSearch: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated Search Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .scaleEffect(lensScale)
                    .overlay(
                        // Shimmer effect
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.6),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 30)
                            .offset(x: shimmerOffset)
                            .clipped()
                    )
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .scaleEffect(isSearching ? 1.1 : 1.0)
                    .rotationEffect(.degrees(isSearching ? 15 : 0))
            }
            .onTapGesture {
                performSearch()
            }
            
            // Search TextField with distortion effect
            TextField("Search with TRAE lens...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.3),
                                            Color.purple.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
                .scaleEffect(x: 1.0 + distortionAmount * 0.02, y: 1.0)
                .onSubmit {
                    performSearch()
                }
        }
        .padding(.horizontal, 20)
        .onAppear {
            startShimmerAnimation()
        }
    }
    
    private func performSearch() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isSearching = true
            lensScale = 1.2
            distortionAmount = 0.5
        }
        
        TRAEMotionSystem.shared.triggerHaptic(.medium)
        onSearch()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isSearching = false
                lensScale = 1.0
                distortionAmount = 0
            }
        }
    }
    
    private func startShimmerAnimation() {
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 200
        }
    }
}

/// Search results with parallax scrolling effect
struct TRAEParallaxSearchResults<Content: View>: View {
    let content: Content
    @State private var scrollOffset: CGFloat = 0
    @GestureState private var dragOffset: CGSize = .zero
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                content
            }
            .padding(.horizontal, 20)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .background(
            // Parallax background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .offset(y: scrollOffset * 0.3)
        )
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
        )
        .offset(x: dragOffset.width * 0.1)
    }
}

/// Individual search result item with hover effects
struct TRAESearchResultItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let onTap: () -> Void
    
    @State private var isHovered: Bool = false
    @State private var shimmerOffset: CGFloat = -100
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(isHovered ? 0.3 : 0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isHovered ? 90 : 0))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    // Shimmer overlay
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 60)
                        .offset(x: shimmerOffset)
                        .clipped()
                        .opacity(isHovered ? 1 : 0)
                )
                .shadow(
                    color: Color.black.opacity(isHovered ? 0.15 : 0.05),
                    radius: isHovered ? 12 : 6,
                    x: 0,
                    y: isHovered ? 6 : 3
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onTapGesture {
            onTap()
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
            
            if hovering {
                TRAEMotionSystem.shared.triggerHaptic(.light)
                startShimmerAnimation()
            }
        }
    }
    
    private func startShimmerAnimation() {
        withAnimation(
            Animation.linear(duration: 0.8)
        ) {
            shimmerOffset = 100
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            shimmerOffset = -100
        }
    }
}

/// Animated search suggestions dropdown
struct TRAESearchSuggestions: View {
    let suggestions: [String]
    let onSelect: (String) -> Void
    @State private var animationOffset: CGFloat = -20
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(suggestion)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .onTapGesture {
                    onSelect(suggestion)
                }
                .offset(y: animationOffset)
                .opacity(opacity)
                .animation(
                    Animation.spring(response: 0.4, dampingFraction: 0.8)
                        .delay(Double(index) * 0.05),
                    value: animationOffset
                )
                .animation(
                    Animation.easeOut(duration: 0.3)
                        .delay(Double(index) * 0.05),
                    value: opacity
                )
                
                if index < suggestions.count - 1 {
                    Divider()
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        )
        .onAppear {
            withAnimation {
                animationOffset = 0
                opacity = 1
            }
        }
    }
}

// MARK: - Preference Keys
// ScrollOffsetPreferenceKey is defined in GlassScaffold.swift

// MARK: - View Extensions

extension View {
    /// Apply TRAE search lens animation
    func traeSearchLens(
        searchText: Binding<String>,
        onSearch: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            TRAESearchLens(searchText: searchText, onSearch: onSearch)
            self
        }
    }
    
    /// Apply TRAE parallax scrolling effect
    func traeParallaxScroll() -> some View {
        TRAEParallaxSearchResults {
            self
        }
    }
    
    /// Apply TRAE search result item styling
    func traeSearchResult(
        title: String,
        subtitle: String,
        icon: String,
        onTap: @escaping () -> Void
    ) -> some View {
        TRAESearchResultItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            onTap: onTap
        )
    }
}