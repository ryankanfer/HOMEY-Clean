//
//  HomeyLandingViewWithProfile.swift
//  HOMEY Clean
//
//  Enhanced HOMEY landing view with profile section and left drawer integration
//

import SwiftUI
import UIKit

struct HomeyLandingViewWithProfile: View {
    @Binding var selectedTab: Int
    @Binding var showLeftDrawer: Bool
    @EnvironmentObject private var router: DrawerRouter
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var userProfileManager: UserProfileManager
    
    // Animation states
    @State private var animateBackground = false
    @State private var animateContent = false
    @State private var conversationText = ""
    @FocusState private var isConversationFocused: Bool
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedGradientBackground(for: .homey)
                .ignoresSafeArea()
                .scaleEffect(animateBackground ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 20).repeatForever(autoreverses: true), value: animateBackground)
            
            VStack(spacing: 0) {
                // Top navigation bar with hamburger menu and profile
                topNavigationBar
                
                // Main content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header section
                        headerSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        VStack(spacing: 20) {
                            // Replace 2x2 grid with customizable homepage
                            CustomizableHomepageGrid()
                            
                            // Replace conversational interface with Next Up smart card
                            NextUpSmartCard()
                        }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            themeManager.setCurrentPage(.homey)
            withAnimation(.easeOut(duration: 0.8)) {
                animateBackground = true
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Hamburger menu button
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
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
            
            Spacer()
            
            // Profile section
            profileSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            DispatchQueue.main.async {
                router.route = .profile
            }
        } label: {
            // Avatar only - no text
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("HOMEY")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Text("Let's get you home, \(userProfileManager.currentProfile?.fullName ?? "friend")!")
                .font(.title3.weight(.medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Action Grid
    private var actionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            HomeyActionGridItem(
                title: "Search Properties",
                subtitle: "Find your dream home",
                icon: "magnifyingglass",
                color: .blue,
                delay: 0.1
            ) {
                selectedTab = 1 // Navigate to Discover tab
            }
            
            HomeyActionGridItem(
                title: "Documents",
                subtitle: "Manage your vault",
                icon: "doc.fill",
                color: .orange,
                delay: 0.2
            ) {
                router.route = .documents
            }
            
            HomeyActionGridItem(
                title: "Matchmaker",
                subtitle: "Find your perfect match",
                icon: "heart.circle",
                color: .pink,
                delay: 0.3
            ) {
                router.route = .matchmaker
            }
            
            HomeyActionGridItem(
                title: "Next Up",
                subtitle: "Your upcoming tasks",
                icon: "arrow.right.circle.fill",
                color: .green,
                delay: 0.4
            ) {
                // Navigate to next step or journey view
                selectedTab = 2 // Navigate to Profile tab to see journey progress
            }
        }
    }
    
    // MARK: - Conversational Interface
    private var conversationalInterface: some View {
        VStack(spacing: 20) {
            Text("Ask HOMEY anything about your home buying journey")
                .font(.headline.weight(.medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 12) {
                TextField("What can I help you with today?", text: $conversationText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
                    .focused($isConversationFocused)
                
                Button {
                    // Handle conversation input
                    if !conversationText.isEmpty {
                        // Process the conversation
                        conversationText = ""
                        isConversationFocused = false
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .disabled(conversationText.isEmpty)
                .opacity(conversationText.isEmpty ? 0.6 : 1.0)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Homey Action Grid Item
struct HomeyActionGridItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let delay: Double
    let action: () -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) { // Reduced from 12 to 9 (25% reduction)
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 45, height: 45) // Reduced from 60 to 45 (25% reduction)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium)) // Reduced from 24 to 18 (25% reduction)
                        .foregroundColor(color)
                }
                
                VStack(spacing: 3) { // Reduced from 4 to 3 (25% reduction)
                    Text(title)
                        .font(.subheadline.weight(.semibold)) // Reduced from .headline
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption2) // Reduced from .caption
                        .foregroundColor(.white.opacity(0.8))
                }
                .multilineTextAlignment(.center)
            }
            .padding(.vertical, 15) // Reduced from 20 to 15 (25% reduction)
            .padding(.horizontal, 12) // Reduced from 16 to 12 (25% reduction)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15) // Reduced from 20 to 15 (25% reduction)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3) // Reduced shadow
            )
            .scaleEffect(animateIn ? 1.0 : 0.8)
            .opacity(animateIn ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateIn)
        }
        .buttonStyle(PressableCardStyle())
        .onAppear {
            animateIn = true
        }
    }
}

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Homey Animated Sky Background
struct HomeyAnimatedSkyBackground: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.3, green: 0.4, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated overlay
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.clear,
                    Color.purple.opacity(0.2)
                ],
                startPoint: UnitPoint(
                    x: 0.5 + 0.3 * cos(phase * 2 * Double.pi),
                    y: 0.5 + 0.3 * sin(phase * 2 * Double.pi)
                ),
                endPoint: UnitPoint(
                    x: 0.5 - 0.3 * cos(phase * 2 * Double.pi),
                    y: 0.5 - 0.3 * sin(phase * 2 * Double.pi)
                )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - Press Gesture Extension
extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

