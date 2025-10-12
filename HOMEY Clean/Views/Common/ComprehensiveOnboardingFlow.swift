import SwiftUI

struct ComprehensiveOnboardingFlow: View {
    @ObservedObject private var onboardingManager = OnboardingStateManager.shared
    @Binding var isPresented: Bool
    let canDismiss: Bool
    
    // Compatibility initializers
    init(onComplete: @escaping () -> Void) {
        self._isPresented = .constant(true)
        self.canDismiss = true
    }
    
    init(isPresented: Binding<Bool>, canDismiss: Bool, onComplete: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.canDismiss = canDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. Redesigned, modern header
            OnboardingHeaderView(
                progress: onboardingManager.getProgress()
            )
            .padding(.bottom, 8)
            
            // 2. Step content area with transitions
            ZStack {
                ForEach(onboardingManager.steps.indices, id: \.self) { index in
                    if index == onboardingManager.currentStepIndex {
                        stepView(for: onboardingManager.steps[index])
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                )
                                .combined(with: .opacity)
                            )
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            // 3. Redesigned, modern footer
            OnboardingFooterView(
                onContinue: {
                    if !onboardingManager.proceedToNextStep() {
                        // Here you could add a shake animation for validation failure
                    }
                },
                onBack: {
                    _ = onboardingManager.goToPreviousStep()
                },
                canGoBack: onboardingManager.currentStepIndex > 0,
                isCompleting: (onboardingManager.currentStepIndex == onboardingManager.steps.count - 1),
                isContinueEnabled: onboardingManager.canProceedToNextStep()
            )
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: onboardingManager.currentStepIndex)
    }

    @ViewBuilder
    private func stepView(for step: OnboardingStep) -> some View {
        // The ScrollView ensures content doesn't get cut off on smaller screens.
        ScrollView {
            // Using a simple switch to route to the correct view for each step.
            switch step.id {
            case "welcome":
                WelcomeStepView()
            case "features":
                FeaturesStepView()
            case "progress_tracking":
                ProgressTrackingStepView()
            case "purpose":
                PurposeStepView(data: stepBinding(for: step.id)).padding(20)
            case "location":
                LocationStepView(data: stepBinding(for: step.id)).padding(20)
            case "budget":
                BudgetStepView(data: stepBinding(for: step.id)).padding(20)
            case "preferences":
                PreferencesStepView(data: stepBinding(for: step.id)).padding(20)
            case "password_setup":
                PasswordSetupStepView(data: stepBinding(for: step.id)).padding(20)
            case "completion":
                CompletionStepView().padding(20)
            default:
                DefaultStepView(data: stepBinding(for: step.id)).padding(20)
            }
        }
    }
    
    // Binding helper to pass step data to subviews
    private func stepBinding(for stepId: String) -> Binding<[String: String]> {
        Binding(
            get: { onboardingManager.steps.first { $0.id == stepId }?.data ?? [:] },
            set: { newData in onboardingManager.updateCurrentStepData(newData) }
        )
    }
}

// MARK: - Redesigned Header
private struct OnboardingHeaderView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "house.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.blue)
                .animation(.spring(), value: progress)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }
}

// MARK: - Redesigned Footer
private struct OnboardingFooterView: View {
    let onContinue: () -> Void
    let onBack: () -> Void
    let canGoBack: Bool
    let isCompleting: Bool
    let isContinueEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if canGoBack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.headline)
                }
                .buttonStyle(OnboardingSecondaryButtonStyle())
            }
            
            Button(action: onContinue) {
                HStack {
                    Text(isCompleting ? "Finish Setup" : "Continue")
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(OnboardingPrimaryButtonStyle())
            .disabled(!isContinueEnabled)
        }
        .padding(20)
        .background(.regularMaterial)
    }
}

// MARK: - Custom Button Styles for Onboarding
struct OnboardingPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .background(isEnabled ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.7)
    }
}

struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(Color(.systemGray5))
            .foregroundColor(.secondary)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#if DEBUG
struct ComprehensiveOnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        ComprehensiveOnboardingFlow(onComplete: {})
            .preferredColorScheme(.dark)
    }
}
#endif