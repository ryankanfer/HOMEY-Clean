//
//  TRAESwipeGestures.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Swipe gestures for quick actions on cards
//

import SwiftUI

// MARK: - Swipe Action Types

enum TRAESwipeAction: String, CaseIterable {
    case reschedule = "Reschedule"
    case save = "Save"
    case share = "Share"
    case delete = "Delete"
    case archive = "Archive"
    case edit = "Edit"
    
    var icon: String {
        switch self {
        case .reschedule: return "calendar.badge.clock"
        case .save: return "bookmark.fill"
        case .share: return "square.and.arrow.up"
        case .delete: return "trash.fill"
        case .archive: return "archivebox.fill"
        case .edit: return "pencil"
        }
    }
    
    var color: Color {
        switch self {
        case .reschedule: return .orange
        case .save: return .blue
        case .share: return .green
        case .delete: return .red
        case .archive: return .gray
        case .edit: return .purple
        }
    }
    
    var hapticType: TRAEHapticType {
        switch self {
        case .reschedule, .save, .share, .edit: return .light
        case .archive: return .medium
        case .delete: return .heavy
        }
    }
}

// MARK: - Swipe Direction

enum TRAESwipeDirection {
    case left
    case right
    
    var alignment: HorizontalAlignment {
        switch self {
        case .left: return .leading
        case .right: return .trailing
        }
    }
}

// MARK: - TRAE Swipeable Card

struct TRAESwipeableCard<Content: View>: View {
    let content: Content
    let leftActions: [TRAESwipeAction]
    let rightActions: [TRAESwipeAction]
    let onAction: (TRAESwipeAction) -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var actionTriggered: TRAESwipeAction? = nil
    @State private var showActionFeedback: Bool = false
    @State private var actionScale: CGFloat = 1.0
    
    private let swipeThreshold: CGFloat = 80
    private let maxSwipeDistance: CGFloat = 150
    
    init(
        leftActions: [TRAESwipeAction] = [],
        rightActions: [TRAESwipeAction] = [],
        onAction: @escaping (TRAESwipeAction) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.leftActions = leftActions
        self.rightActions = rightActions
        self.onAction = onAction
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Background actions
            HStack {
                // Left actions
                if !leftActions.isEmpty && dragOffset > 0 {
                    HStack(spacing: 8) {
                        ForEach(leftActions, id: \.rawValue) { action in
                            TRAESwipeActionButton(
                                action: action,
                                isVisible: dragOffset > swipeThreshold / 2,
                                isActive: dragOffset > swipeThreshold && actionTriggered == action,
                                scale: actionScale
                            )
                        }
                    }
                    .padding(.leading, 16)
                }
                
                Spacer()
                
                // Right actions
                if !rightActions.isEmpty && dragOffset < 0 {
                    HStack(spacing: 8) {
                        ForEach(rightActions, id: \.rawValue) { action in
                            TRAESwipeActionButton(
                                action: action,
                                isVisible: abs(dragOffset) > swipeThreshold / 2,
                                isActive: abs(dragOffset) > swipeThreshold && actionTriggered == action,
                                scale: actionScale
                            )
                        }
                    }
                    .padding(.trailing, 16)
                }
            }
            
            // Main card content
            content
                .offset(x: dragOffset)
                .scaleEffect(isDragging ? 0.98 : 1.0)
                .shadow(
                    color: .black.opacity(isDragging ? 0.15 : 0.05),
                    radius: isDragging ? 12 : 4,
                    x: 0,
                    y: isDragging ? 6 : 2
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDragging)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { value in
                    handleDragEnded(value)
                }
        )
        .overlay(
            // Action feedback overlay
            Group {
                if showActionFeedback, let action = actionTriggered {
                    TRAEActionFeedbackOverlay(action: action)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    EmptyView()
                }
            }
        )
    }
    
    // MARK: - Gesture Handling
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation.width
        
        // Limit drag distance
        let limitedTranslation = max(-maxSwipeDistance, min(maxSwipeDistance, translation))
        
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9)) {
            dragOffset = limitedTranslation
            isDragging = true
        }
        
        // Determine which action would be triggered
        updateActionTriggered()
        
        // Haptic feedback when crossing threshold
        if abs(translation) > swipeThreshold && actionTriggered != nil {
            if let action = actionTriggered {
                TRAEHapticManager.shared.trigger(action.hapticType)
                
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    actionScale = 1.2
                }
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                actionScale = 1.0
            }
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let translation = value.translation.width
        let velocity = value.velocity.width
        
        // Check if action should be triggered
        if abs(translation) > swipeThreshold || abs(velocity) > 500 {
            if let action = actionTriggered {
                triggerAction(action)
                return
            }
        }
        
        // Reset to original position
        resetCard()
    }
    
    private func updateActionTriggered() {
        if dragOffset > swipeThreshold && !leftActions.isEmpty {
            actionTriggered = leftActions.first
        } else if dragOffset < -swipeThreshold && !rightActions.isEmpty {
            actionTriggered = rightActions.first
        } else {
            actionTriggered = nil
        }
    }
    
    private func triggerAction(_ action: TRAESwipeAction) {
        // Show feedback
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showActionFeedback = true
        }
        
        // Trigger haptic
        TRAEHapticManager.shared.trigger(.success)
        
        // Execute action after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onAction(action)
            resetCard()
        }
        
        // Hide feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                showActionFeedback = false
            }
        }
    }
    
    private func resetCard() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            dragOffset = 0
            isDragging = false
            actionTriggered = nil
            actionScale = 1.0
        }
    }
}

