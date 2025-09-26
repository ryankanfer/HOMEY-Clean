//
//  LeftNavigationDrawer.swift
//  HOMEY Clean
//
//  Left-side navigation drawer with smooth drag functionality
//

import SwiftUI

struct LeftNavigationDrawer: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var router: AppRouter
    
    private let drawerWidth: CGFloat = 280
    private let dragThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Background overlay
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
            }
            
            // Drawer content
            HStack(spacing: 0) {
                drawerContent
                    .frame(width: drawerWidth)
                    .offset(x: isPresented ? dragOffset : -drawerWidth + dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let translation = value.translation.width
                                if translation < 0 {
                                    dragOffset = translation
                                }
                            }
                            .onEnded { value in
                                let translation = value.translation.width
                                let velocity = value.velocity.width
                                
                                if translation < -100 || velocity < -500 {
                                    closeDrawer()
                                } else {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                
                Spacer()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
    }
    
    private var drawerContent: some View {
        VStack(spacing: 0) {
            // Header section with profile info
            drawerHeader
            
            // Navigation items
            ScrollView {
                VStack(spacing: 8) {
                    // Primary navigation
                    NavigationSection(title: "Navigate") {
                        DrawerNavigationItem(
                            title: "Home",
                            subtitle: "Your HOMEY dashboard",
                            icon: "house.fill",
                            color: .blue,
                            isActive: router.route == nil,
                            action: { 
                                router.route = nil
                                closeDrawer() 
                            }
                        )
                        
                        DrawerNavigationItem(
                            title: "Search",
                            subtitle: "Discover properties",
                            icon: "magnifyingglass",
                            color: .green,
                            isActive: router.route == .search,
                            action: { 
                                router.route = .search
                                closeDrawer() 
                            }
                        )
                        
                        DrawerNavigationItem(
                            title: "Documents",
                            subtitle: "Your document vault",
                            icon: "doc.fill",
                            color: .orange,
                            isActive: router.route == .documents,
                            action: { 
                                router.route = .documents
                                closeDrawer() 
                            }
                        )
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Tools & Features
                    NavigationSection(title: "Tools & Features") {
                        DrawerNavigationItem(
                            title: "Matchmaker",
                            subtitle: "Property matching",
                            icon: "heart.fill",
                            color: .purple,
                            isActive: router.route == .matchmaker,
                            action: { 
                                router.route = .matchmaker
                                closeDrawer() 
                            }
                        )
                        
                        DrawerNavigationItem(
                            title: "Insights",
                            subtitle: "Market data & analytics",
                            icon: "chart.bar.fill",
                            color: .pink,
                            isActive: router.route == .insights,
                            action: { 
                                router.route = .insights
                                closeDrawer() 
                            }
                        )
                        
                        DrawerNavigationItem(
                            title: "Directory",
                            subtitle: "Trusted vendors",
                            icon: "folder.fill",
                            color: .indigo,
                            isActive: router.route == .directory,
                            action: { 
                                router.route = .directory
                                closeDrawer() 
                            }
                        )
                        
                        DrawerNavigationItem(
                            title: "Vision",
                            subtitle: "Design inspiration",
                            icon: "paintbrush.fill",
                            color: .teal,
                            isActive: router.route == .vision,
                            action: { 
                                router.route = .vision
                                closeDrawer() 
                            }
                        )
                        
                        DrawerNavigationItem(
                            title: "Education Center",
                            subtitle: "Learn about real estate",
                            icon: "graduationcap.fill",
                            color: .mint,
                            isActive: router.route == .education,
                            action: { 
                                router.route = .education
                                closeDrawer() 
                            }
                        )
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Account & Settings
                    NavigationSection(title: "Account") {
                        DrawerNavigationItem(
                            title: "Settings",
                            subtitle: "App preferences",
                            icon: "gearshape.fill",
                            color: .gray,
                            isActive: router.route == .settings,
                            action: { 
                                router.route = .settings
                                closeDrawer() 
                            }
                        )
                        
                        DrawerNavigationItem(
                            title: "Help & Support",
                            subtitle: "Get assistance",
                            icon: "questionmark.circle.fill",
                            color: .cyan,
                            isActive: router.route == .helpSupport,
                            action: { 
                                router.route = .helpSupport
                                closeDrawer() 
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Extra padding for safe area
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            // Right edge shadow
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 8),
            alignment: .trailing
        )
    }
    
    private var drawerHeader: some View {
        VStack(spacing: 16) {
            // Close handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            // Profile section
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Ready to find your home?")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func closeDrawer() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

// MARK: - Supporting Views

struct NavigationSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            content
        }
    }
}

struct DrawerNavigationItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isActive ? color.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(subtitle))
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

// MARK: - Left Edge Swipe Gesture Modifier

struct LeftEdgeSwipeGesture: ViewModifier {
    @Binding var isDrawerPresented: Bool
    private let edgeWidth: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .overlay(
                // Invisible edge area for swipe detection
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: edgeWidth)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.startLocation.x < edgeWidth && value.translation.width > 50 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isDrawerPresented = true
                                    }
                                }
                            }
                    ),
                alignment: .leading
            )
    }
}

extension View {
    func leftEdgeSwipe(isDrawerPresented: Binding<Bool>) -> some View {
        modifier(LeftEdgeSwipeGesture(isDrawerPresented: isDrawerPresented))
    }
}

struct RightEdgeSwipeGesture: ViewModifier {
    @Binding var isDrawerOpenToPeek: Bool
    private let edgeWidth: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: edgeWidth)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Start from trailing edge and drag left to open
                                let screenWidth = UIScreen.main.bounds.width
                                let startFromRight = value.startLocation.x > screenWidth - edgeWidth
                                if startFromRight && value.translation.width < -50 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isDrawerOpenToPeek = true
                                    }
                                }
                            }
                    ),
                alignment: .trailing
            )
    }
}

extension View {
    func rightEdgeSwipe(openBinding: Binding<Bool>) -> some View {
        modifier(RightEdgeSwipeGesture(isDrawerOpenToPeek: openBinding))
    }
}
