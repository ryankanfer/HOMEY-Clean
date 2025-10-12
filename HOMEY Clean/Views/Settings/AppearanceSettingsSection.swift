//
//  AppearanceSettingsSection.swift
//  HOMEY Clean
//
//  Appearance settings section with theme selection and accessibility options
//

import SwiftUI

private func logSettingChange(_ key: String, _ value: Any) {
    Task.detached {
        let uid = await MainActor.run { AppSessionManager.shared.userProfile?.id }
        let sid = await InteractionLogger.shared.makeSessionId()
        await InteractionLogger.shared.log(
            InteractionEvent(
                type: .custom,
                page: .settings,
                userId: uid,
                sessionId: sid,
                metadata: [
                    "setting": .init(key),
                    "value": .init(value)
                ]
            )
        )
    }
}

struct AppearanceSettingsSection: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @AppStorage("textSizeScale") private var textSize: Double = 1.0
    @AppStorage("highContrastEnabled") private var highContrast = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("reduceMotion") private var reduceMotion: Bool = UIAccessibility.isReduceMotionEnabled
    @State private var showingThemeSelection = false
    
    var body: some View {
        Section(header: Text("Appearance")) {
            HStack {
                Image(systemName: "paintbrush")
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme")
                        .font(.body)
                        .foregroundColor(.primary)
                    Text("Midnight Black")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
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
                    .tint(.blue)
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
        .onAppear {
            HapticsManager.shared.enabled = hapticsEnabled
        }
        .onChange(of: hapticsEnabled) { _, newValue in
            Task { @MainActor in
                HapticsManager.shared.enabled = newValue
                logSettingChange("haptics_enabled", newValue)
            }
        }
        .onChange(of: textSize) { _, newValue in
            Task { @MainActor in
                // Hook for propagating text scaling to a global typography system if applicable.
                logSettingChange("text_size_scale", newValue)
            }
        }
        .onChange(of: highContrast) { _, newValue in
            Task { @MainActor in
                logSettingChange("high_contrast_enabled", newValue)
            }
        }
        .onChange(of: animationsEnabled) { _, newValue in
            Task { @MainActor in
                logSettingChange("animations_enabled", newValue)
            }
        }
        .onChange(of: reduceMotion) { _, newValue in
            Task { @MainActor in
                logSettingChange("reduce_motion", newValue)
            }
        }
    }
}

// MARK: - Theme Selection View
struct ThemeSelectionView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("reduceMotion") private var reduceMotion: Bool = UIAccessibility.isReduceMotionEnabled
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Theme Settings")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            Divider()
            
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
                            let shouldAnimate = animationsEnabled && !reduceMotion
                            if shouldAnimate {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    themeManager.setTheme(mode)
                                }
                            } else {
                                themeManager.setTheme(mode)
                            }
                            
                            logSettingChange("theme_mode", mode.rawValue)
                        }
                    }
                } header: {
                    Text("Theme Selection")
                } footer: {
                    Text("Day Mode provides high contrast colors for improved accessibility and readability in bright environments.")
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