//
//  CinematicHomeyLandingView.swift
//  HOMEY Clean
//

import SwiftUI
import UIKit
import AudioToolbox

struct CinematicHomeyLandingView: View {
    @Binding var selectedTab: Int
    @Binding var showLeftDrawer: Bool
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var userProfileManager: UserProfileManager
    
    @State private var animateBackground = false
    @State private var animateContent = false
    @State private var searchText = ""
    @FocusState private var isConversationFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scrollOffset: CGFloat = 0
    private let silhouettePushDown: CGFloat = 20
    
    // Load the new Homeys silhouette background if available
    private func loadSilhouette() -> Image? {
        #if canImport(UIKit)
        if let ui = UIImage(named: "silhoutte_group") ?? UIImage(named: "silhouette_group") {
            return Image(uiImage: ui)
        }
        #endif
        return nil
    }
    
    var body: some View {
        ZStack {
            cinematicBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                cinematicNavigationBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        cinematicHeaderSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        searchSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        ActionBubblesView(
                            neonColor: Color.white.opacity(0.95),
                            actions: contextualActions(),
                            onSelect: { action in
                                handleAction(action)
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: HomeScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("homeScroll")).minY)
                        }
                    )
                }
                .coordinateSpace(name: "homeScroll")
                .onPreferenceChange(HomeScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
            }
        }
        .onAppear {
            themeManager.setCurrentPage(.homey)
            withAnimation(.easeOut(duration: 0.8)) { animateBackground = true }
            withAnimation(.easeOut(duration: 1.2).delay(0.4)) { animateContent = true }
        }
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Background
    private var cinematicBackground: some View {
        ZStack {
            // Base: silhouette image if available, otherwise original gradient
            Group {
                if let img = loadSilhouette() {
                    GeometryReader { geo in
                        // Compute a little extra height so when we push the image down it still fills the top
                        let parallax: CGFloat = reduceMotion ? 0 : (scrollOffset * 0.12)
                        let extra: CGFloat = silhouettePushDown + abs(parallax) + 40

                        img
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height + extra)
                            .offset(y: parallax + silhouettePushDown)
                            .clipped()
                    }
                } else {
                    LinearGradient(
                        colors: [Color.black, Color.black.opacity(0.98)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }

            GeometryReader { geo in
                TimeOfDayTopGradient()
                    .frame(height: geo.size.height * 0.33, alignment: .top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea()
            }

            // Top and bottom legibility scrims
            VStack(spacing: 0) {
                // Top radial scrim for header
                RadialGradient(
                    colors: [Color.black.opacity(0.55), .clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 260
                )
                .frame(height: 260)
                .allowsHitTesting(false)

                Spacer()

                // Bottom legibility scrim for action tiles and text
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.85),
                        Color.black.opacity(0.50),
                        Color.black.opacity(0.15),
                        .clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: UIScreen.main.bounds.height * 0.60)
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()

            // Ambient animated sheen (very subtle)
            LinearGradient(
                colors: [Color.white.opacity(0.06), Color.clear, Color.white.opacity(0.04)],
                startPoint: UnitPoint(
                    x: 0.5 + 0.2 * cos(animateBackground ? 2 * .pi : 0),
                    y: 0.5 + 0.2 * sin(animateBackground ? 2 * .pi : 0)
                ),
                endPoint: UnitPoint(
                    x: 0.5 - 0.2 * cos(animateBackground ? 2 * .pi : 0),
                    y: 0.5 - 0.2 * sin(animateBackground ? 2 * .pi : 0)
                )
            )
            .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: animateBackground)
            .opacity(0.18)
        }
    }
    
    // MARK: - Top Bar
    private var cinematicNavigationBar: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showLeftDrawer = true
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(Theme.CinematicLounge.textPrimary)
                    .padding(14)
                    .background(
                        Circle()
                            .fill(Theme.CinematicLounge.surface)
                            .overlay(Circle().stroke(Theme.CinematicLounge.border, lineWidth: 1))
                            .shadow(color: Theme.CinematicLounge.glassShadow, radius: 12, x: 0, y: 6)
                    )
            }
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                router.route = .profile
            } label: {
                ZStack {
                    Circle()
                        .fill(Theme.CinematicLounge.surface)
                        .frame(width: 48, height: 48)
                        .overlay(Circle().stroke(Theme.CinematicLounge.border, lineWidth: 1))
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.CinematicLounge.mutedIcon)
                }
                .shadow(color: Theme.CinematicLounge.glassShadow, radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
    
    // MARK: - Header
    private var cinematicHeaderSection: some View {
        VStack(spacing: 12) {
            Text("HOMEY")
                .font(.custom("PlayfairDisplay-Regular", size: 42))
                .foregroundStyle(Theme.CinematicLounge.textPrimary)
                .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
            
            Text("Welcome home, \(userProfileManager.currentProfile?.fullName ?? "friend").")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.CinematicLounge.textSecondary.opacity(0.95))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Search
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.white.opacity(0.95))
                TextField("Search", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                    .focused($isConversationFocused)
                    .onSubmit { handleSearch() }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            
            HStack(spacing: 12) {
                suggestionButton("3 bedroom in West Village")
                suggestionButton("1040 forms")
                suggestionButton("pre-approval checklist")
            }
        }
    }
    
    private func suggestionButton(_ text: String) -> some View {
        Button {
            searchText = text
            handleSearch()
        } label: {
            Text(text)
                .font(.caption)
                .foregroundStyle(Theme.CinematicLounge.textSecondary)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
    }
    
    private func handleSearch() {
        let q = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        if q.contains("1040") || q.contains("w2") || q.contains("form") || q.contains("forms") || q.contains("doc") || q.contains("document") || q.contains("documents") {
            router.route = .documents
        } else if q.contains("agent") || q.contains("contractor") || q.contains("mover") || q.contains("lawyer") || q.contains("vendor") || q.contains("directory") {
            router.route = .directory
        } else if q.contains("insight") || q.contains("market") || q.contains("trend") || q.contains("stats") {
            router.route = .insights
        } else {
            router.route = .search
        }
        isConversationFocused = false
    }
    
    private func contextualActions() -> [ContextAction] {
        let fullName = userProfileManager.currentProfile?.fullName ?? ""
        let name = fullName.split(separator: " ").first.map(String.init) ?? "You"
        return [
            ContextAction(title: "Documents", icon: "doc.fill", route: .documents, subtitle: "Upload 1040s"),
            ContextAction(title: "Directory", icon: "person.2.fill", route: .directory, subtitle: "Find pros"),
            ContextAction(title: "Insights", icon: "chart.line.uptrend.xyaxis", route: .insights, subtitle: "Market trends"),
            ContextAction(title: "Search", icon: "magnifyingglass", route: .search, subtitle: "Find anything")
        ]
    }
    
    private func handleAction(_ action: ContextAction) {
        router.route = action.route
    }
}

