import SwiftUI

/// Main orchestrator for the web app-style onboarding flow
struct WebAppOnboardingFlow: View {
    @EnvironmentObject private var session: AppSessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep: FlowStep = .doorSelection
    @State private var onboardingData = OnboardingFlowData()
    @State private var isSaving: Bool = false

    var body: some View {
        ZStack {
            switch currentStep {
            case .doorSelection:
                DoorSelectionView { doorStyle in
                    onboardingData.doorStyle = doorStyle.rawValue
                    withAnimation {
                        currentStep = .userType
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .userType:
                UserTypeView { userType in
                    onboardingData.userType = userType
                    withAnimation {
                        currentStep = .basicIntake
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .basicIntake:
                BasicIntakeView(
                    isBuyer: onboardingData.isBuyer,
                    onNext: { firstName, lastName, phone in
                        onboardingData.firstName = firstName
                        onboardingData.lastName = lastName
                        onboardingData.phone = phone
                        withAnimation {
                            currentStep = .vibeCheck
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .vibeCheck:
                VibeCheckView(
                    isBuyer: onboardingData.isBuyer,
                    onNext: { preferences in
                        onboardingData.vibePreferences = preferences
                        withAnimation {
                            currentStep = .thisOrThat
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .thisOrThat:
                ThisOrThatView(
                    isBuyer: onboardingData.isBuyer,
                    onComplete: { answers in
                        onboardingData.thisOrThatAnswers = answers
                        withAnimation {
                            currentStep = .budgetTimeline
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .budgetTimeline:
                BudgetTimelineView(
                    isBuyer: onboardingData.isBuyer,
                    onNext: { budgetData in
                        onboardingData.budgetMin = budgetData.budgetMin
                        onboardingData.budgetMax = budgetData.budgetMax
                        onboardingData.timeline = budgetData.timeline
                        withAnimation {
                            currentStep = .matchTease
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .matchTease:
                MatchTeaseView {
                    Task {
                        await saveOnboardingData()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
    }

    @MainActor
    private func saveOnboardingData() async {
        isSaving = true

        do {
            // Get current user
            let user = try await session.supabaseClient.auth.user()

            // Update profile with onboarding data
            let profilesRepo = ProfilesRepository(client: session.supabaseClient)

            let updateRequest = ProfileUpdateRequest(
                fullName: "\(onboardingData.firstName ?? "") \(onboardingData.lastName ?? "")".trimmingCharacters(in: .whitespaces),
                phoneNumber: onboardingData.phone,
                preferredComms: nil,
                workingWithAgent: nil,
                clientSegment: onboardingData.userType,
                firstName: onboardingData.firstName,
                lastName: onboardingData.lastName,
                occupation: nil,
                income: onboardingData.budgetMax.map { Double($0) * 40 }, // Rough income estimate
                liquidAssets: nil,
                reasonForPurchase: onboardingData.userType,
                employmentType: nil,
                pets: onboardingData.vibePreferences.contains("pet-friendly"),
                needsElevator: nil,
                preferredNeighborhood: nil,
                bedrooms: nil,
                bathrooms: nil,
                propertyTenure: nil
            )

            _ = try await profilesRepo.updateProfile(updateRequest)

            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "OnboardingCompleted")

            // Dismiss onboarding
            dismiss()

        } catch {
            print("[WebAppOnboardingFlow] Failed to save onboarding data: \(error)")
            // Still dismiss - don't block user
            dismiss()
        }

        isSaving = false
    }
}

// MARK: - Flow Steps

private enum FlowStep {
    case doorSelection
    case userType
    case basicIntake
    case vibeCheck
    case thisOrThat
    case budgetTimeline
    case matchTease
}

// MARK: - Onboarding Data

private class OnboardingFlowData {
    var doorStyle: String?
    var userType: String?
    var firstName: String?
    var lastName: String?
    var phone: String?
    var vibePreferences: [String] = []
    var thisOrThatAnswers: [String: String] = [:]
    var budgetMin: Int?
    var budgetMax: Int?
    var timeline: String?

    var isBuyer: Bool {
        userType?.lowercased() == "buyer"
    }
}

// MARK: - User Type View

private struct UserTypeView: View {
    var onNext: (String) -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 12) {
                    Text("What brings you here?")
                        .font(.custom("PlayfairDisplay-Regular", size: 36))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Tell us your journey")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                VStack(spacing: 16) {
                    // Buyer option
                    Button {
                        onNext("buyer")
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("I'm buying")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white)

                                Text("Ready to own your home")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "house.fill")
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    // Renter option
                    Button {
                        onNext("renter")
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("I'm renting")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white)

                                Text("Looking for the perfect place")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "key.fill")
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

// MARK: - Basic Intake View

private struct BasicIntakeView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var showingPhoneInput: Bool = false

    var isBuyer: Bool
    var onNext: (String, String, String) -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text(showingPhoneInput ? "Hi, \(firstName)." : "Let's get introduced.")
                        .font(.custom("PlayfairDisplay-Regular", size: 36))
                        .foregroundStyle(.white)

                    Text(showingPhoneInput ? "How can we reach you?" : "We like to know who we're welcoming.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                if !showingPhoneInput {
                    // Name inputs
                    VStack(spacing: 24) {
                        TextField("First Name", text: $firstName)
                            .font(.custom("PlayfairDisplay-Regular", size: 32))
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 4)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.white.opacity(0.2)),
                                alignment: .bottom
                            )

                        TextField("Last Name", text: $lastName)
                            .font(.custom("PlayfairDisplay-Regular", size: 32))
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 4)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.white.opacity(0.2)),
                                alignment: .bottom
                            )

                        if !firstName.isEmpty && !lastName.isEmpty {
                            Button {
                                withAnimation {
                                    showingPhoneInput = true
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Continue")
                                        .font(.headline)
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.white)
                                .foregroundStyle(.black)
                                .cornerRadius(16)
                            }
                            .padding(.top, 16)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Phone input
                    VStack(spacing: 24) {
                        TextField("(555) 000-0000", text: $phone)
                            .font(.system(size: 32, design: .monospaced))
                            .foregroundStyle(.white)
                            .keyboardType(.phonePad)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 4)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.white.opacity(0.2)),
                                alignment: .bottom
                            )
                            .onChange(of: phone) { _, newValue in
                                phone = formatPhone(newValue)
                            }

                        if phone.count >= 14 {
                            Button {
                                onNext(firstName, lastName, phone)
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Complete")
                                        .font(.headline)
                                    Image(systemName: "checkmark")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.white)
                                .foregroundStyle(.black)
                                .cornerRadius(16)
                            }
                            .padding(.top, 16)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
    }

    private func formatPhone(_ value: String) -> String {
        let digits = value.filter { $0.isNumber }
        var formatted = ""

        for (index, digit) in digits.enumerated() {
            if index == 0 {
                formatted += "("
            } else if index == 3 {
                formatted += ") "
            } else if index == 6 {
                formatted += "-"
            }

            if index < 10 {
                formatted.append(digit)
            }
        }

        return formatted
    }
}
