import SwiftUI

struct RefinedPortalView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var router: AppRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @StateObject private var vm = PortalVM()
    @State private var showingAgentContact = false
    // Teach Homey
    @StateObject private var teachVM = TeachHomeyViewModel()
    @State private var showTeachHomeySheet = false
    
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
    
    // FAB sheet (repurposed to Pages)
    @State private var showPagesSheet: Bool = false
    
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
                                
                                // Inline Teach Homey daily questions row beneath smartcard
                                DailyTeachHomeyRow(
                                    teachVM: teachVM,
                                    onOpenTeach: {
                                        TRAEHapticManager.shared.trigger(.light)
                                        showTeachHomeySheet = true
                                    }
                                )
                                .padding(.top, 8)
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
                        
                        // Status & Alerts panel (simplified: no title, no upcoming/calendar)
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
                                StatusQuickAction.uploadDocs, StatusQuickAction.scheduleTour,
                                StatusQuickAction.contactAgent, StatusQuickAction.viewInsights,
                                StatusQuickAction.openDirectory, StatusQuickAction.reviewUpdates
                            ],
                            tapHandler: handleStatusQuickAction
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
            
            // Floating Action Button (opens Pages sheet) — keep "h", place bottom-right
            FABButton {
                TRAEHapticManager.shared.trigger(.light)
                showPagesSheet = true
            }
            .padding(.trailing, 22)
            .padding(.bottom, 34)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .accessibilityLabel("Navigate")
        }
        // Removed bottom docked search/chat bar (safeAreaInset)
        .preferredColorScheme(.dark)
        .onDisappear {
            // Cancel any pending tasks when view goes away
            hintTask?.cancel()
            autoHideContactTask?.cancel()
        }
        .sheet(isPresented: $showPagesSheet) {
            NavigatorSheet( // redesigned sheet replacing PagesSheet
                onSelect: { route in
                    TRAEHapticManager.shared.trigger(.light)
                    showPagesSheet = false
                    routeAndDismiss(route)
                },
                onCancel: {
                    TRAEHapticManager.shared.trigger(.light)
                    showPagesSheet = false
                },
                onPortal: {
                    TRAEHapticManager.shared.trigger(.light)
                    showPagesSheet = false
                    routeAndDismiss(.search) // adjust if you have a dedicated portal route
                }
            )
            .presentationDetents([.medium, .large])
            .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $showTeachHomeySheet) {
            TeachHomeyModal()
                .environmentObject(teachVM)
                .presentationDetents([.large, .medium])
                .presentationBackground(.ultraThinMaterial)
        }
        // Removed StatusStrip overlay per request
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
        if lower.contains("teach") && lower.contains("homey") {
            // Open Teach Homey sheet directly from intent
            TRAEHapticManager.shared.trigger(.light)
            showTeachHomeySheet = true
            return
        }
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
    
    // Collapsible "Upcoming" no longer used
    @State private var isUpcomingCollapsed: Bool = false
    
    // Highest priority retained for potential future logic
    private var highestPriority: StatusPriority {
        alerts.map { $0.priority }.max() ?? .informational
    }
    
    // Upcoming removed; keep for potential future but unused
    private var sortedUpcoming: [StatusAlert] {
        []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Removed "What's on deck" title
            
            // Alerts badges row (kept)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(alerts) { alert in
                        StatusBadge(alert: alert)
                    }
                }
            }
            
            // Removed Upcoming collapsible section and calendar-like rows
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
        .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 6)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85), value: alerts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Status alerts")
    }
    
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
    
    // UpcomingRow removed with upcoming section
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

// MARK: - FAB Button + Redesigned Navigator Sheet
private struct FABButton: View {
    let tap: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hover = false
    @State private var breathe = false
    
