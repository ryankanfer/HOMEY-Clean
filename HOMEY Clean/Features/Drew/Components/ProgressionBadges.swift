//
//  ProgressionBadges.swift
//  HOMEY Clean
//
//  Created by Drew's Directory
//

import SwiftUI

struct ProgressionBadges: View {
    let badges: [Badge]
    let onBadgeTap: (Badge) -> Void
    
    @State private var animatingBadges: Set<String> = []
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(badges) { badge in
                BadgeView(
                    badge: badge,
                    isAnimating: animatingBadges.contains(badge.id)
                ) {
                    onBadgeTap(badge)
                }
                .onAppear {
                    if badge.isNewlyEarned {
                        startBadgeAnimation(badge.id)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func startBadgeAnimation(_ badgeId: String) {
        withAnimation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true)) {
            animatingBadges.insert(badgeId)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animatingBadges.remove(badgeId)
        }
    }
}

struct BadgeView: View {
    let badge: Badge
    let isAnimating: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Badge Background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: badge.isEarned ? [
                                badge.type.primaryColor.opacity(0.8),
                                badge.type.secondaryColor.opacity(0.6),
                                Color.black.opacity(0.3)
                            ] : [
                                Color.gray.opacity(0.3),
                                Color.black.opacity(0.6)
                            ],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                badge.isEarned ?
                                LinearGradient(
                                    colors: [
                                        badge.type.primaryColor,
                                        badge.type.secondaryColor
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: badge.isEarned ? 3 : 1
                            )
                    )
                
                // Badge Icon
                Group {
                    if badge.isEarned {
                        Image(badge.type.imageName)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: badge.type.systemIcon)
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
                .frame(width: 30, height: 30)
                
                // Glow Effect for earned badges
                if badge.isEarned {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    badge.type.primaryColor.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                        .opacity(isAnimating ? 0.8 : 0.3)
                }
                
                // Progress Indicator for partially earned badges
                if !badge.isEarned && badge.progress > 0 {
                    Circle()
                        .trim(from: 0, to: badge.progress)
                        .stroke(
                            badge.type.primaryColor.opacity(0.7),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 50, height: 50)
                }
                
                // New Badge Indicator
                if badge.isNewlyEarned {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Text("!")
                                        .font(.custom("JosefinSans-Bold", size: 8))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 8, y: -8)
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(width: 60, height: 60)
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isAnimating)
    }
}

// MARK: - Badge Detail Sheet is defined in BadgeDetailSheet.swift

// MARK: - Badge Models
struct Badge: Identifiable {
    let id: String
    let type: BadgeType
    let isEarned: Bool
    let progress: Double // 0.0 to 1.0
    let earnedDate: Date?
    let isNewlyEarned: Bool
    
    init(
        type: BadgeType,
        isEarned: Bool = false,
        progress: Double = 0.0,
        earnedDate: Date? = nil,
        isNewlyEarned: Bool = false
    ) {
        self.id = type.rawValue
        self.type = type
        self.isEarned = isEarned
        self.progress = progress
        self.earnedDate = earnedDate
        self.isNewlyEarned = isNewlyEarned
    }
}

enum BadgeType: String, CaseIterable {
    case handshake = "handshake"
    case trustedTrio = "trusted_trio"
    case networkBuilder = "network_builder"
    case connector = "connector"
    
    var title: String {
        switch self {
        case .handshake:
            return "First Handshake"
        case .trustedTrio:
            return "Trusted Trio"
        case .networkBuilder:
            return "Network Builder"
        case .connector:
            return "Super Connector"
        }
    }
    
    var description: String {
        switch self {
        case .handshake:
            return "Complete your first professional introduction"
        case .trustedTrio:
            return "Successfully connect with 3 professionals"
        case .networkBuilder:
            return "Build a network of 10 trusted connections"
        case .connector:
            return "Facilitate 25 successful introductions"
        }
    }
    
    var requirement: String {
        switch self {
        case .handshake:
            return "Make 1 introduction to unlock this badge"
        case .trustedTrio:
            return "Make 3 introductions to unlock this badge"
        case .networkBuilder:
            return "Make 10 introductions to unlock this badge"
        case .connector:
            return "Make 25 introductions to unlock this badge"
        }
    }
    
    var imageName: String {
        switch self {
        case .handshake:
            return "badge_handshake"
        case .trustedTrio:
            return "badge_trusted_trio"
        case .networkBuilder:
            return "badge_network_builder"
        case .connector:
            return "badge_connector"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .handshake:
            return "hand.wave"
        case .trustedTrio:
            return "person.3"
        case .networkBuilder:
            return "network"
        case .connector:
            return "star.circle"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .handshake:
            return .yellow
        case .trustedTrio:
            return .orange
        case .networkBuilder:
            return .blue
        case .connector:
            return .purple
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .handshake:
            return .orange
        case .trustedTrio:
            return .red
        case .networkBuilder:
            return .cyan
        case .connector:
            return .pink
        }
    }
    
    var requiredCount: Int {
        switch self {
        case .handshake:
            return 1
        case .trustedTrio:
            return 3
        case .networkBuilder:
            return 10
        case .connector:
            return 25
        }
    }
}

// MARK: - Preview
struct ProgressionBadges_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                ProgressionBadges(
                    badges: [
                        Badge(type: .handshake, isEarned: true, earnedDate: Date(), isNewlyEarned: true),
                        Badge(type: .trustedTrio, progress: 0.67),
                        Badge(type: .networkBuilder, progress: 0.2),
                        Badge(type: .connector)
                    ]
                ) { badge in
                    print("Badge tapped: \(badge.type.title)")
                }
                
                BadgeDetailSheet(
                    badge: Badge(type: .handshake, isEarned: true, earnedDate: Date()),
                    isPresented: .constant(true)
                )
                .frame(height: 400)
            }
        }
        .preferredColorScheme(.dark)
    }
}