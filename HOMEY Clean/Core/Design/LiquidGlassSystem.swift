//
//  LiquidGlassSystem.swift
//  HOMEY Clean
//
//  Liquid Glass Design System inspired by Emergent.sh
//  Created by Trae AI on 1/27/25.
//

import SwiftUI

// MARK: - Liquid Glass Design System
struct LiquidGlassSystem {
    
    // MARK: - Glass Materials
    enum GlassMaterial {
        case ultraThin
        case thin
        case regular
        case thick
        case ultraThick
        
        var material: SwiftUI.Material {
            switch self {
            case .ultraThin: return .ultraThin
            case .thin: return .thin
            case .regular: return .regular
            case .thick: return .thick
            case .ultraThick: return .ultraThick
            }
        }
        
        var opacity: Double {
            switch self {
            case .ultraThin: return 0.05
            case .thin: return 0.1
            case .regular: return 0.15
            case .thick: return 0.2
            case .ultraThick: return 0.25
            }
        }
    }
    
    // MARK: - Glass Styles
    enum GlassStyle {
        case card
        case modal
        case navigation
        case hero
        case overlay
        
        var cornerRadius: CGFloat {
            switch self {
            case .card: return 16
            case .modal: return 20
            case .navigation: return 12
            case .hero: return 24
            case .overlay: return 8
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .card, .modal: return 1
            case .navigation: return 0.5
            case .hero: return 1.5
            case .overlay: return 0.5
            }
        }
    }
    
    // MARK: - Brand Colors (from Emergent.sh palette)
    static let cream = Color(red: 246/255, green: 244/255, blue: 241/255)
    static let slateGray = Color(red: 47/255, green: 79/255, blue: 79/255)
    static let charcoal = Color(red: 47/255, green: 47/255, blue: 47/255)
    static let sand = Color(red: 217/255, green: 203/255, blue: 184/255)
    static let mint = Color(red: 185/255, green: 217/255, blue: 208/255)
    static let accentGold = Color(red: 212/255, green: 175/255, blue: 55/255)
    static let errorRed = Color(red: 228/255, green: 88/255, blue: 88/255)
    static let successGreen = Color(red: 60/255, green: 163/255, blue: 112/255)
    static let infoBlue = Color(red: 91/255, green: 160/255, blue: 255/255)
}

// MARK: - Liquid Glass View Modifier
struct LiquidGlassModifier: ViewModifier {
    let material: LiquidGlassSystem.GlassMaterial
    let style: LiquidGlassSystem.GlassStyle
    let tintColor: Color
    let shadowEnabled: Bool
    
    init(
        material: LiquidGlassSystem.GlassMaterial = .regular,
        style: LiquidGlassSystem.GlassStyle = .card,
        tintColor: Color = LiquidGlassSystem.cream,
        shadowEnabled: Bool = true
    ) {
        self.material = material
        self.style = style
        self.tintColor = tintColor
        self.shadowEnabled = shadowEnabled
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Base glass background
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .fill(tintColor.opacity(material.opacity))
                        .background(material.material)
                    
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear,
                                    Color.black.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay {
                // Glass border
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: style.borderWidth
                    )
            }
            .shadow(
                color: shadowEnabled ? Color.black.opacity(0.1) : Color.clear,
                radius: shadowEnabled ? 10 : 0,
                x: 0,
                y: shadowEnabled ? 4 : 0
            )
    }
}

// MARK: - Liquid Glass Card
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let material: LiquidGlassSystem.GlassMaterial
    let style: LiquidGlassSystem.GlassStyle
    let tintColor: Color
    
    init(
        material: LiquidGlassSystem.GlassMaterial = .regular,
        style: LiquidGlassSystem.GlassStyle = .card,
        tintColor: Color = LiquidGlassSystem.cream,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.material = material
        self.style = style
        self.tintColor = tintColor
    }
    
    var body: some View {
        content
            .padding()
            .liquidGlass(material: material, style: style, tintColor: tintColor)
    }
}

// MARK: - Cinematic Hero Background
struct CinematicHeroBackground: View {
    let gradientColors: [Color]
    let overlayOpacity: Double
    
    init(
        gradientColors: [Color] = [
            LiquidGlassSystem.charcoal,
            LiquidGlassSystem.slateGray,
            LiquidGlassSystem.mint.opacity(0.3)
        ],
        overlayOpacity: Double = 0.7
    ) {
        self.gradientColors = gradientColors
        self.overlayOpacity = overlayOpacity
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle overlay pattern
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 100,
                        endRadius: 400
                    )
                )
                .ignoresSafeArea()
                .opacity(overlayOpacity)
        }
    }
}

// MARK: - Avatar Gradient System
struct AvatarGradient {
    static func gradient(for avatarId: String) -> LinearGradient {
        switch avatarId {
        case "charlie":
            return LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "scout":
            return LinearGradient(
                colors: [Color.green.opacity(0.8), Color.mint.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "isla":
            return LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "viza":
            return LinearGradient(
                colors: [Color.pink.opacity(0.8), Color.orange.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [LiquidGlassSystem.accentGold.opacity(0.8), LiquidGlassSystem.sand.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - View Extensions
extension View {
    func liquidGlass(
        material: LiquidGlassSystem.GlassMaterial = .regular,
        style: LiquidGlassSystem.GlassStyle = .card,
        tintColor: Color = LiquidGlassSystem.cream,
        shadowEnabled: Bool = true
    ) -> some View {
        self.modifier(
            LiquidGlassModifier(
                material: material,
                style: style,
                tintColor: tintColor,
                shadowEnabled: shadowEnabled
            )
        )
    }
    
    func cinematicHeroBackground(
        gradientColors: [Color] = [
            LiquidGlassSystem.charcoal,
            LiquidGlassSystem.slateGray,
            LiquidGlassSystem.mint.opacity(0.3)
        ],
        overlayOpacity: Double = 0.7
    ) -> some View {
        self.background {
            CinematicHeroBackground(
                gradientColors: gradientColors,
                overlayOpacity: overlayOpacity
            )
        }
    }
    
    func avatarGradientBackground(for avatarId: String) -> some View {
        self.background {
            AvatarGradient.gradient(for: avatarId)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Typography Extensions (Emergent.sh inspired)
extension Font {
    static let homeyHeading = Font.custom("JosefinSans-Bold", size: 28)
    static let homeySubheading = Font.custom("JosefinSans-SemiBold", size: 20)
    static let homeyBody = Font.custom("PlayfairDisplay-Regular", size: 16)
    static let homeyCaption = Font.custom("PlayfairDisplay-Regular", size: 14)
    static let homeyUI = Font.system(size: 16, weight: .medium, design: .rounded)
}

// MARK: - Preview Helpers
#if DEBUG
struct LiquidGlassSystem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LiquidGlassCard(material: .thin, style: .card) {
                VStack {
                    Text("Charlie")
                        .font(.homeyHeading)
                        .foregroundColor(LiquidGlassSystem.charcoal)
                    Text("Journey Guide")
                        .font(.homeyBody)
                        .foregroundColor(LiquidGlassSystem.slateGray)
                }
                .padding()
            }
            
            LiquidGlassCard(material: .regular, style: .modal, tintColor: LiquidGlassSystem.mint) {
                Text("Liquid Glass Modal")
                    .font(.homeySubheading)
                    .padding()
            }
        }
        .padding()
        .cinematicHeroBackground()
    }
}
#endif