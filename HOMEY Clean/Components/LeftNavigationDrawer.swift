//
//  LeftNavigationDrawer.swift
//  HOMEY Clean
//
//  Left-side navigation drawer with compact, tab-like layout
//

import SwiftUI

// MARK: - Drawer Container

struct LeftNavigationDrawer: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var router: AppRouter
    
    // Compact drawer width to feel like a “tab”
    private var drawerWidth: CGFloat {
        min(UIScreen.main.bounds.width * 0.78, 300)
    }
    private let closeDragThreshold: CGFloat = 90
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { closeDrawer() }
                    .transition(.opacity)
            }
            
            HStack(spacing: 0) {
                DrawerSurface {
                    DrawerContent(
                        route: router.route,
                        onSelect: handleRouteSelection
                    )
                    .environmentObject(session)
                }
                .frame(width: drawerWidth)
                .offset(x: isPresented ? dragOffset : -drawerWidth + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation < 0 { dragOffset = translation }
                        }
                        .onEnded { value in
                            let predicted = value.predictedEndTranslation.width
                            if value.translation.width < -closeDragThreshold || predicted < -closeDragThreshold {
                                closeDrawer()
                            } else {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                
                Spacer(minLength: 0)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: isPresented)
    }
    
    private func closeDrawer() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
            isPresented = false
            dragOffset = 0
        }
    }
    
    private func handleRouteSelection(_ route: AppRoute?) {
        router.route = route
        closeDrawer()
    }
}

// MARK: - Drawer Surface

private struct DrawerSurface<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.96),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.25), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 6)
        }
    }
}

// MARK: - Drawer Content (Compact)

private struct DrawerContent: View {
    let route: AppRoute?
    let onSelect: (AppRoute?) -> Void
    @EnvironmentObject private var session: AppSessionManager
    @State private var showMore: Bool = false
    
    // AI search state
    @State private var searchText: String = ""
    @State private var showSuggestions: Bool = false
    @State private var suggestedRoutes: [Suggestion] = []
    
    // Rotating placeholder
    @State private var placeholderIndex: Int = 0
    @State private var placeholderVisible: Bool = true
    private let placeholderPhrases: [String] = [
        "What are we looking for?",
        "Type anything here",
        "Try “upload documents”",
        "Ask me for help",
        "Search by address"
    ]
    private let placeholderInterval: TimeInterval = 2.8
    
    struct Suggestion: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let route: AppRoute?
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DrawerHeaderCompact(
                greeting: session.getContextualGreeting(),
                subtitle: "Navigate quickly"
            )
            
