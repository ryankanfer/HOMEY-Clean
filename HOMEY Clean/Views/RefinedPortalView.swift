import SwiftUI

struct RefinedPortalView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var router: AppRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @StateObject private var vm = PortalVM()
    @State private var showingAgentContact = false
    
    // Top pull-down gesture state
    @State private var dragOffset: CGFloat = 0
    private let dismissThreshold: CGFloat = 120
    private let dismissVelocity: CGFloat = 800
    
    // Scroll & UI state
    @State private var scrollOffset: CGFloat = 0
    @State private var headerScale: CGFloat = 1.0
    @State private var agentMini: Bool = false
    @State private var showBackToTop: Bool = false
    @State private var showRefreshStatus: Bool = false
    
    // Collapsible sections
    @State private var collapsedFromAgent: Bool = false
    @State private var collapsedPortfolio: Bool = false
    
    // Agent contact hint
    @State private var showAgentHint: Bool = false
    @State private var hasShownAgentHint: Bool = false
    @State private var hintTask: Task<Void, Never>?
    @State private var autoHideContactTask: Task<Void, Never>?
    
    // Status & Alerts demo data
    @State private var sampleAlerts: [StatusAlert] = [
        StatusAlert(id: UUID(), title: "PENDING", message: "Pre-approval letter required", priority: .informational, dueDate: nil),
        StatusAlert(id: UUID(), title: "Upload Tax Returns", message: "Due in 2 days", priority: .urgent, dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())),
        StatusAlert(id: UUID(), title: "Tour Confirmation", message: "Sat 2:00 PM", priority: .important, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()))
    ]
    @State private var sampleDeadlines: [StatusAlert] = [
        StatusAlert(id: UUID(), title: "Bank Statements", message: "Needed for application", priority: .important, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())),
        StatusAlert(id: UUID(), title: "Lease Review", message: "Review draft terms", priority: .informational, dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()))
    ]
    
    // FAB sheet
    @State private var showQuickActionsSheet: Bool = false
    
    var body: some View {
        ZStack {
            // Immersive backdrop
            TimeOfDayBackdrop()
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.18), .clear, Color.black.opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                // Sun glare overlay to make the sun feel less opaque and more like a bloom
                .overlay(SunGlareOverlay().allowsHitTesting(false))
            
            // Floating glass layers (retuned to gold/pink/blue palette)
            FloatingGlassLayersPortal()
                .opacity(0.6)
                .allowsHitTesting(false)
            
            ScrollViewReader { proxy in
                ScrollView {
                    // Track scroll offset in named space
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("portalScroll")).minY)
                    }
                    .frame(height: 0)
                    .id("top-anchor")
                    
                    // Collapsing Header is now part of the scroll content
                    VStack(spacing: 0) {
                        // Header compression based on scroll
                        PortalHeader(
                            greeting: vm.greeting,
                            subheadline: vm.subheadline,
                            agentCard: {
                                AgentContactBarPortal(
                                    showingContact: $showingAgentContact,
                                    mini: agentMini
                                )
                                .contextMenu {
                                    Button("Message Agent") {
                                        TRAEHapticManager.shared.trigger(.light)
                                        showingAgentContact = true
                                        scheduleAutoHideContact()
                                    }
                                    Button("Schedule Tour") {
                                        TRAEHapticManager.shared.trigger(.light)
                                        routeAndDismiss(.matchmaker)
                                    }
                                }
                                .overlay(alignment: .topTrailing) {
                                    if showAgentHint && !agentMini {
                                        Text("Contact")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(.ultraThinMaterial, in: Capsule())
                                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                            .padding(6)
                                            .transition(.move(edge: .top).combined(with: .opacity))
                                            .accessibilityHidden(true)
                                    }
                                }
                                .onAppear {
                                    // Brief hint once
                                    guard !hasShownAgentHint else { return }
                                    hasShownAgentHint = true
                                    hintTask?.cancel()
                                    hintTask = Task { @MainActor in
                                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                            showAgentHint = true
                                        }
                                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            showAgentHint = false
                                        }
                                    }
                                }
                                // Long press in mini mode to show contact options
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.35)
                                        .onEnded { _ in
                                            if agentMini {
                                                TRAEHapticManager.shared.trigger(.light)
                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                    showingAgentContact.toggle()
                                                }
                                                if showingAgentContact {
                                                    scheduleAutoHideContact()
                                                } else {
                                                    autoHideContactTask?.cancel()
                                                }
                                            }
                                        }
                                )
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Your agent")
                                .accessibilityHint(agentMini ? "Long press to show contact options" : "Double tap to show contact options")
                            },
                            smartAction: {
                                // Gold “hero” smart action
                                ImprovedSmartActionCardPortal(action: vm.currentSmartAction)
                                    .padding(.top, 10)
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("\(vm.currentSmartAction.label)")
                                    .accessibilityHint(vm.currentSmartAction.text)
                            },
                            subtitleOpacity: subtitleOpacity,
                            cardsHeight: headerCardsHeight
                        )
                        // Removed explicit close "X" button overlay
                        .overlay(alignment: .top) {
                            Capsule()
                                .fill(Color.white.opacity(0.35))
                                .frame(width: 44, height: 5)
                                .padding(.top, 8)
                                .accessibilityHidden(true)
                        }
                        .scaleEffect(headerScale, anchor: .top) // unified shrink
                        .padding(.bottom, headerCompressedPadding) // reduce bottom padding while collapsing
                        .gesture(
                            // Keep your drag-to-dismiss on the whole header area
                            DragGesture()
                                .onChanged { value in
                                    let translation = value.translation.height
                                    if translation > 0 {
                                        dragOffset = translation * 0.6
                                    }
                                }
                                .onEnded { value in
                                    let translation = value.translation.height
                                    let velocity = value.velocity.height
                                    if translation > dismissThreshold || velocity > dismissVelocity {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            isPresented = false
                                        }
                                    } else {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                        .offset(y: dragOffset)
                        
                        // Optional refresh status
                        if showRefreshStatus {
                            HStack(spacing: 6) {
                                ProgressView()
                                Text("Checking for new properties...")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(.vertical, 3)
                            .transition(.opacity)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Refreshing")
                            .accessibilityValue("Checking for new properties")
                        }
                        
                        // Status & Alerts panel (renamed and simplified)
                        StatusAlertsPanel(
                            alerts: sampleAlerts,
                            deadlines: sampleDeadlines,
                            quickActionHandler: handleStatusQuickAction
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        
                        // Horizontal Quick Actions bar (global actions near top)
                        HorizontalQuickActionsBar(
                            actions: [
                                .uploadDocs, .scheduleTour, .contactAgent, .viewInsights, .openDirectory, .reviewUpdates
                            ],
                            tapHandler: handleStatusQuickAction
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        
                        // Insights row: Market + Docs mini (side-by-side if width allows)
                        ResponsiveInsightsRow(
                            onUpload: { routeAndDismiss(.documents) }
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        
                        // Main content
                        VStack(spacing: 20) {
                            // Collapsible "From Sarah"
                            CollapsibleSectionHeader(
                                title: "From Sarah",
                                count: "\(vm.fromSarahProperties.count) properties",
                                isCollapsed: $collapsedFromAgent
                            )
                            if !collapsedFromAgent {
                                PropertySectionPortal(
                                    title: "From Sarah",
                                    count: "\(vm.fromSarahProperties.count) properties",
                                    properties: vm.fromSarahProperties
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .padding(.top, 4) // small separation from header/cards
                            }
                            
                            VStack(spacing: 16) {
                                // Collapsible "Your Portfolio"
                                CollapsibleSectionHeader(
                                    title: "Your Portfolio",
                                    count: "\(vm.portfolioProperties.count) saved",
                                    isCollapsed: $collapsedPortfolio
                                )
                                if !collapsedPortfolio {
                                    PropertySectionPortal(
                                        title: "Your Portfolio",
                                        count: "\(vm.portfolioProperties.count) saved",
                                        properties: vm.portfolioProperties
                                    )
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                                
                                // Removed QuickActionsGridPortal per request
                                
                                MarketIntelligenceCardPortal()
                                    .padding(.top, 4)
                                
                                DocumentProgressCardPortal(onUpload: {
                                    routeAndDismiss(.documents)
                                })
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 20) // slightly tighter
                        .padding(.bottom, 110) // lifted a bit more to avoid new lower CTA bar
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "portalScroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                    updateScrollResponsiveUI()
                }
                .refreshable {
                    await performRefresh()
                }
                .overlay(alignment: .bottomTrailing) {
                    if showBackToTop {
                        Button {
                            TRAEHapticManager.shared.trigger(.light)
                            if reduceMotion {
                                proxy.scrollTo("top-anchor", anchor: .top)
                            } else {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    proxy.scrollTo("top-anchor", anchor: .top)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 6)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.35))
                                        .frame(width: 50, height: 50)
                                )
                        }
                        .padding(.trailing, 14)
                        .padding(.bottom, 190) // lift above FAB & sheet affordance
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showBackToTop)
                        .accessibilityLabel("Back to top")
                        .accessibilityHint("Scrolls to the top of the page")
                    }
                }
            }
            
            // Floating Action Button (opens Quick Actions sheet) — keep "h", place bottom-right
            FABButton {
                TRAEHapticManager.shared.trigger(.light)
                showQuickActionsSheet = true
            }
            .padding(.trailing, 22)
            .padding(.bottom, 34)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .accessibilityLabel("Quick actions")
        }
        // Removed bottom docked search/chat bar (safeAreaInset)
        .preferredColorScheme(.dark)
        .onDisappear {
            // Cancel any pending tasks when view goes away
            hintTask?.cancel()
            autoHideContactTask?.cancel()
        }
        .sheet(isPresented: $showQuickActionsSheet) {
            QuickActionsSheet(
                onUpload: {
                    TRAEHapticManager.shared.trigger(.light)
                    showQuickActionsSheet = false
                    routeAndDismiss(.documents)
                },
                onSchedule: {
                    TRAEHapticManager.shared.trigger(.light)
                    showQuickActionsSheet = false
                    routeAndDismiss(.matchmaker)
                },
                onFavorite: {
                    TRAEHapticManager.shared.trigger(.selection)
                    // Placeholder: Could toggle a favorite on top property or open favorites
                    showQuickActionsSheet = false
                },
                onMessageSarah: {
                    TRAEHapticManager.shared.trigger(.light)
                    showQuickActionsSheet = false
                    showingAgentContact = true
                    scheduleAutoHideContact()
                },
                onCallLandlord: {
                    TRAEHapticManager.shared.trigger(.medium)
                    showQuickActionsSheet = false
                    // Placeholder for call integration
                },
                onAddNote: {
                    TRAEHapticManager.shared.trigger(.light)
                    showQuickActionsSheet = false
                    // Placeholder for notes
                }
            )
            .presentationDetents([.medium, .large])
            .presentationBackground(.ultraThinMaterial)
        }
        .overlay(alignment: .top) {
            // Subtle status strip with time only, no right icons
            StatusStrip(opacity: max(0, 1 - min(1, abs(scrollOffset) / 140)))
                .accessibilityHidden(true)
        }
    }
    
    // Computed collapse factor t (0 → 1 over the first ~160pts of scroll)
    private var collapseT: CGFloat {
        let clamp = max(min(0, scrollOffset), -160) // 0 to -160
        return abs(clamp) / 160
    }
    
    // Subtitle opacity fades from 1 → 0.2 as header collapses
    private var subtitleOpacity: Double {
        let minOpacity: Double = 0.2
        let maxOpacity: Double = 1.0
        return max(minOpacity, maxOpacity - (maxOpacity - minOpacity) * Double(collapseT))
    }
    
    // Header cards height interpolates 110 → 88 as header collapses (tightened)
    private var headerCardsHeight: CGFloat {
        let start: CGFloat = 110
        let end: CGFloat = 88
        return start - (start - end) * collapseT
    }
    
    // Compression: reduce header bottom padding as we scroll
    private var headerCompressedPadding: CGFloat {
        // 16 → 0 over the first ~120pts of scroll
        let t = min(max(abs(scrollOffset) / 120, 0), 1)
        return 16 * (1 - t)
    }
    
    private func handleAIIntent(_ text: String) {
        let lower = text.lowercased()
        if lower.contains("upload") || lower.contains("document") || lower.contains("apply") {
            router.route = .documents
        } else if lower.contains("schedule") || lower.contains("tour") || lower.contains("viewing") {
            router.route = .matchmaker
        } else if lower.contains("search") || lower.contains("find") || lower.contains("listing") || lower.contains("property") {
            router.route = .search
        } else if lower.contains("insight") || lower.contains("market") || lower.contains("stats") || lower.contains("analysis") {
            router.route = .insights
        } else if lower.contains("vendor") || lower.contains("directory") || lower.contains("contractor") {
            router.route = .directory
        } else if lower.contains("budget") || lower.contains("price") || lower.contains("afford") {
            router.route = .search
        } else if lower.contains("neighborhood") || lower.contains("area") || lower.contains("school") || lower.contains("walkability") {
            router.route = .search
        } else if lower.contains("compare") || lower.contains("favorite") || lower.contains("portfolio") {
            router.route = .search
        } else {
            router.route = .search
        }
        isPresented = false
    }
    
    private func routeAndDismiss(_ route: AppRoute) {
        // Helper to centralize routing + dismissal + haptic
        TRAEHapticManager.shared.trigger(.light)
        router.route = route
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isPresented = false
        }
    }
    
    private func scheduleAutoHideContact() {
        autoHideContactTask?.cancel()
        autoHideContactTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation { showingAgentContact = false }
        }
    }
    
    // Quick action handler for StatusAlertsPanel and Horizontal bar
    private func handleStatusQuickAction(_ action: StatusQuickAction) {
        switch action {
        case .uploadDocs:
            routeAndDismiss(.documents)
        case .scheduleTour:
            routeAndDismiss(.matchmaker)
        case .reviewTerms:
            // For now, send to documents as a placeholder
            routeAndDismiss(.documents)
        case .contactAgent:
            TRAEHapticManager.shared.trigger(.light)
            showingAgentContact = true
            scheduleAutoHideContact()
        case .viewInsights:
            routeAndDismiss(.insights)
        case .reviewUpdates:
            routeAndDismiss(.search)
        case .openDirectory:
            routeAndDismiss(.directory)
        }
    }
    
    // MARK: - Refresh
    private func performRefresh() async {
        TRAEHapticManager.shared.trigger(.light)
        withAnimation(.easeInOut(duration: 0.2)) { showRefreshStatus = true }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        withAnimation(.easeOut(duration: 0.25)) { showRefreshStatus = false }
        TRAEHapticManager.shared.trigger(.success)
    }
    
    // MARK: - Scroll responsive UI
    private func updateScrollResponsiveUI() {
        // Shrink header between 1.0 and 0.9 based on scroll
        let minScale: CGFloat = 0.9
        let maxScale: CGFloat = 1.0
        let clamp = max(min(0, scrollOffset), -160) // 0 to -160
        let t = abs(clamp) / 160
        headerScale = maxScale - (maxScale - minScale) * t
        
        // Agent mini-mode toggled after threshold
        agentMini = abs(scrollOffset) > 40
        
        // Back to top after scrolling down some distance
        showBackToTop = abs(scrollOffset) > 280
    }
}

