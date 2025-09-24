import SwiftUI
import Supabase

struct OnboardingModalView: View {
    @Binding var isPresented: Bool
    let onComplete: () -> Void
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var preferredComms: CommunicationPreference = .email
    @State private var hasAgent = false
    @State private var showAgentAssignment = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Custom header
                    HStack {
                        Text("Setup")
                            .font(.headline)
                        Spacer()
                        Button("Skip") {
                            isLoading ? () : { isPresented = false }()
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("Welcome to HOMEY")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Let's get you set up with a few quick details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // First Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.headline)
                            TextField("Enter your first name", text: $firstName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Last Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.headline)
                            TextField("Enter your last name", text: $lastName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Phone
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.headline)
                            TextField("Enter your phone number", text: $phone)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.phonePad)
                        }
                        
                        // Communication Preferences
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preferred Communication")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                ForEach(CommunicationPreference.allCases, id: \.self) { pref in
                                    HStack {
                                        Button(action: {
                                            preferredComms = pref
                                        }) {
                                            HStack {
                                                Image(systemName: preferredComms == pref ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(preferredComms == pref ? .blue : .gray)
                                                Text(pref.displayName)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // Agent Question
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Are you working with a real estate agent?")
                                .font(.headline)
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    hasAgent = true
                                }) {
                                    HStack {
                                        Image(systemName: hasAgent ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(hasAgent ? .blue : .gray)
                                        Text("Yes")
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: {
                                    hasAgent = false
                                }) {
                                    HStack {
                                        Image(systemName: !hasAgent ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(!hasAgent ? .blue : .gray)
                                        Text("No")
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                            }
                            
                            if !hasAgent {
                                Button("Find me an agent") {
                                    showAgentAssignment = true
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    // Continue Button
                    Button(action: completeOnboarding) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(hasAgent ? "Continue to app" : "Continue onboarding")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $showAgentAssignment) {
            AgentAssignmentView(isPresented: $showAgentAssignment)
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty && 
        !phone.isEmpty &&
        email.contains("@")
    }
    
    private func completeOnboarding() {
        isLoading = true

        Task {
            let repo = ProfilesRepository()
            let update = ProfileUpdateRequest(
                fullName: "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces),
                phoneNumber: phone,
                preferredComms: preferredComms.rawValue,
                workingWithAgent: hasAgent,
                clientSegment: nil,
                firstName: firstName,
                lastName: lastName,
                occupation: nil,
                income: nil,
                liquidAssets: nil,
                reasonForPurchase: nil,
                employmentType: nil,
                pets: nil,
                needsElevator: nil,
                preferredNeighborhood: nil,
                bedrooms: nil,
                bathrooms: nil,
                propertyTenure: nil
            )
            do {
                _ = try await repo.updateProfile(update)
            } catch {
                // Optionally create then update
                do {
                    let client = AppSessionManager.shared.supabaseClient
                    let user = try await client.auth.user()
                    _ = try await repo.createProfile(
                        userId: user.id,
                        email: email,
                        fullName: "\(firstName) \(lastName)"
                    )
                    _ = try await repo.updateProfile(update)
                } catch {
                    // Ignore for UX; we can prompt later
                }
            }

            isLoading = false
            onComplete()
            isPresented = false
        }
    }
}

// MARK: - Communication Preference Enum
enum CommunicationPreference: String, CaseIterable {
    case sms = "sms"
    case email = "email"
    case call = "call"
    
    var displayName: String {
        switch self {
        case .sms: return "Text Messages"
        case .email: return "Email"
        case .call: return "Phone Calls"
        }
    }
}

// MARK: - Onboarding Data Model
struct OnboardingData {
    let fullName: String
    let email: String
    let phone: String
    let preferredComms: CommunicationPreference
    let hasAgent: Bool
}

// MARK: - Agent Assignment View
struct AgentAssignmentView: View {
    @Binding var isPresented: Bool
    @State private var selectedAgent: AgentOption?
    @State private var isLoading = false
    
    private let availableAgents = [
        AgentOption(
            id: "1",
            name: "Sarah Johnson",
            title: "Senior Agent",
            experience: 8,
            rating: 4.9,
            specialties: ["First-time buyers", "Condos"],
            avatarURL: "https://example.com/sarah.jpg"
        ),
        AgentOption(
            id: "2",
            name: "Mike Chen",
            title: "Luxury Specialist",
            experience: 12,
            rating: 4.8,
            specialties: ["Luxury homes", "Investment"],
            avatarURL: "https://example.com/mike.jpg"
        ),
        AgentOption(
            id: "3",
            name: "Lisa Rodriguez",
            title: "Neighborhood Expert",
            experience: 6,
            rating: 4.9,
            specialties: ["Downtown", "Family homes"],
            avatarURL: "https://example.com/lisa.jpg"
        )
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button("Back") {
                            isPresented = false
                        }
                        Spacer()
                        Text("Agent Assignment")
                            .font(.headline)
                        Spacer()
                        Color.clear.frame(width: 44, height: 0)
                    }
                    .padding()
                    
                    Text("We'll match you with an experienced agent who specializes in your needs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(availableAgents, id: \.id) { agent in
                            AgentOptionCard(
                                agent: agent,
                                isSelected: selectedAgent?.id == agent.id
                            ) {
                                selectedAgent = agent
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if let selectedAgent = selectedAgent {
                        Button(action: assignAgent) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text("Connect with \(selectedAgent.name)")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
        }
    }
    
    private func assignAgent() {
        guard let agent = selectedAgent else { return }
        
        isLoading = true
        
        // TODO: Assign agent via Supabase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            isPresented = false
        }
    }
}

struct AgentOptionCard: View {
    let agent: AgentOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: agent.avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.gray.opacity(0.3))
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(agent.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(agent.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(agent.rating, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("• \(agent.experience) years")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        ForEach(agent.specialties.prefix(2), id: \.self) { specialty in
                            Text(specialty)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(isSelected ? .blue.opacity(0.1) : .clear)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .blue : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            }
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct AgentOption {
    let id: String
    let name: String
    let title: String
    let experience: Int
    let rating: Double
    let specialties: [String]
    let avatarURL: String
}

#Preview {
    OnboardingModalView(isPresented: .constant(true)) {
        print("Onboarding completed")
    }
}