import SwiftUI

struct PortalRefinedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showAgentContact = false
    @State private var greetingTitle: String = "Rise & Shine"
    @State private var greetingSubtitle: String = "Let's find your perfect space"
    @State private var smartAction: SmartAction = .random()
    @State private var chatInput: String = ""
    
    var body: some View {
        ZStack {
            // Sky blue animated gradient background
            TimeOfDayBackdrop()
                .ignoresSafeArea()
            
            // Soft floating glass layers, approximating the HTML glass blobs
            GlassLayers()
                .allowsHitTesting(false)
            
            // Content
            VStack(spacing: 0) {
                // Drag line indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 40, height: 3)
                    .padding(.top, 8)
                
                // Header with greeting + 1/3 + 2/3 cards
                headerSection
                
                // Scrollable gallery
                galleryScroll
                
                // Bottom AI chat glass
                aiChatGlass
            }
        }
        .onAppear {
            updateGreeting()
            scheduleGreetingUpdates()
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greetingTitle)
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 2)
                
                Text(greetingSubtitle)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 1/3 + 2/3 row
            HStack(spacing: 12) {
                agentMinimalCard
                    .frame(width: (UIScreen.main.bounds.width - 28*2 - 12) / 3)
                
                smartActionWide
                    .frame(width: (UIScreen.main.bounds.width - 28*2 - 12) * 2 / 3)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.7), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 0)
            .allowsHitTesting(false)
        )
    }
    
    private var agentMinimalCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.yellow.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
            
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 184/255, green: 134/255, blue: 11/255, opacity: 0.8),
                                    Color(red: 139/255, green: 105/255, blue: 20/255, opacity: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(color: Color(red: 184/255, green: 134/255, blue: 11/255, opacity: 0.3), radius: 10, x: 0, y: 4)
                    
                    Text("SM")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Your Agent")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            
            if showAgentContact {
                VStack(spacing: 10) {
                    contactButton(title: "Call Sarah", system: "phone.fill")
                    contactButton(title: "Send Message", system: "bubble.left.and.bubble.right.fill")
                    contactButton(title: "Email", system: "envelope.fill")
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.92).blur(radius: 20))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .transition(.opacity.combined(with: .scale))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                showAgentContact.toggle()
            }
            if showAgentContact {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showAgentContact = false
                    }
                }
            }
        }
    }
    
    private var smartActionWide: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(smartAction.icon)
                        .font(.system(size: 24))
                    Text(smartAction.label)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                Text(smartAction.text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
        }
    }
    
    // MARK: - Gallery
    
    private var galleryScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 40) {
                gallerySection(
                    title: "From Sarah",
                    countText: "3 properties",
                    cards: [
                        .init(emoji: "🏛️", match: "95% Match", insight: "Optimal commute · Premium amenities", name: "Williamsburg Loft", location: "North Brooklyn", price: "$3,200", alt: .none),
                        .init(emoji: "🏘️", match: "89% Match", insight: "High walkability · Cultural access", name: "Park Slope Residence", location: "Park Slope", price: "$2,900", alt: .alt1),
                        .init(emoji: "🌆", match: "87% Match", insight: "Manhattan views · Modern finishes", name: "LIC Tower", location: "Long Island City", price: "$3,100", alt: .alt2)
                    ]
                )
                
                gallerySection(
                    title: "Your Portfolio",
                    countText: "2 saved",
                    cards: [
                        .init(emoji: "🏛️", match: nil, insight: nil, name: "Cobble Hill Classic", location: "Cobble Hill", price: "$3,400", alt: .none),
                        .init(emoji: "🌃", match: nil, insight: nil, name: "Greenpoint Warehouse", location: "Greenpoint", price: "$3,000", alt: .alt1)
                    ],
                    includeIntelAndDocs: true
                )
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 220) // room for chat glass
            .padding(.top, 12)
        }
    }
    
    private func gallerySection(title: String, countText: String, cards: [PropertyCardData], includeIntelAndDocs: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(title)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundColor(.white)
                Spacer()
                Text(countText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            // 2-column grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(cards) { card in
                    propertyGlassCard(card)
                }
            }
            
            if includeIntelAndDocs {
                marketIntelCard
                documentationCard
                quickActionsRow
            }
        }
    }
    
    private func propertyGlassCard(_ data: PropertyCardData) -> some View {
        VStack(spacing: 0) {
            ZStack {
                // Square image area
                Rectangle()
                    .fill(gradientForAlt(data.alt))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Text(data.emoji)
                            .font(.system(size: 52))
                    )
                
                if let match = data.match {
                    Text(match)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(12)
                }
                
                if let insight = data.insight {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(insight)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.95))
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.blue.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .blur(radius: 0)
                    )
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(data.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(data.location)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                Text(data.price)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundColor(.white)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .contentShape(Rectangle())
        .contextMenu {
            Button("Full Analysis", systemImage: "chart.bar.xaxis") {}
            Button("Compare", systemImage: "rectangle.3.group") {}
            Button("Add to Portfolio", systemImage: "briefcase.fill") {}
        }
    }
    
    private func gradientForAlt(_ alt: PropertyCardData.Alt) -> LinearGradient {
        switch alt {
        case .none:
            return LinearGradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .alt1:
            return LinearGradient(colors: [Color.blue.opacity(0.3), Color.indigo.opacity(0.2)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .alt2:
            return LinearGradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var marketIntelCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Market Intelligence")
                    .font(.system(size: 13, weight: .heavy))
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .tracking(1)
                Spacer()
                Text("↑ 3%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 184/255, green: 134/255, blue: 11/255, opacity: 0.9))
            }
            Text("Brooklyn median rent increased to $3,100/mo this quarter. Your timing is optimal.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(3)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.yellow.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
        )
    }
    
    private var documentationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Documentation")
                    .font(.system(size: 13, weight: .heavy))
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .tracking(1)
                Spacer()
                Text("6 of 8 complete")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(LinearGradient(colors: [
                            Color(red: 184/255, green: 134/255, blue: 11/255, opacity: 0.8),
                            Color(red: 139/255, green: 105/255, blue: 20/255, opacity: 0.8)
                        ], startPoint: .leading, endPoint: .trailing))
                        .frame(width: UIScreen.main.bounds.width * 0.75 - 28, height: 6)
                }
                Text("Remaining: Tax returns, Bank statements")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.yellow.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
        )
    }
    
    private var quickActionsRow: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            quickAction(icon: "arrow.up", label: "Upload")
            quickAction(icon: "magnifyingglass", label: "Search")
            quickAction(icon: "circle.circle", label: "Directory")
            quickAction(icon: "circle.lefthalf.filled", label: "Insights")
        }
        .padding(.top, 6)
    }
    
    // MARK: - Bottom Chat
    
    private var aiChatGlass: some View {
        VStack(spacing: 12) {
            Text("Portfolio Analysis & Advisory")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                TextField("Ask about properties...", text: $chatInput)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .tint(.white)
                    .padding(.horizontal, 2)
                
                Button {
                    // send
                    chatInput = ""
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 184/255, green: 134/255, blue: 11/255, opacity: 0.4),
                                        Color(red: 139/255, green: 105/255, blue: 20/255, opacity: 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.7), radius: 24, x: 0, y: 16)
        )
        .padding(.horizontal, 28)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
    
    // MARK: - Components
    
    private func contactButton(title: String, system: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showAgentContact = false
            }
        } label: {
            HStack {
                Image(systemName: system)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func quickAction(icon: String, label: String) -> some View {
        Button {
            // Handle
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Greeting & Smart Action
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let set: GreetingSet
        if hour >= 5 && hour < 7 {
            set = .earlyBird
        } else if hour >= 7 && hour < 12 {
            set = .morning
        } else if hour >= 12 && hour < 17 {
            set = .afternoon
        } else if hour >= 17 && hour < 21 {
            set = .evening
        } else {
            set = .night
        }
        greetingTitle = set.titles.randomElement() ?? greetingTitle
        greetingSubtitle = set.subs.randomElement() ?? greetingSubtitle
        smartAction = .random()
    }
    
    private func scheduleGreetingUpdates() {
        // Update greeting every minute
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                updateGreeting()
            }
        }
    }
}

