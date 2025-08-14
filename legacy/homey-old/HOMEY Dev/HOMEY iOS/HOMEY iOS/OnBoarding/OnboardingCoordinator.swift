//
//  OnboardingCoordinator.swift
//

import SwiftUI

struct OnboardingCoordinator: View {
    @State private var data = OnboardingData()

    @State private var path: [Int] = [] // step index path
    // Steps: 1 Welcome, 2 Role, 3 Profile+Property, 4 Budget, 5 Prefs, 6 Review -> Dashboard

    var canContinueFromWelcome: Bool { !data.referralCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var canContinueFromRole: Bool { data.role != nil }
    var canContinueFromProfile: Bool {
        // MVP: name + email + at least one property type recommended but not required
        !data.fullName.isEmpty && !data.email.isEmpty
    }

    var body: some View {
        NavigationStack(path: $path) {
            screen1
                .navigationDestination(for: Int.self) { step in
                    switch step {
                    case 2: screen2
                    case 3: screen3
                    case 4: screen4
                    case 5: screen5
                    case 6: screen6
                    case 99: dashboard
                    default: screen1
                    }
                }
        }
    }

    // Screen 1
    private var screen1: some View {
        VStack(spacing: 16) {
            WelcomeReferralView(data: $data)

            PrimaryButton(title: "Continue") {
                guard canContinueFromWelcome else { return }
                path.append(2)
            }
            .disabled(!canContinueFromWelcome)
        }
        .navigationTitle("Welcome")
    }

    // Screen 2
    private var screen2: some View {
        VStack(spacing: 16) {
            RoleSelectionView(data: $data)
            PrimaryButton(title: "Continue") {
                guard canContinueFromRole else { return }
                path.append(3)
            }
            .disabled(!canContinueFromRole)
            .padding(16)
        }
        .navigationTitle("Role")
    }

    // Screen 3
    private var screen3: some View {
        VStack(spacing: 16) {
            ProfilePropertyView(data: $data)
            PrimaryButton(title: "Continue") {
                guard canContinueFromProfile else { return }
                path.append(4)
            }
            .disabled(!canContinueFromProfile)
            .padding(16)
        }
        .navigationTitle("Profile")
    }

    // Screen 4
    private var screen4: some View {
        VStack(spacing: 16) {
            BudgetRoleView(data: $data)
            PrimaryButton(title: "Continue") {
                path.append(5)
            }
            .padding(16)
        }
        .navigationTitle("Budget")
    }

    // Screen 5
    private var screen5: some View {
        VStack(spacing: 16) {
            PreferencesView(data: $data)
            PrimaryButton(title: "Save & Finish") {
                path.append(6)
            }
            .padding(16)
        }
        .navigationTitle("Preferences")
    }

    // Screen 6
    private var screen6: some View {
        VStack(spacing: 16) {
            ReviewConfirmView(data: $data)
            PrimaryButton(title: "Go to Dashboard") {
                path.append(99)
            }
            .padding(16)
        }
        .navigationTitle("Review")
    }

    // Dashboard
    private var dashboard: some View {
        DashboardView(name: data.fullName, avatarData: data.selectedImageData)
    }
}
//
//  OnboardingCoordinator.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/12/25.
//

