//
//  BudgetRealityScreens.swift
//

import SwiftUI

// MARK: - Screen 4: Budget & Reality Check (Role-Specific)
struct BudgetRoleView: View {
    @Binding var data: OnboardingData
    @State private var showRenterReality: Bool = false
    @State private var tempBudgetText: String = ""
    @State private var tempIncomeText: String = ""
    @State private var tempGuarantorIncomeText: String = ""

    var isRenter: Bool { data.role == .renter }
    var isBuyer: Bool { data.role == .buyer }

    var body: some View {
        VStack(spacing: 16) {
            if isRenter {
                CardSection(title: "Rent Budget (Monthly)") {
                    TextField("e.g. 4000", text: $tempBudgetText)
                        .keyboardType(.numberPad)
                        .padding(12).background(Color.secondary.opacity(0.08)).cornerRadius(10)
                    Text("We’ll sanity-check with a quick, modular pop-up.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if isBuyer {
                CardSection(title: "Buy Budget") {
                    TextField("Total budget (e.g. 1200000)", text: Binding(
                        get: { (data.totalBuyBudget ?? 0) == 0 ? "" : String(data.totalBuyBudget ?? 0) },
                        set: { data.totalBuyBudget = Int($0) }
                    ))
                    .keyboardType(.numberPad)
                    .padding(12).background(Color.secondary.opacity(0.08)).cornerRadius(10)

                    Picker("Pre-Approved?", selection: Binding(get: { data.isPreApproved ?? false },
                                                               set: { data.isPreApproved = $0 })) {
                        Text("Yes").tag(true)
                        Text("No / Unsure").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Toggle("First-time homebuyer", isOn: Binding(get: { data.firstTimeBuyer ?? false },
                                                                 set: { data.firstTimeBuyer = $0 }))
                }

                Text("If not pre-approved, Drew can connect you with trusted lenders.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            PrimaryButton(title: "Continue") {
                if isRenter {
                    data.monthlyRentBudget = Int(tempBudgetText)
                    showRenterReality = true
                } else {
                    // Buyer just continues
                }
            }
            .disabled(isRenter && Int(tempBudgetText) == nil)
        }
        .padding(16)
        .sheet(isPresented: $showRenterReality) {
            RenterRealitySheet(data: $data,
                               tempIncomeText: $tempIncomeText,
                               tempGuarantorIncomeText: $tempGuarantorIncomeText)
                .presentationDetents([.fraction(0.75), .large])
        }
        .onAppear {
            if let b = data.monthlyRentBudget { tempBudgetText = String(b) }
        }
    }
}

// MARK: - Modular Pop-Up for Renters
struct RenterRealitySheet: View {
    @Binding var data: OnboardingData
    @Binding var tempIncomeText: String
    @Binding var tempGuarantorIncomeText: String

    @Environment(\.dismiss) private var dismiss

    var requiredIncome: Int {
        max(0, (data.monthlyRentBudget ?? 0) * 40)
    }
    var requiredGuarantorIncome: Int {
        max(0, (data.monthlyRentBudget ?? 0) * 80)
    }

    @State private var showAdjusted: Bool = false
    @State private var suggestedMonthly: Int? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reality Check")
                    .font(.title2.bold())

                Group {
                    Text("Most landlords look for gross income 40x the rent.")
                    Text("Based on your budget of $\(data.monthlyRentBudget ?? 0), your annual income should be at least $\(requiredIncome).")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                CardSection(title: "Your Annual Income") {
                    TextField("e.g. 150000", text: $tempIncomeText)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.secondary.opacity(0.08))
                        .cornerRadius(10)

                    Toggle("I have a guarantor", isOn: $data.hasGuarantor)
                    if data.hasGuarantor {
                        Text("Guarantors are often expected to earn 80x the rent.")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("Based on your budget, their income should be at least $\(requiredGuarantorIncome).")
                            .font(.caption).foregroundStyle(.secondary)

                        TextField("Guarantor Income (e.g. 300000)", text: $tempGuarantorIncomeText)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color.secondary.opacity(0.08))
                            .cornerRadius(10)
                    }
                }

                if showAdjusted, let suggested = suggestedMonthly {
                    CardSection(title: "Suggested Budget") {
                        Text("To align with the info you provided, consider a monthly rent around $\(suggested).")
                            .font(.subheadline)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                HStack {
                    Button("Skip") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Apply & Continue") {
                        let income = Int(tempIncomeText) ?? 0
                        data.renterAnnualIncome = income
                        let guarantorIncome = Int(tempGuarantorIncomeText) ?? 0
                        data.guarantorAnnualIncome = data.hasGuarantor ? guarantorIncome : nil

                        // If income doesn’t meet 40x and no adequate guarantor, suggest adjusted budget
                        let meetsIncome = income >= requiredIncome
                        let meetsGuarantor = data.hasGuarantor && guarantorIncome >= requiredGuarantorIncome

                        if !meetsIncome && !meetsGuarantor {
                            let suggested = max(0, income / 40)
                            suggestedMonthly = suggested
                            withAnimation { showAdjusted = true }
                        } else {
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
//
//  BudgetRealityScreens.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/12/25.
//

