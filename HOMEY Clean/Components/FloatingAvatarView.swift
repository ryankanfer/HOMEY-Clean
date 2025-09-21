//
//  FloatingAvatarView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI

struct FloatingAvatarView: View {
    let homeyKind: HomeyKind
    let currentContext: ChatContext?
    let position: FloatingPosition
    
    @State private var isPressed = false
    @State private var showChat = false
    @State private var pulseAnimation = false
    
    init(
        homeyKind: HomeyKind,
        currentContext: ChatContext? = nil,
        position: FloatingPosition = .bottomTrailing
    ) {
        self.homeyKind = homeyKind
        self.currentContext = currentContext
        self.position = position
    }
    
    var body: some View {
        Button {
            TRAEMotionSystem.shared.triggerHaptic(.light)
            showChat = true
        } label: {
            ZStack {
                // Pulse background for attention
                Circle()
                    .fill(homeyKind.gradients.accent)
                    .opacity(0.3)
                    .scaleEffect(pulseAnimation ? 1.4 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.6)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
                
                // Main avatar circle
                Circle()
                    .fill(homeyKind.gradients.accent)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // Avatar image
                if UIImage(named: homeyKind.assetName) != nil {
                    Image(homeyKind.assetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Text(homeyKind.emoji)
                        .font(.title2)
                }
                
                // Context indicator
                if currentContext != nil {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        Spacer()
                    }
                }
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(TRAEMotionSystem.Animations.buttonPress, value: isPressed)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {}
        .onAppear {
            // Start pulse animation after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                pulseAnimation = true
            }
        }
        .sheet(isPresented: $showChat) {
            ChatModal(target: .homey(homeyKind), currentContext: currentContext)
        }
    }
}

// MARK: - Floating Position

enum FloatingPosition {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    case centerTrailing
    
    var alignment: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        case .centerTrailing: return .trailing
        }
    }
    
    var padding: EdgeInsets {
        switch self {
        case .topLeading:
            return EdgeInsets(top: 60, leading: 16, bottom: 0, trailing: 0)
        case .topTrailing:
            return EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 16)
        case .bottomLeading:
            return EdgeInsets(top: 0, leading: 16, bottom: 100, trailing: 0)
        case .bottomTrailing:
            return EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 16)
        case .centerTrailing:
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)
        }
    }
}

// MARK: - View Extension for Easy Integration

extension View {
    func floatingAvatar(
        _ homeyKind: HomeyKind,
        context: ChatContext? = nil,
        position: FloatingPosition = .bottomTrailing
    ) -> some View {
        ZStack(alignment: position.alignment) {
            self
            
            FloatingAvatarView(
                homeyKind: homeyKind,
                currentContext: context,
                position: position
            )
            .padding(position.padding)
        }
    }
}



#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        VStack {
            Text("Sample Page Content")
                .font(.title)
            Spacer()
        }
    }
    .floatingAvatar(.charlie, context: .documents, position: .bottomTrailing)
}