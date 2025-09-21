//
//  TRAEMicroInteractions.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Contextual micro-interactions for hover, press, and loading states
//

import SwiftUI

// MARK: - Interaction States

enum TRAEInteractionState {
    case idle
    case hover
    case pressed
    case loading
    case success
    case error
    case disabled
}

// MARK: - Interaction Types

enum TRAEInteractionType {
    case button
    case card
    case input
    case toggle
    case slider
    case picker
    
    var defaultScale: CGFloat {
        switch self {
        case .button: return 0.95
        case .card: return 0.98
        case .input: return 0.99
        case .toggle: return 0.92
        case .slider: return 0.96
        case .picker: return 0.97
        }
    }
    
    var hoverScale: CGFloat {
        switch self {
        case .button: return 1.02
        case .card: return 1.01
        case .input: return 1.005
        case .toggle: return 1.05
        case .slider: return 1.02
        case .picker: return 1.01
        }
    }
}

// MARK: - TRAE Interactive View

struct TRAEInteractive<Content: View>: View {
    let content: Content
    let type: TRAEInteractionType
    let isEnabled: Bool
    let onTap: (() -> Void)?
    let onLongPress: (() -> Void)?
    
    @State private var currentState: TRAEInteractionState = .idle
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var shadowRadius: CGFloat = 4
    @State private var shadowY: CGFloat = 2
    @State private var pulseScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200
    
    init(
        type: TRAEInteractionType = .button,
        isEnabled: Bool = true,
        onTap: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.type = type
        self.isEnabled = isEnabled
        self.onTap = onTap
        self.onLongPress = onLongPress
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .shadow(
                color: .black.opacity(currentState == .pressed ? 0.2 : 0.1),
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
            .overlay(
                // Glow effect
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .opacity(glowOpacity)
                    .blur(radius: 4)
            )
            .overlay(
                // Shimmer effect
                Group {
                    if currentState == .loading {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: shimmerOffset)
                            .clipped()
                    } else {
                        EmptyView()
                    }
                }
            )
            .overlay(
                // Pulse effect for loading
                Group {
                    if currentState == .loading {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                            .scaleEffect(pulseScale)
                            .opacity(2.0 - pulseScale)
                    } else {
                        EmptyView()
                    }
                }
            )
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: scale)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: shadowRadius)
            .animation(.easeInOut(duration: 0.2), value: glowOpacity)
            .onTapGesture {
                if isEnabled {
                    handleTap()
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                if isEnabled {
                    handleLongPress()
                }
            } onPressingChanged: { pressing in
                if isEnabled {
                    handlePressChange(pressing)
                }
            }
            .onHover { hovering in
                if isEnabled {
                    handleHover(hovering)
                }
            }
            .onAppear {
                if !isEnabled {
                    currentState = .disabled
                }
            }
    }
    
    // MARK: - Interaction Handlers
    
    private func handleTap() {
        // Quick press animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            scale = type.defaultScale
            shadowRadius = 2
            shadowY = 1
        }
        
        // Haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.light)
        
        // Reset after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = 1.0
                shadowRadius = 4
                shadowY = 2
            }
        }
        
        // Execute callback
        onTap?()
    }
    
    private func handleLongPress() {
        // Success state animation
        setState(.success)
        
        // Haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.success)
        
        // Execute callback
        onLongPress?()
        
        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            setState(.idle)
        }
    }
    
    private func handlePressChange(_ pressing: Bool) {
        if pressing {
            setState(.pressed)
        } else {
            setState(.idle)
        }
    }
    
    private func handleHover(_ hovering: Bool) {
        if hovering {
            setState(.hover)
        } else {
            setState(.idle)
        }
    }
    
    // MARK: - State Management
    
    private func setState(_ newState: TRAEInteractionState) {
        currentState = newState
        
        switch newState {
        case .idle:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                rotation = 0
                glowOpacity = 0
                shadowRadius = 4
                shadowY = 2
            }
            
        case .hover:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = type.hoverScale
                glowOpacity = 0.3
                shadowRadius = 8
                shadowY = 4
            }
            
        case .pressed:
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                scale = type.defaultScale
                shadowRadius = 2
                shadowY = 1
            }
            
        case .loading:
            startLoadingAnimation()
            
        case .success:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.1
                glowOpacity = 0.8
            }
            
        case .error:
            startErrorAnimation()
            
        case .disabled:
            withAnimation(.easeOut(duration: 0.3)) {
                scale = 0.95
                glowOpacity = 0
            }
        }
    }
    
    private func startLoadingAnimation() {
        // Shimmer animation
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            shimmerOffset = 200
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
    }
    
    private func startErrorAnimation() {
        // Shake animation
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
            rotation = -5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                rotation = 5
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                rotation = 0
            }
        }
        
        // Red glow
        withAnimation(.easeInOut(duration: 0.3)) {
            glowOpacity = 0.6
        }
    }
}

