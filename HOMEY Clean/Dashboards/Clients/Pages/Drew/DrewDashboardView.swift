//
//  DrewDashboardView.swift
//  HOMEY Clean
//

import SwiftUI
import Foundation

public struct DrewDashboardView: View {
    @State private var selectedContact: Contact?
    @State private var showingIntroductionRequest = false
    @State private var animateStats = false
    
    private let contacts = Contact.sampleContacts
    private let recentIntroductions = [
        "Connected Sarah Chen with Marcus Johnson",
        "Introduced Emily Carter to Jessica Brown",
        "Facilitated meeting between David Chen and Samuel Ortiz"
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            RoomVibeBackground(kind: .drew)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Hero Section
                    networkingHeroSection
                    
                    // Live Activity Feed
                    recentActivitySection
                    
                    // Top Connections Showcase
                    topConnectionsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Full Directory Access
                    directoryAccessSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Drew")
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                animateStats = true
            }
        }
        .sheet(item: $selectedContact) { contact in
            ContactDetailSheet(contact: contact)
        }
    }

    // MARK: - Hero Section
    private var networkingHeroSection: some View {
        VStack(spacing: 20) {
            // Drew's Avatar and Title
            VStack(spacing: 12) {
                Circle()
                    .fill(HomeyKind.drew.gradients.accent)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text("D")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                    }
                    .shadow(color: HomeyKind.drew.accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 8) {
                    Text("Drew")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(HomeyKind.drew.gradients.accent)
                    
                    Text("Your Network Connector")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .opacity(0.8)
                }
            }
            
            // Networking Stats
            HStack(spacing: 20) {
                NetworkingStatCard(
                    title: "Connections",
                    value: "\(contacts.count)",
                    icon: "person.2.fill",
                    animate: animateStats
                )
                
                NetworkingStatCard(
                    title: "Introductions",
                    value: "47",
                    icon: "handshake.fill",
                    animate: animateStats
                )
                
                NetworkingStatCard(
                    title: "Success Rate",
                    value: "94%",
                    icon: "chart.line.uptrend.xyaxis",
                    animate: animateStats
                )
            }
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(.white.opacity(0.3), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 12)
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title3)
                    .foregroundStyle(HomeyKind.drew.gradients.accent)
                Text("Recent Introductions")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Text("Live")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.green, in: Capsule())
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                ForEach(Array(recentIntroductions.enumerated()), id: \.offset) { index, introduction in
                    IntroductionActivityCard(introduction: introduction, index: index)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.2), lineWidth: 1))
    }
    
    // MARK: - Top Connections Section
    private var topConnectionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                Text("Top Connections")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Button("View All") {
                    TRAEMotionSystem.shared.triggerHaptic(.light)
                    // TODO: Navigate to full connections view
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(HomeyKind.drew.gradients.accent)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(contacts.prefix(5)) { contact in
                        TopConnectionCard(contact: contact) {
                            TRAEMotionSystem.shared.triggerHaptic(.light)
                            selectedContact = contact
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.2), lineWidth: 1))
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 20) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                DrewQuickActionButton(
                    title: "Request Intro",
                    icon: "person.badge.plus",
                    color: .blue
                ) {
                    TRAEMotionSystem.shared.triggerHaptic(.medium)
                    showingIntroductionRequest = true
                }
                
                DrewQuickActionButton(
                    title: "Browse Network",
                    icon: "network",
                    color: .purple
                ) {
                    TRAEMotionSystem.shared.triggerHaptic(.medium)
                    // TODO: Navigate to network browser
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.2), lineWidth: 1))
    }
    
    // MARK: - Directory Access Section
    private var directoryAccessSection: some View {
        NavigationLink(destination: DrewDirectoryView()) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Full Professional Directory")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Explore Drew's complete network of trusted professionals")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(HomeyKind.drew.gradients.accent)
                    .rotationEffect(.degrees(0))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: UUID())
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(HomeyKind.drew.gradients.accent.opacity(0.4), lineWidth: 2))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .onTapGesture {
            TRAEMotionSystem.shared.triggerHaptic(.light)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                // Scale animation handled by action
            }
        }
    }
}

// MARK: - Supporting Views
private struct NetworkingStatCard: View {
    let title: String
    let value: String
    let icon: String
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(HomeyKind.drew.gradients.accent)
                .scaleEffect(animate ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animate)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .opacity(animate ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(0.3), value: animate)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .opacity(animate ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(0.5), value: animate)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.25), lineWidth: 1))
    }
}

private struct IntroductionActivityCard: View {
    let introduction: String
    let index: Int
    
    @State private var animateIndicator = false
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(.green.gradient)
                .frame(width: 10, height: 10)
                .scaleEffect(animateIndicator ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateIndicator)
            
            Text(introduction)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer()
            
            Text("\(index + 1)h ago")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .opacity(0.7)
        }
        .padding(.vertical, 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1)) {
                animateIndicator = true
            }
        }
    }
}

private struct TopConnectionCard: View {
    let contact: Contact
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
            // Avatar with role-based styling
            Circle()
                .fill(contact.role.color.gradient)
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: contact.role.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: contact.id)
            
            VStack(spacing: 6) {
                Text(contact.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(contact.role.displayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(contact.displayTrustScore)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
            .frame(width: 130)
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct DrewQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color.gradient, in: Circle())
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.25), lineWidth: 1))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

private struct ContactDetailSheet: View {
    let contact: Contact
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Contact Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(contact.role.color.gradient)
                            .frame(width: 100, height: 100)
                            .overlay {
                                Image(systemName: contact.role.icon)
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        
                        VStack(spacing: 8) {
                            Text(contact.name)
                                .font(.title.bold())
                            
                            Text(contact.role.displayName)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if let company = contact.company {
                                Text(company)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 16) {
                                Label(contact.displayTrustScore, systemImage: "star.fill")
                                    .foregroundColor(.yellow)
                                
                                Label("\(contact.yearsExperience) years", systemImage: "calendar")
                                    .foregroundColor(.blue)
                                
                                Label("\(contact.pastDeals) deals", systemImage: "handshake")
                                    .foregroundColor(.green)
                            }
                            .font(.caption.bold())
                        }
                    }
                    
                    // Biography
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline.bold())
                        
                        Text(contact.biography)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Contact Actions
                    VStack(spacing: 12) {
                        Button("Request Introduction") {
                            TRAEMotionSystem.shared.triggerHaptic(.success)
                            // Handle introduction request
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(HomeyKind.drew.gradients.accent)
                        
                        Button("View Full Profile") {
                            TRAEMotionSystem.shared.triggerHaptic(.light)
                            // Navigate to full profile
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("Contact Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
