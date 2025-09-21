import SwiftUI

struct ScoutLensTray: View {
    @Bindable var viewModel: ScoutViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Price slider and bedroom/bathroom filters
            mainFilters

            // Lens size control
            lensSizeControl
                .padding(.horizontal, 20)

            // Scrollable lens selector
            lensSelector
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(
            ZStack {
                // Base glass material
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                
                // Glass chip texture overlay
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        Image("glass_chip")
                            .resizable(resizingMode: .tile)
                            .opacity(0.25)
                            .blendMode(.overlay)
                    )
                
                // Futuristic border glow
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .cyan.opacity(0.6),
                                .blue.opacity(0.3),
                                .cyan.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .opacity(0.8)
                
                // Inner highlight for depth
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.4),
                                .clear,
                                .white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(1)
            }
        )
        .shadow(color: .cyan.opacity(0.2), radius: 10, x: 0, y: 5)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }

    private var mainFilters: some View {
        VStack(spacing: 12) {
            // Price range slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Price Range")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))

                PriceSlider(range: $viewModel.priceRange)
            }
            .padding(.horizontal, 20)

            // Bed & Bath filters
            HStack(spacing: 16) {
                // Bedrooms
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beds")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))

                    HStack {
                        ForEach(["Any", "1+", "2+", "3+", "4+"], id: \.self) { count in
                            Button(action: { viewModel.setBedroomFilter(count) }) {
                                Text(count)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isBedroomSelected(count) ?
                                                LinearGradient(
                                                    colors: [.cyan.opacity(0.8), .blue.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(
                                        isBedroomSelected(count) ?
                                            .white : .white.opacity(0.8)
                                    )
                                    .shadow(
                                        color: isBedroomSelected(count) ? .cyan.opacity(0.3) : .clear,
                                        radius: 4, x: 0, y: 2
                                    )
                            }
                        }
                    }
                }

                // Bathrooms
                VStack(alignment: .leading, spacing: 8) {
                    Text("Baths")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))

                    HStack {
                        ForEach(["Any", "1+", "2+", "3+"], id: \.self) { count in
                            Button(action: { viewModel.setBathroomFilter(count) }) {
                                Text(count)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isBathroomSelected(count) ?
                                                LinearGradient(
                                                    colors: [.cyan.opacity(0.8), .blue.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(
                                        isBathroomSelected(count) ?
                                            .white : .white.opacity(0.8)
                                    )
                                    .shadow(
                                        color: isBathroomSelected(count) ? .cyan.opacity(0.3) : .clear,
                                        radius: 4, x: 0, y: 2
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var lensSizeControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lens Size")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 12) {
                ForEach(LensSize.allCases, id: \.self) { size in
                    Button(action: { viewModel.setLensSize(size) }) {
                        Text(size.rawValue)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .frame(width: 48, height: 48)
                            .background(
                                ZStack {
                                    // Base circle with glass effect
                                    Circle()
                                        .fill(
                                            viewModel.lensSize == size ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .cyan.opacity(0.8),
                                                        .blue.opacity(0.6)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.2),
                                                        Color.gray.opacity(0.1)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                        )
                                    
                                    // Lens aperture ring
                                    Circle()
                                        .stroke(
                                            viewModel.lensSize == size ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.9),
                                                        .cyan.opacity(0.5)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.3),
                                                        .gray.opacity(0.2)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .foregroundColor(viewModel.lensSize == size ?
                                .white : .primary
                            )
                            .shadow(
                                color: viewModel.lensSize == size ?
                                    .cyan.opacity(0.4) : .clear,
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                    }
                }

                Spacer()

                Text("Pinch to resize")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private var lensSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LensType.allCases, id: \.self) { lensType in
                    Button(action: { viewModel.toggleLens(Lens(type: lensType)) }) {
                        VStack(spacing: 6) {
                            Image(systemName: lensType.icon)
                                .font(.system(size: 18, weight: .semibold))

                            Text(lensType.displayName)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                        }
                        .frame(width: 64, height: 64)
                        .background(
                            ZStack {
                                // Base circle with glass effect
                                Circle()
                                    .fill(
                                        viewModel.activeLenses.contains { $0.type == lensType } ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    lensType.color.opacity(0.8),
                                                    lensType.color.opacity(0.6)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.2),
                                                    Color.gray.opacity(0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                    )
                                
                                // Lens ring effect
                                Circle()
                                    .stroke(
                                        viewModel.activeLenses.contains { $0.type == lensType } ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.8),
                                                    lensType.color.opacity(0.6),
                                                    .white.opacity(0.4)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.3),
                                                    .gray.opacity(0.2)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                        lineWidth: 2
                                    )
                            }
                        )
                        .foregroundColor(viewModel.activeLenses.contains { $0.type == lensType } ?
                            .white : .primary
                        )
                        .shadow(
                            color: viewModel.activeLenses.contains { $0.type == lensType } ?
                                lensType.color.opacity(0.4) : .clear,
                            radius: 8,
                            x: 0,
                            y: 2
                        )
                    }
                }

                // Reset button
                Button(action: viewModel.resetFilters) {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Reset")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Helper Methods

extension ScoutLensTray {
    private func isBedroomSelected(_ filter: String) -> Bool {
        switch filter {
        case "Any":
            return viewModel.selectedBedrooms == 0
        case "1+":
            return viewModel.selectedBedrooms == 1
        case "2+":
            return viewModel.selectedBedrooms == 2
        case "3+":
            return viewModel.selectedBedrooms == 3
        case "4+":
            return viewModel.selectedBedrooms == 4
        default:
            return false
        }
    }

    private func isBathroomSelected(_ filter: String) -> Bool {
        switch filter {
        case "Any":
            return viewModel.selectedBathrooms == 0
        case "1+":
            return viewModel.selectedBathrooms == 1
        case "2+":
            return viewModel.selectedBathrooms == 2
        case "3+":
            return viewModel.selectedBathrooms == 3
        default:
            return false
        }
    }
}

// MARK: - Accessibility

extension ScoutLensTray {
    private func configureAccessibility() {
        // TODO: Implement accessibility configuration
    }
}

// MARK: - Preview

#Preview {
    ScoutLensTray(viewModel: ScoutViewModel())
        .padding()
}