            // AI Search bar + suggestions
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text(placeholderPhrases[placeholderIndex % placeholderPhrases.count])
                                .foregroundColor(.white.opacity(0.5))
                                .opacity(placeholderVisible ? 1 : 0)
                                .animation(.easeInOut(duration: 0.35), value: placeholderVisible)
                        }
                        TextField("", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                            .onChange(of: searchText) { _, newValue in
                                updateSuggestions(for: newValue)
                            }
                            .onSubmit {
                                submitSearch()
                            }
                    }
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            showSuggestions = false
                            suggestedRoutes = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .accessibilityLabel("Clear search")
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .onAppear {
                    startPlaceholderRotation()
                }
                
                if showSuggestions && !suggestedRoutes.isEmpty {
                    VStack(spacing: 6) {
                        ForEach(suggestedRoutes) { suggestion in
                            Button {
                                onSelect(suggestion.route)
                                // Clear after selection
                                searchText = ""
                                showSuggestions = false
                                suggestedRoutes = []
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(suggestion.color.opacity(0.18))
                                            .frame(width: 30, height: 30)
                                        Image(systemName: suggestion.icon)
                                            .foregroundColor(suggestion.color)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(suggestion.title)
                                            .foregroundColor(.white)
                                            .font(.subheadline.weight(.semibold))
                                        Text(suggestion.subtitle)
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    // Primary (top-priority, always visible)
                    DrawerSectionCompact(title: "Primary") {
                        DrawerItemCompact(
                            title: "Home",
                            icon: "house.fill",
                            color: .cyan,
                            isActive: route == nil
                        ) { onSelect(nil) }
                        
                        DrawerItemCompact(
                            title: "Search",
                            icon: "magnifyingglass",
                            color: .green,
                            isActive: route == .search
                        ) { onSelect(.search) }
                        
                        DrawerItemCompact(
                            title: "Documents",
                            icon: "doc.fill",
                            color: .orange,
                            isActive: route == .documents
                        ) { onSelect(.documents) }
                    }
                    
                    // Secondary (collapsed under “More”)
                    DisclosureGroup(isExpanded: $showMore) {
                        DrawerGrid {
                            DrawerGridItem(
                                title: "Insights",
                                icon: "chart.bar.fill",
                                color: .pink,
                                isActive: route == .insights
                            ) { onSelect(.insights) }
                            
                            DrawerGridItem(
                                title: "Directory",
                                icon: "folder.fill",
                                color: .indigo,
                                isActive: route == .directory
                            ) { onSelect(.directory) }
                            
                            DrawerGridItem(
                                title: "Matchmaker",
                                icon: "heart.fill",
                                color: .purple,
                                isActive: route == .matchmaker
                            ) { onSelect(.matchmaker) }
                            
                            DrawerGridItem(
                                title: "Vision",
                                icon: "paintbrush.fill",
                                color: .teal,
                                isActive: route == .vision
                            ) { onSelect(.vision) }
                            
                            DrawerGridItem(
                                title: "Education",
                                icon: "graduationcap.fill",
                                color: .mint,
                                isActive: route == .education
                            ) { onSelect(.education) }
                        }
                        .padding(.top, 6)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.white.opacity(0.85))
                            Text("More")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white.opacity(0.6))
                                .rotationEffect(.degrees(showMore ? 180 : 0))
                                .animation(.spring(response: 0.35, dampingFraction: 0.9), value: showMore)
                        }
                        .contentShape(Rectangle())
                        .padding(.horizontal, 6) // slightly larger tap target
                        .padding(.vertical, 8)
                    }
                    .tint(.white)
                    .padding(.top, 4)
                    
                    Divider().overlay(Color.white.opacity(0.08))
                        .padding(.vertical, 6)
                    
                    // Account
                    DrawerSectionCompact(title: "Account") {
                        DrawerItemCompact(
                            title: "Settings",
                            icon: "gearshape.fill",
                            color: .gray,
                            isActive: route == .settings
                        ) { onSelect(.settings) }
                        
                        DrawerItemCompact(
                            title: "Help & Support",
                            icon: "questionmark.circle.fill",
                            color: .cyan,
                            isActive: route == .helpSupport
                        ) { onSelect(.helpSupport) }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Placeholder rotation
    private func startPlaceholderRotation() {
        // Animate fade-out -> index increment -> fade-in loop while empty
        Timer.scheduledTimer(withTimeInterval: placeholderInterval, repeats: true) { _ in
            guard searchText.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                placeholderVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                placeholderIndex = (placeholderIndex + 1) % placeholderPhrases.count
                withAnimation(.easeInOut(duration: 0.25)) {
                    placeholderVisible = true
                }
            }
        }
    }
    
    // MARK: - Submit handler
    private func submitSearch() {
        let assumed = inferRoute(for: searchText)
        HapticsManager.shared.impact(.light)
        onSelect(assumed)
        // Clear UI state
        searchText = ""
        showSuggestions = false
        suggestedRoutes = []
    }
    
    // MARK: - Intent inference
    private func inferRoute(for text: String) -> AppRoute {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return .search }
        
        // Documents intents
        if q.contains("1040") || q.contains("w-2") || q.contains("w2") || q.contains("tax") {
            return .documents
        }
        if q.contains("bank statement") || q.contains("bank statements") || q.contains("statement") {
            return .documents
        }
        if q.contains("upload") || q.contains("pdf") || q.contains("vault") || q.contains("document") {
            return .documents
        }
        
        // Directory intents (lender, mortgage, loan officer)
        if q.contains("lender") || q.contains("mortgage") || q.contains("loan officer") || q.contains("broker") {
            return .directory
        }
        
        // Address-like heuristic: contains a number and a street-type token or looks like an address
        let streetTokens = ["st", "street", "ave", "avenue", "blvd", "boulevard", "rd", "road", "dr", "drive", "ln", "lane", "ct", "court", "pl", "place", "way"]
        let hasNumber = q.rangeOfCharacter(from: .decimalDigits) != nil
        let hasStreetToken = streetTokens.contains { token in
            q.contains(" \(token)") || q.hasSuffix(token)
        }
        if hasNumber && hasStreetToken {
            return .search
        }
        // If it looks like a ZIP code or city/hood query, also treat as search
        if q.count == 5, Int(q) != nil { return .search }
        
        // Default: search
        return .search
    }
    
    // MARK: - AI Navigation Heuristics
    private func updateSuggestions(for text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            suggestedRoutes = []
            showSuggestions = false
            return
        }
        
        // Simple keyword-intent mapping. Replace with an AI service later.
        let lower = trimmed.lowercased()
        var results: [Suggestion] = []
        
        func add(_ title: String, _ subtitle: String, _ icon: String, _ color: Color, _ route: AppRoute?) {
            results.append(Suggestion(title: title, subtitle: subtitle, icon: icon, color: color, route: route))
        }
        
        // Prioritize the top inferred route as first suggestion
        let assumed = inferRoute(for: lower)
        switch assumed {
        case .documents:
            add("Documents", "Open your document vault", "doc.fill", .orange, .documents)
        case .directory:
            add("Directory", "Find lenders and pros", "folder.fill", .indigo, .directory)
        case .search, .discover, .insights, .vision, .settings, .profile, .matchmaker, .arFeatures, .helpSupport, .education, .settingsDetail:
            add("Search", "Find neighborhoods, listings, and more", "magnifyingglass", .green, .search)
        }
        
        // Home
        if lower.contains("home") || lower.contains("dashboard") || lower == "h" {
            add("Home", "Go to your dashboard", "house.fill", .cyan, nil)
        }
        // Search
        if lower.contains("search") || lower.contains("find") || lower.contains("browse") {
            add("Search", "Find neighborhoods, listings, and more", "magnifyingglass", .green, .search)
        }
        // Documents (extended)
        if lower.contains("doc") || lower.contains("upload") || lower.contains("pdf") || lower.contains("vault") ||
            lower.contains("1040") || lower.contains("w-2") || lower.contains("w2") || lower.contains("tax") ||
            lower.contains("bank statement") || lower.contains("bank statements") {
            add("Documents", "Open your document vault", "doc.fill", .orange, .documents)
        }
        // Directory (extended)
        if lower.contains("directory") || lower.contains("files") || lower.contains("folders") ||
            lower.contains("lender") || lower.contains("mortgage") || lower.contains("loan officer") || lower.contains("broker") {
            add("Directory", "Browse your directory", "folder.fill", .indigo, .directory)
        }
        // Insights
        if lower.contains("insight") || lower.contains("analytics") || lower.contains("stats") || lower.contains("trends") {
            add("Insights", "View your insights and analytics", "chart.bar.fill", .pink, .insights)
        }
        // Matchmaker
        if lower.contains("match") || lower.contains("recommend") || lower.contains("suggest") || lower.contains("love") {
            add("Matchmaker", "See recommended options", "heart.fill", .purple, .matchmaker)
        }
        // Vision
        if lower.contains("design") || lower.contains("vision") || lower.contains("paint") {
            add("Vision", "Explore creative vision tools", "paintbrush.fill", .teal, .vision)
        }
        // Education
        if lower.contains("learn") || lower.contains("education") || lower.contains("guide") || lower.contains("tutorial") {
            add("Education", "Learn with guides and tutorials", "graduationcap.fill", .mint, .education)
        }
        // Settings
        if lower.contains("settings") || lower.contains("preferences") || lower.contains("account") {
            add("Settings", "Manage your preferences", "gearshape.fill", .gray, .settings)
        }
        // Help
        if lower.contains("help") || lower.contains("support") || lower.contains("contact") || lower.contains("faq") {
            add("Help & Support", "Get assistance and FAQs", "questionmark.circle.fill", .cyan, .helpSupport)
        }
        
        // Address-like fallback -> Search
        let streetTokens = ["st", "street", "ave", "avenue", "blvd", "boulevard", "rd", "road", "dr", "drive", "ln", "lane", "ct", "court", "pl", "place", "way"]
        let hasNumber = lower.rangeOfCharacter(from: .decimalDigits) != nil
        let hasStreetToken = streetTokens.contains { token in
            lower.contains(" \(token)") || lower.hasSuffix(token)
        }
        if results.isEmpty || (hasNumber && hasStreetToken) {
            add("Search", "Find by address or neighborhood", "magnifyingglass", .green, .search)
        }
        
        // Deduplicate by title, keep first occurrence
        var seen = Set<String>()
        suggestedRoutes = results.filter { seen.insert($0.title).inserted }.prefix(5).map { $0 }
        showSuggestions = !suggestedRoutes.isEmpty
    }
}

