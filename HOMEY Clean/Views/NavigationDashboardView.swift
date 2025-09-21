import SwiftUI

struct SignatureNavigationDashboard: View {
    var body: some View {
        TabView {
            SignaturePlaceholderDashboard(title: "Directory", subtitle: "Contact Directory Coming Soon")
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Directory")
                }
                .tag(NavigationTab.directory)

            PaigeDashboard()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Papers")
                }
                .tag(NavigationTab.papers)

            CharlieDashboard()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Journey")
                }
                .tag(NavigationTab.journey)

            SignatureSceneHomepage()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(NavigationTab.home)

            SignaturePlaceholderDashboard(title: "Scout's Room", subtitle: "Property Search Coming Soon")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(NavigationTab.search)

            SignaturePlaceholderDashboard(title: "Insights Dashboard", subtitle: "Analytics Coming Soon")
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Insights")
                }
                .tag(NavigationTab.insights)

            SignaturePlaceholderDashboard(title: "Viza's Studio", subtitle: "Vision Preferences Coming Soon")
                .tabItem {
                    Image(systemName: "paintbrush.fill")
                    Text("Vision")
                }
                .tag(NavigationTab.vision)
        }
        .tint(.white)
    }
}

struct SignaturePlaceholderDashboard: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.8))

                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    SignatureNavigationDashboard()
}
