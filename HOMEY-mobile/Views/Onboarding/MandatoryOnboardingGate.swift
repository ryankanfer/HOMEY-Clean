//
//  MandatoryOnboardingGate.swift
//  HOMEY Clean
//
//  UI blocking component that enforces mandatory onboarding completion
//

import SwiftUI

struct MandatoryOnboardingGate: View {
    @ObservedObject private var onboardingManager = OnboardingStateManager.shared
    
    var body: some View {
        ZStack {
            // The RootView decides when to show this gate.
            // This view's only job is to present the onboarding flow.
            // If the manager is still loading the state from the initial
            // setup in RootView, we show a loading indicator.
            if onboardingManager.isLoading {
                LoadingView()
            } else {
                // Once loading is done, present the full-screen mandatory flow.
                MandatoryOnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: onboardingManager.isLoading)
    }
}

// MARK: - Mandatory Onboarding View

struct MandatoryOnboardingView: View {
    @EnvironmentObject private var session: AppSessionManager
    @ObservedObject private var onboardingManager = OnboardingStateManager.shared
    @State private var attemptedToEscape = false

    var body: some View {
        ZStack {
            // Web app-style onboarding flow
            WebAppOnboardingFlow()
                .environmentObject(session)
                .disabled(onboardingManager.isLoading)

            // Loading overlay
            if onboardingManager.isLoading {
                LoadingOverlay()
            }
        }
    }
}

// MARK: - Onboarding Header

struct OnboardingHeader: View {
    @ObservedObject private var onboardingManager = OnboardingStateManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // App logo/branding
            HStack {
                Image(systemName: "house.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text("HOMEY")
                    .font(.title.bold())
                    .foregroundColor(.primary)
            }
            .padding(.top, 20)
            
            // Progress indicator
            OnboardingProgressBar(
                progress: onboardingManager.getProgress(),
                currentStep: onboardingManager.currentStepIndex + 1,
                totalSteps: onboardingManager.steps.count
            )
            
            // Required completion message
            VStack(spacing: 8) {
                Text("Complete Setup Required")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Please complete all steps to access your HOMEY account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let progress: Double
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
            
            // Step counter
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))% Complete")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Text("Setting up your account...")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Escape Attempt Warning

struct EscapeAttemptWarning: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Setup Required")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("You must complete the setup process to access HOMEY. This ensures the best experience for finding your perfect home.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Continue Setup") {
                onDismiss()
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

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("HOMEY")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Text("Preparing your experience...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MandatoryOnboardingGate()
}