// MARK: - Status & Alerts (local models and views)

private enum StatusPriority: Int, Comparable, CaseIterable {
    case urgent = 3
    case important = 2
    case informational = 1
    
    static func < (lhs: StatusPriority, rhs: StatusPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var label: String {
        switch self {
        case .urgent: return "Urgent"
        case .important: return "Important"
        case .informational: return "Info"
        }
    }
    
    var color: Color {
        switch self {
        case .urgent: return .red
        case .important: return .orange
        case .informational: return Theme.skyBlue
        }
    }
    
    var icon: String {
        switch self {
        case .urgent: return "exclamationmark.triangle.fill"
        case .important: return "exclamationmark.circle.fill"
        case .informational: return "info.circle.fill"
        }
    }
}

private struct StatusAlert: Identifiable, Hashable {
    let id: UUID
    let title: String
    let message: String
    let priority: StatusPriority
    let dueDate: Date?
}

private enum StatusQuickAction: Hashable {
    case uploadDocs
    case scheduleTour
    case reviewTerms
    case contactAgent
    case viewInsights
    case reviewUpdates
    case openDirectory
    
    var label: String {
        switch self {
        case .uploadDocs: return "Upload Docs"
        case .scheduleTour: return "Schedule Tour"
        case .reviewTerms: return "Review Terms"
        case .contactAgent: return "Contact Agent"
        case .viewInsights: return "View Insights"
        case .reviewUpdates: return "Review Updates"
        case .openDirectory: return "Directory"
        }
    }
    
