import SwiftUI

// MARK: - Mock Data Store
class TeachHomeyDataStore {
    static let shared = TeachHomeyDataStore()
    
    let aiQuestions: [AIQuestion] = [
        AIQuestion(id: "ai_q_1", avatar: .scout, category: .neighborhood, questionText: "We noticed you search along the L train—is this your primary commute line?", options: ["Yes", "Sometimes", "No"]),
        AIQuestion(id: "ai_q_2", avatar: .paige, category: .basics, questionText: "You qualify for rentals up to $4k, but you're saving listings around $3k. Prefer to stay on the lower end?", options: ["Yes, please", "Show me all"]),
        AIQuestion(id: "ai_q_3", avatar: .scout, category: .design, questionText: "80% of your saved listings have a balcony. Should we make this a must-have?", options: ["Must-have!", "Nice to have"]),
        AIQuestion(id: "ai_q_4", avatar: .scout, category: .lifestyle, questionText: "You're viewing a lot of pet-friendly places. Do you have any furry friends we should know about?", options: ["Yes, a dog", "Yes, a cat", "No pets"])
    ]
    
    func questions(for category: TeachingSection) -> [AIQuestion] {
        aiQuestions.filter { $0.category == category }
    }
}


// MARK: - Main Modal View
struct TeachHomeyModal: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TeachHomeyViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        if viewModel.isAgentMode {
                            clientSelectionView
                        }
                        CategoryGridView()
                        AIAdaptiveQuestionsView()
                        
                        // Add AI Question Queue at the bottom
                        AIQuestionQueueView()
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.isAgentMode ? "Teach HOMEY - Agent Mode" : "Teach HOMEY")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if viewModel.isAgentMode {
                            viewModel.saveClientPreferences()
                        } else {
                            viewModel.savePreferences()
                        }
                        // Show a confirmation instead of dismissing
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .environmentObject(viewModel)
        .task { await viewModel.detectCurrentUserRole() }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.isAgentMode ? "Teach HOMEY - Agent Mode" : "Teach HOMEY")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(viewModel.isAgentMode ? "Manage your clients' preferences" : "Your answers build the foundation for personalized recommendations and smart matching.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var clientSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Client")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.clients, id: \.id) { client in
                        clientButton(for: client)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
    
    private func clientButton(for client: Profile) -> some View {
        Button(action: {
            viewModel.selectClient(client.id)
        }) {
            VStack {
                Text(client.full_name ?? "Unknown")
                    .font(.headline)
                Text(client.email ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.selectedClient == client.id ? Color.blue : Color(.secondarySystemBackground))
            )
        }
    }
}

// MARK: - Core Components
struct CategoryGridView: View {
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(TeachingSection.allCases, id: \.self) { section in
                NavigationLink(destination: destinationForSection(section)) {
                    CategoryTileView(section: section)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func destinationForSection(_ section: TeachingSection) -> some View {
        switch section {
        case .lifestyle: LifestylePreferencesView()
        case .neighborhood: NeighborhoodPrioritiesView()
        case .design: DesignStyleView()
        case .basics: BasicsPreferencesView()
        }
    }
}

struct AIAdaptiveQuestionsView: View {
    @EnvironmentObject var viewModel: TeachHomeyViewModel
    private let allQuestions = TeachHomeyDataStore.shared.aiQuestions
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Just for You")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(allQuestions.count) New")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue))
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(allQuestions) { question in
                    AIQuestionCard(
                        question: question,
                        selectedOption: viewModel.aiQuestionAnswers[question.id],
                        onSelectAnswer: { answer in
                            viewModel.updateAIAnswer(for: question.id, answer: answer)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Enums & Models
enum TeachingSection: String, CaseIterable, Codable {
    case lifestyle = "Lifestyle", neighborhood = "Neighborhood", design = "Design", basics = "Basics"
    
    var icon: String {
        switch self {
        case .lifestyle: "person.2.fill"
        case .neighborhood: "map.fill"
        case .design: "wand.and.stars"
        case .basics: "doc.text.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .lifestyle: .blue
        case .neighborhood: .green
        case .design: .purple
        case .basics: .orange
        }
    }
}

enum HomeyAvatar: String, Codable {
    case scout, paige, isla
    
    var icon: String {
        switch self {
        case .scout: "compass.drawing"
        case .paige: "doc.on.clipboard"
        case .isla: "chart.pie"
        }
    }
    
    var color: Color {
        switch self {
        case .scout: .green
        case .paige: .orange
        case .isla: .cyan
        }
    }
    
    var name: String {
        self.rawValue.prefix(1).uppercased() + self.rawValue.dropFirst()
    }
}

struct AIQuestion: Identifiable, Codable {
    let id: String // Use a stable ID for persistence
    let avatar: HomeyAvatar
    let category: TeachingSection
    let questionText: String
    let options: [String]
}

// MARK: - UI Tile & Card Views
struct CategoryTileView: View {
    let section: TeachingSection
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: section.icon).font(.title).foregroundColor(section.color)
            Text(section.rawValue).font(.headline).fontWeight(.bold).foregroundColor(.primary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.systemGray4), lineWidth: 1))
    }
}

