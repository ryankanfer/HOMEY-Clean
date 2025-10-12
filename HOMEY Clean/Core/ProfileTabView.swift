import SwiftUI
import UIKit

// MARK: - Main View
struct ProfileTabView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    @StateObject private var profilesRepository = ProfilesRepository()
    @StateObject private var preferencesRepository = PreferencesRepository()
    @State private var userProfile: ProfileRecord?
    @State private var userPreferences: PreferencesRecord?
    
    // UI State
    @State private var showTeachHomey = false
    @State private var showNotifications = false
    @State private var showMilestoneCelebration = false
    @State private var currentMilestone = ""
    
    var body: some View {
        ZStack {
            // 1. Time-of-day animated gradient background
            TimeOfDayGradientView()
                .ignoresSafeArea()
            
            // Subtle animated particles for depth
            ParticleFieldView()
                .opacity(0.3)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Simplified header with cozy feel
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Homebase")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black.opacity(0.85))
                        
                        Text(getGreeting())
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    // Liquid glass profile card
                    ProfileGlassCard {
                        HStack {
                            ProfileAvatarView()
                                .frame(width: 80, height: 80)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(welcomeText)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black.opacity(0.85))
                                
                                Text(profileSubtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.6))
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.caption)
                                    Text(budgetText)
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // 2. New Smart Profile Summary Section
                    SmartProfileSummaryView()
                    
                    // Personalization Controls
                    personalizationControlsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Milestone celebration overlay
            if showMilestoneCelebration {
                MilestoneCelebrationView(
                    milestone: currentMilestone,
                    isVisible: showMilestoneCelebration,
                    onComplete: { showMilestoneCelebration = false }
                )
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.loadProfile()
            loadUserProfile()
            if viewModel.needsOnboarding {
                showTeachHomey = true
            }
        }
        .sheet(isPresented: $showTeachHomey) { TeachHomeyModal() }
        .sheet(isPresented: $showNotifications) {
            NotificationsSheet(isPresented: $showNotifications, notifications: viewModel.notifications)
        }
    }
    
    // MARK: - Computed Properties for Dynamic Content
    
    private var welcomeText: String {
        if let profile = userProfile, let fullName = profile.fullName {
            return "Welcome back, \(fullName.components(separatedBy: " ").first ?? fullName)"
        }
        return "Welcome back, Demo"
    }
    
    private var profileSubtitle: String {
        if let profile = userProfile {
            let role = profile.clientSegment?.capitalized ?? "Renter"
            let neighborhood = userPreferences?.neighborhoods.first ?? "Williamsburg"
            return "\(role) in \(neighborhood)"
        }
        return "Renter in Williamsburg"
    }
    
    private var budgetText: String {
        if let budget = userPreferences?.budget {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 0
            
            if budget.min == budget.max {
                return "\(formatter.string(from: NSNumber(value: budget.max)) ?? "$\(Int(budget.max))") budget"
            } else {
                let minStr = formatter.string(from: NSNumber(value: budget.min)) ?? "$\(Int(budget.min))"
                let maxStr = formatter.string(from: NSNumber(value: budget.max)) ?? "$\(Int(budget.max))"
                return "\(minStr)-\(maxStr) budget"
            }
        }
        return "$4,000 budget"
    }
    
    // MARK: - Helper Methods
    
    private func loadUserProfile() {
        Task {
            do {
                let profile = try await profilesRepository.fetchCurrentUserProfile()
                let preferences = try await preferencesRepository.fetchCurrentUserPreferences()
                await MainActor.run {
                    self.userProfile = profile
                    self.userPreferences = preferences
                }
            } catch {
                print("Failed to load user profile or preferences: \(error)")
            }
        }
    }
    
    // MARK: - Personalization Controls
    private var personalizationControlsSection: some View {
        VStack(spacing: 16) {
            // Teach HOMEY Section
            ProfileGlassCard {
                HStack {
                    Image(systemName: "graduationcap.fill").foregroundColor(.blue).frame(width: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Teach HOMEY").font(.subheadline).fontWeight(.medium).foregroundColor(.black.opacity(0.85))
                        Text("Help HOMEY understand your preferences").font(.caption).foregroundColor(.black.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray.opacity(0.6))
                }
                .contentShape(Rectangle()).onTapGesture { showTeachHomey = true }.padding()
            }
            
            // Notifications Section
            ProfileGlassCard {
                HStack {
                    Image(systemName: "bell.fill").foregroundColor(.blue).frame(width: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications").font(.subheadline).fontWeight(.medium).foregroundColor(.black.opacity(0.85))
                        Text("Manage your alerts and updates").font(.caption).foregroundColor(.black.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray.opacity(0.6))
                }
                .contentShape(Rectangle()).onTapGesture { showNotifications = true }.padding()
            }
            
            // Privacy & Settings
            ProfileGlassCard {
                HStack {
                    Image(systemName: "lock.shield.fill").foregroundColor(.blue).frame(width: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy & Settings").font(.subheadline).fontWeight(.medium).foregroundColor(.black.opacity(0.85))
                        Text("Control your data and preferences").font(.caption).foregroundColor(.black.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray.opacity(0.6))
                }
                .contentShape(Rectangle()).onTapGesture { /* Handle navigation */ }.padding()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
}


// MARK: - Smart Profile Summary
struct SmartProfileSummaryView: View {
    private let titles = ["We’re Noticing…", "All About You", "We’re Taking Notes", "Your Best Angles", "Chef’s Notes", "From The Concierge Desk", "A Literal For You Page"]
    private let insights = [
        ProfileInsight(icon: "dollarsign.circle.fill", text: "Based on your income, you qualify for rentals up to $4,000/month.", color: .green),
        ProfileInsight(icon: "lightbulb.fill", text: "We noticed you love modern kitchens - 12 properties in your saved list feature this style.", color: .yellow),
        ProfileInsight(icon: "chart.bar.fill", text: "Your document completion puts you ahead of 78% of renters in NYC.", color: .blue)
    ]
    
    @State private var currentTitleIndex = 0
    @State private var currentInsightIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Rotating Title
            Text(titles[currentTitleIndex])
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.85))
                .id("Title\(currentTitleIndex)")
                .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .move(edge: .bottom).combined(with: .opacity)))
            
            // Insight Card
            ProfileGlassCard {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: insights[currentInsightIndex].icon)
                            .font(.title2)
                            .foregroundColor(insights[currentInsightIndex].color)
                            .frame(width: 30)
                        
                        Text(insights[currentInsightIndex].text)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.75))
                        
                        Spacer()
                    }
                }
                .padding()
                .id("Insight\(currentInsightIndex)")
                .transition(.opacity)
            }
        }
        .onAppear(perform: setupTimers)
    }
    
    private func setupTimers() {
        // Timer for rotating titles (faster)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentTitleIndex = (currentTitleIndex + 1) % titles.count
            }
        }
        
        // Timer for changing insights (slower)
        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            withAnimation(.easeIn(duration: 0.3)) {
                currentInsightIndex = (currentInsightIndex + 1) % insights.count
            }
        }
    }
}

