//
//  OnboardingStateManager.swift
//  HOMEY Clean
//
//  Manages mandatory onboarding flow state and enforces completion
//

import SwiftUI
import Foundation
#if canImport(Supabase)
import Supabase
#endif

// MARK: - Timeout Error

struct TimeoutError: Error {
    let message = "Operation timed out"
}

// MARK: - Onboarding Step Model

struct OnboardingStep: Identifiable, Codable {
    let id: String
    let title: String
    let isRequired: Bool
    var isCompleted: Bool
    var data: [String: String]
    let validationRules: [ValidationRule]
    
    init(id: String, title: String, isRequired: Bool = true, validationRules: [ValidationRule] = []) {
        self.id = id
        self.title = title
        self.isRequired = isRequired
        self.isCompleted = false
        self.data = [:]
        self.validationRules = validationRules
    }
}

// MARK: - Validation Rule

struct ValidationRule: Codable {
    let field: String
    let type: ValidationType
    let message: String
    
    enum ValidationType: String, Codable {
        case required
        case minLength
        case email
        case phone
        case numeric
        case selection
    }
}

// MARK: - Onboarding State Manager

@MainActor
final class OnboardingStateManager: ObservableObject {
    static let shared = OnboardingStateManager()
    
    @Published var currentStepIndex: Int = 0
    @Published var steps: [OnboardingStep] = []
    @Published var isOnboardingRequired: Bool = false
    @Published var isOnboardingCompleted: Bool = false
    @Published var canSkipOnboarding: Bool = false
    @Published var isLoading: Bool = false
    @Published var validationErrors: [String: String] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "mandatory_onboarding_state"
    private let completionKey = "onboarding_completed"
    
    #if canImport(Supabase)
    private var supabaseClient: SupabaseClient {
        AppSessionManager.shared.supabaseClient
    }
    #endif
    
    private init() {
        setupOnboardingSteps()
        loadPersistedState()
    }
    
    // MARK: - Public Methods
    
    func initializeOnboarding(forceRestart: Bool = false) async {
        isLoading = true
        
        if forceRestart {
            resetOnboardingState()
        }
        
        await loadOnboardingStatus()
        
        if !isOnboardingCompleted && isOnboardingRequired {
            setupOnboardingSteps()
            currentStepIndex = findFirstIncompleteStep()
        }
        
        isLoading = false
    }
    
    func canProceedToNextStep() -> Bool {
        guard currentStepIndex < steps.count else { return false }
        
        let currentStep = steps[currentStepIndex]
        return validateStep(currentStep)
    }
    
    func proceedToNextStep() -> Bool {
        guard canProceedToNextStep() else { return false }
        
        steps[currentStepIndex].isCompleted = true
        
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            completeOnboarding()
        }
        
