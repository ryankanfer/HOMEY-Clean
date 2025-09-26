//
//  ColorPaletteRow.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI

struct ColorPaletteRow: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    let palette: ColorPalette
    let isSelected: Bool
    
    @State private var isAnimating = false
    @State private var showingColorDetails = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Palette Header
            paletteHeader
            
            // Color Swatches
            colorSwatchesRow
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .dayModeAwareLiquidGlass()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected
                    ? Theme.heroGradient(for: .vision)
                    : LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.1)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: isSelected ? 2 : 1
                )
                .opacity(isSelected ? 1.0 : 0.6)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        .onTapGesture {
            selectPalette()
        }
    }
    
    // MARK: - Palette Header
    
    private var paletteHeader: some View {
        HStack {
            // Palette Icon
            Image(systemName: palette.vision.icon)
                .font(.title3)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            
            // Palette Name
            Text(palette.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
            
            Spacer()
            
            // Selection Indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            }
        }
    }
    
    // MARK: - Color Swatches
    
    private var colorSwatchesRow: some View {
        HStack(spacing: 6) {
            // Primary Color
            colorSwatch(
                color: palette.primaryColor,
                label: "Primary",
                size: 32
            )
            
            // Secondary Color
            colorSwatch(
                color: palette.secondaryColor,
                label: "Secondary",
                size: 28
            )
            
            // Accent Color
            colorSwatch(
                color: palette.accentColor,
                label: "Accent",
                size: 28
            )
            
            Spacer()
            
            // Wall Color Preview
            wallColorPreview
            
            // Furniture Accent Preview
            furnitureAccentPreview
        }
    }
    
    private func colorSwatch(color: Color, label: String, size: CGFloat) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .onTapGesture {
            showColorDetails(for: color, label: label)
        }
    }
    
    private var wallColorPreview: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            palette.wallColor,
                            palette.wallColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text("Wall")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private var furnitureAccentPreview: some View {
        VStack(spacing: 4) {
            ZStack {
                // Base furniture shape
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 20, height: 16)
                
                // Accent overlay
                RoundedRectangle(cornerRadius: 2)
                    .fill(palette.furnitureAccentColor)
                    .frame(width: 16, height: 4)
                    .offset(y: -2)
            }
            
            Text("Accent")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Actions
    
    private func selectPalette() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Animate selection
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isAnimating = true
        }
        
        // Apply palette
        viewModel.selectPalette(palette)
        
        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }
    
    private func showColorDetails(for color: Color, label: String) {
        // Future enhancement: Show color picker or details
        showingColorDetails = true
    }
}

// MARK: - Color Palette Collection View

struct ColorPaletteCollection: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Collection Header
            collectionHeader
            
            // Palette Rows
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availablePalettes) { palette in
                        ColorPaletteRow(
                            viewModel: viewModel,
                            palette: palette,
                            isSelected: viewModel.selectedPalette?.id == palette.id
                        )
                        .frame(width: 200)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var collectionHeader: some View {
        HStack {
            Image(systemName: "paintpalette.fill")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Color Palettes")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            // Palette count
            Text("\(viewModel.availablePalettes.count)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Palette Vision Extensions

extension PaletteVision {
    var icon: String {
        switch self {
        case .neutrals:
            return "circle.grid.2x2"
        case .industrial:
            return "building.2"
        case .cozy:
            return "house.fill"
        }
    }
}

// MARK: - Color Transition Effect

struct ColorTransitionEffect: View {
    let fromColor: Color
    let toColor: Color
    let progress: Double
    
    var body: some View {
        ZStack {
            fromColor
                .opacity(1.0 - progress)
            
            toColor
                .opacity(progress)
        }
        .animation(.easeInOut(duration: 0.8), value: progress)
    }
}

// MARK: - Instant Recolor Animation

struct InstantRecolorAnimation: ViewModifier {
    let isRecoloring: Bool
    let targetColor: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(targetColor)
                    .opacity(isRecoloring ? 0.3 : 0.0)
                    .animation(.easeInOut(duration: 0.2), value: isRecoloring)
            )
    }
}

extension View {
    func instantRecolor(isRecoloring: Bool, targetColor: Color) -> some View {
        modifier(InstantRecolorAnimation(isRecoloring: isRecoloring, targetColor: targetColor))
    }
}