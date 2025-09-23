import SwiftUI

// MARK: - Predictive UI Components

/// Adaptive container that changes layout based on predicted user behavior
struct PredictiveContainer<Content: View>: View {
    @StateObject private var predictiveEngine = PredictiveUIEngine()
    @State private var animationPhase: Double = 0
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Adaptive background that responds to predictions
            adaptiveBackground
            
            // Main content with predictive layout
            VStack(spacing: adaptiveSpacing) {
                // Contextual suggestions bar
                if !predictiveEngine.contextualSuggestions.isEmpty {
                    PredictiveSuggestionsBar(suggestions: predictiveEngine.contextualSuggestions)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }
                
                // Adaptive content layout
                adaptiveContentLayout
            }
            
            // Floating predictive actions
            FloatingPredictiveActions(actions: predictiveEngine.predictedActions)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: predictiveEngine.adaptiveLayout)
        .onAppear {
            startPredictiveAnimations()
        }
    }
    
    private var adaptiveBackground: some View {
        Group {
            switch predictiveEngine.adaptiveLayout {
            case .spatialOptimized:
                SpatialGradientBackground()
            case .actionFocused:
                DynamicActionBackground()
            case .contentRich:
                ContentRichBackground()
            case .minimalist:
                MinimalistBackground()
            default:
                StandardBackground()
            }
        }
        .ignoresSafeArea()
    }
    
    private var adaptiveContentLayout: some View {
        Group {
            switch predictiveEngine.adaptiveLayout {
            case .spatialOptimized:
                SpatialOptimizedLayout { content }
            case .actionFocused:
                ActionFocusedLayout { content }
            case .contentRich:
                ContentRichLayout { content }
            case .minimalist:
                MinimalistLayout { content }
            default:
                StandardLayout { content }
            }
        }
    }
    
    private var adaptiveSpacing: CGFloat {
        switch predictiveEngine.adaptiveLayout {
        case .minimalist: return 8
        case .actionFocused: return 12
        case .contentRich: return 16
        case .spatialOptimized: return 20
        default: return 16
        }
    }
    
    private func startPredictiveAnimations() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            animationPhase = 1.0
        }
    }
}

// MARK: - Predictive Suggestions Bar

struct PredictiveSuggestionsBar: View {
    let suggestions: [ContextualSuggestion]
    @State private var selectedSuggestion: ContextualSuggestion?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(suggestions) { suggestion in
                    PredictiveSuggestionCard(suggestion: suggestion) {
                        handleSuggestionTap(suggestion)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
    
    private func handleSuggestionTap(_ suggestion: ContextualSuggestion) {
        selectedSuggestion = suggestion
        // Handle suggestion action
        switch suggestion.action {
        case .navigateToSchedule:
            // Navigate to schedule
            break
        case .openClientChat:
            // Open client chat
            break
        case .startPropertyTour:
            // Start property tour
            break
        case .reviewAnalytics:
            // Review analytics
            break
        case .customAction(let action):
            // Handle custom action
            break
        }
    }
}

struct PredictiveSuggestionCard: View {
    let suggestion: ContextualSuggestion
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(suggestion.title)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Confidence indicator
                    Circle()
                        .fill(confidenceColor)
                        .frame(width: 8, height: 8)
                }
                
                Text(suggestion.description)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: 140, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isPressed ? 0.3 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var confidenceColor: Color {
        if suggestion.confidence > 0.8 {
            return .green
        } else if suggestion.confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Floating Predictive Actions

struct FloatingPredictiveActions: View {
    let actions: [String]
    @State private var showingActions = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                if showingActions && !actions.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(actions.prefix(3), id: \.self) { action in
                            FloatingActionButton(action: action)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                // Main floating action button
                Button(action: toggleActions) {
                    Image(systemName: showingActions ? "xmark" : "sparkles")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .rotationEffect(.degrees(showingActions ? 45 : 0))
                .scaleEffect(showingActions ? 1.1 : 1.0)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 100)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showingActions)
        .onChange(of: actions) { _ in
            if !actions.isEmpty && !showingActions {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0)) {
                    showingActions = true
                }
            }
        }
    }
    
    private func toggleActions() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showingActions.toggle()
        }
    }
}

struct FloatingActionButton: View {
    let action: String
    @State private var isPressed = false
    
    var body: some View {
        Button(action: handleAction) {
            HStack(spacing: 8) {
                Image(systemName: actionIcon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(actionTitle)
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(actionColor.opacity(0.9))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var actionIcon: String {
        let a = action.lowercased()
        if a.contains("spatial") { return "cube.transparent" }
        if a.contains("action") { return "bolt.fill" }
        if a.contains("content") || a.contains("browse") { return "doc.text.magnifyingglass" }
        if a.contains("message") || a.contains("chat") { return "message.fill" }
        if a.contains("analysis") || a.contains("analyz") { return "chart.bar.fill" }
        return "sparkles"
    }
    
    private var actionTitle: String {
        let a = action.lowercased()
        if a.contains("spatial") { return "3D View" }
        if a.contains("action") { return "Quick Action" }
        if a.contains("content") || a.contains("browse") { return "Browse" }
        if a.contains("message") || a.contains("chat") { return "Message" }
        if a.contains("analysis") || a.contains("analyz") { return "Analyze" }
        return "Action"
    }
    
    private var actionColor: Color {
        let a = action.lowercased()
        if a.contains("spatial") { return .purple }
        if a.contains("action") { return .orange }
        if a.contains("content") || a.contains("browse") { return .blue }
        if a.contains("message") || a.contains("chat") { return .green }
        if a.contains("analysis") || a.contains("analyz") { return .red }
        return .indigo
    }
    
    private func handleAction() {
        print("Executing predicted action: \(action)")
    }
}

// MARK: - Adaptive Layout Components

struct SpatialOptimizedLayout<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct ActionFocusedLayout<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
            )
    }
}

struct ContentRichLayout<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 16)
    }
}

struct MinimalistLayout<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 32)
    }
}

struct StandardLayout<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 20)
    }
}

// MARK: - Adaptive Backgrounds

struct SpatialGradientBackground: View {
    @State private var animationPhase: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.2),
                    Color.cyan.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated particles
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...8))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 3...8))
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.2),
                        value: animationPhase
                    )
            }
        }
        .onAppear {
            animationPhase = 1.0
        }
    }
}

struct DynamicActionBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.orange.opacity(0.2),
                Color.red.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ContentRichBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.1),
                Color.indigo.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct MinimalistBackground: View {
    var body: some View {
        Color.clear
    }
}

struct StandardBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.05),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}