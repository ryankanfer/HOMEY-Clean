//
//  TRAEButtonAnimations.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//

import SwiftUI
import UIKit

// MARK: - Haptic Style Type Alias
typealias TRAEHapticStyle = TRAEMotionSystem.TRAEHapticStyle

// MARK: - TRAE Button Animation Components

/// Enhanced button with TRAE motion design system animations
struct TRAEAnimatedButton<Content: View>: View {
    let content: Content
    let action: () -> Void
    let style: TRAEButtonAnimationStyle
    let hapticStyle: TRAEHapticStyle
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    @State private var shadowRadius: CGFloat = 4
    @State private var shadowOffset: CGSize = CGSize(width: 0, height: 2)
    
    init(
        style: TRAEButtonAnimationStyle = .primary,
        hapticStyle: TRAEHapticStyle = .medium,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.action = action
        self.style = style
        self.hapticStyle = hapticStyle
    }
    
    var body: some View {
        Button(action: {
            performButtonAction()
        }) {
            content
                .scaleEffect(scale)
                .shadow(
                    color: style.shadowColor,
                    radius: shadowRadius,
                    x: shadowOffset.width,
                    y: shadowOffset.height
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                handlePressState(pressing)
            },
            perform: {}
        )
    }
    
    private func handlePressState(_ pressing: Bool) {
        isPressed = pressing
        
        if pressing {
            // Press down animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                scale = style.pressedScale
                shadowRadius = style.pressedShadowRadius
                shadowOffset = style.pressedShadowOffset
            }
            
            // Haptic feedback on press
            TRAEMotionSystem.shared.triggerHaptic(hapticStyle)
            
        } else {
            // Release animation with spring bounce
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                shadowRadius = style.normalShadowRadius
                shadowOffset = style.normalShadowOffset
            }
        }
    }
    
    private func performButtonAction() {
        // Additional haptic feedback on action
        TRAEMotionSystem.shared.triggerHaptic(.light)
        action()
    }
}

// MARK: - Button Styles

enum TRAEButtonAnimationStyle {
    case primary
    case secondary
    case ghost
    case danger
    case success
    
    var pressedScale: CGFloat {
        switch self {
        case .primary, .danger, .success:
            return 0.95
        case .secondary:
            return 0.97
        case .ghost:
            return 0.98
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary:
            return Color.blue.opacity(0.3)
        case .secondary:
            return Color.gray.opacity(0.2)
        case .ghost:
            return Color.clear
        case .danger:
            return Color.red.opacity(0.3)
        case .success:
            return Color.green.opacity(0.3)
        }
    }
    
    var normalShadowRadius: CGFloat {
        switch self {
        case .primary, .danger, .success:
            return 6
        case .secondary:
            return 4
        case .ghost:
            return 0
        }
    }
    
    var pressedShadowRadius: CGFloat {
        switch self {
        case .primary, .danger, .success:
            return 2
        case .secondary:
            return 1
        case .ghost:
            return 0
        }
    }
    
    var normalShadowOffset: CGSize {
        switch self {
        case .primary, .danger, .success:
            return CGSize(width: 0, height: 3)
        case .secondary:
            return CGSize(width: 0, height: 2)
        case .ghost:
            return .zero
        }
    }
    
    var pressedShadowOffset: CGSize {
        switch self {
        case .primary, .danger, .success:
            return CGSize(width: 0, height: 1)
        case .secondary:
            return CGSize(width: 0, height: 0.5)
        case .ghost:
            return .zero
        }
    }
}

// MARK: - Floating Action Button

struct TRAEFloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        TRAEAnimatedButton(
            style: .primary,
            hapticStyle: .medium,
            action: action
        ) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .scaleEffect(pulseScale)
                .rotationEffect(.degrees(rotationAngle))
        }
        .onAppear {
            startPulseAnimation()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
                rotationAngle = hovering ? 15 : 0
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.05
        }
    }
}

// MARK: - Toggle Button with Animation

struct TRAEToggleButton: View {
    @Binding var isOn: Bool
    let onIcon: String
    let offIcon: String
    let onColor: Color
    let offColor: Color
    
    @State private var iconRotation: Double = 0
    
    init(
        isOn: Binding<Bool>,
        onIcon: String = "checkmark.circle.fill",
        offIcon: String = "circle",
        onColor: Color = .green,
        offColor: Color = .gray
    ) {
        self._isOn = isOn
        self.onIcon = onIcon
        self.offIcon = offIcon
        self.onColor = onColor
        self.offColor = offColor
    }
    
    var body: some View {
        TRAEAnimatedButton(
            style: .ghost,
            hapticStyle: .light,
            action: {
                toggleState()
            }
        ) {
            Image(systemName: isOn ? onIcon : offIcon)
                .font(.title2)
                .foregroundColor(isOn ? onColor : offColor)
                .rotationEffect(.degrees(iconRotation))
        }
    }
    
    private func toggleState() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isOn.toggle()
            iconRotation += 360
        }
        
        // Haptic feedback for toggle
        TRAEMotionSystem.shared.triggerHaptic(isOn ? .medium : .light)
    }
}

// MARK: - Button Group with Staggered Animation

struct TRAEButtonGroup<Content: View>: View {
    let buttons: [Content]
    let spacing: CGFloat
    let animationDelay: Double
    
    @State private var animatedButtons: [Bool]
    
    init(
        spacing: CGFloat = 12,
        animationDelay: Double = 0.1,
        @ViewBuilder content: () -> [Content]
    ) {
        self.buttons = content()
        self.spacing = spacing
        self.animationDelay = animationDelay
        self._animatedButtons = State(initialValue: Array(repeating: false, count: content().count))
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(buttons.indices, id: \.self) { index in
                buttons[index]
                    .opacity(animatedButtons[index] ? 1 : 0)
                    .scaleEffect(animatedButtons[index] ? 1 : 0.8)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * animationDelay),
                        value: animatedButtons[index]
                    )
            }
        }
        .onAppear {
            animateButtonsIn()
        }
    }
    
    private func animateButtonsIn() {
        for index in buttons.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * animationDelay) {
                animatedButtons[index] = true
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE button animation to any view
    func traeButtonAnimation(
        style: TRAEButtonAnimationStyle = .primary,
        hapticStyle: TRAEHapticStyle = .medium,
        action: @escaping () -> Void
    ) -> some View {
        TRAEAnimatedButton(
            style: style,
            hapticStyle: hapticStyle,
            action: action
        ) {
            self
        }
    }
    
    /// Add spring bounce effect to any view
    func traeSpringBounce(isActive: Bool) -> some View {
        self
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isActive)
    }
}