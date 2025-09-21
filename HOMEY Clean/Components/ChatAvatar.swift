//
//  ChatAvatar.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 1/27/25.
//

import SwiftUI

struct ChatAvatar: View {
    let persona: HomeyKind
    let context: ChatContext?
    
    @State private var showChat = false
    @State private var isPressed = false
    
    init(persona: HomeyKind, context: ChatContext? = nil) {
        self.persona = persona
        self.context = context
    }
    
    var body: some View {
        Button {
            TRAEMotionSystem.shared.triggerHaptic(.light)
            showChat = true
        } label: {
            ZStack {
                // Background circle with persona accent color
                Circle()
                    .fill(persona.accentColor)
                    .frame(width: 44, height: 44)
                    .shadow(
                        color: persona.accentColor.opacity(0.3),
                        radius: isPressed ? 2 : 4,
                        x: 0,
                        y: isPressed ? 1 : 2
                    )
                
                // Avatar image or emoji
                if UIImage(named: persona.assetName) != nil {
                    Image(persona.assetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else {
                    Text(persona.emoji)
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) {
            // Intentionally empty - disables long-press persona switcher
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .sheet(isPresented: $showChat) {
            ChatModal(target: .homey(persona), currentContext: context)
        }
    }
}

// MARK: - View Extension for Easy Integration

extension View {
    func chatAvatar(
        _ persona: HomeyKind,
        context: ChatContext? = nil
    ) -> some View {
        ZStack(alignment: .topLeading) {
            self
            
            ChatAvatar(persona: persona, context: context)
                .padding(.top, 60)
                .padding(.leading, 16)
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
    .chatAvatar(.charlie, context: .dashboard)
}