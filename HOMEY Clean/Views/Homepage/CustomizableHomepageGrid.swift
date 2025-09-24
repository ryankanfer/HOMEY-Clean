import SwiftUI

struct CustomizableHomepageGrid: View {
    var showHeader: Bool = true
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showCustomization = false
    @State private var personalizationVersion = UUID()
    
    private var selectedPages: [HomepageSection] {
        userProfileManager.currentProfile?.preferences.homepageCustomization.selectedSections ?? HomepageCustomization.defaultCustomization.selectedSections
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if showHeader {
                HStack {
                    Text("Your Homepage")
                        .font(.title2.bold())
                        .foregroundStyle(Theme.dynamicText())
                    
                    Spacer()
                    
                    Button {
                        showCustomization = true
                    } label: {
                        Label("Customize", systemImage: "slider.horizontal.3")
                            .font(.subheadline.bold())
                            .foregroundStyle(themeManager.isBlackWhite ? .black : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(Theme.dynamicPrimary())
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            )
                            .accessibilityLabel("Customize homepage")
                    }
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(selectedPages.prefix(4), id: \.self) { section in
                    HomepageGridCard(section: section)
                }
            }
        }
        .id(personalizationVersion)
        .onReceive(userProfileManager.$currentProfile) { _ in
            personalizationVersion = UUID()
        }
        .onChange(of: userProfileManager.currentProfile?.preferences.homepageCustomization) {
            personalizationVersion = UUID()
        }
        .sheet(isPresented: $showCustomization) {
            HomepageCustomizationSheet()
        }
    }
    
    struct HomepageCardInfo {
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
    }
    
    struct HomepageGridCard: View {
        let section: HomepageSection
        @EnvironmentObject private var router: AppRouter
        
        private var cardInfo: HomepageCardInfo {
            switch section {
            case .discover:
                return HomepageCardInfo(title: "Search", subtitle: "Find your perfect home", icon: "magnifyingglass", color: .blue)
            case .vault:
                return HomepageCardInfo(title: "Vault", subtitle: "Your saved documents", icon: "folder.fill", color: .purple)
            case .education:
                return HomepageCardInfo(title: "Education", subtitle: "Learn about real estate", icon: "book.fill", color: .green)
            case .directory:
                return HomepageCardInfo(title: "Directory", subtitle: "Connect with professionals", icon: "person.2.fill", color: .orange)
            case .insights:
                return HomepageCardInfo(title: "Insights", subtitle: "Market data & trends", icon: "chart.bar.fill", color: .red)
            case .vision:
                return HomepageCardInfo(title: "Vision", subtitle: "Visualize your space", icon: "paintbrush.fill", color: .pink)
            case .matchmaker:
                return HomepageCardInfo(title: "Matchmaker", subtitle: "Find your ideal match", icon: "heart.fill", color: .red)
            case .documents:
                return HomepageCardInfo(title: "Documents", subtitle: "Manage your files", icon: "doc.fill", color: .blue)
            case .scout:
                return HomepageCardInfo(title: "Scout", subtitle: "Explore neighborhoods", icon: "location.fill", color: .teal)
            case .profile:
                return HomepageCardInfo(title: "Profile", subtitle: "Manage your account", icon: "person.circle.fill", color: .gray)
            }
        }
        
        var body: some View {
            Button {
                handleCardTap()
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(cardInfo.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: cardInfo.icon)
                                .font(.headline)
                                .foregroundColor(cardInfo.color)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cardInfo.title)
                            .font(.headline.bold())
                            .foregroundStyle(Theme.dynamicText())
                        
                        Text(cardInfo.subtitle)
                            .font(.caption)
                            .foregroundStyle(Theme.dynamicTextSecondary())
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .frame(height: 120)
                .dayModeAwareLiquidGlass()
            }
            .buttonStyle(.plain)
        }
        
        private func handleCardTap() {
            switch section {
            case .discover:
                router.route = .search
            case .vault, .documents:
                router.route = .documents
            case .education:
                router.route = .education
            case .directory:
                router.route = .directory
            case .insights:
                router.route = .insights
            case .vision:
                router.route = .vision
            case .matchmaker:
                router.route = .matchmaker
            case .scout:
                break
            case .profile:
                router.route = .profile
            }
        }
    }
}

