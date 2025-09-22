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
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var userProfileManager: UserProfileManager
    
    @State private var animateBackground = false
    @State private var animateContent = false
    @State private var conversationText = ""
    @FocusState private var isConversationFocused: Bool
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground(for: .homey)
                .ignoresSafeArea()
                .scaleEffect(animateBackground ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 20).repeatForever(autoreverses: true), value: animateBackground)
            
            VStack(spacing: 0) {
                topNavigationBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        headerSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        VStack(spacing: 20) {
                            CustomizableHomepageGrid()
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
    
    private var topNavigationBar: some View {
        HStack {
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
                    .foregroundStyle(Theme.dynamicText())
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: Theme.dynamicText().opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
            
            Spacer()
            
            profileSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var profileSection: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            DispatchQueue.main.async {
                router.route = .profile
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        Theme.gradientForTheme(themeManager.currentTheme(for: .homey))
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.dynamicText())
            }
            .overlay(
                Circle()
                    .stroke(Theme.dynamicTextSecondary().opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Theme.dynamicText().opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("HOMEY")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(Theme.dynamicText())
                .shadow(color: Theme.dynamicText().opacity(0.3), radius: 8, x: 0, y: 4)
            
            Text("Let's get you home, \(userProfileManager.currentProfile?.fullName ?? "friend")!")
                .font(.title3.weight(.medium))
                .foregroundStyle(Theme.dynamicTextSecondary())
                .multilineTextAlignment(.center)
                .shadow(color: Theme.dynamicText().opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
    
    private var actionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            HomeyActionGridItem(
                title: "Search Properties",
                subtitle: "Find your dream home",
                icon: "magnifyingglass",
                color: .blue,
                delay: 0.1
            ) {
                selectedTab = 1
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
                selectedTab = 2
            }
        }
    }
    
    private var conversationalInterface: some View {
        VStack(spacing: 20) {
            Text("Ask HOMEY anything about your home buying journey")
                .font(.headline.weight(.medium))
                .foregroundStyle(Theme.dynamicText())
                .multilineTextAlignment(.center)
                .shadow(color: Theme.dynamicText().opacity(0.2), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 12) {
                TextField("What can I help you with today?", text: $conversationText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Theme.dynamicSurface())
                            .shadow(color: Theme.dynamicText().opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .foregroundStyle(Theme.dynamicText())
                    .focused($isConversationFocused)
                
                Button {
                    if !conversationText.isEmpty {
                        conversationText = ""
                        isConversationFocused = false
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.dynamicText())
                        .padding(12)
                        .background(
                            Circle()
                                .fill(
                                    Theme.gradientForTheme(themeManager.currentTheme(for: .homey))
                                )
                                .shadow(color: Theme.dynamicText().opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .disabled(conversationText.isEmpty)
                .opacity(conversationText.isEmpty ? 0.6 : 1.0)
            }
        }
        .padding(.horizontal, 4)
    }
}

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
            VStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.dynamicText())
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Theme.dynamicTextSecondary())
                }
                .multilineTextAlignment(.center)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Theme.dynamicSurface())
                    .shadow(color: Theme.dynamicText().opacity(0.2), radius: 6, x: 0, y: 3)
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

struct HomeyAnimatedSkyBackground: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.3, green: 0.4, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
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

extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}