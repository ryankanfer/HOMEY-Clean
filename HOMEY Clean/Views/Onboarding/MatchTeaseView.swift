import SwiftUI

struct MatchTeaseView: View {
    @State private var showCards: Bool = false
    @State private var currentCardIndex: Int = 0
    var onComplete: () -> Void

    // Mock property data for teaser
    private let properties: [PropertyTease] = [
        .init(
            address: "123 Park Avenue",
            neighborhood: "Upper East Side",
            price: "$3,200/mo",
            bedrooms: 2,
            bathrooms: 1,
            imageGradient: [Color(red: 0.3, green: 0.5, blue: 0.7), Color(red: 0.2, green: 0.3, blue: 0.5)]
        ),
        .init(
            address: "456 Broadway",
            neighborhood: "SoHo",
            price: "$4,500/mo",
            bedrooms: 3,
            bathrooms: 2,
            imageGradient: [Color(red: 0.6, green: 0.4, blue: 0.5), Color(red: 0.4, green: 0.2, blue: 0.3)]
        ),
        .init(
            address: "789 Fifth Ave",
            neighborhood: "Midtown",
            price: "$5,200/mo",
            bedrooms: 2,
            bathrooms: 2,
            imageGradient: [Color(red: 0.5, green: 0.6, blue: 0.4), Color(red: 0.3, green: 0.4, blue: 0.2)]
        )
    ]

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
                // Header
                VStack(spacing: 16) {
                    // Animated checkmark
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(showCards ? 1.0 : 0.8)
                    .opacity(showCards ? 1.0 : 0.0)

                    VStack(spacing: 8) {
                        Text("You're all set!")
                            .font(.custom("PlayfairDisplay-Regular", size: 36))
                            .foregroundStyle(.white)

                        Text("Here's a sneak peek at your matches")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Property cards stack
                ZStack {
                    ForEach(properties.indices, id: \.self) { index in
                        PropertyCard(property: properties[index])
                            .offset(y: CGFloat(index) * 20)
                            .scaleEffect(1.0 - CGFloat(index) * 0.05)
                            .opacity(showCards ? (index < 3 ? 1.0 : 0.0) : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: showCards)
                            .zIndex(Double(properties.count - index))
                    }
                }
                .frame(height: 400)
                .padding(.horizontal, 20)

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        onComplete()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Start Exploring")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .foregroundStyle(.black)
                        .cornerRadius(16)
                    }

                    Text("We found \(properties.count)+ homes that match your vibe")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .opacity(showCards ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.3).delay(0.5), value: showCards)
            }
        }
        .onAppear {
            // Trigger animations
            withAnimation {
                showCards = true
            }
        }
    }
}

// MARK: - Property Card

private struct PropertyCard: View {
    let property: PropertyTease

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder with gradient
            LinearGradient(
                colors: property.imageGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 240)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        // Like button
                        Circle()
                            .fill(.white.opacity(0.9))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "heart")
                                    .font(.title3)
                                    .foregroundStyle(.black)
                            )
                            .padding(16)
                    }
                }
            )

            // Property details
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.address)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(property.neighborhood)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack(spacing: 16) {
                    Label("\(property.bedrooms) bd", systemImage: "bed.double")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    Label("\(property.bathrooms) ba", systemImage: "shower")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Text(property.price)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}

// MARK: - Property Tease Model

struct PropertyTease {
    let address: String
    let neighborhood: String
    let price: String
    let bedrooms: Int
    let bathrooms: Int
    let imageGradient: [Color]
}
