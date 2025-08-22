import SwiftUI

struct ScoutRootView: View {
    @State private var viewModel = ScoutViewModel()
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @StateObject private var accessibilityService = AccessibilityService.shared

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Main content layers
                scoutHeroLayer
                    .accessibilityLabel("Property exploration lens")
                    .accessibilityHint("Drag to explore properties, pinch to resize lens")

                VStack(spacing: 0) {
                    headerLayer
                    Spacer()
                    bottomTrayLayer
                }

                // Right rail (shortlist)
                HStack {
                    Spacer()
                    rightRailLayer
                }

                // Overlay views
                if viewModel.isShowingPeekCard {
                    peekCardLayer
                }

                if viewModel.isShowingFullSheet {
                    fullSheetLayer
                }

                // Progression event overlay
                if let currentEvent = viewModel.currentProgressionEvent {
                    ProgressionEventView(
                        event: currentEvent
                    ) {
                        viewModel.dismissProgressionEvent()
                    }
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(10)
                }
            }
            .sheet(isPresented: $viewModel.isShowingHoloMap) {
                holoMapLayer
            }
            .onAppear {
                setupAccessibilityRotors()
            }
        }
    }

    // MARK: - Content Layers

    private var scoutHeroLayer: some View {
        ScoutHeroView(viewModel: viewModel)
            .ignoresSafeArea()
    }

    private var headerLayer: some View {
        VStack(spacing: 12) {
            HStack {
                // Left side: Neighborhood badge and time toggle
                HStack(spacing: 12) {
                    neighborhoodBadge
                    timeOfDayToggle
                }

                Spacer()

                // Center: Title
                Text("Scout's Live Lens")
                    .font(.title.weight(.bold))

                Spacer()

                // Right side: Map toggle and status indicator
                HStack(spacing: 12) {
                    mapToggleButton
                    statusIndicator
                }
            }
            .padding(.horizontal)

            searchBar
                .padding(.horizontal)

            filterChips
                .padding(.horizontal)
        }
        .padding(.top)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }

    private var bottomTrayLayer: some View {
        ScoutLensTray(viewModel: viewModel)
            .background(.ultraThinMaterial)
    }

    private var rightRailLayer: some View {
        ScoutRightRail(viewModel: viewModel)
            .frame(width: 320)
            .background(.ultraThinMaterial)
    }

    private var peekCardLayer: some View {
        PeekCard(viewModel: viewModel)
            .transition(.move(edge: .bottom))
    }

    private var fullSheetLayer: some View {
        FullSheetView(viewModel: viewModel)
            .transition(.move(edge: .bottom))
    }

    private var holoMapLayer: some View {
        HoloMapView(viewModel: viewModel)
    }

    // MARK: - Supporting Views

    private var neighborhoodBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .font(.caption)
                .foregroundColor(.white)

            Text("Flatiron") // TODO: Make dynamic based on current location
                .font(.caption.weight(.medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.black.opacity(0.6))
        )
    }

    private var timeOfDayToggle: some View {
        Button(action: {
            accessibilityService.playSelectionHaptic()
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.toggleTimeOfDay()
            }
            accessibilityService.announce("Switched to \(viewModel.timeOfDay.displayName.lowercased()) view")
        }) {
            HStack(spacing: 4) {
                Image(systemName: viewModel.timeOfDay == .day ? "sun.max.fill" : "moon.fill")
                    .font(.caption)
                    .foregroundColor(.white)

                Text(viewModel.timeOfDay.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.black.opacity(0.6))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(viewModel.timeOfDay.displayName) view")
        .accessibilityHint("Switch time of day lighting")
    }

    private var mapToggleButton: some View {
        Button(action: {
            accessibilityService.playHaptic(.medium)
            viewModel.toggleHoloMap()
        }) {
            Image(systemName: "map.fill")
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(
                    Circle()
                        .fill(.black.opacity(0.6))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open map view")
        .accessibilityHint("Shows properties on a holographic map")
    }

    private var statusIndicator: some View {
        Circle()
            .fill(.green) // TODO: Update based on GPS status
            .frame(width: 8, height: 8)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search neighborhoods, addresses...", text: .constant(""))
                .textFieldStyle(.plain)

            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.activeLenses) { lens in
                    filterChip(for: lens)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func filterChip(for lens: Lens) -> some View {
        HStack {
            Image(systemName: lens.icon)
            Text(lens.name)
            Button(action: { viewModel.toggleLens(lens) }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Accessibility

extension ScoutRootView {
    private func setupAccessibilityRotors() {
        // Setup accessibility rotors for navigation
        // This would be implemented with proper rotor configuration
    }
}

// MARK: - Preview

#Preview {
    ScoutRootView()
}
