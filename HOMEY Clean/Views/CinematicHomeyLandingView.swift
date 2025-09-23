//
//  CinematicHomeyLandingView.swift
//  HOMEY Clean
//
//  Cinematic Lounge themed HOMEY landing view with minimalist design
//

import SwiftUI
import UIKit

struct CinematicHomeyLandingView: View {
    @Binding var selectedTab: Int
    @Binding var showLeftDrawer: Bool
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var userProfileManager: UserProfileManager
    
    @State private var animateBackground = false
    @State private var animateContent = false
    @State private var conversationText = ""
    @State private var searchText = ""
    @FocusState private var isConversationFocused: Bool
    
    var body: some View {
        ZStack {
            // Cinematic background with subtle gradient
            cinematicBackground
                .ignoresSafeArea()
            
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
                        
                        NeonHouseInteractiveView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 320)
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            themeManager.setCurrentPage(.homey)
            withAnimation(.easeOut(duration: 0.8)) {
                animateBackground = true
            }
            
            withAnimation(.easeOut(duration: 1.2).delay(0.4)) {
                animateContent = true
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Cinematic Background
    private var cinematicBackground: some View {
        ZStack {
            // Base gradient background
            Theme.CinematicLounge.backgroundGradient
            
            // Subtle animated overlay for depth
            LinearGradient(
                colors: [
                    Color.white.opacity(0.02),
                    Color.clear,
                    Color.white.opacity(0.01)
                ],
                startPoint: UnitPoint(
                    x: 0.5 + 0.2 * cos(animateBackground ? 2 * Double.pi : 0),
                    y: 0.5 + 0.2 * sin(animateBackground ? 2 * Double.pi : 0)
                ),
                endPoint: UnitPoint(
                    x: 0.5 - 0.2 * cos(animateBackground ? 2 * Double.pi : 0),
                    y: 0.5 - 0.2 * sin(animateBackground ? 2 * Double.pi : 0)
                )
            )
            .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: animateBackground)
        }
    }
    
    // MARK: - Cinematic Navigation Bar
    private var cinematicNavigationBar: some View {
        HStack {
            // Hamburger menu with glass effect
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showLeftDrawer = true
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(Theme.CinematicLounge.textPrimary)
                    .padding(14)
                    .background(
                        Circle()
                            .fill(Theme.CinematicLounge.surface)
                            .overlay(
                                Circle()
                                    .stroke(Theme.CinematicLounge.border, lineWidth: 1)
                            )
                            .shadow(color: Theme.CinematicLounge.glassShadow, radius: 12, x: 0, y: 6)
                    )
            }
            
            Spacer()
            
            cinematicProfileSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
    
    // MARK: - Cinematic Profile Section
    private var cinematicProfileSection: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            DispatchQueue.main.async {
                router.route = .profile
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Theme.CinematicLounge.surface)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Theme.CinematicLounge.border, lineWidth: 1)
                    )
                
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.CinematicLounge.mutedIcon)
            }
            .shadow(color: Theme.CinematicLounge.glassShadow, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Cinematic Header Section
    private var cinematicHeaderSection: some View {
        VStack(spacing: 12) {
            // Bold, centered logo
            Text("HOMEY")
                .font(.system(size: 44, weight: .bold, design: .default))
                .foregroundStyle(Theme.CinematicLounge.textPrimary)
                .shadow(color: Theme.CinematicLounge.shadow, radius: 16, x: 0, y: 8)
            
            // Conversational subheading
            Text("Welcome home, \(userProfileManager.currentProfile?.fullName ?? "friend").")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundStyle(Theme.CinematicLounge.textSecondary)
                .multilineTextAlignment(.center)
                .shadow(color: Theme.CinematicLounge.shadow, radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.CinematicLounge.mutedIcon)
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
                            .foregroundStyle(Theme.CinematicLounge.mutedIcon)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.CinematicLounge.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.CinematicLounge.border, lineWidth: 1)
                    )
                    .shadow(color: Theme.CinematicLounge.glassShadow, radius: 10, x: 0, y: 4)
            )

            // Thin suggestions
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
                .foregroundStyle(Theme.CinematicLounge.textTertiary)
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
            router.route = .discover
        }
        isConversationFocused = false
    }
}

