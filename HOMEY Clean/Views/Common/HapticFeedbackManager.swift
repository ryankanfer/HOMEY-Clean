import SwiftUI
import UIKit

// MARK: - Haptic Feedback Manager

class HapticFeedbackManager: ObservableObject {
    
    // MARK: - Haptic Generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    @Published var isHapticsEnabled: Bool = true
    
    init() {
        prepareGenerators()
    }
    
    // MARK: - Preparation
    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Train Movement Haptics
    
    func trainAcceleration() {
        guard isHapticsEnabled else { return }
        
        // Gradual acceleration feedback
        DispatchQueue.main.async {
            self.impactLight.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactMedium.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    func trainDeceleration() {
        guard isHapticsEnabled else { return }
        
        // Gradual deceleration feedback
        DispatchQueue.main.async {
            self.impactHeavy.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.impactMedium.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.impactLight.impactOccurred()
        }
    }
    
    func trainMovementRumble() {
        guard isHapticsEnabled else { return }
        
        // Continuous rumble effect for train movement
        let rumblePattern = [0.0, 0.1, 0.05, 0.1, 0.05, 0.15, 0.1, 0.2]
        
        for (index, delay) in rumblePattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if index % 2 == 0 {
                    self.impactLight.impactOccurred()
                } else {
                    self.impactMedium.impactOccurred()
                }
            }
        }
    }
    
    // MARK: - Door Haptics
    
    func doorOpening() {
        guard isHapticsEnabled else { return }
        
        // Smooth opening sensation
        DispatchQueue.main.async {
            self.impactLight.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.selectionGenerator.selectionChanged()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.notificationGenerator.notificationOccurred(.success)
        }
    }
    
    func doorClosing() {
        guard isHapticsEnabled else { return }
        
        // Firm closing sensation
        DispatchQueue.main.async {
            self.selectionGenerator.selectionChanged()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.impactMedium.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    // MARK: - Station Haptics
    
    func stationArrival() {
        guard isHapticsEnabled else { return }
        
        // Arrival notification pattern
        notificationGenerator.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactMedium.impactOccurred()
        }
    }
    
    func stationDeparture() {
        guard isHapticsEnabled else { return }
        
        // Departure warning pattern
        impactMedium.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    // MARK: - Interaction Haptics
    
    func cardSwipe() {
        guard isHapticsEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    func buttonPress() {
        guard isHapticsEnabled else { return }
        impactMedium.impactOccurred()
    }
    
    func navigationGesture() {
        guard isHapticsEnabled else { return }
        impactLight.impactOccurred()
    }
    
    func errorFeedback() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
    
    func successFeedback() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    // MARK: - Complex Haptic Sequences
    
    func journeyComplete() {
        guard isHapticsEnabled else { return }
        
        // Celebratory completion sequence
        let completionPattern: [(UIImpactFeedbackGenerator.FeedbackStyle, TimeInterval)] = [
            (.light, 0.0),
            (.medium, 0.1),
            (.heavy, 0.2),
            (.medium, 0.3),
            (.light, 0.4),
            (.medium, 0.5),
            (.heavy, 0.7)
        ]
        
        for (style, delay) in completionPattern {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                switch style {
                case .light:
                    self.impactLight.impactOccurred()
                case .medium:
                    self.impactMedium.impactOccurred()
                case .heavy:
                    self.impactHeavy.impactOccurred()
                @unknown default:
                    self.impactMedium.impactOccurred()
                }
            }
        }
        
        // Final success notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.notificationGenerator.notificationOccurred(.success)
        }
    }
    
    func emergencyBrake() {
        guard isHapticsEnabled else { return }
        
        // Sharp emergency brake sensation
        impactHeavy.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impactHeavy.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notificationGenerator.notificationOccurred(.warning)
        }
    }
    
    // MARK: - Settings
    
