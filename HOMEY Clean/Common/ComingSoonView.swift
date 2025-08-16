//
//  ComingSoonView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/16/25.
//


import SwiftUI

public struct ComingSoonView: View {
    public let featureTitle: String
    public let subtitle: String
    public var action: (() -> Void)?

    public init(
        featureTitle: String = "Coming soon",
        subtitle: String = "We’re building this now. Check back shortly.",
        action: (() -> Void)? = nil
    ) {
        self.featureTitle = featureTitle
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .semibold))
                .accessibilityHidden(true)

            Text(featureTitle)
                .font(.title2).fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let action {
                Button("Notify me") { action() }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
