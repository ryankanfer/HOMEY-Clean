import SwiftUI

struct BudgetTimelineView: View {
    @State private var budgetMin: Double = 1000
    @State private var budgetMax: Double = 3000
    @State private var selectedTimeline: String = "3-months"

    var isBuyer: Bool
    var onNext: (BudgetTimelineData) -> Void

    private let buyerBudgetRange: ClosedRange<Double> = 200_000...5_000_000
    private let renterBudgetRange: ClosedRange<Double> = 500...10_000

    private let buyerTimelines: [(id: String, title: String, subtitle: String)] = [
        ("asap", "ASAP", "Ready to move now"),
        ("1-month", "1 Month", "Within 30 days"),
        ("3-months", "3 Months", "Next quarter"),
        ("6-months", "6 Months", "Planning ahead"),
        ("just-looking", "Just Looking", "Exploring options")
    ]

    private let renterTimelines: [(id: String, title: String, subtitle: String)] = [
        ("asap", "ASAP", "Need to move now"),
        ("1-month", "1 Month", "Within 30 days"),
        ("2-months", "2 Months", "Before lease ends"),
        ("3-months", "3+ Months", "Planning ahead"),
        ("just-looking", "Just Browsing", "No rush")
    ]

    private var budgetRange: ClosedRange<Double> {
        isBuyer ? buyerBudgetRange : renterBudgetRange
    }

    private var timelines: [(id: String, title: String, subtitle: String)] {
        isBuyer ? buyerTimelines : renterTimelines
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 12) {
                        Text(isBuyer ? "Let's talk numbers." : "Set your monthly range.")
                            .font(.custom("PlayfairDisplay-Regular", size: 36))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text("We'll find homes that fit")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 60)

                    // Budget Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text(isBuyer ? "Purchase Budget" : "Monthly Rent Budget")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)

                        // Budget display
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Min")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                Text(formatCurrency(budgetMin))
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.white)
                            }

                            Spacer()

                            Image(systemName: "arrow.left.and.right")
                                .foregroundStyle(.white.opacity(0.4))

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Max")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                Text(formatCurrency(budgetMax))
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )

                        // Range sliders
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Minimum")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.7))

                                Slider(value: $budgetMin, in: budgetRange, step: isBuyer ? 25_000 : 100)
                                    .tint(.white)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Maximum")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.7))

                                Slider(value: $budgetMax, in: budgetRange, step: isBuyer ? 25_000 : 100)
                                    .tint(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Timeline Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Timeline")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            ForEach(timelines, id: \.id) { timeline in
                                TimelineOption(
                                    id: timeline.id,
                                    title: timeline.title,
                                    subtitle: timeline.subtitle,
                                    isSelected: selectedTimeline == timeline.id
                                ) {
                                    selectedTimeline = timeline.id
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Continue button
                    Button {
                        onNext(BudgetTimelineData(
                            budgetMin: Int(budgetMin),
                            budgetMax: Int(budgetMax),
                            timeline: selectedTimeline
                        ))
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onChange(of: budgetMin) { _, newValue in
            if newValue > budgetMax {
                budgetMax = newValue
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Timeline Option

private struct TimelineOption: View {
    let id: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .white.opacity(0.15) : .white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(isSelected ? 0.3 : 0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Data Model

struct BudgetTimelineData {
    let budgetMin: Int
    let budgetMax: Int
    let timeline: String
}
