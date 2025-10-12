import Foundation
import SwiftUI

// MARK: - Subway Station Types
enum SubwayStationType: Equatable {
    case welcome
    case vibeCheck
    case feature
    case question
    case arrival
}

enum SubwayOnboardingQuestion: Equatable {
    case purpose
    case location
    case budget
    case preferences
    case agent
}

// MARK: - Subway Station Model
struct SubwayStation: Identifiable, Equatable {
    let id = UUID()
    let stationNumber: Int
    let name: String
    let type: SubwayStationType
    let headline: String
    let subline: String?
    let copy: String
    let buttonText: String
    let question: SubwayOnboardingQuestion?
    let isTerminal: Bool
    
    static let allStations: [SubwayStation] = [
        // Welcome Station
        SubwayStation(
            stationNumber: 0,
            name: "Welcome Terminal",
            type: .welcome,
            headline: "Welcome to HOMEY",
            subline: "An app that actually gets you.",
            copy: "(Warning: May cause elevated hopes for tech in general.)",
            buttonText: "Let's Go! … Please don't hold the doors",
            question: nil,
            isTerminal: false
        ),
        
        // Vibe Check (On Train)
        SubwayStation(
            stationNumber: 1,
            name: "Vibe Check Express",
            type: .vibeCheck,
            headline: "What brings you to HOMEY?",
            subline: "Pick your line:",
            copy: "Choose your journey type to get the right recommendations.",
            buttonText: "Next Stop →",
            question: .purpose,
            isTerminal: false
        ),
        
        // Feature: What is HOMEY
        SubwayStation(
            stationNumber: 2,
            name: "HOMEY Central",
            type: .feature,
            headline: "HOMEY in one sentence",
            subline: nil,
            copy: "We make finding your home less \"rats on the tracks,\" more \"express train, no delays.\"",
            buttonText: "Next Stop →",
            question: nil,
            isTerminal: false
        ),
        
        // Location Question
        SubwayStation(
            stationNumber: 3,
            name: "Location Junction",
            type: .question,
            headline: "Which line are you on?",
            subline: "Type in your neighborhood stop.",
            copy: "Narnia is currently out of service. Wakanda opens late 2026.",
            buttonText: "Next Stop →",
            question: .location,
            isTerminal: false
        ),
        
        // Feature: Progress Tracking
        SubwayStation(
            stationNumber: 4,
            name: "Progress Plaza",
            type: .feature,
            headline: "No more limbo.",
            subline: "Watch your journey unfold.",
            copy: "Track your milestones like subway stops. Except here, \"delayed due to signal issues\" is not an option.",
            buttonText: "Next Stop →",
            question: nil,
            isTerminal: false
        ),
        
        // Budget Question
        SubwayStation(
            stationNumber: 5,
            name: "Budget Boulevard",
            type: .question,
            headline: "Your budget, but make it chill.",
            subline: "Tap the number that doesn't make you nauseous.",
            copy: "Most landlords require 40x your rent. Just keeping it real.",
            buttonText: "Next Stop →",
            question: .budget,
            isTerminal: false
        ),
        
        // Preferences Question
        SubwayStation(
            stationNumber: 6,
            name: "Quantum Station",
            type: .question,
            headline: "Collapse your housing wave function.",
            subline: "Answer fast. Don't overthink.",
            copy: "Quick preferences to match your vibe.",
            buttonText: "Next Stop →",
            question: .preferences,
            isTerminal: false
        ),
        
        // Feature: Search Power
        SubwayStation(
            stationNumber: 7,
            name: "Search Central",
            type: .feature,
            headline: "Search Central",
            subline: "HOMEY lets you type in anything.",
            copy: "\"Whole Foods within 5 minutes\" ✅\n\"Commute under 20 mins\" ✅\n\"Ex's place nowhere nearby\" ✅",
            buttonText: "Next Stop →",
            question: nil,
            isTerminal: false
        ),
        
        // Agent Question
        SubwayStation(
            stationNumber: 8,
            name: "Conductor's Car",
            type: .question,
            headline: "Don't ride alone.",
            subline: "Every rider needs a conductor.",
            copy: "Have an agent? Drop their info or share your HOMEY pass.\nNo agent? No problem. Keep browsing — we'll connect you when you're ready.",
            buttonText: "Punch Agent's Ticket",
            question: .agent,
            isTerminal: false
        ),
        
        // Final Arrival
        SubwayStation(
            stationNumber: 9,
            name: "Final Destination",
            type: .arrival,
            headline: "You've arrived.",
            subline: nil,
            copy: "HOMEY is in your pocket. On your side. Doors opening. Step into your new ride.",
            buttonText: "Open Doors →",
            question: nil,
            isTerminal: true
        )
    ]
}

