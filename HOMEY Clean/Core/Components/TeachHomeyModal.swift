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
            .foregroundColor(viewModel.selectedClient == client.id ? .white : .primary)
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
            
            // Use the new mood stack style for the “global” adaptive questions feed
            MoodStackQuestionsView(
                questions: allQuestions,
                sectionTint: .blue,
                onAnswer: { qId, answer in
                    viewModel.updateAIAnswer(for: qId, answer: answer)
                }
            )
            .frame(height: 420)
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

// MARK: - Mood Stack (Swipeable) Questions
struct MoodStackQuestionsView: View {
    let questions: [AIQuestion]
    var sectionTint: Color
    var onAnswer: (String, String) -> Void // (questionId, answer)
    
    @State private var index: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showLearningBadge: Bool = false
    
    private let cardCornerRadius: CGFloat = 28
    private let cardShadow: CGFloat = 12
    
    private var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(index) / Double(questions.count)
    }
    
    var body: some View {
        ZStack {
            // Background gradient similar to mock
            LinearGradient(gradient: Gradient(colors: [sectionTint.opacity(0.15), Color.black.opacity(0.05)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            // Card stack
            ZStack {
                ForEach(currentCards().indices, id: \.self) { position in
                    let cardQuestion = currentCards()[position]
                    let isTop = position == 0
                    MoodCard(
                        question: cardQuestion,
                        position: position,
                        totalPeek: min(3, remainingCount()),
                        sectionTint: sectionTint,
                        isTop: isTop,
                        dragOffset: isTop ? dragOffset : .zero
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: cardShadow, x: 0, y: 8)
                    .gesture(
                        isTop ? dragGesture(for: cardQuestion) : nil
                    )
                }
            }
            .padding(.horizontal, 8)
            
            // Overlay UI
            VStack {
                // Progress bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: max(0, CGFloat(progress) * UIScreen.main.bounds.width * 0.8), height: 4)
                        .animation(.easeInOut(duration: 0.25), value: progress)
                }
                .padding(.top, 12)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Instruction and count
                VStack(spacing: 6) {
                    Text("\(min(index + 1, max(index, 0) + (questions.isEmpty ? 0 : 1))) of \(questions.count)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .textCase(.uppercase)
                        .tracking(2)
                    Text("What resonates with you?")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 8)
                
                Spacer()
                
                // Swipe buttons
                HStack(spacing: 24) {
                    circularButton(system: "xmark", style: .secondary) {
                        swipe(.left)
                    }
                    circularButton(system: "heart.fill", style: .primary) {
                        swipe(.right)
                    }
                }
                .padding(.bottom, 16)
            }
            
            // Learning badge
            if showLearningBadge {
                Text("Learning your preferences...")
                    .font(.footnote.weight(.bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.purple.opacity(0.95)))
                    .foregroundColor(.white)
                    .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 6)
                    .transition(AnyTransition.scale.combined(with: .opacity))
                    .position(x: UIScreen.main.bounds.width / 2, y: 80)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background(Color.black.opacity(0.05))
        .onChange(of: index) { _, _ in
            pulseLearning()
        }
    }
    
    private func remainingCount() -> Int {
        max(0, questions.count - index)
    }
    
    private func currentCards() -> [AIQuestion] {
        guard index < questions.count else { return [] }
        let slice = questions[index..<min(questions.count, index + 3)]
        return Array(slice)
    }
    
    private enum SwipeDirection { case left, right }
    
    private func dragGesture(for question: AIQuestion) -> some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 80
                if value.translation.width > threshold {
                    handleSwipe(.right, question: question)
                } else if value.translation.width < -threshold {
                    handleSwipe(.left, question: question)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        dragOffset = .zero
                    }
                }
            }
    }
    
    private func swipe(_ direction: SwipeDirection) {
        guard let q = currentCards().first else { return }
        handleSwipe(direction, question: q)
    }
    
    private func handleSwipe(_ direction: SwipeDirection, question: AIQuestion) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            // Map swipe to an answer string to keep backend unchanged.
            // Right swipe picks the first option (treat as "love"); left swipe skips (store "Skip" if you want traceability).
            let answer: String
            switch direction {
            case .right:
                answer = question.options.first ?? "Yes"
            case .left:
                // You could omit calling onAnswer for skip; here we store an explicit skip marker for analytics.
                answer = "Skip"
            }
            onAnswer(question.id, answer)
            dragOffset = .zero
            index = min(index + 1, questions.count)
        }
    }
    
    private func pulseLearning() {
        withAnimation(.easeOut(duration: 0.15)) {
            showLearningBadge = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeIn(duration: 0.25)) {
                showLearningBadge = false
            }
        }
    }
    
    private enum CircleStyle { case primary, secondary }
    @ViewBuilder
    private func circularButton(system: String, style: CircleStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.title3.weight(.bold))
                .foregroundColor(style == .primary ? Color(.systemBackground) : .white)
                .frame(width: 64, height: 64)
                .background(
                    Circle()
                        .fill(style == .primary ? Color.white : Color.white.opacity(0.15))
                )
                .overlay(
                    Circle()
                        .stroke(style == .primary ? Color.white : Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in
                // Tactile press feel
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {}
            }
        )
    }
}

