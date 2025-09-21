//
//  PaigeCompanionView.swift
//  HOMEY Clean
//
//  AI Companion View for contextual guidance
//

import SwiftUI

struct PaigeCompanionView: View {
    let message: String
    let onDismiss: () -> Void
    
    @State private var showAvatar = false
    @State private var showMessage = false
    @State private var avatarScale: CGFloat = 0.8
    @State private var messageOffset: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Paige Avatar
            if showAvatar {
                Button(action: onDismiss) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "2ECC71"),
                                        Color(hex: "27AE60")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        Text("P")
                            .font(.custom("PlayfairDisplay-Bold", size: 24))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(avatarScale)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Message Bubble
            if showMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    
                    HStack {
                        Spacer()
                        Button("Got it") {
                            onDismiss()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.green)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .frame(maxWidth: 280)
                .offset(y: messageOffset)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Avatar appears first
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showAvatar = true
            avatarScale = 1.0
        }
        
        // Message appears after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showMessage = true
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                messageOffset = 0
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            HStack {
                Spacer()
                PaigeCompanionView(
                    message: "Hi! I'm Paige, your document companion. I'll help you organize and understand why each document matters for your home journey.",
                    onDismiss: {}
                )
                .padding()
            }
        }
    }
}