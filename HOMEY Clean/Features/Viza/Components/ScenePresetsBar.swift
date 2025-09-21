//
//  ScenePresetsBar.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI

struct ScenePresetsBar: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    @State private var isAnimating = false
    @State private var selectedPresetScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Presets Header
            presetsHeader
            
            // Preset Buttons
            presetButtonsRow
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Presets Header
    
    private var presetsHeader: some View {
        HStack {
            Image(systemName: "wand.and.stars")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Scene Presets")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            // Active preset indicator
            if let selectedPreset = viewModel.selectedPreset {
                Text(selectedPreset.name)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(selectedPreset.vision.accentColor.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(selectedPreset.vision.accentColor.opacity(0.6), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    // MARK: - Preset Buttons Row
    
    private var presetButtonsRow: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.availablePresets) { preset in
                presetButton(for: preset)
            }
        }
    }
    
    private func presetButton(for preset: ScenePreset) -> some View {
        let isSelected = viewModel.selectedPreset?.id == preset.id
        
        return Button {
            selectPreset(preset)
        } label: {
            VStack(spacing: 8) {
                // Preset Icon with Vision Indicator
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            isSelected ?
                            preset.vision.accentColor.opacity(0.3) :
                            Color.white.opacity(0.1)
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ?
                                    preset.vision.accentColor :
                                    Color.white.opacity(0.3),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                    
                    // Vision icon
                    Image(systemName: preset.vision.icon)
                        .font(.title2)
                        .foregroundColor(
                            isSelected ?
                            preset.vision.accentColor :
                            .white.opacity(0.7)
                        )
                    
                    // Selection indicator
                    if isSelected {
                        Circle()
                            .fill(preset.vision.accentColor)
                            .frame(width: 8, height: 8)
                            .offset(x: 18, y: -18)
                            .scaleEffect(selectedPresetScale)
                    }
                }
                
                // Preset Name
                Text(preset.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(
                        isSelected ?
                        preset.vision.accentColor :
                        .white.opacity(0.8)
                    )
                
                // Vision Description
                Text(preset.vision.description)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80, height: 90)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Actions
    
    private func selectPreset(_ preset: ScenePreset) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Animate selection
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedPresetScale = 1.2
            isAnimating = true
        }
        
        // Apply preset
        viewModel.applyPreset(preset)
        
        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedPresetScale = 1.0
                isAnimating = false
            }
        }
    }
}

// MARK: - Vision Extensions



// MARK: - Preset Quick Actions

struct PresetQuickActions: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Random preset
            quickActionButton(
                title: "Surprise Me",
                icon: "shuffle",
                action: applyRandomPreset
            )
            
            // Clear preset
            quickActionButton(
                title: "Clear",
                icon: "xmark.circle",
                action: clearPreset
            )
            
            // Save custom preset
            quickActionButton(
                title: "Save",
                icon: "bookmark.fill",
                action: saveCustomPreset
            )
        }
    }
    
    private func quickActionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white.opacity(0.7))
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func applyRandomPreset() {
        guard !viewModel.availablePresets.isEmpty else { return }
        let randomPreset = viewModel.availablePresets.randomElement()!
        viewModel.applyPreset(randomPreset)
    }
    
    private func clearPreset() {
        viewModel.selectedPreset = nil
        viewModel.currentDomeEffect = nil
    }
    
    private func saveCustomPreset() {
        // Future enhancement: Save current configuration as custom preset
    }
}

// MARK: - Preset Transition Effect

struct PresetTransitionEffect: View {
    let isTransitioning: Bool
    let fromPreset: ScenePreset?
    let toPreset: ScenePreset?
    
    var body: some View {
        ZStack {
            if isTransitioning {
                // Crossfade overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                toPreset?.vision.accentColor.opacity(0.3) ?? Color.clear,
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isTransitioning ? 0.6 : 0.0)
                    .animation(.easeInOut(duration: 1.0), value: isTransitioning)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ScenePresetsBar(viewModel: VizaVisionViewModel())
        
        PresetQuickActions(viewModel: VizaVisionViewModel())
        
        Spacer()
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}