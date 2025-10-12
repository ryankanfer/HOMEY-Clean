import SwiftUI

// MARK: - Base Station Card
struct SubwayStationCard: View {
    let station: SubwayStation
    let doorState: SubwayLineProgress.DoorState
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Station header
            SubwayStationNameView(
                station: station,
                isArriving: doorState == .opening
            )
            
            Spacer()
            
            // Station content based on type
            Group {
                switch station.type {
                case .welcome:
                    WelcomeStationContent(station: station)
                case .vibeCheck:
                    VibeCheckStationContent(station: station, onContinue: onContinue)
                case .feature:
                    FeatureStationContent(station: station)
                case .question:
                    QuestionStationContent(station: station, onContinue: onContinue)
                case .arrival:
                    ArrivalStationContent(station: station)
                }
            }
            .subwayCardTransition(isVisible: true, doorState: doorState)
            
            Spacer()
            
            // Continue button (if not handled by content)
            if !station.type.hasCustomButton {
                SubwayContinueButton(
                    text: station.buttonText,
                    isEnabled: doorState == .open,
                    action: onContinue
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.cyan.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Welcome Station Content
struct WelcomeStationContent: View {
    let station: SubwayStation
    
    var body: some View {
        VStack(spacing: 20) {
            // Quantum glow effect
            QuantumGlowEffect()
                .frame(height: 150)
            
            VStack(spacing: 12) {
                Text(station.headline)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if let subline = station.subline {
                    Text(subline)
                        .font(.title2)
                        .foregroundColor(.cyan)
                        .multilineTextAlignment(.center)
                }
                
                Text(station.copy)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - Vibe Check Station Content
struct VibeCheckStationContent: View {
    let station: SubwayStation
    let onContinue: () -> Void
    @StateObject private var responses = OnboardingResponsesManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(station.headline)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(station.subline ?? "")
                    .font(.title3)
                    .foregroundColor(.cyan)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                ForEach(PurposeOption.allCases, id: \.self) { option in
                    Button(action: {
                        responses.responses.purpose = option.rawValue
                        onContinue()
                    }) {
                        HStack {
                            Text(option.emoji)
                                .font(.title2)
                            
                            Text(option.displayText)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if responses.responses.purpose == option.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.cyan)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.thinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            responses.responses.purpose == option.rawValue ? .cyan : .clear,
                                            lineWidth: 2
                                        )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Feature Station Content
struct FeatureStationContent: View {
    let station: SubwayStation
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text(station.headline)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if let subline = station.subline {
                    Text(subline)
                        .font(.title3)
                        .foregroundColor(.cyan)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Feature illustration based on station
            featureIllustration
            
            Text(station.copy)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var featureIllustration: some View {
        switch station.stationNumber {
        case 2: // HOMEY explanation
            VStack(spacing: 8) {
                HStack {
                    Text("🐀")
                    Text("→")
                    Text("🚇")
                    Text("→")
                    Text("🏠")
                }
                .font(.title)
                
                Text("rats → express → home")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
        case 4: // Progress tracking
            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < 3 ? .green : .gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if index < 4 {
                        Rectangle()
                            .fill(index < 2 ? .green : .gray.opacity(0.3))
                            .frame(width: 20, height: 2)
                    }
                }
            }
            
        case 7: // Search power
            VStack(spacing: 8) {
                ForEach(station.copy.components(separatedBy: "\n"), id: \.self) { line in
                    if !line.isEmpty {
                        HStack {
                            Text(line)
                                .font(.body)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Question Station Content
struct QuestionStationContent: View {
    let station: SubwayStation
    let onContinue: () -> Void
    @StateObject private var responses = OnboardingResponsesManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(station.headline)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if let subline = station.subline {
                    Text(subline)
                        .font(.title3)
                        .foregroundColor(.cyan)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Question content based on type
            Group {
                switch station.question {
                case .location:
                    LocationQuestionView(onContinue: onContinue)
                case .budget:
                    BudgetQuestionView(onContinue: onContinue)
                case .preferences:
                    PreferencesQuestionView(onContinue: onContinue)
                case .agent:
                    AgentQuestionView(onContinue: onContinue)
                default:
                    EmptyView()
                }
            }
            
            // Tip text
            if !station.copy.isEmpty && station.question == .location {
                Text(station.copy)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Location Question View
struct LocationQuestionView: View {
    let onContinue: () -> Void
    @StateObject private var responses = OnboardingResponsesManager.shared
    @State private var locationText: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Chelsea, Astoria, Bed-Stuy…", text: $locationText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    if !locationText.isEmpty {
                        responses.responses.location = locationText
                        onContinue()
                    }
                }
            
            SubwayContinueButton(
                text: "Next Stop →",
                isEnabled: !locationText.isEmpty,
                action: {
                    responses.responses.location = locationText
                    onContinue()
                }
            )
        }
    }
}

// MARK: - Budget Question View
struct BudgetQuestionView: View {
    let onContinue: () -> Void
    @StateObject private var responses = OnboardingResponsesManager.shared
    @State private var selectedBudget: Double = 3000
    @State private var showGuarantorAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Budget type selector
            Picker("Budget Type", selection: Binding(
                get: { responses.responses.budgetType ?? .rent },
                set: { responses.responses.budgetType = $0 }
            )) {
                ForEach(OnboardingResponses.BudgetType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            // Budget slider
            VStack {
                Text("$\(Int(selectedBudget))")
                    .font(.title2.bold())
                    .foregroundColor(.cyan)
                
                Slider(value: $selectedBudget, in: 1000...10000, step: 250)
                    .accentColor(.cyan)
            }
            
            SubwayContinueButton(
                text: "Next Stop →",
                isEnabled: true,
                action: {
                    responses.responses.budget = selectedBudget
                    
                    // Check 40x rule for renters
                    if responses.responses.budgetType == .rent && selectedBudget * 40 > 100000 {
                        showGuarantorAlert = true
                    } else {
                        onContinue()
                    }
                }
            )
        }
        .alert("Train Delay 🚇", isPresented: $showGuarantorAlert) {
            Button("I have a guarantor") {
                responses.responses.hasGuarantor = true
                onContinue()
            }
            Button("I'll keep this in mind") {
                responses.responses.hasGuarantor = false
                onContinue()
            }
        } message: {
            Text("Most landlords require 40x your rent. Do you meet it?")
        }
    }
}

// MARK: - Preferences Question View
struct PreferencesQuestionView: View {
    let onContinue: () -> Void
    @StateObject private var responses = OnboardingResponsesManager.shared
    
    private let preferencePairs: [(PreferenceOption, PreferenceOption)] = [
        (.sleekModern, .classicCozy),
        (.highRise, .brownstone),
        (.byWater, .inland),
        (.views, .closetSpace)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(preferencePairs.indices, id: \.self) { index in
                let pair = preferencePairs[index]
                
                HStack(spacing: 12) {
                    PreferenceButton(
                        option: pair.0,
                        isSelected: responses.responses.preferences.contains(pair.0.rawValue),
                        onTap: { togglePreference(pair.0) }
                    )
                    
                    Text("or")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    PreferenceButton(
                        option: pair.1,
                        isSelected: responses.responses.preferences.contains(pair.1.rawValue),
                        onTap: { togglePreference(pair.1) }
                    )
                }
            }
            
            SubwayContinueButton(
                text: "Next Stop →",
                isEnabled: !responses.responses.preferences.isEmpty,
                action: onContinue
            )
        }
    }
    
    private func togglePreference(_ option: PreferenceOption) {
        let paired = option.pairedOption
        
        // Remove the paired option if it exists
        responses.responses.preferences.removeAll { $0 == paired.rawValue }
        
        // Toggle the selected option
        if let index = responses.responses.preferences.firstIndex(of: option.rawValue) {
            responses.responses.preferences.remove(at: index)
        } else {
            responses.responses.preferences.append(option.rawValue)
        }
    }
}

struct PreferenceButton: View {
    let option: PreferenceOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(option.displayText)
                .font(.body)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? .cyan : .gray.opacity(0.2))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Agent Question View
struct AgentQuestionView: View {
    let onContinue: () -> Void
    @StateObject private var responses = OnboardingResponsesManager.shared
    @State private var showInviteSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(station.copy)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button(action: {
                    showInviteSheet = true
                }) {
                    Label("Punch Agent's Ticket", systemImage: "qrcode")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(.orange)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    responses.responses.hasAgent = false
                    onContinue()
                }) {
                    Text("Next Stop →")
                        .font(.headline)
                        .foregroundColor(.cyan)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(12)
                }
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteAgentSheet()
        }
    }
    
    private var station: SubwayStation {
        SubwayStation.allStations.first { $0.question == .agent } ?? SubwayStation.allStations[0]
    }
}

// MARK: - Arrival Station Content
struct ArrivalStationContent: View {
    let station: SubwayStation
    
    var body: some View {
        VStack(spacing: 20) {
            // Success animation
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("🚇 → 🏠")
                    .font(.largeTitle)
            }
            
            VStack(spacing: 12) {
                Text(station.headline)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(station.copy)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Continue Button
struct SubwayContinueButton: View {
    let text: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Image(systemName: "arrow.right")
                    .font(.headline.bold())
                    .foregroundColor(.black)
            }
            .padding()
            .background(isEnabled ? .cyan : .gray.opacity(0.3))
            .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

// MARK: - Responses Manager
class OnboardingResponsesManager: ObservableObject {
    static let shared = OnboardingResponsesManager()
    
    @Published var responses = OnboardingResponses()
    
    private init() {}
    
    func reset() {
        responses = OnboardingResponses()
    }
}

// MARK: - Extensions
extension SubwayStationType {
    var hasCustomButton: Bool {
        switch self {
        case .vibeCheck, .question:
            return true
        default:
            return false
        }
    }
}