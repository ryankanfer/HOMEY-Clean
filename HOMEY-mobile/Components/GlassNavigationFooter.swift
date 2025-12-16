import SwiftUI

struct GlassNavigationFooter: View {
    @Binding var selectedTab: NavigationTab

    var body: some View {
        CustomNavigationFooter(selectedTab: $selectedTab)
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
    case vision = "Vision"

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
        case .vision:
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
        case .vision:
            return "Viza's Studio"
        }
    }
    
    var homeyKind: HomeyKind {
        switch self {
        case .directory:
            return .drew
        case .papers:
            return .paige
        case .journey:
            return .charlie
        case .home:
            return .charlie
        case .search:
            return .scout
        case .insights:
            return .isla
        case .vision:
            return .viza
        }
    }
}