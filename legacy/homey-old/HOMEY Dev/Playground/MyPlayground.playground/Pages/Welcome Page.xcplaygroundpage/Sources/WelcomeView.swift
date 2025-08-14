//
//  StartScreen.swift
//  
//
//  Created by Ryan Kanfer on 8/12/25.
//


import SwiftUI
import PlaygroundSupport

// MARK: - Root launcher with route switching (Welcome <-> Admin)
enum StartScreen: String, CaseIterable, Identifiable {
    case welcome = "Welcome"
    case admin   = "Admin Dashboard"
    var id: String { rawValue }
}

struct RootLauncher: View {
    @State private var start: StartScreen = .welcome

    var body: some View {
        NavigationStack {
            Group {
                switch start {
                case .welcome:
                    WelcomeView(onDebugNavigate: { start = $0 })
                case .admin:
                    AdminDashboardSandbox(onClose: { start = .welcome })
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu(start.rawValue) {
                        Picker("Start Screen", selection: $start) {
                            ForEach(StartScreen.allCases) { s in Text(s.rawValue).tag(s) }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - WelcomeView with secret long-press on logo
struct WelcomeView: View {
    @State private var showSignup = false
    @State private var showLogin  = false
    @State private var pageIndex  = 0
    @State private var showDebug  = false

    let onDebugNavigate: (StartScreen) -> Void

    var body: some View {
        ZStack {
            AnimatedGradient()

            VStack(spacing: 16) {
                // Logo row (long-press for Debug Menu)
                HStack {
                    Spacer()
                    Image("homey_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                        .opacity(0.9)
                        .onLongPressGesture(minimumDuration: 1.2) { showDebug = true }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)

                // Top copy
                VStack(spacing: 8) {
                    Text("Real Estate, Reimagined")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text("Real estate is a beast. We’re the team to tame it.\nHOMEY is your concierge-powered path to clarity.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                }
                .padding(.top, 8)

                // Slides
                TabView(selection: $pageIndex) {
                    MeetYourHomeysSlide()
                        .tag(0)
                        .padding(.horizontal, 16)

                    WhosItForSlide()
                        .tag(1)
                        .padding(.horizontal, 24)

                    FeaturesSlide()
                        .tag(2)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: pageIndex)

                // Pager + arrows
                HStack(spacing: 36) {
                    Button { withAnimation(.spring()) { pageIndex = max(pageIndex - 1, 0) } } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(pageIndex == 0 ? .gray.opacity(0.5) : .blue)
                    }
                    .disabled(pageIndex == 0)

                    HStack(spacing: 8) {
                        ForEach(0..<3) { idx in
                            Circle()
                                .fill(idx == pageIndex ? Color.blue : Color.gray.opacity(0.5))
                                .frame(width: 10, height: 10)
                                .onTapGesture { withAnimation(.spring()) { pageIndex = idx } }
                        }
                    }

                    Button { withAnimation(.spring()) { pageIndex = min(pageIndex + 1, 2) } } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(pageIndex == 2 ? .gray.opacity(0.5) : .blue)
                    }
                    .disabled(pageIndex == 2)
                }
                .padding(.vertical, 8)

                // CTAs
                VStack(spacing: 14) {
                    Button { showSignup = true } label: {
                        HStack {
                            Spacer()
                            Text("Get Started").font(.headline)
                            Image(systemName: "arrow.right").font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(colors: [.blue, .purple],
                                           startPoint: .leading, endPoint: .trailing)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        )
                        .foregroundStyle(.white)
                        .shadow(radius: 6, y: 2)
                    }
                    .sheet(isPresented: $showSignup) { CreateAccountPlaceholder() }

                    Button { showLogin = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "person.circle")
                            Text("Login").font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .sheet(isPresented: $showLogin) { LoginPlaceholder() }

                    Button {
                        withAnimation(.spring()) { if pageIndex < 2 { pageIndex += 1 } }
                    } label: {
                        Text("Learn More")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                            .underline()
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 8)
            }
            .padding(.vertical, 12)
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showDebug) {
            DebugMenuView(
                onClose: { showDebug = false },
                onNavigate: { destination in
                    showDebug = false
                    onDebugNavigate(destination)
                }
            )
        }
    }
}

// MARK: - Debug Menu (secret sheet)
struct DebugMenuView: View {
    let onClose: () -> Void
    let onNavigate: (StartScreen) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Quick Jump") {
                    Button("Welcome") { onNavigate(.welcome) }
                    Button("Admin Dashboard") { onNavigate(.admin) }
                }
                Section("Utilities") {
                    Button("Reset onboarding flags") { /* stub */ }
                    Button("Show sample data") { /* stub */ }
                }
                Section("About") {
                    Text("Build: Playground Sandbox")
                    Text("Gesture: Long-press logo ≥1.2s")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Debug")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onClose() }
                }
            }
        }
    }
}

// MARK: - Admin Dashboard (sandbox)
struct AdminDashboardSandbox: View {
    let onClose: () -> Void

    @State private var showStagingData = true
    @State private var users = [
        ("Ava", "renter", "Onboarding 60%"),
        ("Max", "buyer", "Packet 30%"),
        ("Luca", "landlord", "Docs Ready")
    ]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Admin Dashboard")
                    .font(.largeTitle.bold())
                Spacer()
                Button("Close") { onClose() }
            }
            .padding(.horizontal)

            Toggle("Use staging data", isOn: $showStagingData)
                .padding(.horizontal)

            List {
                ForEach(users.indices, id: \.self) { i in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(users[i].0).font(.headline)
                            Text(users[i].1.capitalized).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(users[i].2).font(.footnote)
                    }
                }
            }

            HStack {
                Button {
                    users.shuffle()
                } label: {
                    Label("Shuffle", systemImage: "shuffle")
                }
                Spacer()
                Button {
                    users.append(("New Client", "buyer", "0%"))
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Slides (Meet Homeys with Focused detail)
struct MeetYourHomeysSlide: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    @State private var focusedIndex: Int? = nil

    var body: some View {
        VStack(spacing: 16) {
            if let idx = focusedIndex {
                FocusedHomeyView(index: $focusedIndex, startIndex: idx)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(Array(HomeyKind.allCases.enumerated()), id: \.offset) { (idx, homey) in
                        VStack(spacing: 8) {
                            Image(homey.assetName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .shadow(radius: 4, y: 2)

                            Text(homey.displayName)
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                        .frame(maxWidth: .infinity, minHeight: 140)
                        .contentShape(Rectangle())
                        .onTapGesture { withAnimation(.spring()) { focusedIndex = idx } }
                    }
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
        }
    }
}

struct FocusedHomeyView: View {
    @Binding var index: Int?
    let startIndex: Int
    @GestureState private var dragOffset: CGFloat = 0
    @State private var current: Int

    init(index: Binding<Int?>, startIndex: Int) {
        self._index = index
        self.startIndex = startIndex
        self._current = State(initialValue: startIndex)
    }

    var body: some View {
        let items = HomeyKind.allCases
        let count = items.count
        let homey = items[current]

        VStack(spacing: 20) {
            Spacer(minLength: 12)

            VStack(spacing: 12) {
                Text(homey.displayTitle).font(.title.bold())
                Text(homey.blurb)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))

            Image(homey.waveAsset) // e.g. "charlie_wave"
                .resizable()
                .scaledToFit()
                .frame(height: 340)
                .shadow(radius: 18, y: 10)
                .padding(.bottom, 4)

            HStack(spacing: 40) {
                Button { withAnimation(.spring()) { current = (current - 1 + count) % count } } label: {
                    Image(systemName: "arrow.left.circle.fill").font(.largeTitle)
                }
                Button { withAnimation(.spring()) { current = (current + 1) % count } } label: {
                    Image(systemName: "arrow.right.circle.fill").font(.largeTitle)
                }
            }

            Spacer(minLength: 12)

            Button("Back to all HOMEYs") {
                withAnimation(.spring()) { index = nil }
            }
            .font(.callout.bold())
            .padding(.bottom, 8)
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { val, st, _ in st = val.translation.width }
                .onEnded { val in
                    withAnimation(.spring()) {
                        if val.translation.width < -50 { current = (current + 1) % count }
                        else if val.translation.width > 50 { current = (current - 1 + count) % count }
                    }
                }
        )
    }
}

// MARK: - Slide 2/3 stubs (unchanged from your style)
struct WhosItForSlide: View {
    private let items: [(String, String)] = [
        ("house.fill", "Renters"),
        ("key.fill", "Buyers"),
        ("tag.fill", "Sellers"),
        ("building.2.fill", "Landlords"),
        ("person.2.fill", "Agents")
    ]
    var body: some View {
        VStack(spacing: 14) {
            Text("Who’s It For?").font(.title2.bold())
            Text("Anyone who lives under a roof — and everyone who helps them.")
                .font(.footnote).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(items, id: \.1) { icon, label in
                    HStack(spacing: 12) {
                        Image(systemName: icon).font(.title3)
                        Text(label).font(.headline)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }
}

struct FeaturesSlide: View {
    private let features: [(String, String, String)] = [
        ("sparkles", "AI Onboarding", "Quiz maps profile + goals"),
        ("exclamationmark.triangle.fill", "Reality Checks", "Feasibility + tradeoffs"),
        ("person.crop.circle", "Avatar Profiles", "Evolve via your data"),
        ("brain.head.profile", "Scenario Sims", "Practice key moments"),
        ("doc.text.fill", "Doc Retention", "Review + store files"),
        ("camera.viewfinder", "VR / AR Tours", "Immersive viewings")
    ]
    var body: some View {
        VStack(spacing: 14) {
            Text("What You Get").font(.title2.bold())
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(features, id: \.1) { icon, title, sub in
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: icon).font(.title3)
                        Text(title).font(.headline)
                        Text(sub).font(.caption).foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }
}

// MARK: - Models / Assets
enum HomeyKind: CaseIterable, Identifiable {
    case charlie, paige, scout, isla, drew, viza
    var id: Self { self }
    var assetName: String {
        switch self {
        case .charlie: return "charlieAvatar"
        case .paige:   return "paigeAvatar"
        case .scout:   return "scoutAvatar"
        case .isla:    return "islaAvatar"
        case .drew:    return "drewAvatar"
        case .viza:    return "vizaAvatar"
        }
    }
    var waveAsset: String {
        switch self {
        case .charlie: return "charlie_wave"
        case .paige:   return "paige_wave"
        case .scout:   return "scout_wave"
        case .isla:    return "isla_wave"
        case .drew:    return "drew_wave"
        case .viza:    return "viza_wave"
        }
    }
    var displayName: String {
        switch self {
        case .charlie: return "Charlie"
        case .paige:   return "Paige"
        case .scout:   return "Scout"
        case .isla:    return "Isla"
        case .drew:    return "Drew"
        case .viza:    return "Viza"
        }
    }
    var displayTitle: String { "\(displayName) — \(role)" }
    var role: String {
        switch self {
        case .charlie: return "Concierge"
        case .paige:   return "Paperwork Stylist"
        case .scout:   return "Listing Finder"
        case .isla:    return "Market Analyst"
        case .drew:    return "Vendor Directory"
        case .viza:    return "Space Stylist"
        }
    }
    var blurb: String {
        switch self {
        case .charlie: return "Guides you through the journey with taste and tact."
        case .paige:   return "Tames board packets and document chaos."
        case .scout:   return "Narrows neighborhoods and pulls the right listings."
        case .isla:    return "Translates data into decisions without the panic."
        case .drew:    return "Brings the right lenders, lawyers, and movers to the table."
        case .viza:    return "Sees what the space could be and how to get there."
        }
    }
}

// MARK: - Animated gradient
struct AnimatedGradient: View {
    @State private var t: CGFloat = 0.2
    var body: some View {
        LinearGradient(colors: [Color.black, Color.black.opacity(0.92), Color.black.opacity(0.86)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
        .overlay(
            RadialGradient(colors: [.mint.opacity(0.28), .clear],
                           center: .init(x: t, y: 0.32), startRadius: 60, endRadius: 520)
                .blur(radius: 90)
        )
        .ignoresSafeArea()
        .task {
            while true {
                withAnimation(.easeInOut(duration: 6)) { t = t > 0.8 ? 0.2 : t + 0.25 }
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
}

// MARK: - Placeholder sheets
struct CreateAccountPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image("homey_logo").resizable().scaledToFit().frame(height: 40)
                Text("Create Account").font(.title2.bold())
                Text("In app, present the real CreateAccountView.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Sign Up")
        }
    }
}
struct LoginPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image("homey_logo").resizable().scaledToFit().frame(height: 40)
                Text("Login").font(.title2.bold())
                Text("In app, present the real LoginView.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}

import PlaygroundSupport

PlaygroundPage.current.setLiveView(
    WelcomePageView()
        .preferredColorScheme(.dark)
)


