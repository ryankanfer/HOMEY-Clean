//
//  HomeyLandingViewWithProfile.swift
//  HOMEY Clean
//
//  Enhanced HOMEY landing view with profile section and left drawer integration
//

import SwiftUI
import UIKit

@available(*, deprecated, message: "Use CinematicHomeyLandingView instead.")
struct HomeyLandingViewWithProfile: View {
    @Binding var selectedTab: Int
    @Binding var showLeftDrawer: Bool
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var userProfileManager: UserProfileManager

    var body: some View {
        CinematicHomeyLandingView(selectedTab: $selectedTab, showLeftDrawer: $showLeftDrawer)
    }
}

struct HomeyActionGridItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let delay: Double
    let action: () -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.dynamicText())
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Theme.dynamicTextSecondary())
                }
                .multilineTextAlignment(.center)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Theme.dynamicSurface())
                    .shadow(color: Theme.dynamicText().opacity(0.2), radius: 6, x: 0, y: 3)
            )
            .scaleEffect(animateIn ? 1.0 : 0.8)
            .opacity(animateIn ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateIn)
        }
        .buttonStyle(PressableCardStyle())
        .onAppear {
            animateIn = true
        }
    }
}

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct HomeyAnimatedSkyBackground: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.3, green: 0.4, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.clear,
                    Color.purple.opacity(0.2)
                ],
                startPoint: UnitPoint(
                    x: 0.5 + 0.3 * cos(phase * 2 * Double.pi),
                    y: 0.5 + 0.3 * sin(phase * 2 * Double.pi)
                ),
                endPoint: UnitPoint(
                    x: 0.5 - 0.3 * cos(phase * 2 * Double.pi),
                    y: 0.5 - 0.3 * sin(phase * 2 * Double.pi)
                )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}