// HIDDEN: NeonHouseInteractiveView is not currently used and remains hidden.
// MARK: - Orb -> Key -> 2x2 Actions
private struct NeonHouseInteractiveView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var userProfileManager: UserProfileManager
    
    @State private var isPressing = false
    @State private var longPressSucceeded = false
    
    @State private var neonColor: Color = .cyan
    @State private var pressProgress: CGFloat = 0
    @State private var pulse = false
    @State private var orbRotation: Double = 0
    @State private var ringStartAngle: Double = Double(Int.random(in: 0...359))
    
    @State private var morphToKey = false
    @State private var keyOpacity: Double = 0
    @State private var keyRotation: Double = 0
    
    @State private var zoomed = false
    @State private var showActions = false
    @State private var orbOpacity: Double = 1.0
    
    private let neonPalette: [Color] = [
        .cyan, Color(UIColor.magenta), .green, .pink, .purple, .yellow, .orange, .blue,
        Color(red: 0.4, green: 1.0, blue: 0.8),
        Color(red: 1.0, green: 0.2, blue: 0.6)
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Glass Orb + Neon Ring
                ZStack {
                    let size = min(geo.size.width, 260)
                    
                    // Subtle base glow behind the hero
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.black.opacity(0.35),
                                    Color.black.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: size * 0.7
                            )
                        )
                        .frame(width: size, height: size)
                        .opacity(orbOpacity)
                    
                    // Neon House silhouette (replaces rainbow orb)
                    NeonHouseShape()
                        .stroke(
                            neonColor,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: size * 0.6, height: size * 0.55)
                        .shadow(color: neonColor.opacity(pulse ? 0.9 : 0.4), radius: pulse ? 18 : 8)
                        .shadow(color: neonColor.opacity(pulse ? 0.6 : 0.2), radius: pulse ? 32 : 16)
                        .opacity(orbOpacity)
                    
                    Circle()
                        .trim(from: 0, to: max(0.001, pressProgress))
                        .stroke(neonColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: size * 0.96, height: size * 0.96)
                        .rotationEffect(.degrees(ringStartAngle))
                        .shadow(color: neonColor.opacity(pulse ? 0.9 : 0.4), radius: pulse ? 18 : 8)
                        .shadow(color: neonColor.opacity(pulse ? 0.6 : 0.2), radius: pulse ? 32 : 16)
                        .opacity(orbOpacity)
                    
                    UnlockKeyShape()
                        .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .frame(width: size * 0.72, height: size * 0.28)
                        .rotation3DEffect(.degrees(keyRotation), axis: (x: 0, y: 1, z: 0))
                        .opacity(keyOpacity)
                        .shadow(color: Color.white.opacity(0.35), radius: 10)
                }
                .scaleEffect(zoomed ? 1.6 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: zoomed)
                .opacity(orbOpacity)
                .allowsHitTesting(!showActions)
                
                // 2x2 Actions
                if showActions {
                    ActionBubblesView(neonColor: neonColor, actions: contextualActions(), onSelect: handleAction(_:))
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        .padding(.top, 40)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                LongPressGesture(minimumDuration: 0.9, maximumDistance: 20)
                    .onChanged { pressing in
                        if pressing && !isPressing && !longPressSucceeded {
                            isPressing = true
                            startPress()
                        }
                        if !pressing && isPressing && !longPressSucceeded {
                            cancelPress()
                        }
                    }
                    .onEnded { success in
                        isPressing = false
                        if success {
                            longPressSucceeded = true
                            completePress()
                        } else {
                            cancelPress()
                        }
                    }
            )
            .onAppear {
                withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                    orbRotation = 360
                }
            }
            .onChange(of: showActions) { _, visible in
                if visible {
                    withAnimation(.easeOut(duration: 0.25)) { orbOpacity = 0 }
                } else {
                    orbOpacity = 1
                }
            }
        }
    }
    
    // MARK: - Interactions
    private func startPress() {
        ringStartAngle = Double(Int.random(in: 0...359))
        if let newColor = neonPalette.randomElement() { neonColor = newColor }
        withAnimation(.linear(duration: 1.1)) { pressProgress = 1.0 }
        withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { pulse = true }
    }
    
    private func cancelPress() {
        pulse = false
        withAnimation(.easeOut(duration: 0.25)) {
            pressProgress = 0
            zoomed = false
            morphToKey = false
            keyOpacity = 0
            keyRotation = 0
        }
        longPressSucceeded = false
    }
    
    private func completePress() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
            morphToKey = true
            zoomed = true
        }
        withAnimation(.easeInOut(duration: 0.35).delay(0.05)) { keyOpacity = 1 }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.08)) { keyRotation = -85 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) {
                showActions = true
            }
        }
    }
    
    private func contextualActions() -> [ContextAction] {
        let fullName = userProfileManager.currentProfile?.fullName ?? ""
        let name = fullName.split(separator: " ").first.map(String.init) ?? "You"
        return [
            ContextAction(title: "Documents", icon: "doc.fill", route: .documents, subtitle: "Upload 1040s"),
            ContextAction(title: "Directory", icon: "person.2.fill", route: .directory, subtitle: "Find pros"),
            ContextAction(title: "Insights", icon: "chart.line.uptrend.xyaxis", route: .insights, subtitle: "Market trends"),
            ContextAction(title: "Search", icon: "magnifyingglass", route: .search, subtitle: "Find anything")
        ]
    }
    
    private func handleAction(_ action: ContextAction) {
        router.route = action.route
    }
}

