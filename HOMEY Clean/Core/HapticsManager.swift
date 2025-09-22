import SwiftUI

final class HapticsManager: ObservableObject {
    static let shared = HapticsManager()
    
    private let key = "HapticsEnabled"
    @Published var enabled: Bool {
        didSet { UserDefaults.standard.set(enabled, forKey: key) }
    }
    
    private init() {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(true, forKey: key)
        }
        self.enabled = UserDefaults.standard.bool(forKey: key)
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}