    var systemImage: String {
        switch self {
        case .uploadDocs: return "arrow.up.doc"
        case .scheduleTour: return "calendar.badge.plus"
        case .reviewTerms: return "doc.text.magnifyingglass"
        case .contactAgent: return "person.crop.circle.badge.questionmark"
        case .viewInsights: return "chart.bar.doc.horizontal"
        case .reviewUpdates: return "bell.badge"
        case .openDirectory: return "person.3"
        }
    }
}

private struct StatusAlertsPanel: View {
    let alerts: [StatusAlert]
    let deadlines: [StatusAlert]
    var quickActionHandler: (StatusQuickAction) -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Highest priority retained for potential future logic, but UI chips/urgent banner removed
    private var highestPriority: StatusPriority {
        alerts.map { $0.priority }.max() ?? .informational
    }
    
    // Only allow non-removed actions in the panel quick actions row
    private var recommendedQuickActions: [StatusQuickAction] {
        // From request: remove .uploadDocs, .scheduleTour, .contactAgent from the calendar widget/panel
        return [.viewInsights, .reviewUpdates, .openDirectory]
    }
    
    private var sortedUpcoming: [StatusAlert] {
        (alerts + deadlines)
            .filter { $0.dueDate != nil }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .prefix(4)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title only (renamed), priority chip removed
            HStack {
                Label("What's on deck", systemImage: "exclamationmark.bubble.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            // Urgent banner removed per request
            
            // Alerts badges row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(alerts) { alert in
                        StatusBadge(alert: alert)
                    }
                }
            }
            
