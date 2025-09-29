import SwiftUI
import Combine

class TeachHomeyViewModel: ObservableObject, PreferencesObserver {
    
    // MARK: - Published Properties (User Preferences)
    
    // Lifestyle
    @Published var workFromHome: Bool = false
    @Published var hasPets: Bool = false
    
    // Neighborhood
    @Published var walkability: Double = 3.0
    @Published var safetyRating: Double = 4.0
    
    // Design
    @Published var selectedStyles: Set<String> = []
    
    // Basics
    @Published var maxRent: Double = 4000.0
    @Published var moveInDate: Date = Date()
    
    // AI Questions
    @Published var aiQuestionAnswers: [String: String] = [:]
    
    // Agent mode properties
    @Published var isAgentMode = false
    @Published var clients: [Profile] = []
    @Published var selectedClient: UUID?

    private var cancellables = Set<AnyCancellable>()
    private let preferencesService = PreferencesService.shared
    private let profilesService: ProfilesProviding
    private let authManager: AuthProviding
    
    // This should be replaced with the actual logged-in user's ID
    private var currentUserId: UUID? = nil

    init(
        profilesService: ProfilesProviding = RealSupabaseProfilesService(client: try! RealSupabaseAuthManager().client),
        authManager: AuthProviding = try! RealSupabaseAuthManager()
    ) {
        self.profilesService = profilesService
        self.authManager = authManager
        // Add self as observer for real-time updates
        preferencesService.addObserver(self)
    }
    
    // MARK: - Progress Calculation (To be removed or repurposed)
    
    var lifestyleProgress: (value: Int, total: Int) {
        // Example logic: counts non-default values. A real app might be more complex.
        var completed = 0
        if workFromHome != false { completed += 1 }
        if hasPets != false { completed += 1 }
        return (completed, 2)
    }
    
    var neighborhoodProgress: (value: Int, total: Int) {
        var completed = 0
        if walkability != 3.0 { completed += 1 }
        if safetyRating != 4.0 { completed += 1 }
        return (completed, 2)
    }
    
    var designProgress: (value: Int, total: Int) {
        let completed = selectedStyles.isEmpty ? 0 : 1
        return (completed, 1) // Only one question for now
    }
    
    var basicsProgress: (value: Int, total: Int) {
        var completed = 0
        if maxRent != 4000.0 { completed += 1 }
        // Add other checks for moveInDate, etc.
        completed += 1 // Assuming date is always set
        return (completed, 2)
    }

    func updateAIAnswer(for questionId: String, answer: String) {
        aiQuestionAnswers[questionId] = answer
    }
    
    // MARK: - Data Persistence
    
    func loadPreferences(for userId: UUID) {
        self.currentUserId = userId
        
        Task {
            do {
                if let prefs = try await preferencesService.fetchPreferences(for: userId) {
                    DispatchQueue.main.async {
                        self.workFromHome = prefs.workFromHome
                        self.hasPets = prefs.hasPets
                        self.walkability = prefs.walkability
                        self.safetyRating = prefs.safetyRating
                        self.selectedStyles = Set(prefs.selectedStyles)
                        self.maxRent = prefs.maxRent
                        self.moveInDate = prefs.moveInDate
                        self.aiQuestionAnswers = prefs.aiQuestionAnswers
                        print("Successfully loaded preferences from backend.")
                    }
                } else {
                    print("No preferences found on backend. Using default values.")
                }
                
                // Subscribe to real-time updates
                try await preferencesService.subscribeToUserPreferences(for: userId)
            } catch {
                print("Error loading preferences: \(error.localizedDescription)")
            }
        }
    }
    
