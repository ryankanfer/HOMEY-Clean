import SwiftUI
import Foundation

// MARK: - Continuous Onboarding Manager
@MainActor
class ContinuousOnboardingManager: ObservableObject {
    @Published var currentPrompt: OnboardingPrompt?
    @Published var showPrompt = false
    
    private var userBehavior: UserBehaviorTracker
    private var preferences: OnboardingPreferences
    
    init(userBehavior: UserBehaviorTracker? = nil, 
         preferences: OnboardingPreferences? = nil) {
        self.userBehavior = userBehavior ?? UserBehaviorTracker()
        self.preferences = preferences ?? OnboardingPreferences()
    }
    
    // MARK: - Contextual Triggers
    func checkForContextualPrompts() {
        guard !showPrompt else { return }
        
        // Budget prompt - triggered after viewing 5+ properties
        if shouldShowBudgetPrompt() {
            showBudgetPrompt()
        }
        // Neighborhood prompt - triggered after searching in multiple areas
        else if shouldShowNeighborhoodPrompt() {
            showNeighborhoodPrompt()
        }
        // Timing prompt - triggered after saving properties
        else if shouldShowTimingPrompt() {
            showTimingPrompt()
        }
        // Adaptive Q&A based on behavior
        else if let adaptivePrompt = getAdaptivePrompt() {
            showAdaptivePrompt(adaptivePrompt)
        }
    }
    
    // MARK: - Budget Prompts
    private func shouldShowBudgetPrompt() -> Bool {
        return preferences.budget == nil && 
               userBehavior.propertiesViewed >= 5
    }
    
    private func showBudgetPrompt() {
        currentPrompt = OnboardingPrompt(
            id: "budget",
            type: .budget,
            title: "What's your budget range?",
            subtitle: "Help us show you the right properties",
            questions: [
                OnboardingQuestion(
                    id: "budget_range",
                    text: "Monthly budget for rent/mortgage?",
                    type: .budgetRange,
                    options: ["$2K-3K", "$3K-4K", "$4K-5K", "$5K+", "Custom"]
                )
            ]
        )
        showPrompt = true
    }
    
    // MARK: - Neighborhood Prompts
    private func shouldShowNeighborhoodPrompt() -> Bool {
        return preferences.preferredNeighborhoods.isEmpty && 
               userBehavior.searchedAreas.count >= 3
    }
    
    private func showNeighborhoodPrompt() {
        currentPrompt = OnboardingPrompt(
            id: "neighborhoods",
            type: .neighborhoods,
            title: "Favorite neighborhoods?",
            subtitle: "We noticed you're exploring different areas",
            questions: [
                OnboardingQuestion(
                    id: "preferred_areas",
                    text: "Which areas interest you most?",
                    type: .multiSelect,
                    options: Array(userBehavior.searchedAreas).sorted()
                )
            ]
        )
        showPrompt = true
    }
    
    // MARK: - Timing Prompts
    private func shouldShowTimingPrompt() -> Bool {
        return preferences.moveInTiming == nil && 
               userBehavior.savedProperties >= 2
    }
    
    private func showTimingPrompt() {
        currentPrompt = OnboardingPrompt(
            id: "timing",
            type: .timing,
            title: "When are you looking to move?",
            subtitle: "This helps us prioritize listings for you",
            questions: [
                OnboardingQuestion(
                    id: "move_timing",
                    text: "Ideal move-in timeframe?",
                    type: .singleSelect,
                    options: ["ASAP", "1-2 months", "3-6 months", "6+ months", "Just browsing"]
                )
            ]
        )
        showPrompt = true
    }
    
    // MARK: - Adaptive Q&A
    private func getAdaptivePrompt() -> OnboardingPrompt? {
        // Pets prompt - if user filters by pet-friendly
        if userBehavior.searchedPetFriendly && preferences.hasPets == nil {
            return OnboardingPrompt(
                id: "pets",
                type: .adaptive,
                title: "Do you have pets?",
                subtitle: "We noticed you're looking at pet-friendly places",
                questions: [
                    OnboardingQuestion(
                        id: "has_pets",
                        text: "Any furry friends?",
                        type: .singleSelect,
                        options: ["Yes - Dogs", "Yes - Cats", "Yes - Both", "No pets", "Planning to get one"]
                    )
                ]
            )
        }
        
        // Bedrooms prompt - based on search patterns
        if userBehavior.bedroomSearchPattern.count >= 2 && preferences.bedrooms == nil {
            let mostSearched = userBehavior.bedroomSearchPattern.max { a, b in
                userBehavior.bedroomSearchPattern[a.key] ?? 0 < userBehavior.bedroomSearchPattern[b.key] ?? 0
            }?.key ?? "2"
            
            return OnboardingPrompt(
                id: "bedrooms",
                type: .adaptive,
                title: "How many bedrooms?",
                subtitle: "You've been looking at \(mostSearched)-bedroom places",
                questions: [
                    OnboardingQuestion(
                        id: "bedroom_count",
                        text: "Ideal number of bedrooms?",
                        type: .singleSelect,
                        options: ["Studio", "1 BR", "2 BR", "3 BR", "4+ BR"]
                    )
                ]
            )
        }
        
        return nil
    }
    
    private func showAdaptivePrompt(_ prompt: OnboardingPrompt) {
        currentPrompt = prompt
        showPrompt = true
    }
    
