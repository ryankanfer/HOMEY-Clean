import SwiftUI

// MARK: - ViewModel

final class RightQuickViewDrawerViewModel: ObservableObject {
    enum Persona: String, CaseIterable {
        case renter, buyer
    }

    enum Position: Equatable {
        case closed
        case peek
        case full
    }

    enum DownPaymentMode { case percent, amount }
    enum PropertyType: String, CaseIterable { case coop, condo }

    // Quick Actions
    struct QuickAction: Identifiable, Equatable {
        static func == (lhs: RightQuickViewDrawerViewModel.QuickAction, rhs: RightQuickViewDrawerViewModel.QuickAction) -> Bool {
            lhs.id == rhs.id
        }

        enum Kind {
            case scheduleTour
            case saveSearch
            case share
            case requestInfo
            case mortgagePrequal
            case calculator
        }
        let id = UUID()
        let kind: Kind
        let title: String
        let systemImage: String
        let tint: Color
        let action: () -> Void
    }

    @Published var position: Position = .closed
    @Published var persona: Persona = .buyer

    // Alerts
    @Published var unreadMessages: Int = 0
    @Published var newDocs: Int = 0

    // Criteria (search summary)
    @Published var budgetDisplay: String = "$3.5k"
    @Published var neighborhoodsCount: Int = 3
    @Published var moveInDisplay: String = "Aug 1"

    // Team
    struct TeamMember: Identifiable, Equatable {
        enum Presence { case online, offline }
        let id = UUID()
        let role: String
        let name: String
        let phone: String?
        let email: String?
        let presence: Presence
    }
    @Published var team: [TeamMember] = [
        .init(role: "Agent", name: "Your Agent", phone: nil, email: nil, presence: .online),
        .init(role: "Lender", name: "Your Lender", phone: nil, email: nil, presence: .offline),
        .init(role: "Mover", name: "Mover", phone: nil, email: nil, presence: .offline),
        .init(role: "Lawyer", name: "Lawyer", phone: nil, email: nil, presence: .offline)
    ]

    // Mortgage calculator
    @Published var price: Double = 650_000
    @Published var downPaymentMode: DownPaymentMode = .percent
    @Published var downPaymentPercent: Double = 20
    @Published var downPaymentAmount: Double = 130_000

    @Published var useMarketRate: Bool = true
    @Published var marketRatePercent: Double = 6.75
    @Published var customRatePercent: Double = 6.75

    @Published var propertyType: PropertyType = .condo
    @Published var coopMaintenanceTaxesMonthly: Double = 0
    @Published var condoCommonChargesMonthly: Double = 0
    @Published var condoTaxesMonthly: Double = 0

    var currentRatePercent: Double { useMarketRate ? marketRatePercent : customRatePercent }

    private var principal: Double {
        let dp = downPaymentMode == .percent ? price * (downPaymentPercent / 100.0) : downPaymentAmount
        return max(0, price - dp)
    }

    var monthlyPaymentPI: Double {
        let n = 30.0 * 12.0
        let r = (currentRatePercent / 100.0) / 12.0
        guard r > 0 else { return principal / n }
        return principal * r * pow(1 + r, n) / (pow(1 + r, n) - 1)
    }

    var monthlyCarryingCosts: Double {
        switch propertyType {
        case .coop: return coopMaintenanceTaxesMonthly
        case .condo: return condoCommonChargesMonthly + condoTaxesMonthly
        }
    }

    var monthlyPaymentTotal: Double {
        monthlyPaymentPI + monthlyCarryingCosts
    }

    // Shortcut
    @Published var shortcutTitle: String = "Favorites"
    @Published var shortcutSubtitle: String = "3 homes"

    // Loading states for dynamic content
    @Published var isLoadingAlerts: Bool = false
    @Published var isLoadingTeam: Bool = false
    @Published var isLoadingMortgage: Bool = false
    @Published var isLoadingShortcut: Bool = false

    // Quick actions
    @Published var quickActions: [QuickAction] = []

    // MARK: - Dynamic Loading

