
import UIKit

enum Haptics {
    @MainActor static func success() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
