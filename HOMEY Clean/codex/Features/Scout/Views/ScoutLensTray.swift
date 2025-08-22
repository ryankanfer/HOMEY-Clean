import SwiftUI

struct ScoutLensTray: View {
    @Bindable var viewModel: ScoutViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Price slider and bedroom/bathroom filters
            mainFilters

            // Lens size control
            lensSizeControl
                .padding(.horizontal)

            // Scrollable lens selector
            lensSelector
                .padding(.horizontal)
        }
        .padding(.top, 16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .overlay(
                    Image("glass_chip")
                        .resizable()
                        .opacity(0.3)
                )
        )
    }

    private var mainFilters: some View {
        VStack(spacing: 12) {
            // Price range slider
            VStack(alignment: .leading) {
                Text("Price Range")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                PriceSlider(range: $viewModel.priceRange)
            }
            .padding(.horizontal)

            // Bed & Bath filters
            HStack(spacing: 16) {
                // Bedrooms
                VStack(alignment: .leading) {
                    Text("Beds")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        ForEach(["Any", "1+", "2+", "3+", "4+"], id: \.self) { count in
                            Button(action: { viewModel.setBedroomFilter(count) }) {
                                Text(count)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        isBedroomSelected(count) ?
                                            Color.accentColor : Color.secondary.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        isBedroomSelected(count) ?
                                            .white : .primary
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                }

                // Bathrooms
                VStack(alignment: .leading) {
                    Text("Baths")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        ForEach(["Any", "1+", "2+", "3+"], id: \.self) { count in
                            Button(action: { viewModel.setBathroomFilter(count) }) {
                                Text(count)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        isBathroomSelected(count) ?
                                            Color.accentColor : Color.secondary.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        isBathroomSelected(count) ?
                                            .white : .primary
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var lensSizeControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lens Size")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(LensSize.allCases, id: \.self) { size in
                    Button(action: { viewModel.setLensSize(size) }) {
                        Text(size.rawValue)
                            .font(.headline)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(viewModel.lensSize == size ?
                                        Color.accentColor : Color.secondary.opacity(0.2)
                                    )
                            )
                            .foregroundColor(viewModel.lensSize == size ?
                                .white : .primary
                            )
                    }
                }

                Spacer()

                Text("Pinch to resize")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var lensSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LensType.allCases, id: \.self) { lensType in
                    Button(action: { viewModel.toggleLens(Lens(type: lensType)) }) {
                        VStack(spacing: 4) {
                            Image(systemName: lensType.icon)
                                .font(.title2)

                            Text(lensType.displayName)
                                .font(.caption)
                        }
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(viewModel.activeLenses.contains { $0.type == lensType } ?
                                    lensType.color : Color.secondary.opacity(0.2)
                                )
                        )
                        .foregroundColor(viewModel.activeLenses.contains { $0.type == lensType } ?
                            .white : .primary
                        )
                    }
                }

                // Reset button
                Button(action: viewModel.resetFilters) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)

                        Text("Reset")
                            .font(.caption)
                    }
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.secondary.opacity(0.2))
                    )
                    .foregroundColor(.primary)
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