// MARK: - Onboarding Responses
struct OnboardingResponses: Codable {
    var purpose: String?
    var location: String?
    var budget: Double?
    var budgetType: BudgetType?
    var hasGuarantor: Bool?
    var preferences: [String] = []
    var hasAgent: Bool?
    var agentInfo: String?
    
    enum BudgetType: String, Codable, CaseIterable {
        case rent = "rent"
        case purchase = "purchase"
        
        var displayName: String {
            switch self {
            case .rent: return "Monthly Rent"
            case .purchase: return "Purchase Price"
            }
        }
    }
}

// MARK: - Purpose Options
enum PurposeOption: String, CaseIterable {
    case renting = "renting"
    case buying = "buying"
    case selling = "selling"
    case browsing = "browsing"
    
    var displayText: String {
        switch self {
        case .renting: return "Renting (short-term romance)"
        case .buying: return "Buying (committed relationship)"
        case .selling: return "Selling (clean break energy)"
        case .browsing: return "Just browsing. Maybe forever."
        }
    }
    
    var emoji: String {
        switch self {
        case .renting: return "🏠"
        case .buying: return "💍"
        case .selling: return "✂️"
        case .browsing: return "👀"
        }
    }
}

// MARK: - Preference Options
enum PreferenceOption: String, CaseIterable {
    case sleekModern = "sleek_modern"
    case classicCozy = "classic_cozy"
    case highRise = "high_rise"
    case brownstone = "brownstone"
    case byWater = "by_water"
    case inland = "inland"
    case views = "views"
    case closetSpace = "closet_space"
    
    var displayText: String {
        switch self {
        case .sleekModern: return "Sleek & Modern"
        case .classicCozy: return "Classic & Cozy"
        case .highRise: return "High-rise"
        case .brownstone: return "Brownstone"
        case .byWater: return "By the water"
        case .inland: return "Inland"
        case .views: return "Views"
        case .closetSpace: return "Closet Space"
        }
    }
    
    var pairedOption: PreferenceOption {
        switch self {
        case .sleekModern: return .classicCozy
        case .classicCozy: return .sleekModern
        case .highRise: return .brownstone
        case .brownstone: return .highRise
        case .byWater: return .inland
        case .inland: return .byWater
        case .views: return .closetSpace
        case .closetSpace: return .views
        }
    }
}

// MARK: - Subway Line Progress
class SubwayLineProgress: ObservableObject {
    @Published var currentStation: Int = 0
    @Published var isMoving: Bool = false
    @Published var doorState: DoorState = .closed
    
    enum DoorState {
        case closed
        case opening
        case open
        case closing
    }
    
    var totalStations: Int {
        SubwayStation.allStations.count
    }
    
    var progressPercentage: Double {
        guard totalStations > 0 else { return 0 }
        return Double(currentStation) / Double(totalStations - 1)
    }
    
    var currentStationData: SubwayStation? {
        guard currentStation < SubwayStation.allStations.count else { return nil }
        return SubwayStation.allStations[currentStation]
    }
    
    func moveToNextStation() {
        guard currentStation < totalStations - 1 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            doorState = .closing
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.isMoving = true
                self.currentStation += 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isMoving = false
                self.doorState = .opening
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.doorState = .open
            }
        }
    }
    
    func startJourney() {
        withAnimation(.easeInOut(duration: 0.5)) {
            doorState = .opening
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.doorState = .open
            }
        }
    }
    
    func completeJourney() {
        withAnimation(.easeInOut(duration: 0.3)) {
            doorState = .closing
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.isMoving = false
                self.doorState = .closed
            }
        }
    }
    
    func reset() {
        currentStation = 0
        isMoving = false
        doorState = .closed
    }
}