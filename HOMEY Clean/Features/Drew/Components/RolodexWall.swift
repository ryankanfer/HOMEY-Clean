//
//  RolodexWall.swift
//  HOMEY Clean
//
//  Created by Drew's Directory
//

import SwiftUI

@available(*, deprecated, message: "This component has been replaced by the new, modern DrewDirectoryView.")
struct RolodexWall: View {
    let contacts: [Contact]
    let onContactTap: (Contact) -> Void
    
    @State private var selectedIndex: Int = 0
    @State private var rotationAngle: Double = 0
    @State private var spotlightPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    private let cardWidth: CGFloat = 120
    private let cardHeight: CGFloat = 160
    private let radius: CGFloat = 140
    
    var body: some View {
        ZStack {
            // Background wall
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.9),
                            Color.gray.opacity(0.3),
                            Color.black.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Spotlight effect
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.3),
                            Color.orange.opacity(0.1),
                            Color.clear
                        ],
                        center: UnitPoint(x: spotlightPosition.x, y: spotlightPosition.y),
                        startRadius: 20,
                        endRadius: 150
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.4),
                                    Color.orange.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            
            // 3D Rolodex Cards
            GeometryReader { geometry in
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2 - 10
                
                ForEach(Array(contacts.enumerated()), id: \.element.id) { index, contact in
                    let angle = Double(index) * (360.0 / Double(contacts.count)) + rotationAngle
                    let radians = angle * .pi / 180
                    
                    // Position cards around a circle whose front point is at centerX
                    let x = centerX + (cos(radians) - 1) * radius
                    let y = centerY + sin(radians) * (radius * 0.3)
                    let scale = 0.7 + 0.3 * cos(radians)
                    let opacity = 0.4 + 0.6 * cos(radians)
                    
                    RolodexCard(
                        contact: contact,
                        isSelected: index == selectedIndex,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedIndex = index
                                rotationAngle = -Double(index) * (360.0 / Double(contacts.count))
                                updateSpotlight(for: index)
                            }
                            onContactTap(contact)
                        }
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .position(x: x, y: y)
                    .rotation3DEffect(
                        .degrees(angle > 90 && angle < 270 ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .zIndex(cos(radians) > 0 ? 1 : 0)
                }
            }
            
            // Navigation Controls
            VStack {
                Spacer()
                
                HStack {
                    // Previous Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedIndex = (selectedIndex - 1 + contacts.count) % contacts.count
                            rotationAngle += 360.0 / Double(contacts.count)
                            updateSpotlight(for: selectedIndex)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    // Next Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedIndex = (selectedIndex + 1) % contacts.count
                            rotationAngle -= 360.0 / Double(contacts.count)
                            updateSpotlight(for: selectedIndex)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Title
            VStack {
                HStack {
                    Text("Professional Rolodex")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.7))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.leading, 20)
                
                Spacer()
            }
        }
        .frame(height: 300)
        .onAppear {
            updateSpotlight(for: selectedIndex)
        }
    }
    
    private func updateSpotlight(for index: Int) {
        let angle = Double(index) * (360.0 / Double(contacts.count)) + rotationAngle
        let radians = angle * .pi / 180
        
        spotlightPosition = CGPoint(
            x: 0.5 + cos(radians) * 0.3,
            y: 0.5 + sin(radians) * 0.1
        )
    }
}

// MARK: - Rolodex Card
struct RolodexCard: View {
    let contact: Contact
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Card Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [
                                Color.yellow.opacity(0.3),
                                Color.orange.opacity(0.2),
                                Color.black.opacity(0.8)
                            ] : [
                                Color.black.opacity(0.8),
                                Color.gray.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ?
                                Color.yellow.opacity(0.8) :
                                Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                
                VStack(spacing: 8) {
                    // Avatar
                    Group {
                        if let avatarName = contact.avatarURL, !avatarName.isEmpty {
                            Image(avatarName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                        .font(.caption)
                                )
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ?
                                Color.yellow.opacity(0.8) :
                                Color.gray.opacity(0.5),
                                lineWidth: 1
                            )
                    )
                    
                    VStack(spacing: 2) {
                        // Name
                        Text(contact.name)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // Role
                        Text(contact.role.displayName)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundColor(isSelected ? .yellow : .white.opacity(0.7))
                            .lineLimit(1)
                        
                        // Trust Score
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 6))
                            
                            Text(String(format: "%.1f", contact.trustScore))
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(8)
                
                // Selection Indicator
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 8, height: 8)
                                .padding(.top, 4)
                                .padding(.trailing, 4)
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(width: 80, height: 120)
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
}

// MARK: - Preview
struct RolodexWall_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            RolodexWall(
                contacts: Array(Contact.sampleContacts.prefix(8))
            ) { contact in
                print("Rolodex contact tapped: \(contact.name)")
            }
        }
        .preferredColorScheme(.dark)
    }
}