    @MainActor
    func configureQuickActions(
        onScheduleTour: @escaping () -> Void,
        onSaveSearch: @escaping () -> Void,
        onShare: @escaping () -> Void,
        onRequestInfo: @escaping () -> Void,
        onPrequal: @escaping () -> Void,
        onOpenCalculator: @escaping () -> Void
    ) {
        quickActions = [
            .init(kind: .scheduleTour, title: "Schedule Tour", systemImage: "calendar.badge.plus", tint: .teal, action: onScheduleTour),
            .init(kind: .saveSearch, title: "Save Search", systemImage: "bookmark.fill", tint: .indigo, action: onSaveSearch),
            .init(kind: .share, title: "Share", systemImage: "square.and.arrow.up", tint: .orange, action: onShare),
            .init(kind: .requestInfo, title: "Request Info", systemImage: "questionmark.circle.fill", tint: .pink, action: onRequestInfo),
            .init(kind: .mortgagePrequal, title: "Get Pre-Qual", systemImage: "checkmark.seal.fill", tint: .green, action: onPrequal),
            .init(kind: .calculator, title: "Calculator", systemImage: "function", tint: .blue, action: onOpenCalculator)
        ]
    }

    @MainActor
    func loadAll() async {
        async let a: () = loadAlerts()
        async let t: () = loadTeam()
        async let m: () = loadMortgage()
        async let s: () = loadShortcut()
        _ = await (a, t, m, s)
    }

    @MainActor
    func loadAlerts() async {
        guard !isLoadingAlerts else { return }
        isLoadingAlerts = true
        defer { isLoadingAlerts = false }
        try? await Task.sleep(nanoseconds: 450_000_000)
        unreadMessages = Int.random(in: 0...5)
        newDocs = Int.random(in: 0...3)
    }

    @MainActor
    func loadTeam() async {
        guard !isLoadingTeam else { return }
        isLoadingTeam = true
        defer { isLoadingTeam = false }
        try? await Task.sleep(nanoseconds: 520_000_000)
        team = team.enumerated().map { idx, m in
            var presence: TeamMember.Presence = m.presence
            if idx == 0 { presence = .online }
            else { presence = Bool.random() ? .online : .offline }
            return .init(role: m.role, name: m.name, phone: m.phone, email: m.email, presence: presence)
        }
    }

    @MainActor
    func loadMortgage() async {
        guard !isLoadingMortgage else { return }
        isLoadingMortgage = true
        defer { isLoadingMortgage = false }
        try? await Task.sleep(nanoseconds: 400_000_000)
        marketRatePercent = [6.5, 6.625, 6.75, 6.875, 7.0].randomElement() ?? 6.75
    }

    @MainActor
    func loadShortcut() async {
        guard !isLoadingShortcut else { return }
        isLoadingShortcut = true
        defer { isLoadingShortcut = false }
        try? await Task.sleep(nanoseconds: 350_000_000)
        let count = Int.random(in: 1...6)
        shortcutTitle = "Favorites"
        shortcutSubtitle = "\(count) \(count == 1 ? "home" : "homes")"
    }
}

// MARK: - Right Drawer

struct RightQuickViewDrawer: View {
    @ObservedObject var viewModel: RightQuickViewDrawerViewModel
    let onEditSearch: () -> Void
    let onOpenAlerts: () -> Void
    let onOpenNextUp: () -> Void
    let onOpenMessages: () -> Void
    let onOpenDocs: () -> Void
    let onOpenFavorites: () -> Void

    // New quick actions handlers
    var onScheduleTour: () -> Void = { HapticsManager.shared.impact(.light) }
    var onSaveSearch: () -> Void = { HapticsManager.shared.impact(.light) }
    var onShare: () -> Void = { HapticsManager.shared.impact(.light) }
    var onRequestInfo: () -> Void = { HapticsManager.shared.impact(.light) }
    var onPrequal: () -> Void = { HapticsManager.shared.impact(.light) }
    var onOpenCalculator: () -> Void = { HapticsManager.shared.impact(.light) }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var hSize
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var dragOffset: CGFloat = 0

    // iPhone-first: allow more width on compact screens, cap on larger
    private var maxWidth: CGFloat { 520 }
    private var widthFraction: CGFloat { hSize == .regular ? 0.5 : 0.88 } // 88% on iPhone, 50% on iPad
    private let cornerRadius: CGFloat = 14
    private let shadowOpacity: CGFloat = 0.18

    private enum DragLock { case horizontal, vertical }
    @State private var dragLock: DragLock?

