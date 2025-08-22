//
//  CategoryCard.swift
//  HOMEY Clean
//
//  Frosted glass category cards for the Document Vault
//

import SwiftUI

struct CategoryCard: View {
    let category: DocumentCategory
    let action: () -> Void

    @State private var isPressed = false
    @State private var showConfetti = false
    @State private var pulseRed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var iconSection: some View {
        ZStack {
            // Glow ring for category color
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            category.color.opacity(0.35),
                            category.color.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 40
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(isPressed ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)

            // Icon background
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )

            // SF Symbol icon
            Image(systemName: category.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(category.color)
                .symbolRenderingMode(.hierarchical)

            // Lock indicator for locked items
            if category.isLocked {
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 4))
                                    .foregroundColor(.white)
                            )
                    }
                    Spacer()
                }
                .frame(width: 48, height: 48)
            }
        }
    }

    private var categoryInfoSection: some View {
        VStack(spacing: 4) {
            Text(category.name)
                .font(.custom("Lato-Regular", size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            HStack(spacing: 8) {
                Text("\(Int(category.progress * 100))%")
                    .font(.custom("Lato-Regular", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(category.color)
                    .monospacedDigit()

                Text("•")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)

                Text("\(category.documentCount) docs")
                    .font(.custom("Lato-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var progressBarSection: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white.opacity(0.18))
                .frame(height: 4)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [category.color, category.color.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(4, category.progress * 120), height: 4)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: category.progress)
        }
        .frame(maxWidth: 120)
    }

    private var cardContent: some View {
        VStack(spacing: 12) {
            iconSection
            categoryInfoSection
            progressBarSection
        }
        .padding(16)
        .frame(width: 160, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            category.color.opacity(0.15),
                            category.color.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    category.color.opacity(0.3),
                                    category.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    var body: some View {
        Button(action: action) {
            cardContent
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                // Red halo pulse for missing critical docs
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            .red.opacity(pulseRed ? 0.6 : 0.0),
                            lineWidth: 2
                        )
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: pulseRed
                        )
                        .opacity(category.isCritical && category.progress < 0.5 ? 1 : 0)
                )

                // Confetti overlay for completion
                .overlay(
                    ConfettiView()
                        .opacity(showConfetti ? 1 : 0)
                        .allowsHitTesting(false)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            // Start red halo pulse for critical missing docs
            if category.isCritical && category.progress < 0.5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0 ... 8)) {
                    pulseRed = true
                }
            }

            // Show confetti for completed categories
            if category.progress >= 0.9 && !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showConfetti = false
                    }
                }
            }
        }
    }
}