struct AIQuestionCard: View {
    let question: AIQuestion
    var selectedOption: String?
    let onSelectAnswer: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: question.avatar.icon).font(.title2).foregroundColor(question.avatar.color)
                    .frame(width: 40, height: 40).background(question.avatar.color.opacity(0.15)).clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(question.avatar.name).font(.headline)
                    Text(question.category.rawValue).font(.caption).foregroundColor(.secondary)
                }
            }
            Text(question.questionText).font(.subheadline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(question.options, id: \.self) { option in
                        Button(action: { onSelectAnswer(option) }) {
                            Text(option).font(.caption).fontWeight(.semibold)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(selectedOption == option ? question.category.color : Color(.systemGray5))
                                .foregroundColor(selectedOption == option ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}

// MARK: - Preference Section Views (Refactored)
struct LifestylePreferencesView: View {
    @EnvironmentObject var viewModel: TeachHomeyViewModel
    private let aiQuestions = TeachHomeyDataStore.shared.questions(for: .lifestyle)
    
    var body: some View {
        Form {
            Section(header: Text("Foundational Questions")) {
                Toggle("I work from home", isOn: $viewModel.workFromHome)
                Toggle("I have pets", isOn: $viewModel.hasPets)
            }
            
            if !aiQuestions.isEmpty {
                Section(header: Text("AI-Powered Questions")) {
                    ForEach(aiQuestions) { question in
                        AIQuestionCard(
                            question: question,
                            selectedOption: viewModel.aiQuestionAnswers[question.id],
                            onSelectAnswer: { answer in
                                viewModel.updateAIAnswer(for: question.id, answer: answer)
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Lifestyle")
    }
}

struct NeighborhoodPrioritiesView: View {
    @EnvironmentObject var viewModel: TeachHomeyViewModel
    private let aiQuestions = TeachHomeyDataStore.shared.questions(for: .neighborhood)

    var body: some View {
        Form {
            Section(header: Text("Foundational Questions")) {
                VStack {
                    Text("Walkability Score Importance: \(Int(viewModel.walkability))")
                    Slider(value: $viewModel.walkability, in: 1...5, step: 1)
                }
                VStack {
                    Text("Safety Rating Importance: \(Int(viewModel.safetyRating))")
                    Slider(value: $viewModel.safetyRating, in: 1...5, step: 1)
                }
            }
            
            if !aiQuestions.isEmpty {
                Section(header: Text("AI-Powered Questions")) {
                    ForEach(aiQuestions) { question in
                        AIQuestionCard(
                            question: question,
                            selectedOption: viewModel.aiQuestionAnswers[question.id],
                            onSelectAnswer: { answer in
                                viewModel.updateAIAnswer(for: question.id, answer: answer)
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Neighborhood")
    }
}

struct DesignStyleView: View {
    @EnvironmentObject var viewModel: TeachHomeyViewModel
    private let aiQuestions = TeachHomeyDataStore.shared.questions(for: .design)
    private let styles = ["Modern", "Industrial", "Minimalist", "Bohemian"]
    
    var body: some View {
        Form {
            Section(header: Text("Foundational Questions")) {
                ForEach(styles, id: \.self) { style in
                    Button(action: {
                        if viewModel.selectedStyles.contains(style) { viewModel.selectedStyles.remove(style) }
                        else { viewModel.selectedStyles.insert(style) }
                    }) {
                        HStack {
                            Text(style)
                            Spacer()
                            if viewModel.selectedStyles.contains(style) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }.foregroundColor(.primary)
                }
            }
            
            if !aiQuestions.isEmpty {
                Section(header: Text("AI-Powered Questions")) {
                    ForEach(aiQuestions) { question in
                        AIQuestionCard(
                            question: question,
                            selectedOption: viewModel.aiQuestionAnswers[question.id],
                            onSelectAnswer: { answer in
                                viewModel.updateAIAnswer(for: question.id, answer: answer)
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Design")
    }
}

struct BasicsPreferencesView: View {
    @EnvironmentObject var viewModel: TeachHomeyViewModel
    private let aiQuestions = TeachHomeyDataStore.shared.questions(for: .basics)
    
    var body: some View {
        Form {
            Section(header: Text("Foundational Questions")) {
                HStack {
                    Text("Max Rent")
                    Spacer()
                    Text("$\(Int(viewModel.maxRent))/mo")
                }
                Slider(value: $viewModel.maxRent, in: 1000...10000, step: 100)
                DatePicker("Move-in Date", selection: $viewModel.moveInDate, displayedComponents: .date)
            }
            Section(header: Text("Documents & Info")) {
                Text("Income Verification").foregroundColor(.secondary)
                Text("Employment Status").foregroundColor(.secondary)
                Text("Credit Score").foregroundColor(.secondary)
            }
            
            if !aiQuestions.isEmpty {
                Section(header: Text("AI-Powered Questions")) {
                    ForEach(aiQuestions) { question in
                        AIQuestionCard(
                            question: question,
                            selectedOption: viewModel.aiQuestionAnswers[question.id],
                            onSelectAnswer: { answer in
                                viewModel.updateAIAnswer(for: question.id, answer: answer)
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Basics")
    }
}

// MARK: - Preview
#Preview {
    TeachHomeyModal()
}