    @Namespace private var drawerNamespace

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if viewModel.position != .closed {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { closeDrawer() }
                        .accessibilityHidden(true)
                        .transition(.opacity)
                }

                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    drawerContent(geo: geo)
                        .frame(width: min(maxWidth, geo.size.width * widthFraction))
                        .offset(x: drawerOffsetX(geo: geo) + dragOffset)
                        .shadow(color: .black.opacity(shadowOpacity), radius: 18, x: -10, y: 0)
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { value in
                                    if dragLock == nil {
                                        if abs(value.translation.width) > abs(value.translation.height) {
                                            dragLock = .horizontal
                                        } else {
                                            dragLock = .vertical
                                        }
                                    }
                                    guard dragLock == .horizontal else { return }
                                    let t = value.translation.width
                                    dragOffset = max(min(t, 0), -geo.size.width)
                                }
                                .onEnded { value in
                                    defer { dragOffset = 0; dragLock = nil }
                                    guard dragLock == .horizontal else { return }
                                    let t = value.translation.width
                                    let threshold: CGFloat = 80
                                    if t < -threshold { moveToNextOpenState() }
                                    else if t > threshold { moveToNextClosedState() }
                                    else { snapToNearest(geo: geo) }
                                }
                        )
                        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85), value: viewModel.position)
                        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85), value: dragOffset)
                }
            }
            .accessibilityElement(children: .contain)
            .task {
                await MainActor.run {
                    viewModel.configureQuickActions(
                        onScheduleTour: onScheduleTour,
                        onSaveSearch: onSaveSearch,
                        onShare: onShare,
                        onRequestInfo: onRequestInfo,
                        onPrequal: onPrequal,
                        onOpenCalculator: onOpenCalculator
                    )
                }
                await viewModel.loadAll()
            }
        }
    }

    private func drawerContent(geo: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Grabber
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary.opacity(0.35))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                    .matchedGeometryEffect(id: "grabber", in: drawerNamespace)
                    .accessibilityHidden(true)

                // Quick Actions
                QuickActionsGrid(actions: viewModel.quickActions)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .accessibilityLabel("Quick actions")

                // Alerts
                Group {
                    if viewModel.isLoadingAlerts {
                        AlertsRowSkeleton()
                            .transition(.opacity)
                    } else {
                        AlertsRow(
                            messages: viewModel.unreadMessages,
                            docs: viewModel.newDocs,
                            onOpenAlerts: onOpenAlerts,
                            onOpenNextUp: onOpenNextUp,
                            onOpenMessages: onOpenMessages,
                            onOpenDocs: onOpenDocs
                        )
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }

                // Criteria summary
                CriteriaChips(
                    persona: viewModel.persona,
                    budget: viewModel.budgetDisplay,
                    neighborhoods: viewModel.neighborhoodsCount,
                    moveIn: viewModel.moveInDisplay,
                    onEdit: onEditSearch
                )
                .transition(.opacity)

                // Team
                Group {
                    if viewModel.isLoadingTeam {
                        TeamStackedListSkeleton()
                            .transition(.opacity)
                    } else {
                        TeamStackedList(members: viewModel.team)
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                }

                // Mortgage (buyers only)
                if viewModel.persona == .buyer {
                    Group {
                        if viewModel.isLoadingMortgage {
                            MortgageSkeleton()
                                .transition(.opacity)
                        } else {
                            MortgageCalculatorView(vm: viewModel, applyToSearch: onEditSearch)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                    .id(viewModel.useMarketRate)
                }

                // Shortcut
                Group {
                    if viewModel.isLoadingShortcut {
                        ShortcutTileSkeleton()
                            .transition(.opacity)
                    } else {
                        ShortcutTile(
                            title: viewModel.shortcutTitle,
                            subtitle: viewModel.shortcutSubtitle,
                            action: onOpenFavorites
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 20)
            .tint(Theme.primaryAction)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.9), value: viewModel.isLoadingAlerts)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.9), value: viewModel.isLoadingTeam)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.9), value: viewModel.isLoadingMortgage)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.9), value: viewModel.isLoadingShortcut)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: viewModel.persona)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.clear)
                .background(
                    CinematicBackground(for: .homey)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                )
        )
        .environment(\.layoutDirection, .leftToRight)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .accessibilitySortPriority(1)
    }

    // MARK: - Snap/Offset

    private func drawerOffsetX(geo: GeometryProxy) -> CGFloat {
        let width = min(maxWidth, geo.size.width * widthFraction)
        switch viewModel.position {
        case .closed: return width + 16
        case .peek:
            let visible = width * 0.28 // slightly smaller peek on iPhone
            return width - visible
        case .full: return 0
        }
    }

    private func animate(_ changes: () -> Void) {
        if reduceMotion {
            changes()
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                changes()
            }
        }
    }

    private func moveToNextOpenState() {
        animate {
            switch viewModel.position {
            case .closed: viewModel.position = .peek
            case .peek: viewModel.position = .full
            case .full: break
            }
        }
        HapticsManager.shared.impact(.light)
    }

    private func moveToNextClosedState() {
        animate {
            switch viewModel.position {
            case .full: viewModel.position = .peek
            case .peek, .closed: viewModel.position = .closed
            }
        }
        HapticsManager.shared.impact(.light)
    }

    private func snapToNearest(geo: GeometryProxy) {
        let width = min(maxWidth, geo.size.width * widthFraction)
        let fullOffset: CGFloat = 0
        let peekOffset: CGFloat = width - (width * 0.28)
        let closedOffset: CGFloat = width + 16
        let current = drawerOffsetX(geo: geo) + dragOffset

        let distances: [(RightQuickViewDrawerViewModel.Position, CGFloat)] = [
            (.full, abs(current - fullOffset)),
            (.peek, abs(current - peekOffset)),
            (.closed, abs(current - closedOffset))
        ]
        let nearest = distances.min(by: { $0.1 < $1.1 })?.0 ?? .peek
        animate { viewModel.position = nearest }
    }

    private func closeDrawer() {
        animate { viewModel.position = .closed }
    }
}