// MARK: - TreeView (ambient flanking trees)
private struct TreeView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let trunkW = max(2, w * 0.22)
            let trunkH = h * 0.42
            let crownH = max(0, h - trunkH)

            ZStack(alignment: .bottom) {
                // Foliage crown (layered blobs)
                ZStack {
                    // Base crown
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.33, saturation: 0.55, brightness: 0.75),
                                    Color(hue: 0.33, saturation: 0.65, brightness: 0.55)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: w * 0.95, height: crownH * 0.7)
                        .offset(y: crownH * -0.15)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

                    // Left lobe
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.33, saturation: 0.5, brightness: 0.78),
                                    Color(hue: 0.33, saturation: 0.62, brightness: 0.58)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: w * 0.7, height: crownH * 0.55)
                        .offset(x: -w * 0.18, y: crownH * -0.2)

                    // Right lobe
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.33, saturation: 0.52, brightness: 0.76),
                                    Color(hue: 0.33, saturation: 0.64, brightness: 0.56)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: w * 0.7, height: crownH * 0.55)
                        .offset(x: w * 0.18, y: crownH * -0.2)

                    // Subtle highlight
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        .frame(width: w * 0.6, height: crownH * 0.38)
                        .offset(y: crownH * -0.38)
                        .blendMode(.screen)
                }
                .frame(width: w, height: crownH, alignment: .top)

                // Trunk
                RoundedRectangle(cornerRadius: trunkW / 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.38, green: 0.26, blue: 0.18),
                                Color(red: 0.26, green: 0.18, blue: 0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: trunkW, height: trunkH)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            .frame(width: w, height: h, alignment: .bottom)
        }
    }
}

