import SwiftUI

struct SimplifiedProfileView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var router: AppRouter
    
    let closeDrawerAction: () -> Void
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var budget: String = ""
    @State private var neighborhood: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: closeDrawerAction) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 10)
                
                // Profile Header
                VStack(alignment: .center, spacing: 16) {
                    // Profile Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(fullName.isEmpty ? "Demo User" : fullName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(email.isEmpty ? "demo@homey.com" : email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                // Budget Info
                profileSection(
                    title: "Your Budget",
                    value: budget.isEmpty ? "$4,000" : budget,
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                // Neighborhood Info
                profileSection(
                    title: "Preferred Area",
                    value: neighborhood.isEmpty ? "Williamsburg" : neighborhood,
                    icon: "location.fill",
                    color: .blue
                )
                
                // Contact Agent Button
                Button(action: {
                    closeDrawerAction()
                    // Navigate to full profile for agent contact
                    router.route = .profile
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Contact Your Agent")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                
                // Favorites Button
                Button(action: {
                    closeDrawerAction()
                    // Navigate to search with favorites filter
                    router.route = .search
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Your Favorites")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.pink.opacity(0.1))
                    .foregroundColor(.pink)
                    .cornerRadius(12)
                }
                
                // Full Profile Button
                Button(action: {
                    closeDrawerAction()
                    // Navigate to full profile page
                    router.route = .profile
                }) {
                    HStack {
                        Image(systemName: "person.fill.badge.plus")
                        Text("View Full Profile")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    private func profileSection(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func loadUserProfile() {
        // In a real app, this would fetch from a service
        // For now, we'll use placeholder data
        fullName = "Demo User"
        email = "demo@homey.com"
        budget = "$4,000"
        neighborhood = "Williamsburg"
    }
}

struct SimplifiedProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SimplifiedProfileView(closeDrawerAction: {})
            .environmentObject(AppSessionManager.shared)
            .environmentObject(AppRouter())
    }
}
