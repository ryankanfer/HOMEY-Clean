import Foundation
import SwiftUI
import Combine

@MainActor
class DrewDirectoryViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var filteredContacts: [Contact] = []
    @Published var selectedRole: ProfessionalRole?
    @Published var selectedBorough: Borough?
    @Published var selectedLanguage: Language?
    @Published var hasNewIntroduction = false
    @Published var introductionCount = 0
    
    // Progression tracking
    @Published var hasHandshakeBadge = false
    @Published var hasTrustedTrioBadge = false
    
    // Computed properties for the new UI
    var myTeam: [Contact] {
        // For now, we'll simulate a "My Team" list.
        // In a real app, this would be based on user's connections.
        Array(contacts.prefix(3))
    }
    
    var suggestedProfessionals: [Contact] {
        // Simulate AI suggestions.
        contacts.sorted { $0.adjustedTrustScore > $1.adjustedTrustScore }
    }
    
    var featuredContacts: [Contact] {
        contacts.sorted { $0.adjustedTrustScore > $1.adjustedTrustScore }
    }
    
    var rolodexContacts: [Contact] {
        contacts.shuffled()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupFilterObservers()
        loadProgressionState()
    }
    
    // MARK: - Data Loading
    func loadContacts() {
        // In a real app, this would fetch from API
        contacts = Contact.sampleContacts
        applyFilters()
    }
    
    // MARK: - Filtering
    private func setupFilterObservers() {
        Publishers.CombineLatest3(
            $selectedRole,
            $selectedBorough,
            $selectedLanguage
        )
        .sink { [weak self] _, _, _ in
            self?.applyFilters()
        }
        .store(in: &cancellables)
    }
    
    private func applyFilters() {
        filteredContacts = contacts.filter { contact in
            let roleMatch = selectedRole == nil || contact.role == selectedRole
            let boroughMatch = selectedBorough == nil || contact.borough == selectedBorough
            let languageMatch = selectedLanguage == nil || contact.languages.contains(selectedLanguage!)
            
            return roleMatch && boroughMatch && languageMatch
        }
    }
    
    func toggleRoleFilter(_ role: ProfessionalRole?) {
        selectedRole = selectedRole == role ? nil : role
    }
    
    func toggleBoroughFilter(_ borough: Borough?) {
        selectedBorough = selectedBorough == borough ? nil : borough
    }
    
    func toggleLanguageFilter(_ language: Language?) {
        selectedLanguage = selectedLanguage == language ? nil : language
    }
    
    // MARK: - Introduction Management
    func requestIntroduction(for contact: Contact) {
        guard let index = contacts.firstIndex(where: { $0.id == contact.id }) else { return }
        
        // Update contact status
        contacts[index] = Contact(
            name: contact.name,
            avatar: contact.avatar,
            avatarURL: contact.avatarURL,
            role: contact.role,
            company: contact.company,
            borough: contact.borough,
            languages: contact.languages,
            trustScore: contact.trustScore,
            biography: contact.biography,
            documents: contact.documents,
            endorsements: contact.endorsements,
            introductionStatus: .requested,
            lastActivity: contact.lastActivity,
            contactInfo: contact.contactInfo,
            pastDeals: contact.pastDeals,
            yearsExperience: contact.yearsExperience,
            certifications: contact.certifications,
            recommendations: contact.recommendations
        )
        
        // Simulate real-time status update
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateIntroductionStatus(for: contact.id, to: .pending)
        }
        
        applyFilters()
    }
    
    private func updateIntroductionStatus(for contactId: UUID, to status: IntroductionStatus) {
        guard let index = contacts.firstIndex(where: { $0.id == contactId }) else { return }
        let contact = contacts[index]
        
        contacts[index] = Contact(
            name: contact.name,
            avatar: contact.avatar,
            avatarURL: contact.avatarURL,
            role: contact.role,
            company: contact.company,
            borough: contact.borough,
            languages: contact.languages,
            trustScore: contact.trustScore,
            biography: contact.biography,
            documents: contact.documents,
            endorsements: contact.endorsements,
            introductionStatus: status,
            lastActivity: contact.lastActivity,
            contactInfo: contact.contactInfo,
            pastDeals: contact.pastDeals,
            yearsExperience: contact.yearsExperience,
            certifications: contact.certifications,
            recommendations: contact.recommendations
        )
        
        if status == .accepted {
            handleSuccessfulIntroduction()
        }
        
        applyFilters()
    }
    
    private func handleSuccessfulIntroduction() {
        introductionCount += 1
        hasNewIntroduction = true
        
        // Play notification sound
        playIntroductionSound()
        
        // Update badges
        updateProgressionBadges()
        
        // Reset notification after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hasNewIntroduction = false
        }
    }
    
    // MARK: - Progression System
    private func loadProgressionState() {
        // In a real app, load from UserDefaults or API
        introductionCount = UserDefaults.standard.integer(forKey: "introductionCount")
        updateProgressionBadges()
    }
    
    private func updateProgressionBadges() {
        hasHandshakeBadge = introductionCount >= 1
        hasTrustedTrioBadge = introductionCount >= 3
        
        // Save state
        UserDefaults.standard.set(introductionCount, forKey: "introductionCount")
    }
    
    // MARK: - Audio
    private func playIntroductionSound() {
        // In a real app, implement audio playback
        // AudioServicesPlaySystemSound(SystemSoundID(1016)) // Example system sound
        print("Playing soft_chime.wav")
    }
    
    // MARK: - Real-time Updates
    func startRealTimeUpdates() {
        // In a real app, implement WebSocket connection or polling
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkForUpdates()
            }
            .store(in: &cancellables)
    }
    
    private func checkForUpdates() {
        // Simulate checking for introduction status updates
        // In a real app, this would query the server
    }
    
    // MARK: - Contact Search
    func searchContacts(query: String) {
        if query.isEmpty {
            applyFilters()
        } else {
            filteredContacts = contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(query) ||
                contact.role.rawValue.localizedCaseInsensitiveContains(query) ||
                (contact.company?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
    }
    
    // MARK: - Introduction Status Management
    func updateContactIntroductionStatus(_ contactId: UUID, status: IntroductionStatus) {
        updateIntroductionStatus(for: contactId, to: status)
    }
    
    func syncIntroductionStatuses(with requests: [String: IntroductionStatus]) {
        for (contactIdString, status) in requests {
            if let contactId = UUID(uuidString: contactIdString) {
                updateIntroductionStatus(for: contactId, to: status)
            }
        }
    }
    
    // MARK: - Badge System
    var badges: [Badge] {
        var badgeList: [Badge] = []
        
        // First Handshake Badge
        if introductionCount >= 1 {
            badgeList.append(Badge(
                type: .handshake,
                isEarned: true,
                earnedDate: Date()
            ))
        } else {
            badgeList.append(Badge(
                type: .handshake,
                progress: Double(introductionCount) / 1.0
            ))
        }
        
        // Trusted Trio Badge
        if introductionCount >= 3 {
            badgeList.append(Badge(
                type: .trustedTrio,
                isEarned: true,
                earnedDate: Date()
            ))
        } else {
            badgeList.append(Badge(
                type: .trustedTrio,
                progress: Double(introductionCount) / 3.0
            ))
        }
        
        return badgeList
    }
}