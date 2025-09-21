//
//  AppearanceSettingsSection.swift
//  HOMEY Clean
//
//  Appearance settings section with theme selection and accessibility options
//

import SwiftUI

struct AppearanceSettingsSection: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var textSize: Double = 1.0
    @State private var highContrast = false
    @State private var hapticsEnabled = true
    @State private var animationsEnabled = true
    @State private var reduceMotion = false
    @State private var showingThemeSelection = false
    
    var body: some View {
        Section(header: Text("Appearance")) {
            // Theme Selection
            Button(action: { showingThemeSelection = true }) {
                HStack {
                    Image(systemName: "paintbrush")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Theme")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text(themeManager.currentMode.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Text Size
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "textformat.size")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Text Size")
                        .font(.body)
                    
                    Spacer()
                    
                    Text("\(Int(textSize * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $textSize, in: 0.8...1.5, step: 0.1)
                    .accentColor(.blue)
            }
            
            // High Contrast
            HStack {
                Image(systemName: "circle.lefthalf.filled")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("High Contrast")
                        .font(.body)
                    Text("Increase contrast for better visibility")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $highContrast)
            }
            
            // Haptics
            HStack {
                Image(systemName: "hand.tap")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Haptic Feedback")
                        .font(.body)
                    Text("Feel vibrations for interactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $hapticsEnabled)
            }
            
            // Animations
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.pink)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Animations")
                        .font(.body)
                    Text("Enable smooth transitions and effects")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $animationsEnabled)
            }
            
            // Reduce Motion
            HStack {
                Image(systemName: "figure.walk.motion")
                    .foregroundColor(.red)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reduce Motion")
                        .font(.body)
                    Text("Minimize movement for accessibility")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $reduceMotion)
            }
        }
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView()
        }
    }
}

// MARK: - Theme Selection View
struct ThemeSelectionView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.displayName)
                                    .font(.body)
                                
                                Text(modeDescription(for: mode))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if themeManager.currentMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.setTheme(mode)
                            }
                        }
                    }
                } header: {
                    Text("Theme Selection")
                } footer: {
                    Text("Day Mode provides high contrast colors for improved accessibility and readability in bright environments.")
                }
                
                if themeManager.isDayMode {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "accessibility")
                                    .foregroundColor(.blue)
                                Text("Accessibility Features")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                accessibilityFeature(
                                    icon: "eye.fill",
                                    title: "High Contrast",
                                    description: "21:1 contrast ratio for optimal readability"
                                )
                                
                                accessibilityFeature(
                                    icon: "textformat.size",
                                    title: "Enhanced Text",
                                    description: "Improved text clarity and definition"
                                )
                                
                                accessibilityFeature(
                                    icon: "sun.max.fill",
                                    title: "Bright Environment",
                                    description: "Optimized for outdoor and bright indoor use"
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Day Mode Benefits")
                    }
                }
            }
            .navigationTitle("Theme Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func modeDescription(for mode: ThemeMode) -> String {
        switch mode {
        case .auto:
            return "Follows system appearance"
        case .light:
            return "Always use light appearance"
        case .dark:
            return "Always use dark appearance"
        case .dayMode:
            return "High contrast light mode for accessibility"
        }
    }
    
    private func accessibilityFeature(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct AppearanceSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AppearanceSettingsSection()
        }
        .listStyle(GroupedListStyle())
        .environmentObject(ThemeManager.shared)
    }
}