    func savePreferences() {
        guard let userId = currentUserId else {
            print("Cannot save preferences: User ID is not set.")
            return
        }

        let currentPreferences = HomeyUserPreferences(
            userId: userId,
            workFromHome: self.workFromHome,
            hasPets: self.hasPets,
            walkability: self.walkability,
            safetyRating: self.safetyRating,
            selectedStyles: Array(self.selectedStyles),
            maxRent: self.maxRent,
            moveInDate: self.moveInDate,
            aiQuestionAnswers: self.aiQuestionAnswers
        )

        Task {
            do {
                try await preferencesService.updatePreferences(currentPreferences)
                // Notification is now handled by real-time updates
            } catch {
                print("Error saving preferences: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Agent Mode Functions
    
    func loadAgentData(for agentId: UUID) {
        self.currentUserId = agentId
        self.isAgentMode = true
        
        Task {
            do {
                // Load agent preferences
                if let agentPrefs = try await preferencesService.fetchAgentPreferences(for: agentId) {
                    print("Successfully loaded agent preferences.")
                }
                
                // Load clients
                let clientIds = try await preferencesService.fetchClients(for: agentId)
                
                // Fetch actual client profiles
                var clientProfiles: [Profile] = []
                for clientId in clientIds {
                    do {
                        // This is a simplified approach - in a real app you might want to fetch all at once
                        // For now, we'll create basic profiles
                        let profile = Profile(id: clientId, email: nil, full_name: "Client \(clientId.uuidString.prefix(8))")
                        clientProfiles.append(profile)
                    } catch {
                        print("Error fetching profile for client \(clientId): \(error)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.clients = clientProfiles
                    print("Successfully loaded \(self.clients.count) clients.")
                }
                
                // Subscribe to real-time updates for client preferences
                try await preferencesService.subscribeToAgentClientPreferences(for: agentId)
            } catch {
                print("Error loading agent data: \(error.localizedDescription)")
            }
        }
    }
    
    func selectClient(_ clientId: UUID) {
        self.selectedClient = clientId
        loadPreferences(for: clientId)
    }
    
    func saveClientPreferences() {
        guard let clientId = selectedClient else {
            print("Cannot save client preferences: No client selected.")
            return
        }
        
        let clientPreferences = HomeyUserPreferences(
            userId: clientId,
            workFromHome: self.workFromHome,
            hasPets: self.hasPets,
            walkability: self.walkability,
            safetyRating: self.safetyRating,
            selectedStyles: Array(self.selectedStyles),
            maxRent: self.maxRent,
            moveInDate: self.moveInDate,
            aiQuestionAnswers: self.aiQuestionAnswers
        )
        
        guard let agentId = currentUserId else {
            print("Cannot save client preferences: Agent ID is not set.")
            return
        }
        
        Task {
            do {
                try await preferencesService.updateClientPreferences(clientPreferences, agentId: agentId)
                print("Successfully saved client preferences.")
                // Notification is now handled by real-time updates
            } catch {
                print("Error saving client preferences: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - User Role Detection
    
    func detectCurrentUserRole() async {
        do {
            if let currentUser = try await authManager.currentUser() {
                let profileInfo = try await profilesService.fetchProfile(for: currentUser.id)
                DispatchQueue.main.async {
                    self.isAgentMode = profileInfo.role == "agent"
                    if self.isAgentMode {
                        self.loadAgentData(for: currentUser.id)
                    } else {
                        self.loadPreferences(for: currentUser.id)
                    }
                }
            }
        } catch {
            print("Error detecting current user role: \(error)")
        }
    }
    
    // MARK: - PreferencesObserver Methods
    
    func preferencesDidUpdate(_ preferences: HomeyUserPreferences) {
        // This is called when the current user's preferences are updated
        if preferences.userId == currentUserId && !isAgentMode {
            DispatchQueue.main.async {
                self.workFromHome = preferences.workFromHome
                self.hasPets = preferences.hasPets
                self.walkability = preferences.walkability
                self.safetyRating = preferences.safetyRating
                self.selectedStyles = Set(preferences.selectedStyles)
                self.maxRent = preferences.maxRent
                self.moveInDate = preferences.moveInDate
                self.aiQuestionAnswers = preferences.aiQuestionAnswers
                print("User preferences updated in real-time")
            }
        }
    }
    
    func clientPreferencesDidUpdate(_ preferences: HomeyUserPreferences, for clientId: UUID) {
        // This is called when a client's preferences are updated (agent mode)
        if isAgentMode && selectedClient == clientId {
            DispatchQueue.main.async {
                self.workFromHome = preferences.workFromHome
                self.hasPets = preferences.hasPets
                self.walkability = preferences.walkability
                self.safetyRating = preferences.safetyRating
                self.selectedStyles = Set(preferences.selectedStyles)
                self.maxRent = preferences.maxRent
                self.moveInDate = preferences.moveInDate
                self.aiQuestionAnswers = preferences.aiQuestionAnswers
                print("Client preferences updated in real-time")
            }
        }
    }
}