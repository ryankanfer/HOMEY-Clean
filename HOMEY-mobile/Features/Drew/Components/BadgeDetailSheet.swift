//
//  BadgeDetailSheet.swift
//  HOMEY Clean
//
//  Created by Drew's Directory
//

import SwiftUI

struct BadgeDetailSheet: View {
    let badge: Badge
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.gray.opacity(0.9),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Badge Image
                        badgeImageSection
                        
                        // Badge Info
                        badgeInfoSection
                        
                        // Achievement Details
                        achievementDetailsSection
                        
                        // Progress Section
                        if badge.type != .handshake {
                            progressSection
                        }
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Badge Image Section
    private var badgeImageSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                badge.type.primaryColor.opacity(0.3),
                                badge.type.primaryColor.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)
                
                // Badge image
                Image(badge.type.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .shadow(color: badge.type.primaryColor.opacity(0.5), radius: 10, x: 0, y: 0)
            }
            
            if badge.isNewlyEarned {
                Text("🎉 Just Earned!")
                    .font(.custom("JosefinSans-Bold", size: 16))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .scaleEffect(badge.isNewlyEarned ? 1.1 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badge.isNewlyEarned)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Badge Info Section
    private var badgeInfoSection: some View {
        VStack(spacing: 12) {
            Text(badge.type.title)
                .font(.custom("JosefinSans-Bold", size: 28))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(badge.type.description)
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Achievement Details Section
    private var achievementDetailsSection: some View {
        VStack(spacing: 16) {
            Text("Achievement Details")
                .font(.custom("JosefinSans-SemiBold", size: 20))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                DetailRow(
                    icon: "calendar",
                    title: "Earned On",
                    value: badge.earnedDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not yet earned"
                )
                
                DetailRow(
                    icon: "person.2.fill",
                    title: "Introductions Made",
                    value: "\(Int(badge.progress * Double(badge.type.requiredCount)))"
                )
                
                DetailRow(
                    icon: "star.fill",
                    title: "Rarity",
                    value: rarityText
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(badge.type.primaryColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            Text("Next Achievement")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Text(nextBadgeTitle)
                        .font(.custom("JosefinSans-Medium", size: 16))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(Int(badge.progress * Double(badge.type.requiredCount)))/\(nextBadgeRequirement)")
                        .font(.custom("JosefinSans-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.7))

                }
                
                ProgressView(value: Double(Int(badge.progress * Double(badge.type.requiredCount))), total: Double(nextBadgeRequirement))
                    .progressViewStyle(LinearProgressViewStyle(tint: badge.type.primaryColor))
                    .scaleEffect(y: 2)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Computed Properties
    private var rarityText: String {
        switch badge.type {
        case .handshake:
            return "Common"
        case .trustedTrio:
            return "Rare"
        case .networkBuilder:
            return "Epic"
        case .connector:
            return "Legendary"
        }
    }
    
    private var nextBadgeTitle: String {
        switch badge.type {
        case .handshake:
            return "Trusted Trio"
        case .trustedTrio:
            return "Network Builder"
        case .networkBuilder:
            return "The Connector"
        case .connector:
            return "Master Achieved"
        }
    }
    
    private var nextBadgeRequirement: Int {
        switch badge.type {
        case .handshake:
            return 3
        case .trustedTrio:
            return 10
        case .networkBuilder:
            return 25
        case .connector:
            return 50
        }
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
struct BadgeDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        BadgeDetailSheet(
            badge: Badge(
                type: .handshake,
                isEarned: true,
                earnedDate: Date(),
                isNewlyEarned: true
            ),
            isPresented: .constant(true)
        )
    }
}