private struct StreetLampView: View {
    var body: some View {
        VStack(spacing: 4) {
            // Lamp head glow
            Circle()
                .fill(
                    RadialGradient(colors: [Color.yellow.opacity(0.6), Color.yellow.opacity(0.2), .clear], center: .center, startRadius: 0, endRadius: 12)
                )
                .frame(width: 18, height: 18)
                .overlay(
                    Circle().stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
            // Post
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.7))
                .frame(width: 3, height: 100)
        }
        .opacity(0.95)
    }
}

private struct SunGlareView: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.8), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .blur(radius: 2)
            .opacity(0.8)
    }
}

private struct WindowRectsView: View {
    enum Style { case reflection, glow }
    let style: Style

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            let rects: [CGRect] = [
                CGRect(x: 0.285*w, y: 0.34*h, width: 0.105*w, height: 0.125*h),
                CGRect(x: 0.62*w, y: 0.34*h, width: 0.105*w, height: 0.125*h),
                CGRect(x: 0.285*w, y: 0.56*h, width: 0.105*w, height: 0.125*h),
                CGRect(x: 0.62*w, y: 0.56*h, width: 0.105*w, height: 0.125*h),
                CGRect(x: 0.285*w, y: 0.78*h, width: 0.105*w, height: 0.125*h),
                CGRect(x: 0.62*w, y: 0.78*h, width: 0.105*w, height: 0.125*h)
            ]

            ZStack {
                ForEach(rects.indices, id: \.self) { idx in
                    let r = rects[idx]
                    switch style {
                    case .reflection:
                        // Only show top 4 for day reflection
                        if idx < 4 {
                            Rectangle()
                                .fill(
                                    LinearGradient(colors: [Color(red: 0.53, green: 0.81, blue: 0.98).opacity(0.6), Color(red: 0.88, green: 0.96, blue: 1.0).opacity(0.3)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: r.width, height: r.height)
                                .position(x: r.minX + r.width/2, y: r.minY + r.height/2)
                                .opacity(1)
                        }
                    case .glow:
                        Rectangle()
                            .fill(
                                RadialGradient(colors: [Color.yellow.opacity(0.8), Color.yellow.opacity(0.2)], center: .center, startRadius: 0, endRadius: max(r.width, r.height))
                            )
                            .frame(width: r.width, height: r.height)
                            .position(x: r.minX + r.width/2, y: r.minY + r.height/2)
                            .opacity(0.9)
                    }
                }
            }
        }
    }
}

