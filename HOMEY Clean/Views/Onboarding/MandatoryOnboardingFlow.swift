//
//  MandatoryOnboardingFlow.swift
//  HOMEY Clean
//
//  Mandatory onboarding flow with state management and validation
//

import SwiftUI
import AVFoundation

struct MandatoryOnboardingFlow: View {
    @Binding var isPresented: Bool
    let canDismiss: Bool
    let onComplete: (() -> Void)?
    
    @ObservedObject private var onboardingManager = OnboardingStateManager.shared
    @State private var showingValidationError = false
    @State private var attemptedToSkip = false
    
    // Current step data
    @State private var currentStepData: [String: String] = [:]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                OnboardingProgressHeader()
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // Main content
                TabView(selection: $onboardingManager.currentStepIndex) {
                    ForEach(Array(onboardingManager.steps.enumerated()), id: \.element.id) { index, step in
                        onboardingStepView(for: step, at: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .disabled(!canInteractWithCurrentStep())
                
                // Navigation controls
                NavigationControls()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
            }
            
            // Validation error overlay
            if showingValidationError {
                ValidationErrorOverlay()
            }
            
            // Skip attempt warning
            if attemptedToSkip && !canDismiss {
                SkipAttemptWarning()
            }
        }
        .onAppear {
            initializeOnboarding()
        }
        .onChange(of: onboardingManager.isOnboardingCompleted) { completed in
            if completed {
                handleOnboardingCompletion()
            }
        }
        .gesture(
            // Prevent swipe navigation in mandatory mode
            DragGesture()
                .onEnded { value in
                    if !canDismiss && abs(value.translation.width) > 50 {
                        handleSkipAttempt()
                    }
                }
        )
    }
    
    // MARK: - Step Views
    
    @ViewBuilder
    private func onboardingStepView(for step: OnboardingStep, at index: Int) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch step.id {
                case "welcome":
                    WelcomeStepView()
                case "purpose":
                    PurposeStepView(data: $currentStepData)
                case "features":
                    FeaturesStepView()
                case "location":
                    LocationStepView(data: $currentStepData)
                case "progress_tracking":
                    ProgressTrackingStepView()
                case "budget":
                    BudgetStepView(data: $currentStepData)
                case "preferences":
                    PreferencesStepView(data: $currentStepData)
                case "agent_invite":
                    AgentInviteStepView(data: $currentStepData)
                case "notifications":
                    NotificationsStepView(data: $currentStepData)
                case "completion":
                    CompletionStepView()
                case "password_setup":
                    PasswordSetupStepView(data: $currentStepData)
                default:
                    DefaultStepView(data: $currentStepData)
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
        .onChange(of: currentStepData) { newData in
            onboardingManager.updateCurrentStepData(newData)
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeOnboarding() {
        Task {
            await onboardingManager.initializeOnboarding()
            loadCurrentStepData()
        }
    }
    
    private func loadCurrentStepData() {
        if let currentStep = onboardingManager.getCurrentStep() {
            currentStepData = currentStep.data
        }
    }
    
    private func canInteractWithCurrentStep() -> Bool {
        return !onboardingManager.isLoading
    }
    
    private func handleNextStep() {
        // Validate current step
        guard onboardingManager.validateCurrentStep() else {
            showValidationError()
            return
        }
        
        // Proceed to next step
        if onboardingManager.proceedToNextStep() {
            loadCurrentStepData()
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private func handlePreviousStep() {
        if onboardingManager.goToPreviousStep() {
            loadCurrentStepData()
        } else if !canDismiss {
            handleSkipAttempt()
        }
    }
    
    private func showValidationError() {
        withAnimation(.spring()) {
            showingValidationError = true
        }
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingValidationError = false
            }
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func handleSkipAttempt() {
        guard !canDismiss else { return }
        
        withAnimation(.spring()) {
            attemptedToSkip = true
        }
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                attemptedToSkip = false
            }
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func handleOnboardingCompletion() {
        onComplete?()
        
        if canDismiss {
            isPresented = false
        }
    }
}

// MARK: - Header Components

extension MandatoryOnboardingFlow {
    @ViewBuilder
    private func OnboardingProgressHeader() -> some View {
        VStack(spacing: 16) {
            // App branding
            HStack {
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("HOMEY")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !canDismiss {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("Required")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Progress indicator
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * onboardingManager.getProgress(), height: 6)
                            .cornerRadius(3)
                            .animation(.easeInOut(duration: 0.3), value: onboardingManager.getProgress())
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text("Step \(onboardingManager.currentStepIndex + 1) of \(onboardingManager.steps.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(onboardingManager.getProgress() * 100))% Complete")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                }
            }
            
            // Current step title
            if let currentStep = onboardingManager.getCurrentStep() {
                Text(currentStep.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Navigation Controls

extension MandatoryOnboardingFlow {
    @ViewBuilder
    private func NavigationControls() -> some View {
        HStack(spacing: 16) {
            // Back button (only if allowed)
            if onboardingManager.currentStepIndex > 0 && canDismiss {
                Button(action: handlePreviousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            } else {
                // Placeholder to maintain layout
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
            }
            
            // Next/Complete button
            Button(action: handleNextStep) {
                HStack {
                    Text(isLastStep ? "Complete Setup" : "Continue")
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canProceedFromCurrentStep)
        }
    }
    
    private var isLastStep: Bool {
        onboardingManager.currentStepIndex == onboardingManager.steps.count - 1
    }
    
    private var canProceedFromCurrentStep: Bool {
        onboardingManager.canProceedToNextStep()
    }
}

// MARK: - Overlay Components

extension MandatoryOnboardingFlow {
    @ViewBuilder
    private func ValidationErrorOverlay() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            VStack(spacing: 8) {
                Text("Required Information Missing")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let error = onboardingManager.getCurrentStepError() {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button("Got It") {
                withAnimation {
                    showingValidationError = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 20)
        .padding(.horizontal, 40)
        .transition(.scale.combined(with: .opacity))
    }
    
    @ViewBuilder
    private func SkipAttemptWarning() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Setup Required")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Please complete all steps to access HOMEY. This ensures the best experience for your home search.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Continue Setup") {
                withAnimation {
                    attemptedToSkip = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 20)
        .padding(.horizontal, 40)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview {
    MandatoryOnboardingFlow(
        isPresented: .constant(true),
        canDismiss: false,
        onComplete: {
            print("Onboarding completed!")
        }
    )
}