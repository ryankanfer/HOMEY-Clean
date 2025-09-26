import SwiftUI
import Foundation

public struct DocumentsDashboardView: View {
    
    // MARK: - Data Model
    
    struct DocCategory: Identifiable, Hashable {
        let id: UUID
        let name: String
        let icon: String
        let color: Color
        let progress: Double // 0...1
        let completed: Int
        let total: Int
    }
    
    // MARK: - State
    
    @State private var categories: [DocCategory] = [
        DocCategory(
            id: UUID(),
            name: "Financial Records",
            icon: "banknote",
            color: Color(hex: "A2D2FF"),
            progress: 0.73,
            completed: 11,
            total: 15
        ),
        DocCategory(
            id: UUID(),
            name: "Identity & Legal",
            icon: "person.crop.rectangle",
            color: Color(hex: "FFC8DD"),
            progress: 0.93,
            completed: 14,
            total: 15
        ),
        DocCategory(
            id: UUID(),
            name: "Property History",
            icon: "house.fill",
            color: Color(hex: "B5EAEA"),
            progress: 0.80,
            completed: 4,
            total: 5
        ),
        DocCategory(
            id: UUID(),
            name: "Employment",
            icon: "briefcase.fill",
            color: Color(hex: "FFFCB6"),
            progress: 0.36,
            completed: 4,
            total: 11
        ),
        DocCategory(
            id: UUID(),
            name: "Insurance",
            icon: "shield.fill",
            color: Color(hex: "FFAEBC"),
            progress: 0.44,
            completed: 4,
            total: 9
        )
    ]
    
    // MARK: - Filter Chips
    
    enum FilterChip: String, CaseIterable, Identifiable {
        case actionNeeded = "Action Needed"
        case approved = "Approved"
        case pending = "Pending"
        
        var id: String { rawValue }
    }
    
    @State private var selectedFilters: Set<FilterChip> = []
    
    // MARK: - Actions
    
    private let autoScanAction: () -> Void
    private let secureShareAction: () -> Void
    
    // MARK: - Init
    
    public init(
        autoScanAction: @escaping () -> Void = {},
        secureShareAction: @escaping () -> Void = {}
    ) {
        self.autoScanAction = autoScanAction
        self.secureShareAction = secureShareAction
    }
    
    // MARK: - Computed Properties
    
    private var overallProgress: Double {
        guard !categories.isEmpty else { return 0 }
        return categories.map(\.progress).reduce(0, +) / Double(categories.count)
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Title & Subtitle
                VStack(spacing: 4) {
                    Text("Documents")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundColor(.primary)
                    Text("Secure • Organized • Accessible")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // Overall Progress Card
                overallProgressCard
                
                // Smart Sorting Chips
                smartSortingSection
                
                // Categories List
                categoriesSection
                
                // Quick Actions
                quickActionsSection
                
                Spacer(minLength: 32)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.clear)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var overallProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Overall Progress")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    Text("\(Int(overallProgress * 100))% Completed")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            ProgressBar(progress: overallProgress)
                .frame(height: 10)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var smartSortingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Smart Sorting")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ForEach(FilterChip.allCases) { chip in
                    Button {
                        toggleFilter(chip)
                    } label: {
                        Text(chip.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if selectedFilters.contains(chip) {
                                        Color.accentColor.opacity(0.2)
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .foregroundColor(selectedFilters.contains(chip) ? Color.accentColor : Color.primary.opacity(0.75))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedFilters.contains(chip) ? Color.accentColor.opacity(0.6) : Color.primary.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selectedFilters.contains(chip) ? .isSelected : [])
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(categories, id: \.id) { category in
                categoryRow(category)
            }
        }
    }
    
    @ViewBuilder
    private func categoryRow(_ category: DocCategory) -> some View {
        HStack(spacing: 16) {
            // Circular progress ring with icon
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.12), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(category.progress))
                    .stroke(category.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: category.progress)
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(category.color)
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                Text("\(Int(category.progress * 100))% • \(category.completed)/\(category.total) docs")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    category.color.opacity(0.15),
                    category.color.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                Button {
                    autoScanAction()
                } label: {
                    quickActionButtonLabel(
                        title: "Auto‑scan / Import",
                        systemImage: "doc.text.viewfinder"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("autoScanButton")
                
                Button {
                    secureShareAction()
                } label: {
                    quickActionButtonLabel(
                        title: "Secure Share with Agent",
                        systemImage: "person.crop.circle.badge.checkmark"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("secureShareButton")
            }
        }
    }
    
    @ViewBuilder
    private func quickActionButtonLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.accentColor)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentColor.opacity(0.15))
                )
            
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
    
    // MARK: - Helpers
    
    private func toggleFilter(_ chip: FilterChip) {
        if selectedFilters.contains(chip) {
            selectedFilters.remove(chip)
        } else {
            selectedFilters.insert(chip)
        }
    }
}

// MARK: - ProgressBar Subview

private struct ProgressBar: View {
    var progress: Double // 0...1
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.primary.opacity(0.12))
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.accentColor)
                    .frame(width: CGFloat(proxy.size.width) * CGFloat(progress))
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .accessibilityValue(Text("\(Int(progress * 100)) percent"))
        .accessibilityLabel(Text("Progress"))
    }
}