// MARK: - Helper Types

private enum GreetingSet {
    case earlyBird, morning, afternoon, evening, night
    
    var titles: [String] {
        switch self {
        case .earlyBird: return ["Early Riser", "Sunrise Chaser", "Dawn Patrol"]
        case .morning: return ["Rise & Shine", "Good Morning", "Morning Sunshine"]
        case .afternoon: return ["Good Afternoon", "Midday Check-in", "Lunch Break Browse"]
        case .evening: return ["Good Evening", "Evening Exploration", "Golden Hour"]
        case .night: return ["Night Owl", "Late Night Search", "Burning Midnight Oil"]
        }
    }
    
    var subs: [String] {
        switch self {
        case .earlyBird: return ["The early bird gets the best apartment", "Coffee first, then house hunting", "You're crushing it already"]
        case .morning: return ["Let's find your perfect space", "3 new properties await", "Your dream home is out there"]
        case .afternoon: return ["Time to explore some options", "Sarah has updates for you", "New matches just dropped"]
        case .evening: return ["Perfect time to review your favorites", "Let's narrow down the choices", "Almost there—keep going"]
        case .night: return ["Can't stop thinking about it? We get it", "The search never sleeps", "Tomorrow's tour schedule looks great"]
        }
    }
}

private struct SmartAction {
    let icon: String
    let label: String
    let text: String
    
