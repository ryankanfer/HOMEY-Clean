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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGFloat = 0

    private let maxWidth: CGFloat = 520
    private let cornerRadius: CGFloat = 16
    private let shadowOpacity: CGFloat = 0.15

    private enum DragLock { case horizontal, vertical }
    @State private var dragLock: DragLock?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if viewModel.position != .closed {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { closeDrawer() }
                        .accessibilityHidden(true)
                }

                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    drawerContent(geo: geo)
                        .frame(width: min(maxWidth, geo.size.width * 0.75))
                        .offset(x: drawerOffsetX(geo: geo) + dragOffset)
                        .shadow(color: .black.opacity(shadowOpacity), radius: 20, x: -10, y: 0)
                        // so vertical scroll works inside the drawer
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
                }
            }
            .accessibilityElement(children: .contain)
        }
    }

    private func drawerContent(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(.secondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 1) Attention row: Alerts
                    AlertsRow(
                        messages: viewModel.unreadMessages,
                        docs: viewModel.newDocs,
                        onOpenAlerts: onOpenAlerts,
                        onOpenNextUp: onOpenNextUp,
                        onOpenMessages: onOpenMessages,
                        onOpenDocs: onOpenDocs
                    )

                    // 2) Search chips + Edit
                    CriteriaChips(
                        persona: viewModel.persona,
                        budget: viewModel.budgetDisplay,
                        neighborhoods: viewModel.neighborhoodsCount,
                        moveIn: viewModel.moveInDisplay,
                        onEdit: onEditSearch
                    )

                    // 3) Team snapshot
                    TeamStackedList(members: viewModel.team)

                    // 4) Personal widgets
                    if viewModel.persona == .buyer {
                        MortgageCalculatorView(vm: viewModel, applyToSearch: onEditSearch)
                    }

                    ShortcutTile(
                        title: viewModel.shortcutTitle,
                        subtitle: viewModel.shortcutSubtitle,
                        action: onOpenFavorites
                    )
                }
                .padding(16)
                .padding(.bottom, 16)
            }
        }
        .frame(height: geo.size.height, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.regularMaterial)
        )
        .tint(Theme.primary)
        .environment(\.layoutDirection, .leftToRight) // drawer is on trailing; will mirror for RTL with the caller
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .accessibilitySortPriority(1)
    }

    // MARK: - Snap/Offset

    private func drawerOffsetX(geo: GeometryProxy) -> CGFloat {
        let width = min(maxWidth, geo.size.width * 0.75)
        switch viewModel.position {
        case .closed: return width + 20
        case .peek:
            let visible = width * 0.30
            return width - visible
        case .full: return 0
        }
    }

    private func drawerVisibleWidth(geo: GeometryProxy) -> CGFloat {
        let width = min(maxWidth, geo.size.width * 0.75)
        switch viewModel.position {
        case .closed: return 0
        case .peek: return width * 0.30
        case .full: return width
        }
    }

    private func animate(_ changes: @escaping () -> Void) {
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
        // Choose nearest of [closed, peek, full] by horizontal offset distance
        let width = min(maxWidth, geo.size.width * 0.75)
        let fullOffset: CGFloat = 0
        let peekOffset: CGFloat = width - (width * 0.30)
        let closedOffset: CGFloat = width + 20
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
        HStack(spacing: 12) {
            Button(action: onOpenAlerts) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(Theme.primary)
                    Text("\(total)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.primary.opacity(0.15)))
            }
            .accessibilityLabel("Alerts")
            .accessibilityHint("Opens recent alerts")
            .accessibilityValue("\(total) total")

            Spacer()

            Button(action: onOpenNextUp) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.primary)
                    Text("Next Up")
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.primary.opacity(0.12)))
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
                .foregroundStyle(Theme.primary)
            Text("\(count)")
                .font(.caption.bold())
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.primary.opacity(0.12)))
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
            HStack {
                Text(criteriaSummary)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Button("Edit") { onEdit() }
                    .font(.subheadline.weight(.semibold))
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
                }
            }
        }
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
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.primary.opacity(0.2)).frame(width: 28, height: 28)
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
            VStack(spacing: 12) {
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

                HStack {
                    VStack(alignment: .leading) {
                        Text("Principal & Interest")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(vm.monthlyPaymentPI, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .font(.headline.monospacedDigit())
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Carrying Costs")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(vm.monthlyCarryingCosts, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .font(.headline.monospacedDigit())
                    }
                    Spacer()
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
            }
        }
        .padding(12)
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
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Theme.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint("Opens \(title.lowercased())")
    }
}

// MARK: - Layout Helpers

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var runSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? UIScreen.main.bounds.width
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
