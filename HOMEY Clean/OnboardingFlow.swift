import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers
import Supabase

// MARK: - Models and Helpers

struct OnboardingBudget: Codable {
    var isRent: Bool
    var min: Int?
    var max: Int?
}

class OnboardingPreferencesRepository {
    private let suiteName = "group.com.homey.app"
    private let userDefaults: UserDefaults

    init() {
        if let ud = UserDefaults(suiteName: suiteName) {
            userDefaults = ud
        } else {
            userDefaults = UserDefaults.standard
        }
    }

    convenience init(reference: Any = AppSessionManager.shared) {
        self.init()
    }

    private enum Keys {
        static let geographicFocus = "prefs_geographicFocus"
    }

    var geographicFocus: [String] {
        get { (userDefaults.array(forKey: Keys.geographicFocus) as? [String]) ?? [] }
        set { userDefaults.set(newValue, forKey: Keys.geographicFocus) }
    }
}

// MARK: - Steps

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case basicInfo
    case roleSelection
    case agentConnect
    case location
    case smartDefaults
    case completion

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .basicInfo: return "Tell us about you"
        case .roleSelection: return "What brings you to HOMEY?"
        case .agentConnect: return "Agent Connection"
        case .location: return "Where do you live?"
        case .smartDefaults: return "Smart Defaults"
        case .completion: return "All Set"
        }
    }
}

// MARK: - Main View

public struct OnboardingFlow: View {
    // Theme
    private var creamColor: Color { Color(.systemBackground) }
    private var slateColor: Color { Color.primary }

    // State
    @State private var step: OnboardingStep = .welcome

    // Basic info
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""

    // Role selection
    enum Role: String, CaseIterable, Identifiable {
        case looking = "I'm looking for a place"
        case selling = "I'm selling my home"
        case browsing = "I'm just browsing"
        case partner = "I want to partner"
        case agent = "I work in real estate"
        var id: String { rawValue }
    }
    @State private var selectedRole: Role?

    // Agent connect
    @State private var isWorkingWithAgent: Bool? = nil
    @State private var inviteCode: String = ""
    @State private var agentMatchingWanted: Bool = false

    // Location
    @State private var selectedCity: String?
    private let majorUSCities: [String] = [
        "New York City", "Los Angeles", "Chicago", "Houston", "Phoenix",
        "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose",
        "Austin", "Jacksonville", "San Francisco", "Columbus", "Fort Worth",
        "Indianapolis", "Charlotte", "Seattle", "Denver", "Washington, D.C.",
        "Miami", "Boston", "Nashville", "Detroit", "Orlando"
    ]
    private let preferencesRepo = OnboardingPreferencesRepository(reference: AppSessionManager.shared)

    // Smart defaults
    @State private var smartTimelineNudges: Bool = true
    @State private var smartChecklistProgress: Bool = true
    @State private var smartKeyUpdates: Bool = true

    // Completion
    let onComplete: () -> Void

    // Env
    @Environment(\.colorScheme) private var colorScheme

    // Styling state
    @State private var showContent = false

    // QR / Universal link to Agent app
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    private let agentPortalBaseURL = URL(string: "https://hos-agent-flame.vercel.app/r")!

    // Data
    private let profilesRepo = ProfilesRepository()
    @State private var isSaving = false

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            // Background aligned with app style
            AnimatedSkyGradient()
                .ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.black.opacity(0.25),
                    .clear,
                    Color.black.opacity(0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.top, 12)
                    .padding(.horizontal, 20)

