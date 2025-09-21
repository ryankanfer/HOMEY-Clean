//
//  ProfessionalCard.swift
//  HOMEY Clean
//
//  Created by Drew's Directory
//

import SwiftUI

struct ProfessionalCard: View {
    let contact: Contact
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Professional card frame background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.8),
                                Color.gray.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.yellow.opacity(0.6),
                                        Color.orange.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                VStack(spacing: 12) {
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
                                        .font(.title2)
                                )
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.yellow.opacity(0.8),
                                        Color.orange.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    
                    VStack(spacing: 4) {
                        // Name
                        Text(contact.name)
                            .font(.custom("JosefinSans-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // Professional Role
                        Text(contact.role.displayName)
                            .font(.custom("JosefinSans-Medium", size: 12))
                            .foregroundColor(.yellow.opacity(0.9))
                            .lineLimit(1)
                        
                        // Company
                        if let company = contact.company {
                            Text(company)
                                .font(.custom("PlayfairDisplay-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    
                    // Trust Score
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                        
                        Text(String(format: "%.1f", contact.trustScore))
                            .font(.custom("JosefinSans-Bold", size: 12))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow.opacity(0.4), lineWidth: 0.5)
                            )
                    )
                }
                .padding(16)
            }
        }
        .frame(width: 128, height: 168)
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: contact.id)
    }
}

// MARK: - Professional Card Carousel
struct ProfessionalCardCarousel: View {
    let contacts: [Contact]
    let onContactTap: (Contact) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Professional Network")
                .font(.custom("JosefinSans-SemiBold", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(contacts) { contact in
                        ProfessionalCard(contact: contact) {
                            onContactTap(contact)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Preview
struct ProfessionalCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                ProfessionalCard(contact: Contact.sampleContacts[0]) {
                    print("Card tapped")
                }
                
                Spacer().frame(height: 40)
                
                ProfessionalCardCarousel(
                    contacts: Array(Contact.sampleContacts.prefix(5))
                ) { contact in
                    print("Contact tapped: \(contact.name)")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}