struct ProfileInsight {
    let icon: String
    let text: String
    let color: Color
}

// MARK: - Time of Day Gradient
struct TimeOfDayGradientView: View {
    @State private var gradientAnimation = false
    
    var body: some View {
        let colors = timeOfDayColors()
        
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: gradientAnimation ? .topLeading : .bottomLeading,
                       endPoint: gradientAnimation ? .bottomTrailing : .topTrailing)
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    gradientAnimation.toggle()
                }
            }
    }
    
    private func timeOfDayColors() -> [Color] {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<8: // Sunrise
            return [Color(red: 255/255, green: 228/255, blue: 181/255), Color(red: 255/255, green: 218/255, blue: 185/255), Color(red: 240/255, green: 180/255, blue: 150/255)]
        case 8..<17: // Day
            return [Color(red: 245/255, green: 245/255, blue: 245/255), Color(red: 248/255, green: 244/255, blue: 240/255), Color.white]
        case 17..<20: // Sunset
            return [Color(red: 248/255, green: 200/255, blue: 180/255), Color(red: 220/255, green: 180/255, blue: 210/255), Color(red: 180/255, green: 190/255, blue: 230/255)]
        default: // Night
            return [Color(red: 30/255, green: 35/255, blue: 60/255), Color(red: 50/255, green: 45/255, blue: 80/255), Color(red: 20/255, green: 25/255, blue: 40/255)]
        }
    }
}


// MARK: - Supporting Views (with adjustments)
struct ProfileGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.65)) // More transparent
                .background(BlurView(style: .systemUltraThinMaterial))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.6), .black.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.0 // Thinner border
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            content
        }
    }
}

struct ProfileAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.4), Color(white: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Circle().stroke(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.8), .black.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            
            Image(systemName: "person.fill").foregroundColor(.white).font(.title2)
        }
    }
}

struct ParticleFieldView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle().fill(particle.color).frame(width: particle.size, height: particle.size).position(x: particle.x, y: particle.y).opacity(particle.opacity)
            }
        }.onAppear(perform: generateParticles)
    }
    
    private func generateParticles() {
        particles = (0..<50).map { _ in
            Particle(id: UUID(),
                     x: .random(in: 0...UIScreen.main.bounds.width),
                     y: .random(in: 0...UIScreen.main.bounds.height),
                     size: .random(in: 1...3),
                     opacity: .random(in: 0.1...0.3),
                     color: Color(red: 142/255, green: 142/255, blue: 147/255))
        }
    }
}

struct Particle: Identifiable {
    let id: UUID
    let x: CGFloat, y: CGFloat, size: CGFloat, opacity: CGFloat
    let color: Color
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    ProfileTabView()
        .environmentObject(AppSessionManager.shared)
        .environmentObject(ThemeManager())
        .environmentObject(AppRouter())
}