private struct BrownstoneOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        // Main building rectangle
        let bodyRect = CGRect(x: 0.2*w, y: 0.25*h, width: 0.6*w, height: 0.58*h)
        p.addRect(bodyRect)

        // Roofline
        p.move(to: CGPoint(x: 0.18*w, y: 0.25*h))
        p.addLine(to: CGPoint(x: 0.82*w, y: 0.25*h))

        // Cornice detail
        p.move(to: CGPoint(x: 0.19*w, y: 0.27*h))
        p.addLine(to: CGPoint(x: 0.81*w, y: 0.27*h))

        // Stoop steps
        p.addRect(CGRect(x: 0.35*w, y: 0.78*h, width: 0.3*w, height: 0.025*h))
        p.addRect(CGRect(x: 0.325*w, y: 0.805*h, width: 0.35*w, height: 0.025*h))
        p.addRect(CGRect(x: 0.30*w, y: 0.83*h, width: 0.40*w, height: 0.025*h))

        // Stoop railings (curves)
        p.move(to: CGPoint(x: 0.30*w, y: 0.78*h))
        p.addQuadCurve(to: CGPoint(x: 0.30*w, y: 0.74*h), control: CGPoint(x: 0.27*w, y: 0.76*h))
        p.addQuadCurve(to: CGPoint(x: 0.30*w, y: 0.78*h), control: CGPoint(x: 0.33*w, y: 0.76*h))

        p.move(to: CGPoint(x: 0.70*w, y: 0.78*h))
        p.addQuadCurve(to: CGPoint(x: 0.70*w, y: 0.74*h), control: CGPoint(x: 0.73*w, y: 0.76*h))
        p.addQuadCurve(to: CGPoint(x: 0.70*w, y: 0.78*h), control: CGPoint(x: 0.67*w, y: 0.76*h))

        // Windows (frames only; panes implied by WindowRectsView)
        func addWindow(x: CGFloat, y: CGFloat) {
            p.addRect(CGRect(x: x, y: y, width: 0.105*w, height: 0.125*h))
        }
        addWindow(x: 0.285*w, y: 0.34*h)
        addWindow(x: 0.62*w, y: 0.34*h)
        addWindow(x: 0.285*w, y: 0.56*h)
        addWindow(x: 0.62*w, y: 0.56*h)
        addWindow(x: 0.285*w, y: 0.78*h)
        addWindow(x: 0.62*w, y: 0.78*h)

        // Door
        p.addRect(CGRect(x: 0.425*w, y: 0.69*h, width: 0.15*w, height: 0.18*h))
        // Door knob
        p.addEllipse(in: CGRect(x: 0.495*w, y: 0.78*h, width: 0.015*w, height: 0.015*w))

        return p
    }
}

private struct NeonHouseShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        // Roof (triangle)
        let roofTop = CGPoint(x: 0.5 * w, y: 0.12 * h)
        let roofLeft = CGPoint(x: 0.2 * w, y: 0.4 * h)
        let roofRight = CGPoint(x: 0.8 * w, y: 0.4 * h)
        p.move(to: roofLeft)
        p.addLine(to: roofTop)
        p.addLine(to: roofRight)
        p.addLine(to: roofLeft)

        // House body
        let bodyRect = CGRect(x: 0.28 * w, y: 0.4 * h, width: 0.44 * w, height: 0.45 * h)
        p.addRect(bodyRect)

        // Door
        let doorRect = CGRect(x: 0.48 * w, y: 0.58 * h, width: 0.12 * w, height: 0.27 * h)
        p.addRect(doorRect)

        // Windows
        let leftWin = CGRect(x: 0.33 * w, y: 0.48 * h, width: 0.1 * w, height: 0.1 * h)
        let rightWin = CGRect(x: 0.57 * w, y: 0.48 * h, width: 0.1 * w, height: 0.1 * h)
        p.addRect(leftWin)
        p.addRect(rightWin)

        // Chimney
        let chimney = CGRect(x: 0.62 * w, y: 0.2 * h, width: 0.06 * w, height: 0.14 * h)
        p.addRect(chimney)

        return p
    }
}

