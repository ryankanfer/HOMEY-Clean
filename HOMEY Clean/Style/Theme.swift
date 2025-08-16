import SwiftUI

struct Theme {
    let top: Color
    let bottom: Color
    let accent: Color
}

func theme(for kind: HomeyKind) -> Theme {
    switch kind {
    case .charlie:
        return .init(top: Color(#colorLiteral(red:0.94, green:0.96, blue:1.00, alpha:1)),
                     bottom: Color(#colorLiteral(red:0.86, green:0.91, blue:1.00, alpha:1)),
                     accent: .blue)
    case .paige:
        return .init(top: Color.purple.opacity(0.18),
                     bottom: Color.indigo.opacity(0.14),
                     accent: .purple)
    case .scout:
        return .init(top: Color.green.opacity(0.16),
                     bottom: Color.teal.opacity(0.14),
                     accent: .green)
    case .isla:
        return .init(top: Color.orange.opacity(0.14),
                     bottom: Color.yellow.opacity(0.14),
                     accent: .orange)
    case .viza:
        return .init(top: Color.pink.opacity(0.16),
                     bottom: Color.gray.opacity(0.10),
                     accent: .pink)
    case .drew:
        return .init(top: Color.gray.opacity(0.14),
                     bottom: Color.gray.opacity(0.10),
                     accent: .mint)
    }
}

struct GradientBackground: View {
    let theme: Theme
    @State private var animate = false

    var body: some View {
        LinearGradient(colors: [theme.top, theme.bottom],
                       startPoint: animate ? .topLeading : .top,
                       endPoint: animate ? .bottomTrailing : .bottom)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

struct HeroHeader: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name).font(.largeTitle.bold()).foregroundStyle(.primary)
            Text(subtitle).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

