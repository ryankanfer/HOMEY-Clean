import SwiftUI

struct OnboardingCardStack: View {
    var onDone: () -> Void

    @State private var index: Int = 0

    private struct Card: Identifiable {
        let id = UUID()
        let number: String
        let title: String
        let desc: String
        let cta: String
    }

    private let cards: [Card] = [
        .init(number: "01", title: "Tell us how you live", desc: "Share your vision with HOMEY—we understand exactly what you're looking for.", cta: "Swipe to continue →"),
        .init(number: "02", title: "Browse live NYC listings", desc: "We connect you to StreetEasy's real-time inventory across all neighborhoods.", cta: "Swipe to continue →"),
        .init(number: "03", title: "Track everything in HOMEY", desc: "Save favorites—we'll organize notes, next steps, and keep your search on track.", cta: "Begin search →")
    ]

    // Layout constants
    private let cardWidth: CGFloat = 340
    private let cardHeight: CGFloat = 420
    private let maxVisibleDepth: Int = 3
    private let scaleStep: CGFloat = 0.05
    private let yOffsetStep: CGFloat = 20

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.04, blue: 0.18),
                    Color(red: 0.06, green: 0.02, blue: 0.08)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text("HOMEY")
                        .font(.caption.weight(.semibold))
                        .kerning(3)
                        .opacity(0.6)

                    Text("Find your\nnext home")
                        .font(.system(size: 44, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Swipe to explore")
                        .font(.subheadline)
                        .opacity(0.6)
                }
                .padding(.top, 60)
                .padding(.bottom, 20)

                ZStack {
                    ForEach(0..<cards.count, id: \.self) { i in
                        let depth = max(0, i - index)
                        if i >= index && depth < maxVisibleDepth {
                            let c = cards[i]
                            onboardingCard(c)
                                .frame(width: cardWidth, height: cardHeight)
                                .scaleEffect(1.0 - CGFloat(depth) * scaleStep, anchor: .center)
                                .offset(y: CGFloat(depth) * yOffsetStep)
                                .opacity(1.0 - Double(depth) * 0.25)
                                .zIndex(Double(cards.count - i))
                                .allowsHitTesting(i == index)
                                .accessibilityHidden(i != index)
                                .animation(.spring(response: 0.5, dampingFraction: 0.9), value: index)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight + CGFloat(maxVisibleDepth - 1) * yOffsetStep + 8)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            if value.translation.width < -40 || value.translation.height < -40 {
                                advance()
                            } else if value.translation.width > 40 || value.translation.height > 40 {
                                retreat()
                            }
                        }
                )

                HStack(spacing: 8) {
                    ForEach(0..<cards.count, id: \.self) { i in
                        Capsule()
                            .fill(i == index ? Color.blue : Color.white.opacity(0.3))
                            .frame(width: i == index ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: index)
                    }
                }
                .padding(.top, 24)

                Spacer()

                Button("Done") { onDone() }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 12)
        }
    }

    @ViewBuilder
    private func onboardingCard(_ card: Card) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(card.number)
                .font(.system(size: 72, weight: .black))
                .opacity(0.12)

            Text(card.title)
                .font(.title2.weight(.bold))
                .lineLimit(2)

            Text(card.desc)
                .font(.body)
                .opacity(0.75)

            Spacer()

            Text(card.cta)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2)))
                .cornerRadius(16)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.1)))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }

    private func advance() {
        if index < cards.count - 1 {
            index += 1
        } else {
            onDone()
        }
    }

    private func retreat() {
        if index > 0 {
            index -= 1
        }
    }
}