// MARK: - Compact Header

private struct DrawerHeaderCompact: View {
    let greeting: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.25))
                .frame(width: 40, height: 4)
                .padding(.top, 10)
                .accessibilityHidden(true)
            
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                        .shadow(color: .cyan.opacity(0.25), radius: 6, x: 0, y: 3)
                    Image(systemName: "person.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting.isEmpty ? "Welcome" : greeting)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 6)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.85), Color.black.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Compact Section

private struct DrawerSectionCompact<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundColor(.white.opacity(0.55))
                .padding(.horizontal, 4)
            content
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Compact Item Row

private struct DrawerItemCompact: View {
    let title: String
    let icon: String
    let color: Color
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.impact(.light)
            action()
        }) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isActive {
                    Circle()
                        .fill(color.opacity(0.9))
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

// MARK: - Grid for “More” items

private struct DrawerGrid<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            content()
        }
    }
}

private struct DrawerGridItem: View {
    let title: String
    let icon: String
    let color: Color
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            HapticsManager.shared.impact(.light)
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.18))
                        .frame(height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

// MARK: - Left Edge Swipe Gesture Modifier

struct LeftEdgeSwipeGesture: ViewModifier {
    @Binding var isDrawerPresented: Bool
    private let edgeWidth: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: edgeWidth)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.startLocation.x < edgeWidth && value.translation.width > 50 {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                        isDrawerPresented = true
                                    }
                                }
                            }
                    ),
                alignment: .leading
            )
    }
}

extension View {
    func leftEdgeSwipe(isDrawerPresented: Binding<Bool>) -> some View {
        modifier(LeftEdgeSwipeGesture(isDrawerPresented: isDrawerPresented))
    }
}

// MARK: - Right Edge Swipe Gesture Modifier

struct RightEdgeSwipeGesture: ViewModifier {
    @Binding var isDrawerOpenToPeek: Bool
    private let edgeWidth: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: edgeWidth)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let screenWidth = UIScreen.main.bounds.width
                                let startFromRight = value.startLocation.x > screenWidth - edgeWidth
                                if startFromRight && value.translation.width < -50 {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                        isDrawerOpenToPeek = true
                                    }
                                }
                            }
                    ),
                alignment: .trailing
            )
    }
}

extension View {
    func rightEdgeSwipe(openBinding: Binding<Bool>) -> some View {
        modifier(RightEdgeSwipeGesture(isDrawerOpenToPeek: openBinding))
    }
}

// MARK: - TextField Placeholder helper

private extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}