            // Upcoming mini calendar list (timeline-like cards)
            if !sortedUpcoming.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundColor(.white.opacity(0.9))
                        Text("Upcoming")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(sortedUpcoming) { item in
                            UpcomingRow(item: item)
                                .transition(.opacity)
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Quick actions (restricted set)
            HStack(spacing: 10) {
                ForEach(recommendedQuickActions, id: \.self) { action in
                    Button {
                        TRAEHapticManager.shared.trigger(.light)
                        quickActionHandler(action)
                    } label: {
                        Label(action.label, systemImage: action.systemImage)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(action.label)
                }
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
                .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 6)
        )
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85), value: alerts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("What's on deck")
    }
    
    // UrgentBanner removed
    
    private struct StatusBadge: View {
        let alert: StatusAlert
        
        var body: some View {
            HStack(spacing: 8) {
                Circle()
                    .fill(alert.priority.color)
                    .frame(width: 6, height: 6)
                Text(alert.title)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(.white)
                if let due = alert.dueDate {
                    Text(relDate(due))
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(alert.priority.color.opacity(0.35), lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(alert.title), \(alert.priority.label)\(alert.dueDate != nil ? ", due \(relDate(alert.dueDate!))" : "")")
        }
        
        private func relDate(_ date: Date) -> String {
            let df = RelativeDateTimeFormatter()
            df.unitsStyle = .short
            return df.localizedString(for: date, relativeTo: Date())
        }
    }
    
    private struct UpcomingRow: View {
        let item: StatusAlert
        
        var body: some View {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.priority.color.opacity(0.18))
                    VStack(spacing: 0) {
                        Text(dayAbbrev(item.dueDate))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.top, 4)
                        Text(dayNum(item.dueDate))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom, 4)
                    }
                }
                .frame(width: 36, height: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: item.priority.icon)
                            .foregroundColor(item.priority.color)
                            .font(.system(size: 12, weight: .semibold))
                        Text(item.title)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    Text(item.message)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer()
                if let due = item.dueDate {
                    Text(timeOnly(due))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(item.title), \(item.message)")
        }
        
        private func dayAbbrev(_ date: Date?) -> String {
            guard let d = date else { return "--" }
            let f = DateFormatter()
            f.dateFormat = "EEE"
            return f.string(from: d).uppercased()
        }
        private func dayNum(_ date: Date?) -> String {
            guard let d = date else { return "--" }
            let f = DateFormatter()
            f.dateFormat = "d"
            return f.string(from: d)
        }
        private func timeOnly(_ date: Date) -> String {
            let f = DateFormatter()
            f.timeStyle = .short
            return f.string(from: date)
        }
    }
}

// MARK: - View Model and Models (unchanged)
private final class PortalVM: ObservableObject {
    @Published var greeting: String = "Rise & Shine"
    @Published var subheadline: String = "Let's find your perfect space"
    @Published var currentSmartAction: PortalSmartAction
    
    // Simulate loading for skeleton demo
    @Published var isLoading: Bool = true
    
    let fromSarahProperties: [PortalProperty] = [
        .init(id: "1", name: "Williamsburg Loft", location: "North Brooklyn", price: "$3,200", matchPercent: "95%", insight: "Optimal commute · Premium amenities", emoji: "🏛️", isFavorite: false),
        .init(id: "2", name: "Park Slope Residence", location: "Park Slope", price: "$2,900", matchPercent: "89%", insight: "High walkability · Cultural access", emoji: "🏘️", isFavorite: false),
        .init(id: "3", name: "LIC Tower", location: "Long Island City", price: "$3,100", matchPercent: "87%", insight: "Manhattan views · Modern finishes", emoji: "🌆", isFavorite: false)
    ]
    
    let portfolioProperties: [PortalProperty] = [
        .init(id: "4", name: "Cobble Hill Classic", location: "Cobble Hill", price: "$3,400", matchPercent: nil, insight: nil, emoji: "🏛️", isFavorite: true),
        .init(id: "5", name: "Greenpoint Warehouse", location: "Greenpoint", price: "$3,000", matchPercent: nil, insight: nil, emoji: "🌃", isFavorite: true)
    ]
    
    init() {
        currentSmartAction = PortalSmartAction.random()
        updateGreeting()
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateGreeting()
        }
        // Simulate loading then reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) { self?.isLoading = false }
        }
    }
    
    func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let set: ([String],[String]) = {
            switch hour {
            case 5..<7: return (["Early Riser","Sunrise Chaser","Dawn Patrol"], ["The early bird gets the best apartment","Coffee first, then house hunting","You're crushing it already"])
            case 7..<12: return (["Rise & Shine","Good Morning","Morning Sunshine"], ["Let's find your perfect space","3 new properties await","Your dream home is out there"])
            case 12..<17: return (["Good Afternoon","Midday Check-in","Lunch Break Browse"], ["Time to explore some options","Sarah has updates for you","New matches just dropped"])
            case 17..<21: return (["Good Evening","Evening Exploration","Golden Hour"], ["Perfect time to review your favorites","Let's narrow down the choices","Almost there—keep going"])
            default: return (["Night Owl","Late Night Search","Burning Midnight Oil"], ["Can't stop thinking about it? We get it","The search never sleeps","Tomorrow's tour schedule looks great"])
            }
        }()
        greeting = set.0.randomElement() ?? "Hello"
        subheadline = set.1.randomElement() ?? "Welcome back"
    }
}

private struct PortalProperty: Identifiable {
    let id: String
    let name: String
    let location: String
    let price: String
    let matchPercent: String?
    let insight: String?
    let emoji: String
    let isFavorite: Bool
}

private struct PortalSmartAction {
    let icon: String
    let label: String
    let text: String
    