// MARK: - Glass Effect Card Style for Cinematic Theme
struct CinematicGlassCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Cinematic Action Grid Item
struct CinematicActionGridItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let delay: Double
    let action: () -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon with glass background
                ZStack {
                    Circle()
                        .fill(Theme.CinematicLounge.surface)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Theme.CinematicLounge.border, lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Theme.CinematicLounge.mutedIcon)
                }
                
                // Text content
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundStyle(Theme.CinematicLounge.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundStyle(Theme.CinematicLounge.textTertiary)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.CinematicLounge.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.CinematicLounge.border, lineWidth: 1)
                    )
                    .shadow(color: Theme.CinematicLounge.glassShadow, radius: 16, x: 0, y: 8)
            )
            .scaleEffect(animateIn ? 1.0 : 0.8)
            .opacity(animateIn ? 1.0 : 0.0)
            .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(delay), value: animateIn)
        }
        .buttonStyle(CinematicGlassCardStyle())
        .onAppear {
            animateIn = true
        }
    }
}

// MARK: - Neon House Interactive View
private struct NeonHouseInteractiveView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @EnvironmentObject private var session: AppSessionManager

    @State private var isPressing = false
    @State private var longPressSucceeded = false
    @State private var drawProgress: CGFloat = 0
    @State private var neonColor: Color = .cyan
    @State private var pulse = false
    @State private var zoomed = false
    @State private var showActions = false
    @State private var houseOpacity: Double = 1.0
    @State private var leftWindowOn = false
    @State private var rightWindowOn = false
    @State private var doorProgress: CGFloat = 0
    @State private var doorOpen = false

    private let neonPalette: [Color] = [
        .cyan, Color(UIColor.magenta), .green, .pink, .purple, .yellow, .orange, .blue,
        Color(red: 0.4, green: 1.0, blue: 0.8), // mint-cyan
        Color(red: 1.0, green: 0.2, blue: 0.6)  // hot pink
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // House container
                VStack(spacing: 16) {
                    ZStack {
                        // Subtle base outline (day: black, night: white)
                        let baseStroke = (colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.15))

                        HouseOutlineShape()
                            .stroke(baseStroke, lineWidth: 1)
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .opacity(houseOpacity)

                        // Neon outline drawing in
                        HouseOutlineShape()
                            .trim(from: 0, to: drawProgress)
                            .stroke(neonColor, style: StrokeStyle(lineWidth: 4, lineCap: .butt, lineJoin: .round))
                            .shadow(color: neonColor.opacity(pulse ? 0.9 : 0.4), radius: pulse ? 18 : 8)
                            .shadow(color: neonColor.opacity(pulse ? 0.6 : 0.2), radius: pulse ? 32 : 16)
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .opacity(houseOpacity)

                        // Windows (left then right)
                        LeftWindow()
                            .fill(neonColor.opacity(leftWindowOn ? (pulse ? 0.9 : 0.6) : 0))
                            .shadow(color: neonColor.opacity(leftWindowOn ? (pulse ? 0.6 : 0.2) : 0), radius: pulse ? 14 : 6)
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .opacity(houseOpacity)
                        LeftWindow()
                            .stroke(neonColor.opacity(leftWindowOn ? 1 : 0), lineWidth: leftWindowOn ? 3 : 0)
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .opacity(houseOpacity)

                        RightWindow()
                            .fill(neonColor.opacity(rightWindowOn ? (pulse ? 0.9 : 0.6) : 0))
                            .shadow(color: neonColor.opacity(rightWindowOn ? (pulse ? 0.6 : 0.2) : 0), radius: pulse ? 14 : 6)
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .opacity(houseOpacity)
                        RightWindow()
                            .stroke(neonColor.opacity(rightWindowOn ? 1 : 0), lineWidth: rightWindowOn ? 3 : 0)
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .opacity(houseOpacity)

                        // Door outline + fill + swing
                        HouseDoor()
                            .trim(from: 0, to: doorProgress)
                            .stroke(neonColor, lineWidth: max(1, 3 * doorProgress))
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .opacity(houseOpacity)

                        DoorLeaf()
                            .fill(neonColor.opacity(doorProgress > 0 ? (pulse ? 0.85 : 0.65) : 0))
                            .frame(width: min(geo.size.width, 320) - 40, height: 180)
                            .rotationEffect(.degrees(doorOpen ? -65 : 0), anchor: .leading)
                            .shadow(color: neonColor.opacity(doorOpen ? 0.5 : 0), radius: 12, x: 0, y: 4)
                            .opacity(houseOpacity)
                    }
                    .scaleEffect(zoomed ? 2.6 : 1.0, anchor: UnitPoint(x: 0.5, y: 0.78))
                    .rotation3DEffect(.degrees(zoomed ? 2 : 0), axis: (x: 1, y: 0, z: 0), anchor: .center, perspective: 0.8)
                    .blur(radius: zoomed ? 4 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: zoomed)

                    // Hint text
                    if !showActions {
                        Text("Long press to enter your home")
                            .font(.footnote)
                            .foregroundStyle(Theme.CinematicLounge.textTertiary)
                            .opacity(0.8)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())

                // Action bubbles reveal
                if showActions {
                    ActionBubblesView(neonColor: neonColor, actions: contextualActions(), onSelect: handleAction(_:))
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.8, maximumDistance: 20)
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
            .accessibilityAddTraits(.isButton)
            .onChange(of: drawProgress) { _, newValue in
                if newValue >= 0.18 && !leftWindowOn {
                    withAnimation(.easeOut(duration: 0.2)) { leftWindowOn = true }
                }
                if newValue >= 0.55 && !rightWindowOn {
                    withAnimation(.easeOut(duration: 0.2)) { rightWindowOn = true }
                }
                if newValue >= 0.75 && doorProgress == 0 {
                    withAnimation(.easeInOut(duration: 0.25)) { doorProgress = 1 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            doorOpen = true
                        }
                    }
                }
            }
        }
    }

    private func startPress() {
        // Pick a random neon color
        if let newColor = neonPalette.randomElement() {
            neonColor = newColor
        }
        // Draw in the outline
        withAnimation(.linear(duration: 0.8)) {
            drawProgress = 1.0
        }
        // Begin pulsing
        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }

    private func cancelPress() {
        pulse = false
        withAnimation(.easeOut(duration: 0.3)) {
            drawProgress = 0.0
            leftWindowOn = false
            rightWindowOn = false
            doorProgress = 0
            doorOpen = false
        }
    }

    private func completePress() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            zoomed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.25)) {
                houseOpacity = 0.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                showActions = true
            }
        }
    }

    private func reset() {
        // Reset to initial state
        pulse = false
        withAnimation(.easeOut(duration: 0.25)) {
            showActions = false
            houseOpacity = 1.0
            zoomed = false
            drawProgress = 0.0
            longPressSucceeded = false
            leftWindowOn = false
            rightWindowOn = false
            doorProgress = 0
            doorOpen = false
        }
    }

    private func contextualActions() -> [ContextAction] {
        // Example: tailor based on simple heuristics (extend with real stage logic)
        var actions: [ContextAction] = []
        let fullName = userProfileManager.currentProfile?.fullName ?? ""
        let name = fullName.split(separator: " ").first.map(String.init) ?? "You"
        actions.append(ContextAction(title: "Documents", icon: "doc.fill", route: .documents, subtitle: "Upload 1040s"))
        actions.append(ContextAction(title: "Directory", icon: "person.2.fill", route: .directory, subtitle: "Find pros"))
        actions.append(ContextAction(title: "Insights", icon: "chart.line.uptrend.xyaxis", route: .insights, subtitle: "Market trends"))
        actions.append(ContextAction(title: "Discover", icon: "sparkles", route: .discover, subtitle: "Welcome, \(name)"))
        return actions
    }

    private func handleAction(_ action: ContextAction) {
        // Navigate and optionally reset
        router.route = action.route
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
        let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
        LazyVGrid(columns: columns, alignment: .center, spacing: 24) {
            ForEach(actions.indices, id: \.self) { idx in
                ActionBubble(action: actions[idx], neonColor: neonColor) {
                    onSelect(actions[idx])
                }
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.85)
                .animation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.05 * Double(idx)), value: appear)
            }
        }
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity)
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
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle()
                                .stroke(neonColor.opacity(0.8), lineWidth: 2)
                        )
                        .shadow(color: neonColor.opacity(0.5), radius: 10)

                    Image(systemName: action.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(neonColor)
                }

                Text(action.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.CinematicLounge.textPrimary)

                Text(action.subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.CinematicLounge.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - House Shapes

private struct HouseOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        p.move(to: CGPoint(x: w * 0.25, y: h * 0.88))             // bottom-left
        p.addLine(to: CGPoint(x: w * 0.25, y: h * 0.50))           // up left wall
        p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.18))            // to roof peak
        p.addLine(to: CGPoint(x: w * 0.75, y: h * 0.50))           // down to right roof base
        p.addLine(to: CGPoint(x: w * 0.75, y: h * 0.88))           // down right wall
        p.addLine(to: CGPoint(x: w * 0.25, y: h * 0.88))           // along base back to start

        return p
    }
}

