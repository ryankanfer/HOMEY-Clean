import SwiftUI

struct LivePanelCard: View {
    enum LiveContentType {
        case agent, client, listings
    }

    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let liveContent: LiveContentType

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 10)

            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Text(title)
                    .font(.title3.bold())
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(Theme.textMuted)

                liveContentView()
                    .padding(.top, 6)
            }
            .padding(16)

            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.ultraThinMaterial)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(color)
                )
                .shadow(radius: 2)
                .offset(x: 84, y: 48)
                .allowsHitTesting(false)
        }
        .frame(height: 160)
    }

    @ViewBuilder
    private func liveContentView() -> some View {
        switch liveContent {
        case .agent: AgentLiveContent()
        case .client: ClientLiveContent()
        case .listings: ListingsLiveContent()
        }
    }
}
