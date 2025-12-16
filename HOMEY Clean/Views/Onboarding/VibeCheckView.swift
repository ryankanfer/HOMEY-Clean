import SwiftUI

struct VibeCheckView: View {
    @State private var selectedPreferences: Set<VibePreference> = []
    var isBuyer: Bool
    var onNext: ([String]) -> Void

    private let buyerPreferences: [VibePreference] = [
        .init(id: "outdoor", icon: "leaf", title: "Outdoor Spaces", description: "Gardens, terraces, outdoor areas"),
        .init(id: "natural-light", icon: "sun.max", title: "Natural Light", description: "Bright, sun-filled rooms"),
        .init(id: "modern", icon: "sparkles", title: "Modern Finishes", description: "Contemporary design & materials"),
        .init(id: "character", icon: "building.columns", title: "Character Features", description: "Original details & charm"),
        .init(id: "quiet", icon: "moon.zzz", title: "Peace & Quiet", description: "Low noise environment"),
        .init(id: "walkable", icon: "figure.walk", title: "Walkability", description: "Shops, cafes, transit nearby"),
        .init(id: "storage", icon: "shippingbox", title: "Storage Space", description: "Closets, basement, attic"),
        .init(id: "kitchen", icon: "fork.knife", title: "Chef's Kitchen", description: "High-end appliances & space")
    ]

    private let renterPreferences: [VibePreference] = [
        .init(id: "outdoor", icon: "leaf", title: "Outdoor Access", description: "Patio, balcony, or yard"),
        .init(id: "natural-light", icon: "sun.max", title: "Bright Spaces", description: "Well-lit rooms"),
        .init(id: "location", icon: "map", title: "Great Location", description: "Near work, transit, or amenities"),
        .init(id: "modern", icon: "sparkles", title: "Updated Interior", description: "Renovated or modern"),
        .init(id: "quiet", icon: "moon.zzz", title: "Quiet", description: "Peaceful environment"),
        .init(id: "pet-friendly", icon: "pawprint", title: "Pet-Friendly", description: "Allows pets"),
        .init(id: "laundry", icon: "washer", title: "In-Unit Laundry", description: "Washer/dryer in apartment"),
        .init(id: "parking", icon: "car", title: "Parking", description: "Dedicated parking spot")
    ]

    private var preferences: [VibePreference] {
        isBuyer ? buyerPreferences : renterPreferences
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
                // Header
                VStack(spacing: 12) {
                    Text("What's your vibe?")
                        .font(.custom("PlayfairDisplay-Regular", size: 36))
                        .foregroundStyle(.white)

                    Text("Select all that matter to you")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 60)
                .padding(.bottom, 32)

                // Scrollable grid of preferences
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(preferences) { pref in
                            PreferenceCard(
                                preference: pref,
                                isSelected: selectedPreferences.contains(pref)
                            ) {
                                if selectedPreferences.contains(pref) {
                                    selectedPreferences.remove(pref)
                                } else {
                                    selectedPreferences.insert(pref)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }

                Spacer()

                // Continue button
                if !selectedPreferences.isEmpty {
                    Button {
                        onNext(Array(selectedPreferences.map { $0.id }))
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
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
    }
}

// MARK: - Preference Card

private struct PreferenceCard: View {
    let preference: VibePreference
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: preference.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.7))

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                Text(preference.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(preference.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .white.opacity(0.2) : .white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? .white.opacity(0.4) : .white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Vibe Preference Model

struct VibePreference: Identifiable, Hashable {
    let id: String
    let icon: String
    let title: String
    let description: String
}