    static func random() -> PortalSmartAction {
        let actions = [
            PortalSmartAction(icon: "📋", label: "Next Step", text: "Upload tax returns by Friday"),
            PortalSmartAction(icon: "📍", label: "Reminder", text: "Don't forget 111 Wall Street tomorrow at 2pm"),
            PortalSmartAction(icon: "✅", label: "Action Needed", text: "Sign lease documents for review"),
            PortalSmartAction(icon: "🏦", label: "Pending", text: "Bank statements required for approval"),
            PortalSmartAction(icon: "📞", label: "Follow Up", text: "Call landlord about utilities setup"),
            PortalSmartAction(icon: "🔑", label: "Almost There", text: "Move-in date confirmed: March 15th")
        ]
        return actions.randomElement()!
    }
}

// MARK: - Improved Smart Action Card
private struct ImprovedSmartActionCardPortal: View {
    let action: PortalSmartAction
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sheenPhase: CGFloat = -1
    
    var body: some View {
        ZStack {
            // Elevated glass background with “gold hero” feel
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.9),
                            Color(red: 1.0, green: 0.93, blue: 0.31).opacity(0.9)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.2), lineWidth: 1))
                .shadow(color: Color.yellow.opacity(0.35), radius: 14, x: 0, y: 8)
                .overlay(
                    // Subtle animated sheen accent
                    LinearGradient(
                        colors: [Color.white.opacity(0.0), Color.white.opacity(0.18), Color.white.opacity(0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(reduceMotion ? 0 : 1)
                    .mask(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.0), .white.opacity(0.8), .white.opacity(0.0)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .offset(x: sheenPhase * 280)
                    )
                )
            
            HStack(spacing: 12) {
                // Icon chip
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color.white.opacity(0.35), Color.yellow.opacity(0.35)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                        .frame(width: 40, height: 40)
                    Text(action.icon)
                        .font(.system(size: 18))
                }
                .accessibilityHidden(true)
                
                // Labels
                VStack(alignment: .leading, spacing: 4) {
                    // Removed "Your journey" progress from header, not here
                    Text(action.label.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.75))
                        .tracking(0.6)
                    Text(action.text)
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Trailing chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                sheenPhase = 1
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Shimmer (single modifier)
private struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1
    func body(content: Content) -> some View {
        if isActive && !reduceMotion {
            content
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.05), Color.white.opacity(0.25), Color.white.opacity(0.05)],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .rotationEffect(.degrees(12))
                    .offset(x: phase * 240)
                    .blendMode(.plusLighter)
                    .mask(content)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}
private extension View {
    func shimmering(_ active: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: active))
    }
}

// MARK: - Collapsible Section Header
private struct CollapsibleSectionHeader: View {
    let title: String
    let count: String
    @Binding var isCollapsed: Bool
    
    var body: some View {
        Button {
            TRAEHapticManager.shared.trigger(.selection)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                isCollapsed.toggle()
            }
        } label: {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isCollapsed)
                        .foregroundStyle(Theme.secondaryText)
                    Text(title)
                        .font(.system(size: 18, weight: .semibold)) // smaller
                        .foregroundColor(Theme.primaryText)
                }
                Spacer()
                Text(count)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.secondaryText)
            }
            .contentShape(Rectangle())
        }
        .accessibilityLabel("\(title), \(count)")
        .accessibilityHint(isCollapsed ? "Double tap to expand" : "Double tap to collapse")
        .buttonStyle(.plain)
    }
}

// MARK: - UI Sections

private struct PortalHeader<AgentCard: View, SmartCard: View>: View {
    let greeting: String
    let subheadline: String
    @ViewBuilder var agentCard: () -> AgentCard
    @ViewBuilder var smartAction: () -> SmartCard
    
    // New: subtitle fade + card height interpolation
    let subtitleOpacity: Double
    let cardsHeight: CGFloat
    
    init(
        greeting: String,
        subheadline: String,
        @ViewBuilder agentCard: @escaping () -> AgentCard,
        @ViewBuilder smartAction: @escaping () -> SmartCard,
        subtitleOpacity: Double,
        cardsHeight: CGFloat
    ) {
        self.greeting = greeting
        self.subheadline = subheadline
        self.agentCard = agentCard
        self.smartAction = smartAction
        self.subtitleOpacity = subtitleOpacity
        self.cardsHeight = cardsHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Greeting only — removed "Your journey" progress line
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Text(subheadline)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .opacity(subtitleOpacity)
            }
            .padding(.top, 2)
            
            // Each card takes a full row: stack vertically
            VStack(spacing: 12) {
                agentCard()
                    .frame(maxWidth: .infinity)
                    .frame(height: cardsHeight * 0.55) // thin contact bar
                smartAction()
                    .frame(maxWidth: .infinity)
                    .frame(height: cardsHeight) // fuller smart action row
            }
            .padding(.top, 2)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: cardsHeight)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.6), Color.clear],
                startPoint: .top, endPoint: .bottom
            )
            .blur(radius: 14)
        )
    }
}

// Thin, full-width agent contact bar with Call / Message / Email
private struct AgentContactBarPortal: View {
    @Binding var showingContact: Bool
    let mini: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            HStack(spacing: 12) {
                // Left: avatar + label
                HStack(spacing: 10) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.72, green: 0.53, blue: 0.04),
                                    Color(red: 0.55, green: 0.41, blue: 0.08)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .overlay(Text("SM").font(.system(size: 10, weight: .bold)).foregroundColor(.white))
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Your Agent")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        Text("Sarah M.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
                
                Spacer()
                
                // Right: actions
                HStack(spacing: 8) {
                    ContactIconButton(systemName: "phone.fill") {
                        TRAEHapticManager.shared.trigger(.light)
                        showingContact = false
                    }
                    ContactIconButton(systemName: "message.fill") {
                        TRAEHapticManager.shared.trigger(.light)
                        showingContact = true
                    }
                    ContactIconButton(systemName: "envelope.fill") {
                        TRAEHapticManager.shared.trigger(.light)
                        showingContact = false
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Agent contact bar")
        .accessibilityHint("Call, message, or email your agent")
    }
}

private struct ContactIconButton: View {
    let systemName: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 28)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(systemName)
    }
}