    private var goldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.90, blue: 0.35), // light top
                Color(red: 0.98, green: 0.78, blue: 0.20)  // rich bottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: tap) {
            ZStack {
                // Soft outer glow halo
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.35),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 44
                        )
                    )
                    .blur(radius: 6)
                    .opacity(reduceMotion ? 0.7 : (breathe ? 0.9 : 0.6))
                    .scaleEffect(reduceMotion ? 1.0 : (breathe ? 1.06 : 1.0))
                
                // Core button
                Circle()
                    .fill(goldGradient)
                    .overlay(
                        // Inner ring
                        Circle()
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            .blur(radius: 0.2)
                    )
                    .overlay(
                        // Top highlight
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.6), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.2
                            )
                            .blendMode(.screen)
                    )
                    .shadow(color: Color.yellow.opacity(0.45), radius: 16, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                
                // "h" mark
                Text("h")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.black.opacity(0.85))
                    .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1) // subtle inner feel
            }
            .frame(width: 56, height: 56)
            .scaleEffect((hover && !reduceMotion) ? 1.06 : 1.0)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: hover)
            .animation(reduceMotion ? nil : .easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: breathe)
        }
        .buttonStyle(.plain)
        .onAppear { if !reduceMotion { breathe = true } }
        .onHover { isHovering in
            #if os(iOS)
            // no hover on iOS
            #else
            hover = isHovering
            #endif
        }
        .accessibilityLabel("Homey Navigator")
    }
}

// MARK: - Daily Teach Homey Row (inline under smartcard)
private struct DailyTeachHomeyRow: View {
    @ObservedObject var teachVM: TeachHomeyViewModel
    @StateObject private var triggerService = AIQuestionTriggerService.shared
    private let dataStore = TeachHomeyDataStore.shared
    
    var onOpenTeach: () -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var topQuestions: [AIQuestion] {
        // Map TriggeredQuestion -> AIQuestion; fallback to first 3 if none triggered
        let triggered = triggerService.getUnansweredQuestions().prefix(3)
        let mapped = triggered.compactMap { tq in
            dataStore.aiQuestions.first(where: { $0.id == tq.questionId })
        }
        if !mapped.isEmpty { return Array(mapped.prefix(3)) }
        return Array(dataStore.aiQuestions.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.yellow)
                Text("Teach Homey")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    TRAEHapticManager.shared.trigger(.light)
                    onOpenTeach()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Open")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 6)
            
            // Inline chips for 2–3 daily questions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(topQuestions, id: \.id) { q in
                        InlineQuestionChip(
                            question: q,
                            selected: teachVM.aiQuestionAnswers[q.id],
                            onSelect: { answer in
                                TRAEHapticManager.shared.trigger(.selection)
                                teachVM.updateAIAnswer(for: q.id, answer: answer)
                                // Mark triggered question as answered if present
                                AIQuestionTriggerService.shared.markQuestionAsAnswered(q.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85), value: topQuestions.map(\.id))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Teach Homey daily questions")
    }
    
    private struct InlineQuestionChip: View {
        let question: AIQuestion
        let selected: String?
        let onSelect: (String) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: question.avatar.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(question.avatar.color)
                        .padding(6)
                        .background(Circle().fill(question.avatar.color.opacity(0.18)))
                    Text(question.category.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                Text(question.questionText)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(maxWidth: 180, alignment: .leading)
                
                // Options row (first 2–3)
                HStack(spacing: 6) {
                    ForEach(question.options.prefix(3), id: \.self) { opt in
                        Button {
                            onSelect(opt)
                        } label: {
                            Text(opt)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(selected == opt ? .black : .white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selected == opt ? Color.white : Color.white.opacity(0.12))
                                )
                                .overlay(
                                    Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(question.questionText), option \(opt)")
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
            )
        }
    }
}

// MARK: - New, richer navigator sheet inspired by the mockups
private struct NavigatorSheet: View {
    let onSelect: (AppRoute) -> Void
    let onCancel: () -> Void
    let onPortal: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var query: String = ""
    @State private var recent: [RouteChip] = [
        .init(icon: "magnifyingglass", title: "Search", route: .search),
        .init(icon: "doc.text.fill", title: "Documents", route: .documents)
    ]
    
    private struct RouteChip: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let route: AppRoute
    }
    
    private struct BigTile: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let subtitle: String
        let route: AppRoute
    }
    
    private var bigTiles: [BigTile] {
        [
            .init(icon: "magnifyingglass", title: "Search", subtitle: "Find your perfect home", route: .search),
            .init(icon: "doc.text.fill", title: "Documents", subtitle: "Your paperwork vault", route: .documents)
        ].filter { tile in
            query.isEmpty ? true : tile.title.localizedCaseInsensitiveContains(query)
        }
    }
    
    private struct SmallTile: Identifiable {
        let id = UUID()
        let emoji: String
        let title: String
        let route: AppRoute
    }
    
    private var smallTiles: [SmallTile] {
        let all: [SmallTile] = [
            .init(emoji: "💖", title: "Saved", route: .search),
            .init(emoji: "🎯", title: "Matchmaker", route: .matchmaker),
            .init(emoji: "📊", title: "Insights", route: .insights),
            .init(emoji: "🎨", title: "Vision", route: .vision),
            .init(emoji: "📁", title: "Directory", route: .directory),
            .init(emoji: "📅", title: "Calendar", route: .discover),
            .init(emoji: "⚙️", title: "Settings", route: .settings)
        ]
        if query.isEmpty { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.07, blue: 0.12), Color(red: 0.03, green: 0.04, blue: 0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 18) {
                        heroHeader
                        searchField
                        recentRow
                        bigTilesGrid
                        Divider().overlay(Color.white.opacity(0.12)).padding(.horizontal, 6)
                        smallTilesGrid
                        bottomBar
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Sections
    
    private var heroHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.yellow.opacity(0.55), Color.orange.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 44
                        )
                    )
                    .blur(radius: 8)
                    .scaleEffect(reduceMotion ? 1 : 1.05)
                    .opacity(0.9)
                Circle()
                    .fill(LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
                    .overlay(
                        Text("h")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.black.opacity(0.85))
                    )
            }
            Text("Where to?")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.white)
            Text("Choose a page to navigate")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.top, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Where to? Choose a page to navigate")
    }
    
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.7))
            TextField("Search pages...", text: $query)
                .textInputAutocapitalization(.never)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .accessibilityLabel("Search pages")
    }
    
    private var recentRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "clock.badge.exclamationmark").foregroundColor(.white.opacity(0.7))
                Text("RECENT")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.75))
                    .textCase(.uppercase)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(recent) { chip in
                        Button {
                            onSelect(chip.route)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: chip.icon)
                                Text(chip.title)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 12.5))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.top, 6)
    }
    
    private var bigTilesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(bigTiles) { tile in
                Button {
                    onSelect(tile.route)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 56, height: 56)
                            .overlay(Image(systemName: tile.icon).font(.system(size: 24, weight: .semibold)).foregroundColor(.white.opacity(0.9)))
                        Text(tile.title)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(.white)
                        Text(tile.subtitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.14), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tile.title)
            }
        }
        .padding(.top, 6)
    }
    
    private var smallTilesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(smallTiles) { tile in
                Button {
                    onSelect(tile.route)
                } label: {
                    VStack(spacing: 8) {
                        Text(tile.emoji).font(.system(size: 24))
                        Text(tile.title)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tile.title)
            }
        }
    }
    
    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                onCancel()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                    Text("Cancel").fontWeight(.heavy)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            
            Button {
                onPortal()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Text("🏠")
                    Text("Portal").fontWeight(.heavy)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .foregroundColor(.black)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }
}