// MARK: - Alerts Row

private struct AlertsRow: View {
    let messages: Int
    let docs: Int
    let onOpenAlerts: () -> Void
    let onOpenNextUp: () -> Void
    let onOpenMessages: () -> Void
    let onOpenDocs: () -> Void

    var total: Int { messages + docs }

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onOpenAlerts) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(Theme.primaryAction)
                    Text("\(total)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.primaryAction.opacity(0.15)))
            }
            .accessibilityLabel("Alerts")
            .accessibilityHint("Opens recent alerts")
            .accessibilityValue("\(total) total")

            Spacer()

            Button(action: onOpenNextUp) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.primaryAction)
                    Text("Next Up")
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.primaryAction.opacity(0.12)))
            }
            .accessibilityLabel("Next Up")

            if messages > 0 {
                Button(action: onOpenMessages) {
                    labelPill(system: "text.bubble.fill", count: messages)
                }
                .accessibilityLabel("Unread messages")
                .accessibilityValue("\(messages)")
            }

            if docs > 0 {
                Button(action: onOpenDocs) {
                    labelPill(system: "doc.fill.badge.plus", count: docs)
                }
                .accessibilityLabel("New documents")
                .accessibilityValue("\(docs)")
            }
        }
    }

    private func labelPill(system: String, count: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: system)
                .foregroundStyle(Theme.primaryAction)
            Text("\(count)")
                .font(.caption.bold())
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.primaryAction.opacity(0.12)))
    }
}

private struct AlertsRowSkeleton: View {
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.15))
                .frame(width: 110, height: 34)
                .redacted(reason: .placeholder)
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.12))
                .frame(width: 90, height: 30)
                .redacted(reason: .placeholder)
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.12))
                .frame(width: 66, height: 28)
                .redacted(reason: .placeholder)
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.12))
                .frame(width: 66, height: 28)
                .redacted(reason: .placeholder)
        }
        .shimmer()
    }
}

// MARK: - Search Summary Chips

private struct CriteriaChips: View {
    let persona: RightQuickViewDrawerViewModel.Persona
    let budget: String
    let neighborhoods: Int
    let moveIn: String
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(criteriaSummary)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Button("Edit") { onEdit() }
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.bordered)
            }

            FlowLayout(spacing: 8, runSpacing: 8) {
                Chip("Budget: \(budget)", systemImage: "dollarsign.circle")
                Chip("Neighborhoods: \(neighborhoods)", systemImage: "mappin.and.ellipse")
                if persona == .renter {
                    Chip("Move-in: \(moveIn)", systemImage: "calendar")
                } else {
                    Chip("Buyer", systemImage: "house")
                }
            }
            .accessibilityElement(children: .contain)
        }
    }

    private var criteriaSummary: String {
        let personaPart = persona == .renter ? "Move-in \(moveIn)" : "Buyer"
        return "\(budget) • \(neighborhoods) neighborhoods • \(personaPart)"
    }

    private func Chip(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.12))
        )
    }
}

