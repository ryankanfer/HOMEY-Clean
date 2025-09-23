import SwiftUI

private struct SuggestionEngineKey: EnvironmentKey {
    static let defaultValue: SuggestionEngine = .shared
}

extension EnvironmentValues {
    var suggestionEngine: SuggestionEngine {
        get { self[SuggestionEngineKey.self] }
        set { self[SuggestionEngineKey.self] = newValue }
    }
}