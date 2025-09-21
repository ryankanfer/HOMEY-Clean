//
//  DossierSheet.swift
//  HOMEY Clean
//
//  Created by Drew's Directory
//

import SwiftUI

struct DossierSheet: View {
    let contact: Contact
    @Binding var isPresented: Bool
    let onRequestIntro: () -> Void
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.gray.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Tab Selection
                        tabSelector
                        
                        // Content based on selected tab
                        Group {
                            switch selectedTab {
                            case 0:
                                biographySection
                            case 1:
                                documentsSection
                            case 2:
                                introductionsSection
                            default:
                                biographySection
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons Overlay
                VStack {
                    Spacer()
                    actionButtons
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Avatar
            AsyncImage(url: URL(string: contact.avatarURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.largeTitle)
                    )
            }
            .frame(width: 100, height: 100)
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
                        lineWidth: 3
                    )
            )
            
            VStack(spacing: 8) {
                Text(contact.name)
                    .font(.custom("JosefinSans-Bold", size: 24))
                    .foregroundColor(.white)

                Text(contact.role.displayName)
                    .font(.custom("JosefinSans-Medium", size: 16))
                    .foregroundColor(.yellow.opacity(0.9))

                if let company = contact.company {
                    Text(company)
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Trust Score
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f Trust Score", contact.trustScore))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            Capsule()
                                .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    Text(tabTitle(for: index))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(selectedTab == index ? .black : .white.opacity(0.7))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedTab == index ?
                            Color.yellow.opacity(0.9) :
                            Color.clear
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Biography"
        case 1: return "Documents"
        case 2: return "Introductions"
        default: return ""
        }
    }
    
    // MARK: - Biography Section
    private var biographySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.custom("JosefinSans-SemiBold", size: 18))
                .foregroundColor(.white)

            Text(contact.biography)
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
            
            // Endorsements
            if !contact.endorsements.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Endorsements")
                        .font(.custom("JosefinSans-SemiBold", size: 16))
                        .foregroundColor(.white)
                    
                    ForEach(contact.endorsements, id: \.id) { endorsement in
                        endorsementCard(endorsement)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func endorsementCard(_ endorsement: Endorsement) -> some View {
        HStack(spacing: 12) {
            Image("ribbon_recommended")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(endorsement.endorserName)
                    .font(.custom("JosefinSans-SemiBold", size: 12))
                    .foregroundColor(.white)

                Text(endorsement.message)
                    .font(.custom("PlayfairDisplay-Regular", size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    // MARK: - Documents Section
    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Documents")
                .font(.custom("JosefinSans-SemiBold", size: 18))
                .foregroundColor(.white)
            
            if contact.documents.isEmpty {
                Text("No documents available")
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ForEach(contact.documents, id: \.id) { document in
                    documentCard(document)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func documentCard(_ document: DrewDocument) -> some View {
        HStack(spacing: 12) {
            Image(systemName: documentIcon(for: document.type))
                .foregroundColor(.yellow)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.custom("JosefinSans-SemiBold", size: 14))
                    .foregroundColor(.white)

                Text(document.type.rawValue.capitalized)
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .foregroundColor(.yellow.opacity(0.7))
                .font(.caption)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func documentIcon(for type: DrewDocumentType) -> String {
        switch type {
        case .license: return "doc.text.fill"
        case .certification: return "rosette"
        case .portfolio: return "folder.fill"
        case .testimonial: return "quote.bubble.fill"
        case .contract: return "doc.text.fill"
        }
    }
    
    // MARK: - Introductions Section
    private var introductionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Introduction Status")
                .font(.custom("JosefinSans-SemiBold", size: 18))
                .foregroundColor(.white)
            
            introductionStatusCard
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var introductionStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.title2)
                
                Text(statusText)
                    .font(.custom("JosefinSans-SemiBold", size: 16))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if contact.introductionStatus != .none {
                Text(statusDescription)
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(statusColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(statusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var statusIcon: String {
        switch contact.introductionStatus {
        case .none: return "person.badge.plus"
        case .requested: return "clock.fill"
        case .pending: return "hourglass"
        case .accepted: return "checkmark.circle.fill"
        case .declined: return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch contact.introductionStatus {
        case .none: return .blue
        case .requested: return .orange
        case .pending: return .yellow
        case .accepted: return .green
        case .declined: return .red
        }
    }
    
    private var statusText: String {
        switch contact.introductionStatus {
        case .none: return "No Introduction"
        case .requested: return "Introduction Requested"
        case .pending: return "Introduction Pending"
        case .accepted: return "Introduction Accepted"
        case .declined: return "Introduction Declined"
        }
    }
    
    private var statusDescription: String {
        switch contact.introductionStatus {
        case .none: return ""
        case .requested: return "Your introduction request has been sent and is awaiting review."
        case .pending: return "The introduction is being arranged by our team."
        case .accepted: return "Introduction completed! You can now connect directly."
        case .declined: return "Introduction request was declined. You may try again later."
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Request Introduction Button
            if contact.introductionStatus == .none {
                Button(action: onRequestIntro) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Request Introduction")
                            .font(.custom("JosefinSans-SemiBold", size: 16))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            

        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

// MARK: - Preview
struct DossierSheet_Previews: PreviewProvider {
    static var previews: some View {
        DossierSheet(
            contact: Contact.sampleContacts[0],
            isPresented: .constant(true),
            onRequestIntro: {
                print("Request intro tapped")
            }
        )
        .preferredColorScheme(.dark)
    }
}