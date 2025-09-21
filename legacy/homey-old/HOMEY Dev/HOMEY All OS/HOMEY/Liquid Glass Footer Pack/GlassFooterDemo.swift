import SwiftUI

struct GlassFooterDemo: View {
    var body: some View {
        ZStack {
            // Background to show translucency
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.quaternary)
                .frame(width: 240)
            VStack { Spacer() }
            GlassFooter(
                title: "Ask",
                ctaTitle: "Ask Charlie",
                items: [
                    .init(title: "Charlie", imageName: "charlie"),
                    .init(title: "Paige", imageName: "doc.text"),
                    .init(title: "Scout", imageName: "magnifyingglass"),
                    .init(title: "Isla", imageName: "phone"),
                    .init(title: "Viza", imageName: "heart"),
                    .init(title: "Drew", imageName: "briefcase"),
                ],
                onSelectItem: { _ in },
                onTapCTA: {}
            )
        }
    }
}