// MARK: - Team Snapshot

private struct TeamStackedList: View {
    let members: [RightQuickViewDrawerViewModel.TeamMember]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team").font(.headline)
            VStack(spacing: 8) {
                ForEach(members) { m in
                    TeamRow(member: m)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        }
    }
}

private struct TeamStackedListSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team").font(.headline).opacity(0.6)
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.12))
                        .frame(height: 52)
                        .redacted(reason: .placeholder)
                }
            }
        }
        .shimmer()
    }
}

private struct TeamRow: View {
    let member: RightQuickViewDrawerViewModel.TeamMember

    var presenceColor: Color {
        switch member.presence {
        case .online: return .green
        case .offline: return .gray
        }
    }

    var presenceText: String {
        switch member.presence {
        case .online: return "online"
        case .offline: return "offline"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Theme.primaryAction.opacity(0.2)).frame(width: 28, height: 28)
                Text(initials(from: member.name))
                    .font(.caption.weight(.semibold))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(member.name).font(.subheadline.weight(.semibold))
                Text(member.role).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Circle().fill(presenceColor)
                .frame(width: 10, height: 10)
                .accessibilityLabel("Presence: \(presenceText)")

            HStack(spacing: 10) {
                Button { HapticsManager.shared.impact(.light) } label: { Image(systemName: "message.fill") }
                Button { HapticsManager.shared.impact(.light) } label: { Image(systemName: "phone.fill") }
                Button { HapticsManager.shared.impact(.light) } label: { Image(systemName: "square.and.arrow.up") }
            }
            .font(.caption)
            .buttonStyle(.borderless)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.08)))
        .contextMenu {
            Button("Chat") {}
            Button("Call") {}
            Button("Share Doc") {}
        }
    }

    private func initials(from name: String) -> String {
        let comps = name.split(separator: " ").map { String($0.prefix(1)) }
        return comps.prefix(2).joined()
    }
}

// MARK: - Mortgage Mini

private struct MortgageCalculatorView: View {
    @ObservedObject var vm: RightQuickViewDrawerViewModel
    let applyToSearch: () -> Void
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 10) {
                LabeledStepper(title: "Price",
                               value: $vm.price,
                               step: 5_000,
                               range: 0...5_000_000,
                               format: .currency(code: Locale.current.currency?.identifier ?? "USD"))

                Picker("Down Payment Mode", selection: $vm.downPaymentMode) {
                    Text("%").tag(RightQuickViewDrawerViewModel.DownPaymentMode.percent)
                    Text("$").tag(RightQuickViewDrawerViewModel.DownPaymentMode.amount)
                }
                .pickerStyle(.segmented)

                if vm.downPaymentMode == .percent {
                    LabeledStepper(title: "Down Payment %",
                                   value: $vm.downPaymentPercent,
                                   step: 1,
                                   range: 0...100,
                                   format: .number.precision(.fractionLength(0)))
                } else {
                    LabeledStepper(title: "Down Payment $",
                                   value: $vm.downPaymentAmount,
                                   step: 1_000,
                                   range: 0...5_000_000,
                                   format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }

                Toggle("Use Market Rate (\(vm.marketRatePercent.formatted(.number.precision(.fractionLength(3))))%)", isOn: $vm.useMarketRate)
                    .font(.caption)

                if !vm.useMarketRate {
                    LabeledStepper(title: "Rate %",
                                   value: $vm.customRatePercent,
                                   step: 0.125,
                                   range: 0...20,
                                   format: .number.precision(.fractionLength(3)))
                }

                Picker("Property Type", selection: $vm.propertyType) {
                    Text("Condo").tag(RightQuickViewDrawerViewModel.PropertyType.condo)
                    Text("Coop").tag(RightQuickViewDrawerViewModel.PropertyType.coop)
                }
                .pickerStyle(.segmented)

                if vm.propertyType == .coop {
                    LabeledStepper(title: "Monthly Maintenance & Taxes",
                                   value: $vm.coopMaintenanceTaxesMonthly,
                                   step: 25,
                                   range: 0...10_000,
                                   format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                } else {
                    LabeledStepper(title: "Common Charges",
                                   value: $vm.condoCommonChargesMonthly,
                                   step: 25,
                                   range: 0...10_000,
                                   format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    LabeledStepper(title: "Taxes",
                                   value: $vm.condoTaxesMonthly,
                                   step: 25,
                                   range: 0...10_000,
                                   format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }

                Divider()

                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Principal & Interest")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(vm.monthlyPaymentPI, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .font(.headline.monospacedDigit())
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .leading) {
                        Text("Carrying Costs")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(vm.monthlyCarryingCosts, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .font(.headline.monospacedDigit())
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .leading) {
                        Text("Estimated Total")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(vm.monthlyPaymentTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .font(.title3.bold().monospacedDigit())
                    }
                }
            }
            .padding(.top, 6)
        } label: {
            HStack {
                Text("Mortgage Calculator")
                    .font(.headline)
                Spacer()
                Text(vm.monthlyPaymentTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.primary)
                Button {
                    applyToSearch()
                } label: {
                    Image(systemName: "arrow.triangle.merge")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Apply to search")
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Mortgage calculator")
        .onAppear { isExpanded = false }
    }
}

private struct LabeledStepper<F: FormatStyle & Sendable, V: BinaryFloatingPoint>: View where F.FormatInput == V, F.FormatOutput == String {
    let title: String
    @Binding var value: V
    let step: V
    var range: ClosedRange<V> = .leastNonzeroMagnitude...V.greatestFiniteMagnitude
    let format: F

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Button { value = max(range.lowerBound, value - step) } label: { Image(systemName: "minus.circle.fill") }
                Text(format.format(value)).font(.subheadline.monospacedDigit())
                Button { value = min(range.upperBound, value + step) } label: { Image(systemName: "plus.circle.fill") }
            }
            .buttonStyle(.borderless)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Shortcut Tile

private struct ShortcutTile: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Theme.primaryAction)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint("Opens \(title.lowercased())")
    }
}

private struct ShortcutTileSkeleton: View {
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 6).fill(.white.opacity(0.15)).frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.15)).frame(width: 120, height: 14)
                RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.12)).frame(width: 80, height: 12)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.12)).frame(width: 10, height: 16)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
        .redacted(reason: .placeholder)
        .shimmer()
    }
}

