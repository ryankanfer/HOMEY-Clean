//
//  ThemeSettingsView.swift
//  HOMEY Clean
//
//  Created by Assistant on 8/25/25.
//

import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
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
                                    .themedText()
                                
                                Text(modeDescription(for: mode))
                                    .font(.caption)
                                    .themedMuted()
                            }
                            
                            Spacer()
                            
                            if themeManager.currentMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.dynamicPrimary())
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
                    Text("Appearance")
                } footer: {
                    Text("Day Mode provides high contrast colors for improved accessibility and readability in bright environments.")
                        .themedMuted()
                }
                
                if themeManager.isDayMode {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "accessibility")
                                    .foregroundColor(Theme.DayMode.primary)
                                Text("Accessibility Features")
                                    .font(.headline)
                                    .themedText()
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
            .themedCardBackground()
            .navigationTitle("Theme Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .themedPrimary()
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
                .foregroundColor(Theme.DayMode.accent)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .themedText()
                
                Text(description)
                    .font(.caption)
                    .themedMuted()
            }
            
            Spacer()
        }
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(ThemeManager.shared)
}