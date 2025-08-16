struct FlagsPanel: View {
    @EnvironmentObject private var flags: FeatureFlags
    var body: some View {
        SectionCard(title: "Feature flags", subtitle: "Flip responsibly") {
            Toggle("Client: Legacy tabs", isOn: $flags.useLegacyClientTabs)
            Toggle("AI: Chat enabled", isOn: $flags.aiChatEnabled)
            Toggle("Onboarding: New role picker", isOn: $flags.newRolePicker)
        }
    }
}

// Extend your flags
final class FeatureFlags: ObservableObject {
    @AppStorage("USE_LEGACY_CLIENT_TABS") var useLegacyClientTabs = false
    @AppStorage("FF_AI_CHAT") var aiChatEnabled = true
    @AppStorage("FF_NEW_ROLE_PICKER") var newRolePicker = true
}