private struct UnlockKeyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        // Key head (outer circle)
        let headCenter = CGPoint(x: 0.25 * w, y: 0.5 * h)
        let headRadius = 0.18 * h
        let headRect = CGRect(x: headCenter.x - headRadius, y: headCenter.y - headRadius, width: headRadius * 2, height: headRadius * 2)
        p.addEllipse(in: headRect)

        // Key head hole (inner circle)
        let holeRadius = 0.08 * h
        let holeRect = CGRect(x: headCenter.x - holeRadius, y: headCenter.y - holeRadius, width: holeRadius * 2, height: holeRadius * 2)
        p.addEllipse(in: holeRect)

        // Shaft
        let shaftHeight = 0.09 * h
        let shaftStartX = headCenter.x + headRadius * 0.75
        let shaftRect = CGRect(x: shaftStartX, y: headCenter.y - shaftHeight / 2, width: 0.45 * w, height: shaftHeight)
        p.addRect(shaftRect)

        // Teeth
        let tooth1 = CGRect(x: shaftRect.maxX - 0.18 * w, y: shaftRect.maxY - 0.02 * h, width: 0.06 * w, height: 0.06 * h)
        let tooth2 = CGRect(x: shaftRect.maxX - 0.08 * w, y: shaftRect.maxY - 0.04 * h, width: 0.08 * w, height: 0.08 * h)
        p.addRect(tooth1)
        p.addRect(tooth2)

        return p
    }
}

private struct ContextAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let route: AppRoute
    let subtitle: String
}

private struct ActionBubblesView: View {
    let neonColor: Color
    let actions: [ContextAction]
    let onSelect: (ContextAction) -> Void
    @State private var appear = false
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
            ForEach(actions.indices, id: \.self) { idx in
                ActionBubble(action: actions[idx], neonColor: neonColor) {
                    onSelect(actions[idx])
                }
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.85)
                .animation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.05 * Double(idx)), value: appear)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 24)
        .onAppear { appear = true }
    }
}