    // MARK: - Response Handling
    func handleResponse(_ responses: [String: String]) {
        guard let prompt = currentPrompt else { return }
        
        // Update preferences based on responses
        switch prompt.type {
        case .budget:
            if let budgetRange = responses["budget_range"] {
                preferences.budget = budgetRange
            }
        case .neighborhoods:
            if let areas = responses["preferred_areas"] {
                preferences.preferredNeighborhoods = areas.components(separatedBy: ",")
            }
        case .timing:
            if let timing = responses["move_timing"] {
                preferences.moveInTiming = timing
            }
        case .adaptive:
            handleAdaptiveResponse(prompt.id, responses)
        }
        
        // Record event for HOMEY Brain
        recordOnboardingEvent(prompt.id, responses)
        
        // Close prompt
        dismissPrompt()
    }
    
    private func handleAdaptiveResponse(_ promptId: String, _ responses: [String: String]) {
        switch promptId {
        case "pets":
            preferences.hasPets = responses["has_pets"]
        case "bedrooms":
            preferences.bedrooms = responses["bedroom_count"]
        default:
            break
        }
    }
    
    private func recordOnboardingEvent(_ promptId: String, _ responses: [String: String]) {
        // Fire event for HOMEY Brain to learn from
        EventsManager.shared.recordOnboardingAnswer(
            promptId: promptId,
            responses: responses,
            context: userBehavior.currentContext()
        )
    }
    
    func dismissPrompt() {
        withAnimation(.easeOut(duration: 0.3)) {
            showPrompt = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentPrompt = nil
        }
    }
}

// MARK: - Data Models
struct OnboardingPrompt: Identifiable {
    let id: String
    let type: OnboardingPromptType
    let title: String
    let subtitle: String
    let questions: [OnboardingQuestion]
}

enum OnboardingPromptType {
    case budget, neighborhoods, timing, adaptive
}

struct OnboardingQuestion: Identifiable {
    let id: String
    let text: String
    let type: QuestionType
    let options: [String]
}

enum QuestionType {
    case singleSelect, multiSelect, budgetRange, textInput
}

// MARK: - User Behavior Tracker
@MainActor
class UserBehaviorTracker: ObservableObject {
    @Published var propertiesViewed: Int = 0
    @Published var searchedAreas: Set<String> = []
    @Published var savedProperties: Int = 0
    @Published var searchedPetFriendly: Bool = false
    @Published var bedroomSearchPattern: [String: Int] = [:]
    
    func recordPropertyView() {
        propertiesViewed += 1
    }
    
    func recordSearch(area: String, bedrooms: String? = nil, petFriendly: Bool = false) {
        searchedAreas.insert(area)
        
        if petFriendly {
            searchedPetFriendly = true
        }
        
        if let bedrooms = bedrooms {
            bedroomSearchPattern[bedrooms, default: 0] += 1
        }
    }
    
    func recordSave() {
        savedProperties += 1
    }
    
    func currentContext() -> [String: Any] {
        return [
            "properties_viewed": propertiesViewed,
            "searched_areas": Array(searchedAreas),
            "saved_properties": savedProperties,
            "searched_pet_friendly": searchedPetFriendly,
            "bedroom_pattern": bedroomSearchPattern
        ]
    }
}

// MARK: - Onboarding Preferences
@MainActor
class OnboardingPreferences: ObservableObject {
    @Published var budget: String?
    @Published var preferredNeighborhoods: [String] = []
    @Published var moveInTiming: String?
    @Published var hasPets: String?
    @Published var bedrooms: String?
}

// MARK: - Continuous Onboarding View
struct ContinuousOnboardingView: View {
    @ObservedObject var manager: ContinuousOnboardingManager
    @State private var responses: [String: String] = [:]
    
    var body: some View {
        if manager.showPrompt, let prompt = manager.currentPrompt {
            ZStack {
                // Backdrop
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        manager.dismissPrompt()
                    }
                
                // Prompt Card
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text(prompt.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        
                        Text(prompt.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    ForEach(prompt.questions) { question in
                        QuestionView(
                            question: question,
                            response: Binding(
                                get: { responses[question.id] ?? "" },
                                set: { responses[question.id] = $0 }
                            )
                        )
                    }
                    
                    HStack(spacing: 12) {
                        Button("Skip") {
                            manager.dismissPrompt()
                        }
                        .foregroundColor(.secondary)
                        
                        Button("Continue") {
                            manager.handleResponse(responses)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(responses.isEmpty)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
            }
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .scale(scale: 0.8).combined(with: .opacity)
            ))
        }
    }
}

struct QuestionView: View {
    let question: OnboardingQuestion
    @Binding var response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.text)
                .font(.subheadline.weight(.medium))
            
            switch question.type {
            case .singleSelect:
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                    ForEach(question.options, id: \.self) { option in
                        Button(option) {
                            response = option
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(response == option ? .white : .primary)
                        .background(response == option ? Color.accentColor : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
            case .multiSelect:
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                    ForEach(question.options, id: \.self) { option in
                        let isSelected = response.contains(option)
                        Button(option) {
                            toggleMultiSelect(option)
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(isSelected ? .white : .primary)
                        .background(isSelected ? Color.accentColor : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
            case .budgetRange:
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(question.options, id: \.self) { option in
                        Button(option) {
                            response = option
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(response == option ? .white : .primary)
                        .background(response == option ? Color.accentColor : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
            case .textInput:
                TextField("Your answer", text: $response)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private func toggleMultiSelect(_ option: String) {
        let selected = response.components(separatedBy: ",").filter { !$0.isEmpty }
        
        if selected.contains(option) {
            let filtered = selected.filter { $0 != option }
            response = filtered.joined(separator: ",")
        } else {
            let updated = selected + [option]
            response = updated.joined(separator: ",")
        }
    }
}

