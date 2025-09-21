import SwiftUI

struct ScoutHeroView: View {
    @Bindable var viewModel: ScoutViewModel
    @StateObject private var accessibilityService = AccessibilityService.shared

    // Gesture State
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var scale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base panorama layer
                Image(viewModel.timeOfDay == .day ? "scout_pano_day" : "scout_pano_dusk")
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFill()
                    .offset(x: dragOffset.width, y: dragOffset.height)
                    .gesture(dragGesture(size: geometry.size))
                    .gesture(magnificationGesture())
                    .gesture(doubleTapGesture(size: geometry.size))

                // Active overlays
                overlayLayers
                    .blendMode(.overlay)

                // Circular mask
                CircularMask(
                    size: viewModel.lensSize,
                    position: viewModel.lensPosition,
                    isDragging: viewModel.isDragging
                )
                .withGlow()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Scout lens")
                .accessibilityHint("Drag to move the lens, pinch to resize, double tap to center")
                .accessibilityValue(
                    "Size: \(viewModel.lensSize.rawValue), Position: \(Int(viewModel.lensPosition.x)), \(Int(viewModel.lensPosition.y))"
                )

                // Time of day and neighborhood indicators
                VStack {
                    HStack {
                        neighborhoodBadge
                        Spacer()
                        timeControls
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    Spacer()
                }
            }
            .onAppear {
                // Center the lens initially
                viewModel.lensPosition = CGPoint(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
            }
        }
    }

    // MARK: - Supporting Views

    private var overlayLayers: some View {
        ZStack {
            ForEach(viewModel.activeLenses.filter { $0.type.hasOverlay }) { lens in
                Image(systemName: lens.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(lens.type.color)
                    .opacity(0.7)
            }

            // Subtle noise grain
            Image("film_grain_bg")
                .resizable()
                .blendMode(.overlay)
                .opacity(0.05)
        }
    }

    private var neighborhoodBadge: some View {
        HStack(spacing: 10) {
            Image("badge_flatiron") // TODO: Make dynamic
                .resizable()
                .frame(width: 28, height: 28)

            Text("Flatiron")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    private var timeControls: some View {
        Button(action: { viewModel.toggleTimeOfDay() }) {
            HStack(spacing: 10) {
                Image(systemName: viewModel.timeOfDay == .day ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.timeOfDay == .day ? .orange : .blue)
                Text(viewModel.timeOfDay.rawValue.capitalized)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Gestures

    private func dragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onChanged { value in
                viewModel.isDragging = true

                // Track lens interaction for analytics
                let currentPosition = CGPoint(
                    x: viewModel.lensPosition.x + value.translation.width,
                    y: viewModel.lensPosition.y + value.translation.height
                )
                viewModel.trackLensInteraction(at: currentPosition, zoomLevel: Double(scale))
            }
            .onEnded { value in
                viewModel.isDragging = false
                // Update lens position with bounds checking
                let newX = viewModel.lensPosition.x + value.translation.width
                let newY = viewModel.lensPosition.y + value.translation.height

                viewModel.lensPosition = CGPoint(
                    x: min(
                        max(newX, viewModel.lensSize.radius),
                        size.width - viewModel.lensSize.radius
                    ),
                    y: min(
                        max(newY, viewModel.lensSize.radius),
                        size.height - viewModel.lensSize.radius
                    )
                )

                accessibilityService.playHaptic(.light)
            }
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .updating($scale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                // Update lens size based on pinch
                let previousSize = viewModel.lensSize
                if value < 0.8 {
                    viewModel.setLensSize(.small)
                } else if value > 1.2 {
                    viewModel.setLensSize(.large)
                } else {
                    viewModel.setLensSize(.medium)
                }

                // Provide haptic feedback when size changes
                if previousSize != viewModel.lensSize {
                    accessibilityService.playSelectionHaptic()
                    accessibilityService.announce("Lens size changed to \(viewModel.lensSize.rawValue)")
                }

                accessibilityService.playHaptic(.medium)
            }
    }

    private func doubleTapGesture(size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                // Center the lens
                viewModel.lensPosition = CGPoint(
                    x: size.width / 2,
                    y: size.height / 2
                )
            }
    }
}

// MARK: - Accessibility

extension ScoutHeroView {
    private func configureAccessibility() {
        // TODO: Implement accessibility configuration
    }
}

// MARK: - Preview

#Preview {
    ScoutHeroView(viewModel: ScoutViewModel())
}