private struct ActionBubble: View {
    let action: ContextAction
    let neonColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)
                        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.CinematicLounge.textPrimary)
                }
                Text(action.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.CinematicLounge.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(action.subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.CinematicLounge.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FacadeFillOverlay
private struct FacadeFillOverlay: View {
    enum Mode {
        case day, night, none
    }
    
    var mode: Mode?
    
    var body: some View {
        GeometryReader { geo in
            let gradient = Self.gradient(for: mode ?? .none)
            Rectangle()
                .fill(gradient)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    private static func gradient(for mode: Mode) -> LinearGradient {
        switch mode {
        case .day:
            return LinearGradient(
                colors: [Color(red: 0.62, green: 0.45, blue: 0.36), Color(red: 0.45, green: 0.33, blue: 0.27)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .night:
            return LinearGradient(
                colors: [Color(red: 0.22, green: 0.26, blue: 0.32), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .none:
            return LinearGradient(
                colors: [Color.clear, Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - DoorLightSpillOverlay
private struct DoorLightSpillOverlay: View {
    enum Mode {
        case day, night, none
    }
    
    var mode: Mode?
    
    var body: some View {
        GeometryReader { geo in
            let colors = Self.spillColors(for: mode ?? .none)
            RadialGradient(
                gradient: Gradient(colors: colors),
                center: .bottom,
                startRadius: 0,
                endRadius: geo.size.height * 0.8
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private static func spillColors(for mode: Mode) -> [Color] {
        switch mode {
        case .day:
            return [Color.yellow.opacity(0.55), .clear]
        case .night:
            return [Color(hue: 0.12, saturation: 0.9, brightness: 1.0).opacity(0.85), .clear]
        case .none:
            return [Color.yellow.opacity(0.5), .clear]
        }
    }
}

// MARK: - DoorOverlay
private struct DoorOverlay: View {
    enum Mode {
        case day, night, none
    }
    
    var mode: Mode?
    
    var body: some View {
        GeometryReader { geo in
            let colors = Self.doorColors(for: mode ?? .none)
            let doorColorTop = colors.top
            let doorColorBottom = colors.bottom
            
            LinearGradient(
                colors: [doorColorTop, doorColorBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(8)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private static func doorColors(for mode: Mode) -> (top: Color, bottom: Color) {
        switch mode {
        case .day:
            return (
                Color(red: 0.35, green: 0.20, blue: 0.12),
                Color(red: 0.22, green: 0.12, blue: 0.07)
            )
        case .night:
            return (
                Color(red: 0.20, green: 0.22, blue: 0.26),
                Color(red: 0.10, green: 0.12, blue: 0.16)
            )
        case .none:
            return (
                Color.gray,
                Color.gray.opacity(0.8)
            )
        }
    }
}

#Preview {
    CinematicHomeyLandingView(selectedTab: .constant(0), showLeftDrawer: .constant(false))
        .environmentObject(AppRouter())
        .environmentObject(AppSessionManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(UserProfileManager.shared)
}

private struct HomeScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Time-of-day sky with sun/moon, clouds/stars and animated gradients
private struct SkyBackdropView: View {
    enum TimeOfDay { case day, sunset, night }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private func mode(for date: Date) -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<17: return .day
        case 17..<20: return .sunset
        default: return .night
        }
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date
            let m = mode(for: now)
            ZStack {
                switch m {
                case .day:
                    DaySkyLayer(reduceMotion: reduceMotion)
                case .sunset:
                    SunsetSkyLayer(reduceMotion: reduceMotion)
                case .night:
                    NightSkyLayer(reduceMotion: reduceMotion)
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

private struct DaySkyLayer: View {
    let reduceMotion: Bool
    @State private var animateSheen = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.65),
                    Color.cyan.opacity(0.45),
                    Color.white.opacity(0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 24)
            
            // Soft moving sheen
            LinearGradient(
                colors: [Color.white.opacity(0.10), .clear, Color.white.opacity(0.08)],
                startPoint: animateSheen ? .topLeading : .bottomTrailing,
                endPoint: animateSheen ? .bottomTrailing : .topLeading
            )
            .animation(reduceMotion ? nil : .linear(duration: 20).repeatForever(autoreverses: true), value: animateSheen)
            .onAppear { animateSheen = true }
            .blur(radius: 40)
            
            // Sun
            SunView()
                .frame(width: 140, height: 140)
                .offset(x: 120, y: -220)
                .opacity(0.9)
            
            // Clouds
            VStack(spacing: 0) {
                CloudRow(yOffset: -140, speed: 36, scale: 1.0, opacity: 0.30, reverse: false, reduceMotion: reduceMotion)
                CloudRow(yOffset: -40, speed: 48, scale: 1.1, opacity: 0.25, reverse: true, reduceMotion: reduceMotion)
                CloudRow(yOffset: 60, speed: 60, scale: 0.95, opacity: 0.20, reverse: false, reduceMotion: reduceMotion)
            }
        }
    }
}

private struct SunsetSkyLayer: View {
    let reduceMotion: Bool
    @State private var animateSheen = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.55),
                    Color.pink.opacity(0.45),
                    Color.purple.opacity(0.40)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 24)
            
            LinearGradient(
                colors: [Color.white.opacity(0.10), .clear, Color.white.opacity(0.08)],
                startPoint: animateSheen ? .topLeading : .bottomTrailing,
                endPoint: animateSheen ? .bottomTrailing : .topLeading
            )
            .animation(reduceMotion ? nil : .linear(duration: 24).repeatForever(autoreverses: true), value: animateSheen)
            .onAppear { animateSheen = true }
            .blur(radius: 46)
            .opacity(0.8)
            
            // Low sun at horizon
            SunView()
                .frame(width: 120, height: 120)
                .offset(x: 40, y: 180)
                .opacity(0.85)
            
            // Gentle clouds
            VStack(spacing: 0) {
                CloudRow(yOffset: -20, speed: 52, scale: 1.0, opacity: 0.22, reverse: false, reduceMotion: reduceMotion)
                CloudRow(yOffset: 80, speed: 64, scale: 1.15, opacity: 0.18, reverse: true, reduceMotion: reduceMotion)
            }
        }
    }
}

private struct NightSkyLayer: View {
    let reduceMotion: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.65),
                    Color.blue.opacity(0.45),
                    Color.black.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 16)
            
            // Stars
            StarsLayer(count: 80, twinkle: !reduceMotion)
                .opacity(0.9)
            
            // Moon
            MoonView()
                .frame(width: 90, height: 90)
                .offset(x: -120, y: -200)
                .opacity(0.95)
        }
    }
}

private struct SunView: View {
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [Color.yellow.opacity(0.7), Color.orange.opacity(0.3), .clear],
                                   center: .center, startRadius: 0, endRadius: 120)
                )
                .scaleEffect(pulse ? 1.06 : 0.98)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulse)
            Circle()
                .fill(Color.yellow.opacity(0.95))
        }
        .onAppear { pulse = true }
    }
}

private struct MoonView: View {
    @State private var glow = false
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [Color.white.opacity(0.65), Color.white.opacity(0.15), .clear],
                                   center: .center, startRadius: 0, endRadius: 100)
                )
                .blur(radius: glow ? 9 : 5)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glow)
            Circle()
                .fill(Color.white.opacity(0.95))
            // Subtle crescent effect
            Circle()
                .fill(Color.black.opacity(0.85))
                .offset(x: 12)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        .onAppear { glow = true }
    }
}

private struct CloudRow: View {
    let yOffset: CGFloat
    let speed: Double
    let scale: CGFloat
    let opacity: Double
    let reverse: Bool
    let reduceMotion: Bool
    @State private var x: CGFloat = -600
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            HStack(spacing: 80) {
                CloudView().frame(width: 180, height: 70)
                CloudView().frame(width: 140, height: 56)
                CloudView().frame(width: 200, height: 80)
                CloudView().frame(width: 120, height: 48)
            }
            .opacity(opacity)
            .scaleEffect(scale, anchor: .center)
            .offset(x: x, y: yOffset)
            .onAppear {
                guard !reduceMotion else { return }
                x = reverse ? (width + 220) : (-width - 220)
                withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                    x = reverse ? (-width - 220) : (width + 220)
                }
            }
        }
    }
}

