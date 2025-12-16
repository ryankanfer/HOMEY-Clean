import SwiftUI

struct ThisOrThatView: View {
    @State private var currentQuestionIndex: Int = 0
    @State private var answers: [String: String] = [:]
    var isBuyer: Bool
    var onComplete: ([String: String]) -> Void

    private let buyerQuestions: [ThisOrThatQuestion] = [
        .init(
            id: "view",
            question: "What's more important?",
            optionA: .init(icon: "mountain.2", title: "Amazing View", description: "Scenic overlook"),
            optionB: .init(icon: "figure.walk", title: "Walkable Area", description: "Everything nearby")
        ),
        .init(
            id: "space",
            question: "Which would you choose?",
            optionA: .init(icon: "square.split.2x2", title: "More Rooms", description: "Extra bedroom/office"),
            optionB: .init(icon: "arrow.up.left.and.arrow.down.right", title: "Bigger Rooms", description: "Spacious living areas")
        ),
        .init(
            id: "style",
            question: "Your aesthetic preference?",
            optionA: .init(icon: "building.columns", title: "Classic Charm", description: "Historic details"),
            optionB: .init(icon: "sparkles", title: "Modern Sleek", description: "Contemporary design")
        ),
        .init(
            id: "outdoor",
            question: "Outdoor priority?",
            optionA: .init(icon: "leaf", title: "Private Yard", description: "Your own green space"),
            optionB: .init(icon: "figure.pool.swim", title: "Shared Amenities", description: "Pool, gym, rooftop")
        )
    ]

    private let renterQuestions: [ThisOrThatQuestion] = [
        .init(
            id: "location",
            question: "What matters more?",
            optionA: .init(icon: "building.2", title: "Great Location", description: "Heart of the action"),
            optionB: .init(icon: "dollarsign.circle", title: "Lower Rent", description: "Save money monthly")
        ),
        .init(
            id: "amenities",
            question: "Which would you prefer?",
            optionA: .init(icon: "washer", title: "In-Unit Laundry", description: "Washer/dryer in apartment"),
            optionB: .init(icon: "figure.pool.swim", title: "Building Gym", description: "Fitness center access")
        ),
        .init(
            id: "space",
            question: "Space preference?",
            optionA: .init(icon: "bed.double", title: "Extra Bedroom", description: "More rooms"),
            optionB: .init(icon: "sofa", title: "Bigger Living Room", description: "Spacious common area")
        ),
        .init(
            id: "outdoor",
            question: "Outdoor space?",
            optionA: .init(icon: "leaf", title: "Private Balcony", description: "Your own outdoor spot"),
            optionB: .init(icon: "building", title: "Rooftop Access", description: "Shared rooftop terrace")
        )
    ]

    private var questions: [ThisOrThatQuestion] {
        isBuyer ? buyerQuestions : renterQuestions
    }

    private var currentQuestion: ThisOrThatQuestion {
        questions[currentQuestionIndex]
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

            VStack(spacing: 0) {
                // Progress
                HStack(spacing: 8) {
                    ForEach(questions.indices, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentQuestionIndex ? Color.white : Color.white.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 32)

                // Question
                VStack(spacing: 8) {
                    Text(currentQuestion.question)
                        .font(.custom("PlayfairDisplay-Regular", size: 32))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Tap to choose")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)

                // Options
                VStack(spacing: 20) {
                    // Option A
                    OptionCard(
                        option: currentQuestion.optionA,
                        onTap: {
                            selectOption("A")
                        }
                    )

                    // VS Divider
                    Text("or")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.vertical, 8)

                    // Option B
                    OptionCard(
                        option: currentQuestion.optionB,
                        onTap: {
                            selectOption("B")
                        }
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private func selectOption(_ choice: String) {
        // Save answer
        answers[currentQuestion.id] = choice

        // Move to next question or complete
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentQuestionIndex += 1
            }
        } else {
            // All questions answered
            onComplete(answers)
        }
    }
}

// MARK: - Option Card

private struct OptionCard: View {
    let option: ThisOrThatOption
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: option.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(option.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Models

struct ThisOrThatQuestion: Identifiable {
    let id: String
    let question: String
    let optionA: ThisOrThatOption
    let optionB: ThisOrThatOption
}

struct ThisOrThatOption {
    let icon: String
    let title: String
    let description: String
}