// MARK: - Swipe Action Button

struct TRAESwipeActionButton: View {
    let action: TRAESwipeAction
    let isVisible: Bool
    let isActive: Bool
    let scale: CGFloat
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: action.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(action.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 60, height: 60)
        .background(
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            action.color,
                            action.color.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: action.color.opacity(0.4),
                    radius: isActive ? 12 : 6,
                    x: 0,
                    y: isActive ? 6 : 3
                )
        )
        .scaleEffect(isVisible ? scale : 0.1)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isVisible)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: scale)
    }
}

// MARK: - Action Feedback Overlay

struct TRAEActionFeedbackOverlay: View {
    let action: TRAESwipeAction
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var checkmarkScale: CGFloat = 0.1
    
    var body: some View {
        ZStack {
            // Background blur
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.9)
            
            VStack(spacing: 12) {
                // Action icon with checkmark
                ZStack {
                    Circle()
                        .fill(action.color)
                        .frame(width: 60, height: 60)
                        .scaleEffect(pulseScale)
                    
                    Image(systemName: action.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // Checkmark overlay
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 20, y: -20)
                        .scaleEffect(checkmarkScale)
                }
                
                Text("\(action.rawValue) Action")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 200, height: 120)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                pulseScale = 1.1
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.2)) {
                checkmarkScale = 1.0
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE swipe gestures to any view
    func traeSwipeable(
        leftActions: [TRAESwipeAction] = [],
        rightActions: [TRAESwipeAction] = [],
        onAction: @escaping (TRAESwipeAction) -> Void
    ) -> some View {
        TRAESwipeableCard(
            leftActions: leftActions,
            rightActions: rightActions,
            onAction: onAction
        ) {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Example card with left and right actions
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .frame(height: 100)
            .overlay(
                VStack {
                    Text("Swipe me!")
                        .font(.headline)
                    Text("← Save/Share | Reschedule/Delete →")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .traeSwipeable(
                leftActions: [.save, .share],
                rightActions: [.reschedule, .delete]
            ) { action in
                print("Action triggered: \(action.rawValue)")
            }
        
        // Another example with different actions
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .frame(height: 80)
            .overlay(
                Text("Another swipeable card")
                    .font(.subheadline)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .traeSwipeable(
                leftActions: [.archive],
                rightActions: [.edit, .share]
            ) { action in
                print("Action triggered: \(action.rawValue)")
            }
    }
    .padding()
}