private struct CloudView: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.75)).frame(width: 68, height: 54).offset(x: -30, y: -6)
            Circle().fill(Color.white.opacity(0.75)).frame(width: 84, height: 64).offset(x: 0, y: -10)
            Circle().fill(Color.white.opacity(0.75)).frame(width: 64, height: 50).offset(x: 34, y: -4)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.75))
                .frame(width: 160, height: 40)
                .offset(y: 8)
        }
        .blur(radius: 0.6)
    }
}

private struct StarsLayer: View {
    let count: Int
    let twinkle: Bool
    @State private var phase = false
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let px = pseudoRandom(i, seed: 73) * w
                    let py = pseudoRandom(i, seed: 19) * (h * 0.7)
                    let size = 1.0 + pseudoRandom(i, seed: 101) * 2.0
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: size, height: size)
                        .position(x: px, y: py)
                        .opacity(twinkle ? (0.5 + 0.5 * sin((Double(i) * 0.7) + (phase ? 0 : .pi))) : 0.9)
                }
            }
            .onAppear {
                guard twinkle else { return }
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: true)) {
                    phase.toggle()
                }
            }
        }
    }
    
    private func pseudoRandom(_ i: Int, seed: Int) -> CGFloat {
        let v = abs(sin(Double(i * seed)) * 10_000).truncatingRemainder(dividingBy: 1)
        return CGFloat(v)
    }
}

// MARK: - Time-of-day top-third animated gradient
private struct TimeOfDayTopGradient: View {
    @State private var animate = false

    private func mode(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<17: return "day"
        case 17..<20: return "sunset"
        default: return "night"
        }
    }

    private func colors(for mode: String) -> [Color] {
        switch mode {
        case "day":
            return [Color.blue.opacity(0.55), Color.cyan.opacity(0.40), Color.white.opacity(0.08)]
        case "sunset":
            return [Color.orange.opacity(0.55), Color.pink.opacity(0.45), Color.purple.opacity(0.35)]
        default:
            return [Color.indigo.opacity(0.55), Color.blue.opacity(0.40), Color.black.opacity(0.35)]
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let m = mode(for: timeline.date)
            LinearGradient(
                colors: colors(for: m),
                startPoint: animate ? .topLeading : .top,
                endPoint: animate ? .trailing : .bottomTrailing
            )
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
            .blur(radius: 22)
            .allowsHitTesting(false)
        }
    }
}