// MARK: - Property Section with Parallax + Stagger + Gestures + Context Menu
private struct PropertySectionPortal: View {
    @EnvironmentObject private var router: AppRouter
    let title: String
    let count: String
    let properties: [PortalProperty]
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Make a local mutable copy for UI removal
    @State private var localProperties: [PortalProperty] = []
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Keep the header inside for redaction timing but it’s visually controlled by CollapsibleSectionHeader
            HStack {
                Text(title)
                    .font(.system(size: 0)) // hidden, header handled above
                    .opacity(0)
                Spacer()
                Text(count)
                    .font(.system(size: 0))
                    .opacity(0)
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Array(localProperties.enumerated()), id: \.element.id) { index, property in
                    ParallaxCardWrapper {
                        FlippablePropertyCard(property: property) {
                            // Favorite toggle haptic
                            TRAEHapticManager.shared.trigger(.selection)
                        } onDismiss: {
                            // Remove card
                            TRAEHapticManager.shared.trigger(.medium)
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                localProperties.removeAll { $0.id == property.id }
                            }
                        } onShare: {
                            TRAEHapticManager.shared.trigger(.light)
                            TRAEHapticManager.shared.trigger(.success)
                        }
                        .contextMenu {
                            Button {
                                TRAEHapticManager.shared.trigger(.medium)
                                // Full Analysis
                            } label: {
                                Label("Full Analysis", systemImage: "chart.bar.doc.horizontal")
                            }
                            Button {
                                TRAEHapticManager.shared.trigger(.light)
                                // Compare
                            } label: {
                                Label("Compare", systemImage: "arrow.left.arrow.right")
                            }
                            Button {
                                TRAEHapticManager.shared.trigger(.light)
                                // Share
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            Button(role: .destructive) {
                                TRAEHapticManager.shared.trigger(.warning)
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    localProperties.removeAll { $0.id == property.id }
                                }
                            } label: {
                                Label("Hide", systemImage: "eye.slash")
                            }
                        } preview: {
                            PropertyCardFront(property: property)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 0)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                )
                                .frame(width: 220, height: 220)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(property.name), \(property.location), \(property.price)")
                        .accessibilityHint("Double tap to flip. Swipe right to favorite, left to hide, down to share.")
                    }
                    .redacted(reason: reasons.union(appear ? [] : .placeholder))
                    .shimmering(!appear)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(reduceMotion ? nil : .spring(response: 0.6).delay(Double(index) * 0.08), value: appear)
                }
            }
        }
        .onAppear {
            // Initialize local copy and trigger stagger entrance
            if localProperties.isEmpty {
                localProperties = properties
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.3)) { appear = true }
            }
        }
    }
}

// MARK: - Card Flip + Press State + Swipe Gestures
private struct FlippablePropertyCard: View {
    let property: PortalProperty
    var onFavorite: () -> Void
    var onDismiss: () -> Void
    var onShare: () -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFlipped = false
    @State private var isPressed = false
    @State private var dragOffset: CGSize = .zero
    @State private var showHeart = false
    
    var body: some View {
        ZStack {
            if isFlipped {
                PropertyCardBack(property: property)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                PropertyCardFront(property: property)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 0)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
        .overlay(alignment: .center) {
            if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(.red)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 5)
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    .accessibilityHidden(true)
            }
        }
        .shadow(color: .black.opacity(0.35), radius: isPressed ? 6 : 12, x: 0, y: 6)
        .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.985 : 1.0))
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
        .offset(x: dragOffset.width, y: dragOffset.height)
        .rotationEffect(.degrees(Double(dragOffset.width / 18)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    let threshold: CGFloat = 80
                    if dx > threshold {
                        // Right → favorite
                        TRAEHapticManager.shared.trigger(.selection)
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            showHeart = true
                        }
                        onFavorite()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.easeInOut(duration: 0.25)) { showHeart = false }
                        }
                    } else if dx < -threshold {
                        // Left → dismiss
                        onDismiss()
                    } else if dy > threshold {
                        // Down → share
                        onShare()
                    }
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        dragOffset = .zero
                    }
                }
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.01)
                .onChanged { _ in if !reduceMotion { withAnimation(.easeIn(duration: 0.08)) { isPressed = true } } }
                .onEnded { _ in if !reduceMotion { withAnimation(.easeOut(duration: 0.12)) { isPressed = false } } else { isPressed = false } }
        )
        .onTapGesture {
            TRAEHapticManager.shared.trigger(.light)
            if reduceMotion {
                isFlipped.toggle()
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            }
        }
        .accessibilityAddTraits(.isButton)
    }
}

private struct PropertyCardFront: View {
    let property: PortalProperty
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(colors: [
                    Color(red: 0.72, green: 0.53, blue: 0.04).opacity(0.28),
                    Color(red: 0.55, green: 0.08, blue: 0.08).opacity(0.18)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                Text(property.emoji).font(.system(size: 42))
            }
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            VStack(alignment: .leading, spacing: 2) {
                Text(property.name).font(.system(size: 13, weight: .bold)).foregroundColor(.white).lineLimit(1)
                Text(property.location).font(.system(size: 10, weight: .medium)).foregroundColor(.white.opacity(0.6))
                Text(property.price).font(.system(size: 16, weight: .bold, design: .serif)).foregroundColor(.white).padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
        }
    }
}

private struct PropertyCardBack: View {
    let property: PortalProperty
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Floor Plan & Details")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
                .padding(.top, 8)
                .padding(.horizontal, 10)
            // Placeholder plan + stats
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                .frame(height: 88)
                .padding(.horizontal, 10)
                .overlay(
                    Text("Floor plan preview")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                )
            VStack(alignment: .leading, spacing: 4) {
                Label("2 Bed · 1.5 Bath", systemImage: "bed.double.fill")
                Label("Elevator · Doorman", systemImage: "figure.stand.line.dotted.figure.stand")
                Label("Pets OK · In-Unit W/D", systemImage: "pawprint.fill")
            }
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Parallax Wrapper (reduced height)
private struct ParallaxCardWrapper<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        GeometryReader { geo in
            // Use local container coordinates to reduce global re-layout impact
            let minY = geo.frame(in: .named("portalScroll")).minY
            let offset = (minY.truncatingRemainder(dividingBy: 200)) / 200
            content()
                .offset(y: reduceMotion ? 0 : -offset * 6) // subtle per-card parallax
        }
        .frame(height: 180)
    }
}