        persistState()
        return true
    }
    
    func goToPreviousStep() -> Bool {
        if isOnboardingRequired && !canSkipOnboarding {
            return false
        }
        
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            persistState()
            return true
        }
        
        return false
    }
    
    func updateCurrentStepData(_ data: [String: String]) {
        guard currentStepIndex < steps.count else { return }
        
        steps[currentStepIndex].data.merge(data) { _, new in new }
        validateCurrentStep()
        persistState()
    }
    
    func validateCurrentStep() -> Bool {
        guard currentStepIndex < steps.count else { return false }
        
        let currentStep = steps[currentStepIndex]
        return validateStep(currentStep)
    }
    
    func getCurrentStep() -> OnboardingStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    func getProgress() -> Double {
        guard !steps.isEmpty else { return 0.0 }
        
        let completedSteps = steps.filter { $0.isCompleted }.count
        return Double(completedSteps) / Double(steps.count)
    }
    
    func isBlockingAppAccess() -> Bool {
        // If we're still loading, don't block access yet
        if isLoading {
            return false
        }
        
        return isOnboardingRequired && !isOnboardingCompleted
    }
    
    func forceCompleteOnboarding() {
        isOnboardingCompleted = true
        isOnboardingRequired = false
        persistCompletionState()
    }
    
    // MARK: - Private Methods
    
    private func setupOnboardingSteps() {
        steps = [
            OnboardingStep(
                id: "welcome",
                title: "Welcome",
                isRequired: true
            ),
            OnboardingStep(
                id: "purpose",
                title: "What brings you here?",
                isRequired: true,
                validationRules: [
                    ValidationRule(field: "purpose", type: .selection, message: "Please select your purpose")
                ]
            ),
            OnboardingStep(
                id: "features",
                title: "What makes HOMEY different?",
                isRequired: true
            ),
            OnboardingStep(
                id: "location",
                title: "Where are you looking?",
                isRequired: true,
                validationRules: [
                    ValidationRule(field: "neighborhood", type: .required, message: "Please enter a neighborhood or city")
                ]
            ),
            OnboardingStep(
                id: "progress_tracking",
                title: "Track your progress",
                isRequired: true
            ),
            OnboardingStep(
                id: "budget",
                title: "What's your budget?",
                isRequired: true,
                validationRules: [
                    ValidationRule(field: "budget_amount", type: .numeric, message: "Please set a valid budget amount")
                ]
            ),
            OnboardingStep(
                id: "preferences",
                title: "Your preferences",
                isRequired: true
            ),
            OnboardingStep(
                id: "agent_invite",
                title: "Invite your agent",
                isRequired: false
            ),
            OnboardingStep(
                id: "notifications",
                title: "Stay updated",
                isRequired: true
            ),
            OnboardingStep(
                id: "completion",
                title: "You're all set!",
                isRequired: true
            ),
            OnboardingStep(
                id: "password_setup",
                title: "Secure your account",
                isRequired: true,
                validationRules: [
                    ValidationRule(field: "password", type: .minLength, message: "Password must be at least 8 characters")
                ]
            )
        ]
    }
    
    private func validateStep(_ step: OnboardingStep) -> Bool {
        // We compute the validation result synchronously.
        var currentValidationError: String?
        var isValid = true

        if step.isRequired {
            for rule in step.validationRules {
                let value = step.data[rule.field] ?? ""
                var ruleFailed = false
                
                switch rule.type {
                case .required:
                    if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ruleFailed = true
                    }
                case .minLength:
                    if value.count < 8 {
                        ruleFailed = true
                    }
                case .email:
                    if !isValidEmail(value) {
                        ruleFailed = true
                    }
                case .phone:
                    if !isValidPhone(value) {
                        ruleFailed = true
                    }
                case .numeric:
                    if Double(value) == nil {
                        ruleFailed = true
                    }
                case .selection:
                    if value.isEmpty {
                        ruleFailed = true
                    }
                }

                if ruleFailed {
                    currentValidationError = rule.message
                    isValid = false
                    break // First error is enough
                }
            }
        }

        // Defer the state update for `validationErrors` to the next run loop
        // to avoid publishing changes during a view update.
        DispatchQueue.main.async {
            if let error = currentValidationError {
                // Only update if the error is new or different
                if self.validationErrors[step.id] != error {
                    self.validationErrors[step.id] = error
                }
            } else {
                // Only update if there was an error before
                if self.validationErrors[step.id] != nil {
                    self.validationErrors.removeValue(forKey: step.id)
                }
            }
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[+]?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    private func findFirstIncompleteStep() -> Int {
        for (index, step) in steps.enumerated() {
            if step.isRequired && !step.isCompleted {
                return index
            }
        }
        return 0
    }
    
    private func completeOnboarding() {
        isLoading = true
        Task {
            let success = await saveOnboardingDataToBackend()
            await MainActor.run {
                if success {
                    self.isOnboardingCompleted = true
                    self.isOnboardingRequired = false
                    self.persistCompletionState()
                }
                self.isLoading = false
            }
        }
    }
    
    private func loadOnboardingStatus() async {
        // First, trust local completion for returning users.
        let locallyCompleted = userDefaults.bool(forKey: completionKey)
        if locallyCompleted {
            isOnboardingCompleted = true
            isOnboardingRequired = false
            return
        }
        
        #if canImport(Supabase)
        do {
            // Race timeout vs backend check
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await Task.sleep(nanoseconds: 8_000_000_000)
                    throw TimeoutError()
                }
                
                group.addTask { [supabaseClient] in
                    // Use explicit client to avoid init timing races
                    let profilesRepo = ProfilesRepository(client: supabaseClient)
                    do {
                        let user = try await supabaseClient.auth.user()
                        let profileRecord = try await profilesRepo.fetchProfile(for: user.id)
                        
                        // The most reliable indicator of a completed onboarding is the 'clientSegment'
                        // (i.e., the user's "purpose"), which is a required step.
                        let hasCompletedOnboarding = profileRecord.clientSegment != nil && !profileRecord.clientSegment!.isEmpty
                        
                        await MainActor.run {
                            self.isOnboardingCompleted = hasCompletedOnboarding
                            self.isOnboardingRequired = !hasCompletedOnboarding
                            self.canSkipOnboarding = false
                        }
                    } catch {
                        // If there's an error fetching profile, don't block the user
                        await MainActor.run {
                            self.isOnboardingRequired = false
                            self.isOnboardingCompleted = false
                            self.canSkipOnboarding = true // soft gate: allow access, recheck later
                        }
                    }
                }
                
                try await group.next()
                group.cancelAll()
            }
        } catch {
            // Do NOT force mandatory onboarding on backend failure/timeout for returning users.
            // Since local completion was false (first-time users), we will soft-allow and re-evaluate later.
            print("[OnboardingStateManager] Non-fatal onboarding status error/timeout: \(error)")
            await MainActor.run {
                self.isOnboardingRequired = false
                self.isOnboardingCompleted = false
                self.canSkipOnboarding = true // soft gate: allow access, recheck later
            }
        }
        #else
        // No Supabase: trust local flag only
        isOnboardingCompleted = userDefaults.bool(forKey: completionKey)
        isOnboardingRequired = !isOnboardingCompleted
        #endif
    }
    
    private func saveOnboardingDataToBackend() async -> Bool {
        #if canImport(Supabase)
        do {
            let user = try await supabaseClient.auth.user()
            let profilesRepo = ProfilesRepository(client: supabaseClient)
            
            // 1. Consolidate data from all steps into one dictionary
            let allOnboardingData = steps.reduce(into: [String: String]()) { result, step in
                result.merge(step.data) { (_, new) in new }
            }
            
            // 2. Map the consolidated data to the update request model
            let updateRequest = ProfileUpdateRequest(
                fullName: nil, // Not collected in onboarding
                phoneNumber: nil, // Not collected in onboarding
                preferredComms: nil, // Not collected in onboarding
                workingWithAgent: nil, // Logic can be added if collected
                clientSegment: allOnboardingData["purpose"],
                firstName: nil, // Not collected in onboarding
                lastName: nil, // Not collected in onboarding
                occupation: nil, // Not collected in onboarding
                income: allOnboardingData["budget_amount"].flatMap { Double($0) }.map { $0 * 40 },
                liquidAssets: nil, // Not collected in onboarding
                reasonForPurchase: allOnboardingData["purpose"],
                employmentType: nil, // Not collected in onboarding
                pets: allOnboardingData["pets"].flatMap { $0.lowercased() == "true" },
                needsElevator: allOnboardingData["needs_elevator"].flatMap { Bool($0) },
                preferredNeighborhood: allOnboardingData["neighborhood"],
                bedrooms: allOnboardingData["bedrooms"].flatMap { Int($0) },
                bathrooms: allOnboardingData["bathrooms"].flatMap { Double($0) }.map { Int($0) },
                propertyTenure: nil // Not collected in onboarding
            )
            
            // 3. Log the request and send it to the backend
            print("[OnboardingStateManager] Preparing to save onboarding data to backend...")
            print("[OnboardingStateManager] Update Request Payload: \(updateRequest)")
            
            let updatedProfile = try await profilesRepo.updateProfile(updateRequest)
            print("[OnboardingStateManager] Successfully saved onboarding data. Updated profile: \(updatedProfile)")
            return true
            
        } catch {
            print("[OnboardingStateManager] Failed to save onboarding data: \(error.localizedDescription)")
            return false
        }
        #else
        return true // In non-Supabase environments, assume success
        #endif
    }
    
    private func persistState() {
        do {
            let data = try JSONEncoder().encode(steps)
            userDefaults.set(data, forKey: onboardingKey)
            userDefaults.set(currentStepIndex, forKey: "\(onboardingKey)_current_step")
        } catch {
            print("[OnboardingStateManager] Failed to persist state: \(error)")
        }
    }
    
    private func loadPersistedState() {
        guard let data = userDefaults.data(forKey: onboardingKey),
              let persistedSteps = try? JSONDecoder().decode([OnboardingStep].self, from: data) else {
            return
        }
        
        steps = persistedSteps
        currentStepIndex = userDefaults.integer(forKey: "\(onboardingKey)_current_step")
    }
    
    private func persistCompletionState() {
        userDefaults.set(isOnboardingCompleted, forKey: completionKey)
        userDefaults.removeObject(forKey: onboardingKey)
        userDefaults.removeObject(forKey: "\(onboardingKey)_current_step")
    }
    
    func resetOnboardingState() {
        isOnboardingCompleted = false
        isOnboardingRequired = true
        canSkipOnboarding = false
        currentStepIndex = 0
        validationErrors.removeAll()
        
        userDefaults.removeObject(forKey: completionKey)
        userDefaults.removeObject(forKey: onboardingKey)
        userDefaults.removeObject(forKey: "\(onboardingKey)_current_step")
        
        setupOnboardingSteps()
    }
}

// MARK: - Extensions

extension OnboardingStateManager {
    func getCurrentStepError() -> String? {
        guard let currentStep = getCurrentStep() else { return nil }
        return validationErrors[currentStep.id]
    }
    
    func canAccessStep(at index: Int) -> Bool {
        if isOnboardingRequired && !canSkipOnboarding {
            return index <= currentStepIndex
        }
        
        return index < steps.count
    }
    
    func getStepsCompletionStatus() -> [Bool] {
        return steps.map { $0.isCompleted }
    }
}