private struct HouseWindows: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        let windowSize = CGSize(width: w * 0.16, height: h * 0.16)
        let leftWindowOrigin = CGPoint(x: w * 0.28 - windowSize.width/2, y: h * 0.55 - windowSize.height/2)
        let rightWindowOrigin = CGPoint(x: w * 0.72 - windowSize.width/2, y: h * 0.55 - windowSize.height/2)

        p.addRoundedRect(in: CGRect(origin: leftWindowOrigin, size: windowSize), cornerSize: CGSize(width: 6, height: 6))
        p.addRoundedRect(in: CGRect(origin: rightWindowOrigin, size: windowSize), cornerSize: CGSize(width: 6, height: 6))

        return p
    }
}

private struct LeftWindow: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let windowSize = CGSize(width: w * 0.16, height: h * 0.16)
        let origin = CGPoint(x: w * 0.28 - windowSize.width/2, y: h * 0.55 - windowSize.height/2)
        p.addRoundedRect(in: CGRect(origin: origin, size: windowSize), cornerSize: CGSize(width: 6, height: 6))
        return p
    }
}

private struct RightWindow: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let windowSize = CGSize(width: w * 0.16, height: h * 0.16)
        let origin = CGPoint(x: w * 0.72 - windowSize.width/2, y: h * 0.55 - windowSize.height/2)
        p.addRoundedRect(in: CGRect(origin: origin, size: windowSize), cornerSize: CGSize(width: 6, height: 6))
        return p
    }
}

private struct HouseDoor: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let doorWidth = w * 0.18
        let doorHeight = h * 0.3
        let doorOrigin = CGPoint(x: w * 0.5 - doorWidth/2, y: h * 0.85 - doorHeight)

        p.addRoundedRect(in: CGRect(origin: doorOrigin, size: CGSize(width: doorWidth, height: doorHeight)), cornerSize: CGSize(width: 6, height: 6))
        return p
    }
}

private struct DoorLeaf: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let doorWidth = w * 0.18
        let doorHeight = h * 0.3
        let doorOrigin = CGPoint(x: w * 0.5 - doorWidth/2, y: h * 0.85 - doorHeight)
        let doorRect = CGRect(origin: doorOrigin, size: CGSize(width: doorWidth, height: doorHeight))
        p.addRoundedRect(in: doorRect, cornerSize: CGSize(width: 6, height: 6))
        return p
    }
}

#Preview {
    CinematicHomeyLandingView(selectedTab: .constant(0), showLeftDrawer: .constant(false))
        .environmentObject(AppRouter())
        .environmentObject(AppSessionManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(UserProfileManager.shared)
}