// MARK: - Market Intelligence with Sparkline
private struct MarketIntelligenceCardPortal: View {
    @State private var percent: Double = 0
    @State private var target: Double = 3
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("MARKET INTELLIGENCE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1)
                    Spacer()
                    Text(String(format: "↑ %.0f%%", percent))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.72, green: 0.53, blue: 0.04))
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.8), value: percent)
                }
                Sparkline(data: [2.8, 2.9, 3.0, 3.1, 3.0, 3.2, 3.1, 3.3])
                    .frame(height: 28)
                Text("Brooklyn median rent increased to $3,100/mo this quarter. Your timing is optimal.")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(3)
            }
            .padding(16)
        }
        .onAppear {
            if reduceMotion {
                percent = target
            } else {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    percent = target
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Market Intelligence")
        .accessibilityValue("Up \(Int(percent)) percent")
    }
}

private struct Sparkline: View {
    let data: [Double]
    var body: some View {
        GeometryReader { geo in
            let maxV = data.max() ?? 1
            let minV = data.min() ?? 0
            let w = geo.size.width
            let h = geo.size.height
            let step = w / CGFloat(max(1, data.count - 1))
            Path { p in
                for (i, v) in data.enumerated() {
                    let x = CGFloat(i) * step
                    let y = h - CGFloat((v - minV) / max(0.0001, (maxV - minV))) * h
                    if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                    else { p.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Document Progress Enhanced
private struct DocumentProgressCardPortal: View {
    var onUpload: () -> Void
    @State private var progress: CGFloat = 0
    @State private var expanded: Bool = false
    private let targetProgress: CGFloat = 0.75
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("DOCUMENTATION")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1)
                    Spacer()
                    HStack(spacing: 6) {
                        if progress >= targetProgress {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .transition(.scale)
                                .accessibilityHidden(true)
                        }
                        Text("\(Int(progress * 8)) of 8 complete")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(colors: [
                                Color(red: 0.72, green: 0.53, blue: 0.04),
                                Color(red: 0.55, green: 0.41, blue: 0.08)
                            ], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.9), value: progress)
                    }
                }
                .frame(height: 6)
                
                if expanded {
                    VStack(alignment: .leading, spacing: 8) {
                        ChecklistRow(title: "Government ID", done: true)
                        ChecklistRow(title: "Paystubs (3 months)", done: true)
                        ChecklistRow(title: "Employment Letter", done: true)
                        ChecklistRow(title: "Tax Returns", done: false)
                        ChecklistRow(title: "Bank Statements", done: false)
                        Button {
                            TRAEHapticManager.shared.trigger(.light)
                            onUpload()
                        } label: {
                            Label("Upload Remaining", systemImage: "arrow.up.doc")
                                .font(.system(size: 12.5, weight: .semibold))
                                .padding(.vertical, 9)
                                .padding(.horizontal, 11)
                                .background(.ultraThinMaterial, in: Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        .foregroundColor(.white)
                        .padding(.top, 4)
                        .accessibilityAddTraits(.isButton)
                    }
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .top)))
                }
                
                HStack {
                    Spacer()
                    Button {
                        TRAEHapticManager.shared.trigger(.selection)
                        if reduceMotion {
                            expanded.toggle()
                        } else {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                expanded.toggle()
                            }
                        }
                    } label: {
                        Label(expanded ? "Hide Details" : "View Details", systemImage: expanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .accessibilityLabel(expanded ? "Hide details" : "View details")
                }
            }
            .padding(16)
        }
        .onAppear {
            if reduceMotion {
                progress = targetProgress
            } else {
                withAnimation(.easeOut(duration: 0.9)) { progress = targetProgress }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Documentation progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

private struct ChecklistRow: View {
    let title: String
    let done: Bool
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundColor(done ? .green : .white.opacity(0.5))
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(done ? "Complete" : "Incomplete")
    }
}

private struct QuickActionsGridPortal: View {
    let onUpload: () -> Void
    let onSearch: () -> Void
    let onDirectory: () -> Void
    let onInsights: () -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            QuickActionButtonPortal(icon: "↑", label: "Upload", action: {
                TRAEHapticManager.shared.trigger(.light)
                onUpload()
            })
            QuickActionButtonPortal(icon: "⌕", label: "Search", action: {
                TRAEHapticManager.shared.trigger(.light)
                onSearch()
            })
            QuickActionButtonPortal(icon: "◉", label: "Directory", action: {
                TRAEHapticManager.shared.trigger(.light)
                onDirectory()
            })
            QuickActionButtonPortal(icon: "◐", label: "Insights", action: {
                TRAEHapticManager.shared.trigger(.light)
                onInsights()
            })
        }
    }
}

private struct QuickActionButtonPortal: View {
    let icon: String
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(icon).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Text(label).font(.system(size: 9.5, weight: .semibold)).foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.28), radius: 10, x: 0, y: 5)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}

private struct VisualEffectBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

private struct AIChatPanelPortal: View {
    @State private var message = ""
    var onSend: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 16, weight: .semibold))
                TextField("Ask me anything", text: $message)
                    .font(.system(size: 14.5, weight: .medium))
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(false)
                    .accessibilityLabel("Ask AI")
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            
            Button(action: sendMessage) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.7),
                                    Color.purple.opacity(0.55)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.35), radius: 8, x: 0, y: 2)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 38, height: 38)
                .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }
            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel("Send")
        }
    }
    
    private func sendMessage() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSend(trimmed)
        message = ""
    }
}

