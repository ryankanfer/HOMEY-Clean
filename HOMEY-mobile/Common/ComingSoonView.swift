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
        ZStack {
            LinearGradient(colors: [Theme.background, Theme.surface], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .semibold))
                    .accessibilityHidden(true)

                Text(featureTitle)
                    .font(.title2).fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)

                if let action {
                    Button("Notify me") { action() }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .padScreen()
        .navigationTitle("Coming Soon")
    }
}