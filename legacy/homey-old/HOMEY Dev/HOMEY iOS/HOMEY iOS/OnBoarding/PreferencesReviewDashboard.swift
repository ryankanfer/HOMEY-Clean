//
//  PreferencesReviewDashboard.swift
//

import SwiftUI

// MARK: - Screen 5: Must-Haves & Preferences
struct PreferencesView: View {
    @Binding var data: OnboardingData

    var body: some View {
        VStack(spacing: 16) {
            CardSection(title: "Must-haves") {
                Toggle("Pets allowed", isOn: Binding(
                    get: { data.mustHaves.contains(.pets) },
                    set: { isOn in if isOn { data.mustHaves.insert(.pets) } else { data.mustHaves.remove(.pets) } }
                ))
                Toggle("Laundry", isOn: Binding(
                    get: { data.mustHaves.contains(.laundry) },
                    set: { isOn in if isOn { data.mustHaves.insert(.laundry) } else { data.mustHaves.remove(.laundry) } }
                ))
                Toggle("Outdoor space", isOn: Binding(
                    get: { data.mustHaves.contains(.outdoor) },
                    set: { isOn in if isOn { data.mustHaves.insert(.outdoor) } else { data.mustHaves.remove(.outdoor) } }
                ))
                Toggle("Elevator", isOn: Binding(
                    get: { data.mustHaves.contains(.elevator) },
                    set: { isOn in if isOn { data.mustHaves.insert(.elevator) } else { data.mustHaves.remove(.elevator) } }
                ))
                Toggle("Doorman", isOn: Binding(
                    get: { data.mustHaves.contains(.doorman) },
                    set: { isOn in if isOn { data.mustHaves.insert(.doorman) } else { data.mustHaves.remove(.doorman) } }
                ))
                Toggle("Walk-up is fine", isOn: Binding(
                    get: { data.mustHaves.contains(.walkUpOK) },
                    set: { isOn in if isOn { data.mustHaves.insert(.walkUpOK) } else { data.mustHaves.remove(.walkUpOK) } }
                ))
            }

            Spacer()
        }
        .padding(16)
    }
}

// MARK: - Screen 6: Review & Confirm
struct ReviewConfirmView: View {
    @Binding var data: OnboardingData
    @State private var showLottie: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard

                PrimaryButton(title: "Confirm Profile") {
                    withAnimation { showLottie = true }
                    NotificationManager.shared.schedule24hNudge(name: data.fullName)
                    // In a real app, save to backend then route to dashboard.
                }

                if showLottie {
                    LottieCheck()
                        .padding(.top, 12)
                }
            }
            .padding(16)
        }
    }

    private var summaryCard: some View {
        CardSection(title: "Review") {
            Group {
                row("Name", data.fullName)
                row("Email", data.email)
                row("Phone", data.phone)
                row("City", data.city)
                row("Role", data.role?.rawValue ?? "")
                row("Neighborhoods", data.neighborhoods.sorted().joined(separator: ", "))
                row("Types", data.propertyTypes.sorted().joined(separator: ", "))
            }

            if data.role == .renter {
                row("Rent Budget", data.monthlyRentBudget.map { "$\($0)" } ?? "")
                row("Annual Income", data.renterAnnualIncome.map { "$\($0)" } ?? "")
                if data.hasGuarantor {
                    row("Guarantor Income", data.guarantorAnnualIncome.map { "$\($0)" } ?? "")
                }
            }

            if data.role == .buyer {
                row("Buy Budget", data.totalBuyBudget.map { "$\($0)" } ?? "")
                row("Pre-Approved", (data.isPreApproved ?? false) ? "Yes" : "No/Unsure")
                row("First-time", (data.firstTimeBuyer ?? false) ? "Yes" : "No")
            }

            row("Must-haves", mustHaveText(data.mustHaves))
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.subheadline.weight(.semibold))
            Spacer()
            Text(value.isEmpty ? "—" : value).foregroundStyle(.secondary)
        }
    }

    private func mustHaveText(_ set: MustHaves) -> String {
        var arr: [String] = []
        if set.contains(.pets) { arr.append("Pets") }
        if set.contains(.laundry) { arr.append("Laundry") }
        if set.contains(.outdoor) { arr.append("Outdoor") }
        if set.contains(.elevator) { arr.append("Elevator") }
        if set.contains(.doorman) { arr.append("Doorman") }
        if set.contains(.walkUpOK) { arr.append("Walk-up OK") }
        return arr.isEmpty ? "—" : arr.joined(separator: ", ")
    }
}

// MARK: - Dashboard (MVP)
struct DashboardView: View {
    let name: String
    let avatarData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        if let data = avatarData, let ui = UIImage(data: data) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 54, height: 54)
                                .clipShape(Circle())
                        } else {
                            Circle().fill(Color.secondary.opacity(0.15))
                                .frame(width: 54, height: 54)
                                .overlay(Image(systemName: "person.fill"))
                        }
                        VStack(alignment: .leading) {
                            Text("Welcome, \(name.isEmpty ? "Homey user" : name)")
                                .font(.title3.weight(.bold))
                            Text("Your Homeys are standing by.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    CardSection(title: "Charlie’s Corner") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Matches preview — coming soon")
                                .font(.subheadline)
                            // Placeholder grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                                ForEach(0..<6) { _ in
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.secondary.opacity(0.12))
                                        .frame(height: 80)
                                        .overlay(Text("Coming\nSoon").font(.caption).multilineTextAlignment(.center).foregroundStyle(.secondary))
                                }
                            }
                        }
                    }

                    CardSection(title: "Keep going") {
                        Text("Option to continue onboarding for better personalization.")
                        NavigationLink("Add timeline & more must-haves") {
                            Text("Future onboarding expansion").padding()
                        }
                    }

                    CardSection(title: "Reminders") {
                        Text("Charlie will nudge you in 24 hours if you haven’t finished setup.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Dashboard")
        }
    }
}
//
//  PreferencesReviewDashboard.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/12/25.
//