private struct FloatingGlassLayersPortal: View {
    @State private var animate1 = false
    @State private var animate2 = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color.yellow.opacity(0.22), Color.clear], center: .center, startRadius: 0, endRadius: 140))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: animate1 ? 30 : -30, y: animate1 ? -30 : 30)
                .animation(reduceMotion ? nil : .easeInOut(duration: 25).repeatForever(autoreverses: true), value: animate1)
                .onAppear { animate1 = true }
                .position(x: 100, y: 200)
            Circle()
                .fill(RadialGradient(colors: [Color.pink.opacity(0.18), Color.clear], center: .center, startRadius: 0, endRadius: 110))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: animate2 ? -20 : 20, y: animate2 ? 20 : -20)
                .animation(reduceMotion ? nil : .easeInOut(duration: 20).repeatForever(autoreverses: true), value: animate2)
                .onAppear { animate2 = true }
                .position(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 300)
        }
        .allowsHitTesting(false)
    }
}

// A subtle additive glare overlay for the sun phases to reduce the "opaque" feeling
private struct SunGlareOverlay: View {
    @ObservedObject private var time = TimeOfDayService.shared
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                if time.phase == .sunrise || time.phase == .day || time.phase == .sunset {
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.22),
                            Color.orange.opacity(0.12),
                            .clear
                        ],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: min(size.width, size.height) * 0.8
                    )
                    .blendMode(.plusLighter)
                    .blur(radius: 40)
                    .offset(x: size.width * 0.18, y: -size.height * 0.22)
                    
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            .clear
                        ],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: min(size.width, size.height) * 0.5
                    )
                    .blendMode(.screen)
                    .blur(radius: 28)
                    .offset(x: size.width * 0.22, y: -size.height * 0.26)
                }
            }
        }
    }
}

private extension DragGesture.Value {
    var velocity: CGSize {
        let time: CGFloat = 0.2
        let vx = (predictedEndLocation.x - location.x) / time
        let vy = (predictedEndLocation.y - location.y) / time
        return CGSize(width: vx, height: vy)
    }
}

// MARK: - Status Strip (time only)
private struct StatusStrip: View {
    @State private var now: Date = Date()
    let opacity: CGFloat
    var body: some View {
        HStack {
            Text(timeString(now))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            LinearGradient(colors: [Color.blue.opacity(0.5), Color.clear], startPoint: .top, endPoint: .bottom)
                .opacity(0.6)
        )
        .opacity(opacity)
        .onAppear {
            // Update minute-by-minute
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                now = Date()
            }
        }
    }
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f.string(from: date)
    }
}

// MARK: - Horizontal Quick Actions Bar (global actions)
private struct HorizontalQuickActionsBar: View {
    let actions: [StatusQuickAction]
    let tapHandler: (StatusQuickAction) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(actions, id: \.self) { action in
                    Button {
                        TRAEHapticManager.shared.trigger(.light)
                        tapHandler(action)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: action.systemImage)
                                .font(.system(size: 14, weight: .semibold))
                            Text(action.label)
                                .font(.system(size: 12.5, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(action.label)
                }
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85), value: actions)
    }
}

// MARK: - Responsive Insights Row (Market + Docs mini)
private struct ResponsiveInsightsRow: View {
    var onUpload: () -> Void
    @Environment(\.horizontalSizeClass) private var hClass
    
    var body: some View {
        if hClass == .regular {
            HStack(spacing: 12) {
                MarketIntelligenceCardPortal()
                DocumentsMiniCard(onUpload: onUpload)
                    .frame(width: 180)
            }
        } else {
            VStack(spacing: 12) {
                MarketIntelligenceCardPortal()
                DocumentsMiniCard(onUpload: onUpload)
            }
        }
    }
    
    private struct DocumentsMiniCard: View {
        var onUpload: () -> Void
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.15), lineWidth: 1))
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Documents")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                            Text("6 of 8")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [Color.yellow, Color(red: 1.0, green: 0.93, blue: 0.31)], startPoint: .leading, endPoint: .trailing))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .mask(
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: 140) // ~75%
                                )
                        )
                    Text("2 docs remaining")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Button {
                        TRAEHapticManager.shared.trigger(.light)
                        onUpload()
                    } label: {
                        Label("Upload", systemImage: "arrow.up.doc")
                            .font(.system(size: 12.5, weight: .semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    .foregroundColor(.white)
                }
                .padding(14)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
        }
    }
}

// MARK: - FAB Button + Sheet
private struct FABButton: View {
    let tap: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hover = false
    var body: some View {
        Button(action: tap) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.yellow, Color(red: 1.0, green: 0.93, blue: 0.31)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color.yellow.opacity(0.5), radius: 16, x: 0, y: 8)
                // Replace icon with letter "h"
                Text("h")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
            }
            .frame(width: 56, height: 56)
            .scaleEffect(hover && !reduceMotion ? 1.06 : 1.0)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: hover)
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            #if os(iOS)
            // no hover on iOS
            #else
            hover = isHovering
            #endif
        }
    }
}

private struct QuickActionsSheet: View {
    let onUpload: () -> Void
    let onSchedule: () -> Void
    let onFavorite: () -> Void
    let onMessageSarah: () -> Void
    let onCallLandlord: () -> Void
    let onAddNote: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Quick Actions").foregroundColor(.secondary)) {
                    QuickActionRow(icon: "arrow.up.doc", label: "Upload Document", action: onUpload)
                    QuickActionRow(icon: "calendar.badge.plus", label: "Schedule Tour", action: onSchedule)
                    QuickActionRow(icon: "heart.fill", label: "Add Property to Favorites", action: onFavorite)
                    QuickActionRow(icon: "message.fill", label: "Message Sarah", action: onMessageSarah)
                    QuickActionRow(icon: "phone.fill", label: "Call Landlord", action: onCallLandlord)
                    QuickActionRow(icon: "pencil", label: "Add Note", action: onAddNote)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Quick Actions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private struct QuickActionRow: View {
        let icon: String
        let label: String
        let action: () -> Void
        var body: some View {
            Button(action: {
                TRAEHapticManager.shared.trigger(.selection)
                action()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                    Text(label)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .accessibilityLabel(label)
        }
    }
}

