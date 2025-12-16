import SwiftUI

struct ScoutFilterTray: View {
    @Binding var selectedFilters: Set<ScoutFilter>
    let onFilterChange: (Set<ScoutFilter>) -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main filter lenses row
            HStack(spacing: 16) {
                ForEach(ScoutFilter.primaryFilters, id: \.self) { filter in
                    FilterLensButton(
                        filter: filter,
                        isSelected: selectedFilters.contains(filter),
                        onTap: {
                            toggleFilter(filter)
                        }
                    )
                }
                
                Spacer()
                
                // Expand/collapse button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .accessibilityLabel(isExpanded ? "Collapse filters" : "Expand filters")
            }
            
            // Expanded secondary filters
            if isExpanded {
                HStack(spacing: 12) {
                    ForEach(ScoutFilter.secondaryFilters, id: \.self) { filter in
                        FilterLensButton(
                            filter: filter,
                            isSelected: selectedFilters.contains(filter),
                            onTap: {
                                toggleFilter(filter)
                            }
                        )
                    }
                    
                    Spacer()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Active filters summary
            if !selectedFilters.isEmpty {
                ActiveFiltersSummary(
                    activeFilters: selectedFilters,
                    onClearAll: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedFilters.removeAll()
                            onFilterChange(selectedFilters)
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Base glass material
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.gray.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass chip texture overlay
                Image("glass_chip")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.15)
                    .blendMode(.overlay)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Periscope border glow
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .cyan.opacity(0.6),
                                .blue.opacity(0.3),
                                .cyan.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                
                // Inner highlight for depth
                RoundedRectangle(cornerRadius: 19)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.3),
                                .clear,
                                .clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                    .padding(1)
            }
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .shadow(color: .cyan.opacity(0.2), radius: 12, x: 0, y: 0)
    }
    
    private func toggleFilter(_ filter: ScoutFilter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedFilters.contains(filter) {
                selectedFilters.remove(filter)
            } else {
                selectedFilters.insert(filter)
            }
            onFilterChange(selectedFilters)
        }
    }
}

// MARK: - Filter Lens Button
struct FilterLensButton: View {
    let filter: ScoutFilter
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Lens icon
                ZStack {
                    // Base lens housing
                    Circle()
                        .fill(
                            isSelected ? 
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.9), Color.blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.gray.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 44, height: 44)
                    
                    // Glass chip texture overlay
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Image("glass_chip")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.2)
                                .blendMode(.overlay)
                        )
                        .clipShape(Circle())
                        .frame(width: 44, height: 44)
                    
                    // Lens aperture ring
                    Circle()
                        .stroke(
                            isSelected ? 
                                LinearGradient(
                                    colors: [.white.opacity(0.8), .cyan.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: isSelected ? 2 : 1.5
                        )
                        .frame(width: 44, height: 44)
                    
                    // Inner lens reflection
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            ),
                            lineWidth: 1
                        )
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: filter.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: isSelected ? .cyan.opacity(0.4) : .black.opacity(0.2),
                    radius: isSelected ? 8 : 4,
                    x: 0,
                    y: isSelected ? 4 : 2
                )
                
                // Filter label
                Text(filter.displayName)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel(filter.displayName)
        .accessibilityHint(isSelected ? "Remove filter" : "Apply filter")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Active Filters Summary
struct ActiveFiltersSummary: View {
    let activeFilters: Set<ScoutFilter>
    let onClearAll: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(activeFilters.count) filter\(activeFilters.count == 1 ? "" : "s") active")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Button("Clear All", action: onClearAll)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
        )
    }
}

#Preview {
    ScoutFilterTray(
        selectedFilters: .constant([.price, .beds]),
        onFilterChange: { _ in }
    )
    .padding()
    .background(Color.black)
}