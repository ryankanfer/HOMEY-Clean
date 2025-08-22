import SwiftUI

struct GlassNavigationFooter: View {
    @Binding var selectedTab: NavigationTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NavigationTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                                .scaleEffect(selectedTab == tab ? 1.1 : 1.0)

                            Text(tab.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                        }
                        .frame(width: 80)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedTab == tab ?
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedTab == tab ?
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.4),
                                                        Color.white.opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    colors: [Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                            lineWidth: selectedTab == tab ? 1 : 0
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 34) // Account for home indicator
    }
}

// MARK: - Navigation Tab Model

enum NavigationTab: String, CaseIterable {
    case directory = "Directory"
    case papers = "Papers"
    case journey = "Journey"
    case home = "Home"
    case search = "Search"
    case insights = "Insights"
    case style = "Style"

    var title: String {
        return rawValue
    }

    var icon: String {
        switch self {
        case .directory:
            return "folder.fill"
        case .papers:
            return "doc.fill"
        case .journey:
            return "map.fill"
        case .home:
            return "house.fill"
        case .search:
            return "magnifyingglass"
        case .insights:
            return "chart.bar.fill"
        case .style:
            return "paintbrush.fill"
        }
    }

    var destination: String {
        switch self {
        case .directory:
            return "Directory"
        case .papers:
            return "Paige's Office"
        case .journey:
            return "Charlie's Journey Guide"
        case .home:
            return "Home"
        case .search:
            return "Scout's Room"
        case .insights:
            return "Insights Dashboard"
        case .style:
            return "Viza's Studio"
        }
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            Spacer()
            GlassNavigationFooter(selectedTab: .constant(.journey))
        }
    }
}
