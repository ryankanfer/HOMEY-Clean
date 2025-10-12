import SwiftUI

// MARK: - Immersive Profile View
struct ImmersiveProfileView: View {
    @StateObject private var performanceMonitor = PerformanceOptimizationSystem.PerformanceMonitor()
    @State private var selectedSection: ProfileSection = .overview
    @State private var isPortalMode: Bool = false
    @State private var consciousnessLevel: Double = 0.8
    
    enum ProfileSection: String, CaseIterable {
        case overview = "Overview"
        case journey = "Journey"
        case achievements = "Achievements"
        case connections = "Connections"
        case insights = "Insights"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .overview: return "person.circle"
            case .journey: return "map"
            case .achievements: return "star.circle"
            case .connections: return "link"
            case .insights: return "chart.line.uptrend.xyaxis"
            case .settings: return "gearshape"
            }
        }
        
        var color: Color {
            switch self {
            case .overview: return .cyan
            case .journey: return .purple
            case .achievements: return .yellow
            case .connections: return .green
            case .insights: return .orange
            case .settings: return .gray
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Consciousness Atmosphere Background
            ConsciousnessAtmosphere(
                intensity: consciousnessLevel
            )
            .ignoresSafeArea()
            
            // Synaptic Network Overlay
            SynapticNetworkView(
                config: .standard
            )
            .ignoresSafeArea()
            .opacity(0.3)
            
            ScrollView {
                LazyVStack(spacing: 30) {
                    // Quantum Header
                    quantumHeaderSection
                    
                    // Portal Navigation or Traditional Sections
                    if isPortalMode {
                        portalNavigationSection
                    } else {
                        traditionalSectionsView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
            }
            .optimizedImmersive(config: performanceMonitor.recommendedConfig)
            
            // Navigation Controls
            navigationControls
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startConsciousnessAnimation()
        }
    }
    
    // MARK: - Quantum Header Section
    private var quantumHeaderSection: some View {
        QuantumProfileHeader(
            userName: "HOMEY Profile",
            userStatus: "Digital Consciousness Interface"
        )
        .organicMovement(
            config: .subtle
        )
        .synapticInteractions(
            config: .standard
        )
    }
    
    // MARK: - Portal Navigation Section
    private var portalNavigationSection: some View {
        PortalNavigationGrid(
            destinations: ProfileSection.allCases.map { section in
                switch section {
                case .overview:
                    return PortalNavigationSystem.PortalDestination.profile
                case .journey:
                    return PortalNavigationSystem.PortalDestination.journey
                case .achievements:
                    return PortalNavigationSystem.PortalDestination.achievements
                case .connections:
                    return PortalNavigationSystem.PortalDestination.connections
                case .insights:
                    return PortalNavigationSystem.PortalDestination.insights
                case .settings:
                    return PortalNavigationSystem.PortalDestination.settings
                }
            },
            config: .standard,
            onNavigate: { destination in
                if let section = ProfileSection.allCases.first(where: { section in
                    switch (section, destination) {
                    case (.overview, .profile), (.journey, .journey), (.achievements, .achievements),
                         (.connections, .connections), (.insights, .insights), (.settings, .settings):
                        return true
                    default:
                        return false
                    }
                }) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        selectedSection = section
                        isPortalMode = false
                    }
                }
            }
        )
        .floatingField(particleCount: 15, config: .subtle)
    }
    
    // MARK: - Traditional Sections View
    private var traditionalSectionsView: some View {
        LazyVStack(spacing: 20) {
            // Current Section Content
            currentSectionContent
            
            // Section Navigation Cards
            sectionNavigationCards
        }
    }
    
    // MARK: - Current Section Content
    @ViewBuilder
    private var currentSectionContent: some View {
        switch selectedSection {
        case .overview:
            overviewSection
        case .journey:
            journeySection
        case .achievements:
            achievementsSection
        case .connections:
            connectionsSection
        case .insights:
            insightsSection
        case .settings:
            settingsSection
        }
    }
    
    // MARK: - Section Implementations
    private var overviewSection: some View {
        ImmersiveProfileSectionCard(
            title: "Profile Overview",
            subtitle: "Your digital consciousness snapshot",
            icon: "person.circle"
        ) {
            VStack(spacing: 20) {
                // Avatar with Consciousness Ring
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.cyan.opacity(0.3), .purple.opacity(0.1)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 120, height: 120)
                        .breathing(intensity: 0.1, cycle: 4.0)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .organicMovement(config: .subtle)
                }
                .holographicBorder()
                
                // Stats Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    statCard("Journey Progress", "78%", .cyan)
                    statCard("Connections", "142", .green)
                    statCard("Achievements", "23", .yellow)
                    statCard("Insights", "89", .orange)
                }
            }
        }
    }
    
    private var journeySection: some View {
        ImmersiveProfileSectionCard(
            title: "Journey Progress",
            subtitle: "Your path through digital consciousness",
            icon: "map"
        ) {
            VStack(spacing: 20) {
                // Progress Visualization
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: 0.78)
                        .stroke(
                            AngularGradient(
                                colors: [.cyan, .purple, .pink, .cyan],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .organicMovement(config: .subtle)
                    
                    Text("78%")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                
                Text("Next Milestone: Digital Enlightenment")
                    .font(.headline)
                    .foregroundColor(.cyan)
                    .breathing(intensity: 0.05, cycle: 3.0)
            }
        }
    }
    
    private var achievementsSection: some View {
        ImmersiveProfileSectionCard(
            title: "Achievements",
            subtitle: "Consciousness milestones unlocked",
            icon: "star.circle"
        ) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(0..<6, id: \.self) { index in
                    achievementBadge(index)
                }
            }
        }
    }
    
    private var connectionsSection: some View {
        ImmersiveProfileSectionCard(
            title: "Neural Connections",
            subtitle: "Your consciousness network",
            icon: "link"
        ) {
            VStack(spacing: 15) {
                ForEach(0..<5, id: \.self) { index in
                    connectionRow(index)
                }
            }
        }
    }
    
    private var insightsSection: some View {
        ImmersiveProfileSectionCard(
            title: "Consciousness Insights",
            subtitle: "Data from your digital journey",
            icon: "chart.line.uptrend.xyaxis"
        ) {
            VStack(spacing: 20) {
                // Insight Chart Placeholder
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white.opacity(0.1))
                    .frame(height: 120)
                    .overlay(
                        Text("Consciousness Activity Chart")
                            .foregroundColor(.white.opacity(0.6))
                    )
                    .holographicBorder()
                
                // Key Metrics
                HStack(spacing: 20) {
                    insightMetric("Awareness", "94%", .cyan)
                    insightMetric("Growth", "+12%", .green)
                    insightMetric("Harmony", "87%", .purple)
                }
            }
        }
    }
    
    private var settingsSection: some View {
        ImmersiveProfileSectionCard(
            title: "Interface Settings",
            subtitle: "Customize your reality experience",
            icon: "gearshape"
        ) {
            VStack(spacing: 20) {
                settingRow("Consciousness Level", value: consciousnessLevel) { newValue in
                    consciousnessLevel = newValue
                }
                
                settingToggle("Portal Navigation", isOn: $isPortalMode)
                settingToggle("Neural Effects", isOn: .constant(true))
                settingToggle("Organic Movement", isOn: .constant(true))
            }
        }
    }
    
    // MARK: - Section Navigation Cards
    private var sectionNavigationCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            ForEach(ProfileSection.allCases, id: \.self) { section in
                sectionNavigationCard(section)
            }
        }
    }
    
    // MARK: - Navigation Controls
    private var navigationControls: some View {
        VStack {
            HStack {
                Button(action: { isPortalMode.toggle() }) {
                    Image(systemName: isPortalMode ? "rectangle.grid.2x2" : "circle.grid.cross")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                        .holographicBorder()
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                        .holographicBorder()
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Helper Views
    private func statCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .holographicBorder()
        .organicMovement(config: .subtle)
    }
    
    private func achievementBadge(_ index: Int) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.yellow.opacity(0.8), .orange.opacity(0.3)],
                    center: .center,
                    startRadius: 10,
                    endRadius: 30
                )
            )
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: "star.fill")
                    .foregroundColor(.white)
            )
            .holographicBorder()
            .organicMovement(config: .subtle)
    }
    
    private func connectionRow(_ index: Int) -> some View {
        HStack {
            Circle()
                .fill(.green.opacity(0.6))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Connection \(index + 1)")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text("Neural link established")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
            }
            
            Spacer()
            
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
                .breathing(intensity: 0.3, cycle: 2.0)
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .synapticInteractions(config: .standard)
    }
    
    private func insightMetric(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func settingRow(_ title: String, value: Double, onChange: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
            
            Slider(value: Binding(
                get: { value },
                set: onChange
            ), in: 0...1)
            .accentColor(.cyan)
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func settingToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func sectionNavigationCard(_ section: ProfileSection) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.8)) {
                selectedSection = section
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundColor(section.color)
                
                Text(section.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                selectedSection == section ? 
                section.color.opacity(0.2) : 
                Color.white.opacity(0.05)
            )
            .cornerRadius(12)
            .holographicBorder()
        }
        .organicMovement(config: .subtle)
    }
    
    // MARK: - Animation Functions
    private func startConsciousnessAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            consciousnessLevel = 0.9
        }
    }
}

// MARK: - Preview
#Preview {
    ImmersiveProfileView()
        .performanceMetrics()
}