    static func random() -> SmartAction {
        let actions: [SmartAction] = [
            .init(icon: "📋", label: "Next Step", text: "Upload tax returns by Friday"),
            .init(icon: "📍", label: "Reminder", text: "Don't forget 111 Wall Street tomorrow at 2pm"),
            .init(icon: "✅", label: "Action Needed", text: "Sign lease documents for review"),
            .init(icon: "🏦", label: "Pending", text: "Bank statements required for approval"),
            .init(icon: "📞", label: "Follow Up", text: "Call landlord about utilities setup"),
            .init(icon: "🔑", label: "Almost There", text: "Move-in date confirmed: March 15th")
        ]
        return actions.randomElement() ?? actions[0]
    }
}

private struct PropertyCardData: Identifiable {
    enum Alt { case none, alt1, alt2 }
    let id = UUID()
    let emoji: String
    let match: String?
    let insight: String?
    let name: String
    let location: String
    let price: String
    let alt: Alt
}

// Floating glass layers approximation
private struct GlassLayers: View {
    @State private var t1 = false
    @State private var t2 = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [
                        Color.yellow.opacity(0.30),
                        .clear
                    ], center: .center, startRadius: 0, endRadius: 140)
                )
                .frame(width: 280, height: 280)
                .blur(radius: 100)
                .opacity(0.2)
                .offset(x: t1 ? -40 : -20, y: t1 ? -40 : -10)
                .animation(.easeInOut(duration: 25).repeatForever(autoreverses: true), value: t1)
                .onAppear { t1 = true }
            
            Circle()
                .fill(
                    RadialGradient(colors: [
                        Color.blue.opacity(0.25),
                        .clear
                    ], center: .center, startRadius: 0, endRadius: 110)
                )
                .frame(width: 220, height: 220)
                .blur(radius: 100)
                .opacity(0.2)
                .offset(x: t2 ? 30 : -10, y: t2 ? 40 : 120)
                .animation(.easeInOut(duration: 25).repeatForever(autoreverses: true).delay(8), value: t2)
                .onAppear { t2 = true }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    PortalRefinedView()
}
