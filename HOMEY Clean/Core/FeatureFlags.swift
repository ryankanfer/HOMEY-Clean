import SwiftUI

final class FeatureFlags: ObservableObject {
    @AppStorage("USE_LEGACY_CLIENT_TABS") var useLegacyClientTabs: Bool = false
}

enum Flags {
    static let shared = FeatureFlags()
}