private struct ImprovedSmartActionCardPortal: View {
    let action: PortalSmartAction
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji/icon
            Text(action.icon)
                .font(.system(size: 22))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.35),
                                    Color.orange.opacity(0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(action.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Text(action.text)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        )
        .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 6)
        .scaleEffect(reduceMotion ? 1.0 : 1.0)
        .accessibilityElement(children: .combine)
    }
}

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

// MARK: - Missing Views Implementations Added

// 1) HorizontalQuickActionsBar: a compact row of tappable chips for StatusQuickAction
private struct HorizontalQuickActionsBar: View {
    let actions: [StatusQuickAction]
    let tapHandler: (StatusQuickAction) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(actions, id: \.self) { action in
                    Button {
                        tapHandler(action)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: action.systemImage)
                                .font(.system(size: 12, weight: .semibold))
                            Text(action.label)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(action.label)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

// 2) PropertySectionPortal: simple 2-column grid using PortalProperty
private struct PropertySectionPortal: View {
    let title: String
    let count: String
    let properties: [PortalProperty]
    
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(properties) { p in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.25), Color.orange.opacity(0.2)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                LinearGradient(colors: [.clear, Color.black.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                            )
                        Text(p.emoji).font(.system(size: 44))
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        if let match = p.matchPercent {
                            Text(match)
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white, in: Capsule())
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .padding(8)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(p.location)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                        Text(p.price)
                            .font(.system(.headline, design: .serif).weight(.bold))
                            .foregroundColor(.white)
                        if let insight = p.insight {
                            Text(insight)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.75))
                                .lineLimit(2)
                                .padding(.top, 2)
                        }
                    }
                    .padding(10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            }
        }
    }
}

// 3) ContactIconButton: small circular icon button used by AgentContactBarPortal
private struct ContactIconButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(systemName)
    }
}