    func toggleHaptics() {
        isHapticsEnabled.toggle()
        
        if isHapticsEnabled {
            // Confirmation haptic when enabling
            impactMedium.impactOccurred()
        }
    }
    
    func setHapticsEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
        
        if enabled {
            prepareGenerators()
        }
    }
    
    // MARK: - Public Haptic Methods for External Use
    
    func lightImpact() {
        guard isHapticsEnabled else { return }
        impactLight.impactOccurred()
    }
    
    func mediumImpact() {
        guard isHapticsEnabled else { return }
        impactMedium.impactOccurred()
    }
    
    func heavyImpact() {
        guard isHapticsEnabled else { return }
        impactHeavy.impactOccurred()
    }
}

// MARK: - Haptic View Modifier

struct HapticFeedbackModifier: ViewModifier {
    let hapticManager: HapticFeedbackManager
    let feedbackType: HapticFeedbackType
    let trigger: Bool
    
    enum HapticFeedbackType {
        case trainAcceleration
        case trainDeceleration
        case trainMovement
        case doorOpening
        case doorClosing
        case stationArrival
        case stationDeparture
        case cardSwipe
        case buttonPress
        case navigationGesture
        case journeyComplete
        case emergencyBrake
        case success
        case error
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { triggered in
                if triggered {
                    performHapticFeedback()
                }
            }
    }
    
    private func performHapticFeedback() {
        switch feedbackType {
        case .trainAcceleration:
            hapticManager.trainAcceleration()
        case .trainDeceleration:
            hapticManager.trainDeceleration()
        case .trainMovement:
            hapticManager.trainMovementRumble()
        case .doorOpening:
            hapticManager.doorOpening()
        case .doorClosing:
            hapticManager.doorClosing()
        case .stationArrival:
            hapticManager.stationArrival()
        case .stationDeparture:
            hapticManager.stationDeparture()
        case .cardSwipe:
            hapticManager.cardSwipe()
        case .buttonPress:
            hapticManager.buttonPress()
        case .navigationGesture:
            hapticManager.navigationGesture()
        case .journeyComplete:
            hapticManager.journeyComplete()
        case .emergencyBrake:
            hapticManager.emergencyBrake()
        case .success:
            hapticManager.successFeedback()
        case .error:
            hapticManager.errorFeedback()
        }
    }
}

// MARK: - View Extensions

extension View {
    func hapticFeedback(
        _ hapticManager: HapticFeedbackManager,
        type: HapticFeedbackModifier.HapticFeedbackType,
        trigger: Bool
    ) -> some View {
        self.modifier(
            HapticFeedbackModifier(
                hapticManager: hapticManager,
                feedbackType: type,
                trigger: trigger
            )
        )
    }
}

// MARK: - Haptic Patterns

struct HapticPatterns {
    
    static func subwayRhythm(hapticManager: HapticFeedbackManager) {
        // Mimics the rhythm of a subway train on tracks
        let pattern: [(UIImpactFeedbackGenerator.FeedbackStyle, TimeInterval)] = [
            (.light, 0.0),
            (.light, 0.2),
            (.medium, 0.4),
            (.light, 0.6),
            (.light, 0.8),
            (.medium, 1.0),
            (.heavy, 1.2),
            (.medium, 1.4),
            (.light, 1.6),
            (.light, 1.8)
        ]
        
        for (style, delay) in pattern {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                switch style {
                case .light:
                    hapticManager.lightImpact()
                case .medium:
                    hapticManager.mediumImpact()
                case .heavy:
                    hapticManager.heavyImpact()
                @unknown default:
                    hapticManager.mediumImpact()
                }
            }
        }
    }
    
    static func doorChime(hapticManager: HapticFeedbackManager) {
        // Mimics the subway door chime with haptics
        hapticManager.lightImpact()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            hapticManager.mediumImpact()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hapticManager.lightImpact()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            hapticManager.mediumImpact()
        }
    }
}