                progressView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                // Card container
                ScrollView {
                    VStack {
                        contentViewCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .scrollIndicators(.hidden)

                controlView
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { showContent = true }
            // Defaults already true; transparency and clarity
            smartTimelineNudges = true
            smartChecklistProgress = true
            smartKeyUpdates = true
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerView: some View {
        switch step {
        case .welcome:
            Text("HOMEY")
                .font(.custom("PlayfairDisplay-Bold", size: 36))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .shadow(radius: 2)
                .accessibilityAddTraits(.isHeader)
        default:
            Text(step.title)
                .font(.custom("PlayfairDisplay-SemiBold", size: 24))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(radius: 1)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var progressView: some View {
        let progress = Double(step.rawValue) / Double(OnboardingStep.allCases.count - 1)
        return ProgressView(value: progress)
            .tint(.white)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Progress")
            .accessibilityValue("\(Int(progress * 100)) percent")
    }

    // MARK: - Content Card

    private var contentViewCard: some View {
        VStack {
            contentView
                .padding(20)
        }
        .frame(maxWidth: 720)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
        .opacity(showContent ? 1 : 0.85)
        .scaleEffect(showContent ? 1.0 : 0.98)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch step {
        case .welcome:
            welcomeView
        case .basicInfo:
            basicInfoView
        case .roleSelection:
            roleSelectionView
        case .agentConnect:
            agentConnectView
        case .location:
            locationView
        case .smartDefaults:
            smartDefaultsView
        case .completion:
            completionView
        }
    }

    // MARK: - Step Views

    private var welcomeView: some View {
        VStack(spacing: 18) {
            Text("Welcome to the future of real estate. One platform. Your entire journey.")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 4)

            Text("We’ll personalize your experience with a few quick questions.")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var fieldLabel: FieldLabelStyle { FieldLabelStyle() }

    private var inputBG: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.95))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08), lineWidth: 1))
    }

    private var basicInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Let’s start with the basics")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("First Name").modifier(fieldLabel)
                    TextField("Enter your first name", text: $firstName)
                        .textContentType(.givenName)
                        .padding(12)
                        .background(inputBG)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Last Name").modifier(fieldLabel)
                    TextField("Enter your last name", text: $lastName)
                        .textContentType(.familyName)
                        .padding(12)
                        .background(inputBG)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Cell Phone").modifier(fieldLabel)
                    TextField("(555) 000-0000", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .padding(12)
                        .background(inputBG)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Email").modifier(fieldLabel)
                    TextField("name@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .textContentType(.emailAddress)
                        .padding(12)
                        .background(inputBG)
                }
            }
        }
    }

    private var roleSelectionView: some View {
        VStack(spacing: 16) {
            Text("What brings you to HOMEY?")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                RoleSelectionCard(
                    role: Role.looking.rawValue,
                    title: "I'm looking for a place",
                    description: "Buying or renting a home",
                    icon: "house.fill",
                    isSelected: selectedRole == .looking
                ) { selectedRole = .looking }

                RoleSelectionCard(
                    role: Role.selling.rawValue,
                    title: "I'm selling my home",
                    description: "List and sell a property",
                    icon: "dollarsign.circle.fill",
                    isSelected: selectedRole == .selling
                ) { selectedRole = .selling }

                RoleSelectionCard(
                    role: Role.browsing.rawValue,
                    title: "I'm just browsing",
                    description: "Explore neighborhoods, listings, and insights",
                    icon: "sparkles",
                    isSelected: selectedRole == .browsing
                ) { selectedRole = .browsing }

                RoleSelectionCard(
                    role: Role.partner.rawValue,
                    title: "I want to partner",
                    description: "Partner with HOMEY",
                    icon: "briefcase.fill",
                    isSelected: selectedRole == .partner
                ) { selectedRole = .partner }

                RoleSelectionCard(
                    role: Role.agent.rawValue,
                    title: "I work in real estate",
                    description: "Agent, broker, or industry pro",
                    icon: "person.badge.key.fill",
                    isSelected: selectedRole == .agent
                ) {
                    selectedRole = .agent
                    if let url = URL(string: "https://agent.homey.com") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var agentConnectView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Are you working with an agent?")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                Button {
                    withAnimation {
                        isWorkingWithAgent = true
                        agentMatchingWanted = false
                    }
                    createClientInviteCode()
                } label: { choiceButtonLabel(text: "Yes", isSelected: isWorkingWithAgent == true) }

                Button {
                    withAnimation {
                        isWorkingWithAgent = false
                        agentMatchingWanted = true
                    }
                } label: { choiceButtonLabel(text: "No", isSelected: isWorkingWithAgent == false) }
            }

            if isWorkingWithAgent == true {
                Divider().background(Color.white.opacity(0.15))
                Text("Share this QR or link with your agent to connect.")
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 20) {
                    if let qrImage = generateQRCode(from: "\(agentPortalBaseURL.absoluteString)?code=\(inviteCode)") {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                            .accessibilityLabel("QR to connect with your agent")
                    }

                    ShareLink(item: URL(string: "\(agentPortalBaseURL.absoluteString)?code=\(inviteCode)")!) {
                        Label("Share Link", systemImage: "square.and.arrow.up")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }

    private var locationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Where do you live?")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                Picker("Select your city", selection: Binding(get: {
                    selectedCity ?? majorUSCities.first ?? ""
                }, set: { newVal in
                    selectedCity = newVal
                })) {
                    ForEach(majorUSCities, id: \.self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)

                Text("Quick picks")
                    .font(.caption).foregroundStyle(.white.opacity(0.8))

                HStack(spacing: 10) {
                    quickPickCityButton("New York City")
                    quickPickCityButton("Los Angeles")
                    quickPickCityButton("Miami")
                }
            }
        }
        .onChange(of: selectedCity) { _, city in
            if let city {
                preferencesRepo.geographicFocus = [city]
            }
        }
    }

    private func quickPickCityButton(_ city: String) -> some View {
        Button {
            selectedCity = city
        } label: {
            Text(city)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var smartDefaultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Smart Defaults")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("We’ve turned on these so you don’t miss important steps. You can change anytime.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))

            PreferenceSection(title: "Personalization", icon: "slider.horizontal.3") {
                VStack(spacing: 14) {
                    PreferenceToggle(
                        title: "Timeline nudges",
                        description: "Helpful reminders tailored to your timeline",
                        isOn: $smartTimelineNudges
                    )
                    PreferenceToggle(
                        title: "Checklist progress",
                        description: "Track and visualize your progress",
                        isOn: $smartChecklistProgress
                    )
                    PreferenceToggle(
                        title: "Key updates",
                        description: "Stay in the loop on important changes",
                        isOn: $smartKeyUpdates
                    )
                }
            }
        }
    }

    private var completionView: some View {
        VStack(spacing: 26) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.white)

            Text("You’re all set!")
                .font(.custom("PlayfairDisplay-Bold", size: 28))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Your personalized HOMEY experience starts now.")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Controls

    private var controlView: some View {
        HStack {
            Button(action: backAction) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(step == .welcome ? 0.4 : 0.9))
            .disabled(step == .welcome)

            Spacer()

            Button {
                Task { await nextAction() }
            } label: {
                Text(step == .completion ? "Finish" : "Continue")
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .disabled(!canGoNext)
        }
        .frame(maxWidth: 720)
    }

    private func backAction() {
        guard step.rawValue > 0 else { return }
        step = OnboardingStep(rawValue: step.rawValue - 1) ?? step
    }

    private func nextAction() async {
        guard canGoNext else { return }
        switch step {
        case .welcome:
            step = .basicInfo
        case .basicInfo:
            isSaving = true
            do {
                try await saveBasicInfoToSupabase()
                isSaving = false
                step = .roleSelection
            } catch {
                isSaving = false
            }
        case .roleSelection:
            step = .agentConnect
        case .agentConnect:
            isSaving = true
            do {
                try await saveAgentPreference()
                isSaving = false
                step = .location
            } catch {
                isSaving = false
            }
        case .location:
            step = .smartDefaults
        case .smartDefaults:
            step = .completion
        case .completion:
            UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
            onComplete()
        }
    }

    private var canGoNext: Bool {
        switch step {
        case .welcome:
            return true
        case .basicInfo:
            let fnOk = !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            let lnOk = !lastName.trimmingCharacters(in: .whitespaces).isEmpty
            let emailOk = email.contains("@") && email.contains(".")
            let phoneOk = phone.trimmingCharacters(in: .whitespaces).count >= 7
            return fnOk && lnOk && emailOk && phoneOk
        case .roleSelection:
            return selectedRole != nil
        case .agentConnect:
            return isWorkingWithAgent != nil
        case .location:
            return selectedCity != nil
        case .smartDefaults:
            return true
        case .completion:
            return true
        }
    }

    // MARK: - Persistence helpers

    private func saveBasicInfoToSupabase() async throws {
        let segment = segmentForRole(selectedRole)
        let update = ProfileUpdateRequest(
            fullName: "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces),
            phoneNumber: phone,
            preferredComms: nil,
            workingWithAgent: nil,
            clientSegment: segment,
            firstName: firstName,
            lastName: lastName,
            occupation: nil,
            income: nil,
            liquidAssets: nil,
            reasonForPurchase: nil,
            employmentType: nil,
            pets: nil,
            needsElevator: nil,
            preferredNeighborhood: selectedCity,
            bedrooms: nil,
            bathrooms: nil,
            propertyTenure: nil
        )
        _ = try await profilesRepo.updateProfile(update)
    }

    private func saveAgentPreference() async throws {
        let update = ProfileUpdateRequest(
            fullName: nil,
            phoneNumber: nil,
            preferredComms: nil,
            workingWithAgent: isWorkingWithAgent,
            clientSegment: nil,
            firstName: nil,
            lastName: nil,
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
        _ = try await profilesRepo.updateProfile(update)
    }

    private func segmentForRole(_ role: Role?) -> String? {
        guard let role else { return nil }
        switch role {
        case .looking: return "buyer"
        case .selling: return "seller"
        case .browsing: return "renter"
        case .partner, .agent: return nil
        }
    }

    private func supabaseURL() -> URL? {
        if let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String {
            return URL(string: s)
        }
        return nil
    }

    private func createClientInviteCode() {
        Task {
            guard inviteCode.isEmpty, let base = supabaseURL() else { return }
            do {
                let client = AppSessionManager.shared.supabaseClient
                let session = try await client.auth.session
                var req = URLRequest(url: base.appendingPathComponent("functions/v1/create_client_invite"))
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
                req.httpBody = Data("{}".utf8)
                let (data, resp) = try await URLSession.shared.data(for: req)
                guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else { return }
                if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let ok = obj["ok"] as? Bool, ok,
                   let code = obj["code"] as? String {
                    inviteCode = code
                }
            } catch {
                // If failing silently, agent can still be matched later
            }
        }
    }

    // MARK: - Helpers

    private func choiceButtonLabel(text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
            )
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        guard let outputImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let cgimg = context.createCGImage(outputImage.transformed(by: transform), from: outputImage.extent)
        else { return nil }
        return UIImage(cgImage: cgimg)
    }
}

private struct FieldLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundStyle(.white.opacity(0.8))
    }
}