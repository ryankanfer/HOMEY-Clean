//
//  BudgetStepView.swift
//  HOMEY Clean
//
//  Budget step view for mandatory onboarding flow
//

import SwiftUI

struct BudgetStepView: View {
    @Binding var data: [String: String]
    @State private var budgetMode: BudgetMode = .rent
    @State private var budgetAmount: Double = 3000
    
    enum BudgetMode: String, CaseIterable {
        case rent = "rent"
        case buy = "buy"
        
        var title: String {
            switch self {
            case .rent: return "Monthly Rent"
            case .buy: return "Purchase Price"
            }
        }
        
        var range: ClosedRange<Double> {
            switch self {
            case .rent: return 1000...10000
            case .buy: return 200000...3000000
            }
        }
        
        var step: Double {
            switch self {
            case .rent: return 100
            case .buy: return 25000
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your budget?")
                    .font(.title.bold())
                    .foregroundColor(.primary)
                
                Text("Help us show you the right properties")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                Picker("Budget Type", selection: $budgetMode) {
                    Text("Monthly Rent").tag(BudgetMode.rent)
                    Text("Purchase Price").tag(BudgetMode.buy)
                }
                .pickerStyle(.segmented)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(budgetMode.title)
                            .font(.headline)
                        Spacer()
                        Text(formatCurrency(budgetAmount))
                            .font(.headline.bold())
                            .foregroundColor(.blue)
                    }
                    
                    Slider(
                        value: $budgetAmount,
                        in: budgetMode.range,
                        step: budgetMode.step
                    )
                    .tint(.blue)
                    
                    HStack {
                        Text(formatCurrency(budgetMode.range.lowerBound))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatCurrency(budgetMode.range.upperBound))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            loadBudgetData()
        }
        .onChange(of: budgetMode) { _ in
            saveBudgetData()
        }
        .onChange(of: budgetAmount) { _ in
            saveBudgetData()
        }
    }
    
    private func loadBudgetData() {
        if let modeString = data["budget_mode"], let mode = BudgetMode(rawValue: modeString) {
            budgetMode = mode
        }
        if let amountString = data["budget_amount"], let amount = Double(amountString) {
            budgetAmount = amount
        }
    }
    
    private func saveBudgetData() {
        data["budget_mode"] = budgetMode.rawValue
        data["budget_amount"] = String(budgetAmount)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}