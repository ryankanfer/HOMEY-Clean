//
//  GlassScaffold.swift
//  HOMEY Clean
//
//  Enhanced with dynamic blur effects, parallax depth, and multi-layer reflections
//

import SwiftUI

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct GlassScaffold<Content: View>: View {
    let items: [GlassFooterItem]
    let selectedTitle: String?
    let showFooterBackground: Bool
    let footerBottomPadding: CGFloat
    var onSelectPersona: (GlassFooterItem) -> Void
    var onLongPressPersona: ((GlassFooterItem) -> Void)?
    var onAskCTA: () -> Void
    private let iconSize: CGFloat = 34
    
    // Enhanced glass properties
    @State private var scrollOffset: CGFloat = 0
    @State private var glassIntensity: Double = 1.0
    @State private var parallaxOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @ViewBuilder var content: Content

    init(
        items: [GlassFooterItem],
        selectedTitle: String? = nil,
        showFooterBackground: Bool = true,
        footerBottomPadding: CGFloat = 8,
        onSelectPersona: @escaping (GlassFooterItem) -> Void = { _ in },
        onLongPressPersona: ((GlassFooterItem) -> Void)? = nil,
        onAskCTA: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.items = items
        self.selectedTitle = selectedTitle
        self.showFooterBackground = showFooterBackground
        self.footerBottomPadding = footerBottomPadding
        self.onSelectPersona = onSelectPersona
        self.onLongPressPersona = onLongPressPersona
        self.onAskCTA = onAskCTA
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background parallax layer
            if !reduceMotion {
                backgroundParallaxLayer
            }
            
            VStack(spacing: 0) {
                // Content with scroll tracking
                ScrollViewReader { proxy in
                    content
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                            }
                        )
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            updateScrollEffects(offset: value)
                        }
                }
                .padding(.bottom, 12)

                EnhancedGlassFooter(
                    title: "Ask",
                    ctaTitle: "Ask \(selectedTitle ?? "Charlie")",
                    items: items,
                    selectedTitle: selectedTitle,
                    showBackground: showFooterBackground,
                    bottomPadding: footerBottomPadding,
                    glassIntensity: glassIntensity,
                    parallaxOffset: parallaxOffset,
                    onSelectItem: onSelectPersona,
                    onLongPressItem: onLongPressPersona,
                    onTapCTA: onAskCTA
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Enhanced Glass Effects
    
    private var backgroundParallaxLayer: some View {
        ZStack {
            // Multi-layer depth effect
            ForEach(0..<3, id: \.self) { layer in
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.02 * Double(layer + 1)),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: CGFloat(layer * 2 + 1))
                    .offset(y: parallaxOffset * CGFloat(layer + 1) * 0.1)
                    .scaleEffect(1.0 + CGFloat(layer) * 0.02)
            }
        }
        .opacity(0.6)
    }
    
    private func updateScrollEffects(offset: CGFloat) {
        guard !reduceMotion else { return }
        
        let normalizedOffset = offset / 100.0
        
        withAnimation(AnimationConstants.quickSpring) {
            scrollOffset = offset
            glassIntensity = max(0.3, min(1.0, 1.0 - abs(normalizedOffset) * 0.3))
            parallaxOffset = normalizedOffset * 20
        }
    }
}



// MARK: - Enhanced Glass Footer

private struct EnhancedGlassFooter: View {
    var title: String
    var ctaTitle: String
    var items: [GlassFooterItem]
    var selectedTitle: String?
    var showBackground: Bool
    var bottomPadding: CGFloat
    var glassIntensity: Double
    var parallaxOffset: CGFloat
    var onSelectItem: (GlassFooterItem) -> Void
    var onLongPressItem: ((GlassFooterItem) -> Void)?
    var onTapCTA: () -> Void
    private let iconSize: CGFloat = 34
    
    @State private var shimmerPhase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 14) {
            // Enhanced drag indicator with glass effect
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.primary.opacity(0.2 * glassIntensity),
                            Color.primary.opacity(0.08 * glassIntensity)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 36, height: 4)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3 * glassIntensity), lineWidth: 0.5)
                )
                .padding(.top, 6)
                .offset(y: parallaxOffset * 0.1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 28) {
                    ForEach(items) { item in
                        let isSelected = (item.title == selectedTitle)
                        enhancedPersonaItem(item: item, isSelected: isSelected)
                    }
                }
                .padding(.horizontal, 20)
            }
            .offset(y: parallaxOffset * 0.05)

            enhancedCTAButton
                .offset(y: parallaxOffset * 0.02)
        }
        .background(showBackground ? AnyShapeStyle(enhancedGlassBackground) : AnyShapeStyle(.clear))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            startShimmerAnimation()
        }
    }
    
    // MARK: - Enhanced Components
    
    private func enhancedPersonaItem(item: GlassFooterItem, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            item.image
                .resizable().scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .background(
                    // Multi-layer glass effect
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(glassIntensity)
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4 * glassIntensity),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Shimmer effect for selected items
                        if isSelected && !reduceMotion {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .init(x: shimmerPhase - 0.3, y: 0),
                                        endPoint: .init(x: shimmerPhase + 0.3, y: 1)
                                    )
                                )
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            isSelected ? 
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.2 * glassIntensity), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? Color.accentColor.opacity(0.3) : Color.black.opacity(0.1),
                    radius: isSelected ? 8 : 2,
                    x: 0,
                    y: isSelected ? 4 : 1
                )
                .scaleEffect(isSelected ? 1.04 : 1.0)
                .animation(AnimationConstants.quickSpring, value: isSelected)

            Text(item.title)
                .typography(.caption, color: Color.semanticTextPrimary.opacity(0.9))
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .contentShape(Rectangle())
        .onTapGesture { onSelectItem(item) }
        .onLongPressGesture(minimumDuration: 0.4) { onLongPressItem?(item) }
    }
    
    private var enhancedCTAButton: some View {
        Button(action: onTapCTA) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(ctaTitle)
                    .typography(.button)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(EnhancedGlassButtonStyle(intensity: glassIntensity))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.bottom, bottomPadding)
    }
    
    private var enhancedGlassBackground: some ShapeStyle {
        .ultraThinMaterial
    }
    
    private func startShimmerAnimation() {
        guard !reduceMotion else { return }
        
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            shimmerPhase = 1.3
        }
    }
}

// MARK: - Enhanced Glass Button Style

struct EnhancedGlassButtonStyle: ButtonStyle {
    let intensity: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.thinMaterial)
                        .opacity(intensity)
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(0.8),
                                    Color.accentColor.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3 * intensity),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4 * intensity),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AnimationConstants.quickSpring, value: configuration.isPressed)
    }
}