// MARK: - TRAE Button Styles

struct TRAEButtonStyle: ButtonStyle {
    let type: TRAEInteractionType
    let isDestructive: Bool
    
    init(type: TRAEInteractionType = .button, isDestructive: Bool = false) {
        self.type = type
        self.isDestructive = isDestructive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: isDestructive ? 
                                [.red, .red.opacity(0.8)] :
                                [.blue, .blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .scaleEffect(configuration.isPressed ? type.defaultScale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - TRAE Loading Button

struct TRAELoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    @State private var loadingDots: String = ""
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    
                    Text("Loading\(loadingDots)")
                        .onAppear {
                            startLoadingAnimation()
                        }
                } else {
                    Text(title)
                }
            }
            .frame(minWidth: 120)
        }
        .buttonStyle(TRAEButtonStyle())
        .disabled(isLoading)
    }
    
    private func startLoadingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !isLoading {
                timer.invalidate()
                loadingDots = ""
                return
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                if loadingDots.count >= 3 {
                    loadingDots = ""
                } else {
                    loadingDots += "."
                }
            }
        }
    }
}

// MARK: - TRAE Toggle Style

struct TRAEToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? .green : .gray.opacity(0.3))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(.white)
                        .shadow(radius: 2)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        configuration.isOn.toggle()
                    }
                    TRAEMotionSystem.shared.triggerHaptic(.light)
                }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE interactive behavior to any view
    func traeInteractive(
        type: TRAEInteractionType = .button,
        isEnabled: Bool = true,
        onTap: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil
    ) -> some View {
        TRAEInteractive(
            type: type,
            isEnabled: isEnabled,
            onTap: onTap,
            onLongPress: onLongPress
        ) {
            self
        }
    }
    
    /// Apply TRAE button style
    func traeButtonStyle(isDestructive: Bool = false) -> some View {
        self.buttonStyle(TRAEButtonStyle(isDestructive: isDestructive))
    }
    
    /// Apply TRAE toggle style
    func traeToggleStyle() -> some View {
        self.toggleStyle(TRAEToggleStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        // Interactive button
        Text("Tap me!")
            .padding()
            .background(.blue.opacity(0.1))
            .cornerRadius(12)
            .traeInteractive(type: .button) {
                print("Button tapped!")
            }
        
        // Interactive card
        VStack {
            Text("Interactive Card")
                .font(.headline)
            Text("Hover and press for effects")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(radius: 4)
        .traeInteractive(type: .card) {
            print("Card tapped!")
        } onLongPress: {
            print("Card long pressed!")
        }
        
        // Loading button
        TRAELoadingButton(
            title: "Submit",
            isLoading: false
        ) {
            print("Submit tapped!")
        }
        
        // Toggle with TRAE style
        Toggle("Enable notifications", isOn: .constant(true))
            .traeToggleStyle()
    }
    .padding()
}