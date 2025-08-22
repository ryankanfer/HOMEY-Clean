import SwiftUI
import UIKit

class AccessibilityService: ObservableObject {
    static let shared = AccessibilityService()

    @Published var isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
    @Published var isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
    @Published var prefersCrossFadeTransitions = UIAccessibility.prefersCrossFadeTransitions

    private init() {
        setupAccessibilityNotifications()
    }

    private func setupAccessibilityNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        }

        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
            self.prefersCrossFadeTransitions = UIAccessibility.prefersCrossFadeTransitions
        }
    }

    // MARK: - Haptic Feedback

    func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func playSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // MARK: - Accessibility Announcements

    func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    func announcePageChanged(_ message: String) {
        UIAccessibility.post(notification: .pageScrolled, argument: message)
    }

    func announceLayoutChanged(_ message: String? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: message)
    }

    // MARK: - Custom Rotor Actions

    func createPropertyRotor(
        properties: [Listing],
        onSelect: @escaping (Listing) -> Void
    ) -> UIAccessibilityCustomRotor {
        return UIAccessibilityCustomRotor(name: "Properties") { predicate in
            let currentIndex = properties.firstIndex { listing in
                guard let element = predicate.currentItem.targetElement as? UIView else { return false }
                return listing.id.uuidString == element.accessibilityIdentifier
            } ?? -1

            let nextIndex: Int
            switch predicate.searchDirection {
            case .next:
                nextIndex = (currentIndex + 1) % properties.count
            case .previous:
                nextIndex = currentIndex > 0 ? currentIndex - 1 : properties.count - 1
            @unknown default:
                nextIndex = 0
            }

            guard nextIndex < properties.count else { return nil }

            let property = properties[nextIndex]
            onSelect(property)

            return UIAccessibilityCustomRotorItemResult(
                targetElement: predicate.currentItem,
                targetRange: nil
            )
        }
    }

    func createNeighborhoodRotor(
        neighborhoods: [String],
        onSelect: @escaping (String) -> Void
    ) -> UIAccessibilityCustomRotor {
        return UIAccessibilityCustomRotor(name: "Neighborhoods") { predicate in
            let currentIndex = neighborhoods.firstIndex(of: predicate.currentItem.accessibilityLabel ?? "") ?? -1

            let nextIndex: Int
            switch predicate.searchDirection {
            case .next:
                nextIndex = (currentIndex + 1) % neighborhoods.count
            case .previous:
                nextIndex = currentIndex > 0 ? currentIndex - 1 : neighborhoods.count - 1
            @unknown default:
                nextIndex = 0
            }

            guard nextIndex < neighborhoods.count else { return nil }

            let neighborhood = neighborhoods[nextIndex]
            onSelect(neighborhood)

            return UIAccessibilityCustomRotorItemResult(
                targetElement: predicate.currentItem,
                targetRange: nil
            )
        }
    }
}

// MARK: - SwiftUI Extensions

extension View {
    func accessibleTap(
        action: @escaping () -> Void,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    ) -> some View {
        onTapGesture {
            AccessibilityService.shared.playHaptic(hapticStyle)
            action()
        }
    }

    func accessibleButton(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = .isButton,
        action: @escaping () -> Void
    ) -> some View {
        accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
            .accessibleTap(action: action)
    }

    func accessibleCard(
        label: String,
        value: String? = nil,
        hint: String? = nil
    ) -> some View {
        accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityValue(value ?? "")
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }

    func reduceMotionSensitive<T: View>(
        @ViewBuilder alternative: () -> T
    ) -> some View {
        Group {
            if UIAccessibility.isReduceMotionEnabled {
                alternative()
            } else {
                self
            }
        }
    }
}
