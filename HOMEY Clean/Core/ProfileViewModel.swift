import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var overallProgress: Double = 0.0
    @Published var marketInsights: MarketInsights?
    @Published var vendorSuggestions: [VendorSuggestion] = []
    @Published var agent: ProfileRecord?
    @Published var notifications: [ProfileNotification] = []
    @Published var needsOnboarding: Bool = false
    @Published var isLoading: Bool = false
    @Published var journeyStage: JourneyStage = .exploring
    
    private var cancellables = Set<AnyCancellable>()
    private let eventsManager = EventsManager.shared
    private let userPreferences = UserPreferences.shared
    private let profilesRepository = ProfilesRepository()
    
    init() {
        // Initialize with mock data for now
        loadMockData()
        
        // Record profile view event
        eventsManager.recordProfileView()
    }
    
    func loadProfile() {
        isLoading = true
        
        // Check if user needs onboarding
        checkOnboardingStatus()
        
        // Load user progress
        calculateProgress()
        
        // Load market insights
        loadMarketInsights()
        
        // Load vendor suggestions
        loadVendorSuggestions()
        
        // Load agent info
        loadAgentInfo()
        
        // Load notifications
        loadNotifications()
        
        isLoading = false
    }
    
    private func checkOnboardingStatus() {
        // TODO: Check if user has completed basic intake
        // For now, assume they need onboarding if no profile data exists
        needsOnboarding = agent == nil && notifications.isEmpty
    }
    
    private func calculateProgress() {
        // TODO: Calculate based on completed journey steps
        // For now, use mock progress
        overallProgress = 0.65
    }
    
    private func loadMarketInsights() {
        // Fetch market insights based on user's saved areas and preferences
        let savedAreas = userPreferences.savedNeighborhoods
        let primaryArea = savedAreas.first ?? "Downtown"
        
        // In production, this would fetch from a market data API
        marketInsights = MarketInsights(
            medianRent: generateMarketData(for: primaryArea, type: .rent),
            medianSale: generateMarketData(for: primaryArea, type: .sale),
            area: primaryArea,
            trendDirection: .flat,
            trendPercentage: 3.2,
            daysOnMarket: 28,
            pricePerSqFt: "$485"
        )
        
        // Record market insights view event
        eventsManager.recordEvent(.marketInsightsView(area: primaryArea))
    }
    
    private func loadVendorSuggestions() {
        // Generate vendor suggestions based on journey stage and user behavior
        let journeyStage = determineJourneyStage()
        vendorSuggestions = generateVendorSuggestions(for: journeyStage)
        
        // Record vendor suggestions view event
        eventsManager.recordEvent(.vendorSuggestionsView)
    }
    
    private func determineJourneyStage() -> JourneyStage {
        // Determine current stage based on user activity and progress
        let documentsCount = 0 // TODO: Get from DocumentsManager
        let savedPropertiesCount = 0 // TODO: Get from SavedPropertiesManager
        let tourRequestsCount = 0 // TODO: Get from TourManager
        
        if tourRequestsCount > 0 {
            return .viewing
        } else if savedPropertiesCount > 5 {
            return .researching
        } else if documentsCount > 0 {
            return .researching
        } else {
            return .exploring
        }
    }
    
    private func generateVendorSuggestions(for stage: JourneyStage) -> [VendorSuggestion] {
        switch stage {
        case .exploring:
            return getExploringVendors()
        case .researching:
            return getResearchingVendors()
        case .viewing:
            return getViewingVendors()
        case .negotiating:
            return getNegotiatingVendors()
        case .closing:
            return getClosingVendors()
        case .settled:
            return getSettledVendors()
        }
    }
    
    private func getExploringVendors() -> [VendorSuggestion] {
        return [
            VendorSuggestion(
                id: "1",
                name: "First National Bank",
                category: "Lender",
                rating: 4.8,
                description: "Pre-approval in 24 hours",
                relevanceScore: 0.95
            ),
            VendorSuggestion(
                id: "2",
                name: "HomeBuyer's Insurance Co.",
                category: "Insurance",
                rating: 4.6,
                description: "Get quotes before you buy",
                relevanceScore: 0.87
            )
        ]
    }
    
    private func getResearchingVendors() -> [VendorSuggestion] {
        return [
            VendorSuggestion(
                id: "3",
                name: "Elite Property Inspectors",
                category: "Inspector",
                rating: 4.9,
                description: "Thorough inspections, same day reports",
                relevanceScore: 0.92
            ),
            VendorSuggestion(
                id: "4",
                name: "Metro Title Services",
                category: "Title Company",
                rating: 4.7,
                description: "Fast, reliable title searches",
                relevanceScore: 0.88
            )
        ]
    }
    
    private func getViewingVendors() -> [VendorSuggestion] {
        return [
            VendorSuggestion(
                id: "5",
                name: "City Home Inspectors",
                category: "Inspector",
                rating: 4.9,
                description: "Same-day inspection scheduling",
                relevanceScore: 0.94
            ),
            VendorSuggestion(
                id: "6",
                name: "MoveMaster Insurance",
                category: "Insurance",
                rating: 4.8,
                description: "Bundle home & auto for savings",
                relevanceScore: 0.89
            )
        ]
    }
    
    private func getNegotiatingVendors() -> [VendorSuggestion] {
        return [
            VendorSuggestion(
                id: "7",
                name: "Swift Movers Co.",
                category: "Moving",
                rating: 4.8,
                description: "Book now for next month availability",
                relevanceScore: 0.96
            ),
            VendorSuggestion(
                id: "8",
                name: "Home Warranty Plus",
                category: "Warranty",
                rating: 4.7,
                description: "Protect your new investment",
                relevanceScore: 0.91
            )
        ]
    }
    
    private func getClosingVendors() -> [VendorSuggestion] {
        return [
            VendorSuggestion(
                id: "9",
                name: "Professional Movers Inc.",
                category: "Moving",
                rating: 4.9,
                description: "Full-service moving solutions",
                relevanceScore: 0.97
            ),
            VendorSuggestion(
                id: "10",
                name: "Home Security Plus",
                category: "Security",
                rating: 4.6,
                description: "Secure your new home",
                relevanceScore: 0.85
            )
        ]
    }
    
    private func getSettledVendors() -> [VendorSuggestion] {
        return [
            VendorSuggestion(
                id: "11",
                name: "Local Handyman Services",
                category: "Maintenance",
                rating: 4.8,
                description: "Trusted local professionals",
                relevanceScore: 0.93
            ),
            VendorSuggestion(
                id: "12",
                name: "Garden & Landscape Co.",
                category: "Landscaping",
                rating: 4.7,
                description: "Transform your outdoor space",
                relevanceScore: 0.89
            )
        ]
    }
    
    private func generateMarketData(for area: String, type: MarketDataType) -> String {
        // In production, this would fetch real market data
        let baseRent = 2500
        let baseSale = 450000
        
        let areaMultiplier: Double = {
            switch area.lowercased() {
            case "downtown": return 1.2
            case "midtown": return 1.1
            case "uptown": return 0.9
            case "suburbs": return 0.8
            default: return 1.0
            }
        }()
        
        switch type {
        case .rent:
            let rent = Int(Double(baseRent) * areaMultiplier)
            return "$\(rent.formatted(.number.grouping(.automatic)))"
        case .sale:
            let sale = Int(Double(baseSale) * areaMultiplier)
            return "$\(sale / 1000)K"
        }
    }
    
    private func loadAgentInfo() {
        Task {
            do {
                // Get current user's assigned agent from agent_client_links
                let currentUser = try await profilesRepository.fetchCurrentUserProfile()
                
                if let agentId = currentUser.agentId {
                    // Fetch the assigned agent's profile
                    let agentProfile = try await profilesRepository.fetchProfile(for: agentId)
                    await MainActor.run {
                        self.agent = agentProfile
                    }
                } else {
                    // No agent assigned yet
                    await MainActor.run {
                        self.agent = nil
                    }
                }
            } catch {
                print("Error loading agent info: \(error)")
                await MainActor.run {
                    self.agent = nil
                }
            }
        }
    }
    
    private func loadNotifications() {
        // TODO: Fetch from Supabase
        notifications = [
            ProfileNotification(
                id: "1",
                title: "Document Approved",
                message: "Your pay stub has been approved by your agent",
                timestamp: Date().addingTimeInterval(-3600),
                iconName: "checkmark.circle.fill",
                color: .green,
                isRead: false
            ),
            ProfileNotification(
                id: "2",
                title: "Tour Scheduled",
                message: "Your tour for 123 Main St is confirmed for tomorrow at 2 PM",
                timestamp: Date().addingTimeInterval(-7200),
                iconName: "calendar.circle.fill",
                color: .blue,
                isRead: true
            ),
            ProfileNotification(
                id: "3",
                title: "Agent Message",
                message: "Sarah sent you a message about your offer",
                timestamp: Date().addingTimeInterval(-10800),
                iconName: "message.circle.fill",
                color: .orange,
                isRead: false
            )
        ]
    }
    
    func completeOnboarding() {
        needsOnboarding = false
        // TODO: Save onboarding completion to Supabase
        // Reload profile data
        loadProfile()
    }
    
    private func loadMockData() {
        // This method provides initial mock data
        overallProgress = 0.65
        
        marketInsights = MarketInsights(
            medianRent: "$2,850",
            medianSale: "$485K",
            area: "Downtown",
            trendDirection: .up,
            trendPercentage: 5.2,
            daysOnMarket: 28,
            pricePerSqFt: "$425"
        )
        
        vendorSuggestions = [
            VendorSuggestion(
                id: "1",
                name: "Premier Mortgage Co.",
                category: "Lender",
                rating: 4.8,
                description: "Fast pre-approval process",
                relevanceScore: 0.92
            ),
            VendorSuggestion(
                id: "2",
                name: "City Home Inspectors",
                category: "Inspector",
                rating: 4.9,
                description: "Thorough inspections with detailed reports",
                relevanceScore: 0.95
            )
        ]
        
        agent = ProfileRecord(
            id: UUID(),
            email: "sarah@homey.com",
            fullName: "Sarah Johnson",
            role: "agent",
            clientSegment: nil,
            createdAt: Date(),
            updatedAt: Date(),
            avatarUrl: "https://example.com/avatar.jpg",
            phoneNumber: "+1 (555) 123-4567",
            preferredComms: "email",
            workingWithAgent: nil,
            firstName: "Sarah",
            lastName: "Johnson",
            agentId: nil
        )
        
        notifications = [
            ProfileNotification(
                id: "1",
                title: "Document Approved",
                message: "Your pay stub has been approved by your agent",
                timestamp: Date().addingTimeInterval(-3600),
                iconName: "checkmark.circle.fill",
                color: .green,
                isRead: false
            ),
            ProfileNotification(
                id: "2",
                title: "Tour Scheduled",
                message: "Your tour for 123 Main St is confirmed for tomorrow at 2 PM",
                timestamp: Date().addingTimeInterval(-7200),
                iconName: "calendar.circle.fill",
                color: .blue,
                isRead: true
            )
        ]
    }
}

// MARK: - Models
struct MarketInsights {
    let medianRent: String
    let medianSale: String
    let area: String
    let trendDirection: TrendDirection
    let trendPercentage: Double
    let daysOnMarket: Int
    let pricePerSqFt: String
}



enum MarketDataType {
    case rent, sale
}

struct VendorSuggestion {
    let id: String
    let name: String
    let category: String
    let rating: Double
    let description: String
    let relevanceScore: Double
}

struct ProfileNotification: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let iconName: String
    let color: Color
    let isRead: Bool
}