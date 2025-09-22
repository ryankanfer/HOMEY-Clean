import SwiftUI

struct HomepageCustomizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedSections: [HomepageSection] = []
    @State private var selectedTheme: ThemeMode = .auto
    
    private let availableSections = HomepageSection.allCases
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Customize Your Homepage")
                            .font(.title2.bold())
                        
                        Text("Select up to 4 sections to display on your homepage")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Section Selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Homepage Sections")
                                .font(.headline.bold())
                            Spacer()
                            NavigationLink {
                                ReorderSelectedSectionsView(selectedSections: $selectedSections)
                            } label: {
                                Label("Reorder", systemImage: "arrow.up.arrow.down")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(availableSections, id: \.self) { section in
                                SectionSelectionCard(
                                    section: section,
                                    isSelected: selectedSections.contains(section),
                                    canSelect: selectedSections.count < 4 || selectedSections.contains(section)
                                ) {
                                    toggleSection(section)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Theme Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Theme Preference")
                            .font(.headline.bold())
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(ThemeMode.allCases, id: \.self) { theme in
                                ThemeSelectionRow(
                                    theme: theme,
                                    isSelected: selectedTheme == theme
                                ) {
                                    selectedTheme = theme
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .navigationTitle("Homepage Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCustomization()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedSections.isEmpty)
                }
            }
        }
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private func loadCurrentSettings() {
        guard let profile = userProfileManager.currentProfile else { return }
        let customization = profile.preferences.homepageCustomization
        selectedSections = customization.selectedSections
        
        // Convert ThemePreference to ThemeMode for backward compatibility
        switch customization.themePreference {
        case .light:
            selectedTheme = .light
        case .dark:
            selectedTheme = .dark
        case .system:
            selectedTheme = .auto
        }
    }
    
    private func toggleSection(_ section: HomepageSection) {
        if selectedSections.contains(section) {
            selectedSections.removeAll { $0 == section }
        } else if selectedSections.count < 4 {
            selectedSections.append(section)
        }
    }
    
    private func saveCustomization() {
        guard var profile = userProfileManager.currentProfile else { return }
        
        // Convert ThemeMode back to ThemePreference for storage
        let themePreference: ThemePreference
        switch selectedTheme {
        case .light:
            themePreference = .light
        case .dark:
            themePreference = .dark
        case .auto:
            themePreference = .system
        case .dayMode:
            themePreference = .light // Map dayMode to light for storage
        }
        
        profile.preferences.homepageCustomization = HomepageCustomization(
            selectedSections: selectedSections,
            themePreference: themePreference
        )
        
        // Apply theme change immediately
        themeManager.setTheme(selectedTheme)
        
        Task {
            await userProfileManager.updateProfile(profile)
        }
    }
}


struct SectionInfo {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct ThemeInfo {
    let title: String
    let subtitle: String
    let icon: String
}

struct SectionSelectionCard: View {
    let section: HomepageSection
    let isSelected: Bool
    let canSelect: Bool
    let action: () -> Void
    
    private var sectionInfo: SectionInfo {
        switch section {
        case .discover:
            return SectionInfo(title: "Discover", subtitle: "Find properties", icon: "magnifyingglass", color: .blue)
        case .vault:
            return SectionInfo(title: "Vault", subtitle: "Your documents", icon: "folder.fill", color: .purple)
        case .education:
            return SectionInfo(title: "Education", subtitle: "Learn & grow", icon: "book.fill", color: .green)
        case .directory:
            return SectionInfo(title: "Directory", subtitle: "Find professionals", icon: "person.2.fill", color: .orange)
        case .insights:
            return SectionInfo(title: "Insights", subtitle: "Market data", icon: "chart.bar.fill", color: .red)
        case .vision:
            return SectionInfo(title: "Vision", subtitle: "Visualize spaces", icon: "paintbrush.fill", color: .pink)
        case .matchmaker:
            return SectionInfo(title: "Matchmaker", subtitle: "Perfect matches", icon: "heart.fill", color: .red)
        case .documents:
            return SectionInfo(title: "Documents", subtitle: "File management", icon: "doc.fill", color: .blue)
        case .scout:
            return SectionInfo(title: "Scout", subtitle: "Explore neighborhoods", icon: "location.fill", color: .teal)
        case .profile:
            return SectionInfo(title: "Profile", subtitle: "Manage your account", icon: "person.circle.fill", color: .gray)
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(sectionInfo.color.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: sectionInfo.icon)
                            .font(.caption)
                            .foregroundColor(sectionInfo.color)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(sectionInfo.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    Text(sectionInfo.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                SectionThumbnailView(section: section)
                    .frame(height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                    )
            }
            .padding(12)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
            .opacity(canSelect ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!canSelect)
    }
}

struct ThemeSelectionRow: View {
    let theme: ThemeMode
    let isSelected: Bool
    let action: () -> Void
    
    private var themeInfo: ThemeInfo {
        switch theme {
        case .light:
            return ThemeInfo(title: "Light", subtitle: "Always use light theme", icon: "sun.max.fill")
        case .dark:
            return ThemeInfo(title: "Dark", subtitle: "Always use dark theme", icon: "moon.fill")
        case .auto:
            return ThemeInfo(title: "Auto", subtitle: "Follow device settings", icon: "gear")
        case .dayMode:
            return ThemeInfo(title: "Day Mode", subtitle: "High contrast accessibility mode", icon: "accessibility")
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: themeInfo.icon)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(themeInfo.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    Text(themeInfo.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ReorderSelectedSectionsView: View {
    @Binding var selectedSections: [HomepageSection]
    @State private var editMode: EditMode = .active
    
    var body: some View {
        List {
            ForEach(selectedSections, id: \.self) { section in
                HStack(spacing: 12) {
                    Image(systemName: section.icon)
                        .foregroundStyle(section.color)
                    Text(section.rawValue)
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.secondary)
                }
            }
            .onMove { indices, newOffset in
                selectedSections.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .navigationTitle("Reorder Sections")
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
}

struct SectionThumbnailView: View {
    let section: HomepageSection
    
    var body: some View {
        switch section {
        case .discover:
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.2))
                RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.15))
                RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.1))
            }
        case .vault, .documents:
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 4).fill(Color.purple.opacity(0.15))
                    .frame(width: 18)
                RoundedRectangle(cornerRadius: 4).fill(Color.purple.opacity(0.25))
                RoundedRectangle(cornerRadius: 4).fill(Color.purple.opacity(0.15))
            }
        case .education:
            VStack(alignment: .leading, spacing: 4) {
                Capsule().fill(Color.green.opacity(0.3)).frame(height: 6)
                Capsule().fill(Color.green.opacity(0.2)).frame(height: 6)
                Capsule().fill(Color.green.opacity(0.15)).frame(height: 6)
            }
        case .directory:
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    Circle().fill(Color.orange.opacity(0.25))
                }
            }
        case .insights:
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width
                    let h = geo.size.height
                    p.move(to: CGPoint(x: 0, y: h * 0.8))
                    p.addLine(to: CGPoint(x: w * 0.25, y: h * 0.6))
                    p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.7))
                    p.addLine(to: CGPoint(x: w * 0.75, y: h * 0.4))
                    p.addLine(to: CGPoint(x: w, y: h * 0.5))
                }
                .stroke(Color.indigo.opacity(0.8), lineWidth: 2)
            }
            .background(Color.indigo.opacity(0.08))
        case .vision:
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.pink.opacity(0.12))
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6).fill(Color.pink.opacity(0.25))
                    RoundedRectangle(cornerRadius: 6).fill(Color.pink.opacity(0.15))
                }
                .padding(.horizontal, 6)
            }
        case .matchmaker:
            HStack(spacing: 8) {
                Capsule().fill(Color.red.opacity(0.25)).frame(width: 40)
                Capsule().fill(Color.red.opacity(0.15))
            }
        case .scout:
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.teal.opacity(0.12))
                HStack(spacing: 6) {
                    Circle().fill(Color.teal.opacity(0.25)).frame(width: 8, height: 8)
                    Circle().fill(Color.teal.opacity(0.2)).frame(width: 8, height: 8)
                    Circle().fill(Color.teal.opacity(0.15)).frame(width: 8, height: 8)
                }
            }
        case .profile:
            HStack(spacing: 8) {
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 20, height: 20)
                VStack(alignment: .leading, spacing: 4) {
                    Capsule().fill(Color.gray.opacity(0.3)).frame(height: 6)
                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
                }
            }
        }
    }
}

#Preview {
    HomepageCustomizationSheet()
        .environmentObject(UserProfileManager.shared)
        .environmentObject(ThemeManager.shared)
}