// MARK: - Quick Actions

private struct QuickActionsGrid: View {
    let actions: [RightQuickViewDrawerViewModel.QuickAction]
    // iPhone-friendly minimum tile width
    private let columns = [GridItem(.adaptive(minimum: 112), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Utilities")
                .font(.headline)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(actions) { action in
                    QuickActionTile(action: action)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        }
    }
}

private struct QuickActionTile: View {
    let action: RightQuickViewDrawerViewModel.QuickAction

    var body: some View {
        Button {
            HapticsManager.shared.impact(.light)
            action.action()
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(action.tint.opacity(0.18))
                        .frame(width: 32, height: 32)
                    Image(systemName: action.systemImage)
                        .foregroundStyle(action.tint)
                        .font(.subheadline.weight(.semibold))
                }
                Text(action.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.title)
    }
}

// MARK: - Mortgage Skeleton

private struct MortgageSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.15)).frame(width: 180, height: 16)
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.12)).frame(height: 36)
            }
            RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.12)).frame(height: 24)
            RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.12)).frame(height: 24)
            Divider().opacity(0.2)
            HStack {
                ForEach(0..<3, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.15)).frame(width: 100, height: 12)
                        RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.18)).frame(width: 120, height: 16)
                    }
                    if index < 2 { Spacer() }
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
        .redacted(reason: .placeholder)
        .shimmer()
    }
}

// MARK: - Layout Helpers

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var runSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth: CGFloat
        if let w = proposal.width {
            maxWidth = w
        } else {
            #if os(iOS)
            maxWidth = UIScreen.main.bounds.width
            #else
            maxWidth = 800
            #endif
        }
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + runSpacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }

        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        let maxX = bounds.maxX

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if currentX + size.width > maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + runSpacing
                rowHeight = 0
            }

            sub.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Shimmer Modifier (Lightweight)

private struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.0),
                            .white.opacity(0.25),
                            .white.opacity(0.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Rectangle()
                        .fill(gradient)
                        .rotationEffect(.degrees(15))
                        .offset(x: phase * geo.size.width * 1.5)
                        .blendMode(.overlay)
                        .opacity(0.8)
                }
                .allowsHitTesting(false)
            )
            .mask(content)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

private extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}