private struct MoodCard: View {
    let question: AIQuestion
    let position: Int // 0 top, 1 second, 2 third
    let totalPeek: Int
    let sectionTint: Color
    let isTop: Bool
    let dragOffset: CGSize
    
    private var scale: CGFloat {
        switch position {
        case 0: return 1.0
        case 1: return 0.96
        default: return 0.92
        }
    }
    private var verticalOffset: CGFloat {
        switch position {
        case 0: return 0
        case 1: return 18
        default: return 36
        }
    }
    private var opacity: Double {
        switch position {
        case 0: return 1.0
        case 1: return 0.6
        default: return 0.35
        }
    }
    
    var body: some View {
        ZStack {
            // Background “scene” colorized by category
            LinearGradient(
                colors: [
                    sectionTint.opacity(0.85),
                    sectionTint.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                LinearGradient(
                    colors: [Color.black.opacity(0.1), Color.black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            
            // Top overlay header
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: question.avatar.icon)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(question.avatar.color.opacity(0.25)))
                    Text(question.avatar.name)
                        .foregroundColor(.white.opacity(0.95))
                        .font(.headline)
                    Spacer()
                    Text(question.category.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.18)))
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                
                Spacer()
            }
            
            // Center icon for vibe
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.25))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
            
            // Bottom content
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                Text(question.questionText)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                    .padding(.bottom, 6)
                
                // Show a short list of options as chips (non-interactive here; selection happens via swipe/buttons)
                HStack(spacing: 8) {
                    ForEach(question.options.prefix(3), id: \.self) { opt in
                        Text(opt)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.white.opacity(0.18)))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 14)
            }
            .padding(18)
        }
        .overlay(
            ZStack {
                // Swipe indicators
                if isTop {
                    Text("✗")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(.white.opacity(max(0, min(1, (-dragOffset.width) / 120)) * 0.9))
                        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
                        .opacity(dragOffset.width < 0 ? 1 : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24)
                    
                    Text("✓")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(.white.opacity(max(0, min(1, (dragOffset.width) / 120)) * 0.9))
                        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
                        .opacity(dragOffset.width > 0 ? 1 : 0)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 24)
                }
            }
        )
        .scaleEffect(scale)
        .offset(y: verticalOffset)
        .opacity(opacity)
        .offset(x: isTop ? dragOffset.width : 0, y: isTop ? dragOffset.height / 6 : 0)
        .rotationEffect(.degrees(isTop ? Double(dragOffset.width / 18) : 0))
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: dragOffset)
    }
}

// MARK: - Preference Section Views (Refactored to use MoodStack)
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
                    MoodStackQuestionsView(
                        questions: aiQuestions,
                        sectionTint: TeachingSection.lifestyle.color,
                        onAnswer: { qId, answer in
                            viewModel.updateAIAnswer(for: qId, answer: answer)
                        }
                    )
                    .frame(height: 420)
                    .listRowInsets(EdgeInsets())
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
                    MoodStackQuestionsView(
                        questions: aiQuestions,
                        sectionTint: TeachingSection.neighborhood.color,
                        onAnswer: { qId, answer in
                            viewModel.updateAIAnswer(for: qId, answer: answer)
                        }
                    )
                    .frame(height: 420)
                    .listRowInsets(EdgeInsets())
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
                    MoodStackQuestionsView(
                        questions: aiQuestions,
                        sectionTint: TeachingSection.design.color,
                        onAnswer: { qId, answer in
                            viewModel.updateAIAnswer(for: qId, answer: answer)
                        }
                    )
                    .frame(height: 420)
                    .listRowInsets(EdgeInsets())
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
                    MoodStackQuestionsView(
                        questions: aiQuestions,
                        sectionTint: TeachingSection.basics.color,
                        onAnswer: { qId, answer in
                            viewModel.updateAIAnswer(for: qId, answer: answer)
                        }
                    )
                    .frame(height: 420)
                    .listRowInsets(EdgeInsets())
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
