import SwiftUI

struct CustomizableHomepageGrid: View {
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @State private var showCustomization = false
    @State private var personalizationVersion = UUID()
    
    private var selectedPages: [HomepageSection] {
        userProfileManager.currentProfile?.preferences.homepageCustomization.selectedSections ?? HomepageCustomization.defaultCustomization.selectedSections
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with customization button
            HStack {
                Text("Your Homepage")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    showCustomization = true
                } label: {
                    Label("Customize", systemImage: "slider.horizontal.3")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                        )
                }
            }
            
            // Customizable 2x2 grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(selectedPages.prefix(4), id: \.self) { section in
                    HomepageGridCard(section: section)
                }
            }
        }
        .id(personalizationVersion)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HomepageCustomizationUpdated"))) { _ in
            personalizationVersion = UUID()
        }
        .onChange(of: userProfileManager.currentProfile?.preferences.homepageCustomization) { _, _ in
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
        @EnvironmentObject private var router: DrawerRouter
        
        private var cardInfo: HomepageCardInfo {
            switch section {
            case .discover:
                return HomepageCardInfo(title: "Discover", subtitle: "Find your perfect home", icon: "magnifyingglass", color: .blue)
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
                            .foregroundColor(.white)
                        
                        Text(cardInfo.subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
        
        private func handleCardTap() {
            switch section {
            case .discover:
                // Navigate to discover/search
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToDiscover"), object: nil)
            case .vault, .documents:
                // Navigate to full page instead of modal
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToFullPage"), object: "documents")
            case .education:
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToFullPage"), object: "education")
            case .directory:
                // Navigate to full page instead of modal
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToFullPage"), object: "directory")
            case .insights:
                // Navigate to full page instead of modal
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToFullPage"), object: "insights")
            case .vision:
                // Navigate to full page instead of modal
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToFullPage"), object: "vision")
            case .matchmaker:
                // Navigate to full page instead of modal
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToFullPage"), object: "matchmaker")
            case .scout:
                // Navigate to scout/neighborhood exploration
                break
            case .profile:
                // Navigate to profile section
                break
            }
        }
    }
    
   
}