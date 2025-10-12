//
//  CinematicBackground.swift
//  HOMEY Clean
//
//  Cohesive cinematic background system for all pages
//  Based on HomeyHeroBackground pattern with page-specific variations
//

import SwiftUI

struct CinematicBackground: View {
    let page: AppPage
    let intensity: Double
    
    init(for page: AppPage, intensity: Double = 1.0) {
        self.page = page
        self.intensity = intensity
    }
    
    var body: some View {
        ZStack {
            // Base cinematic gradient with page-specific color variations
            LinearGradient(
                colors: pageColors,
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Consistent vignette for depth (from HomeyHeroBackground)
            RadialGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.22 * intensity)],
                center: .center,
                startRadius: 300,
                endRadius: 900
            )
            .blendMode(.multiply)
            
            // Subtle atmospheric particles for premium feel
            if intensity > 0.5 {
                CinematicParticles(density: intensity * 0.3)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var pageColors: [Color] {
        switch page {
        case .homey:
            // Original homepage colors (keep as reference)
            return [
                Color(red: 0.16, green: 0.42, blue: 0.66),   // deep sky blue
                Color(red: 0.34, green: 0.71, blue: 0.86),   // cyan mid
                Color(red: 0.88, green: 0.93, blue: 0.97)    // misty bottom
            ]
        case .discover:
            // Warmer, discovery-focused palette
            return [
                Color(red: 0.20, green: 0.35, blue: 0.70),   // deeper blue
                Color(red: 0.45, green: 0.65, blue: 0.85),   // warm cyan
                Color(red: 0.90, green: 0.94, blue: 0.98)    // bright misty
            ]
        case .directory:
            // Professional, network-focused palette
            return [
                Color(red: 0.18, green: 0.45, blue: 0.60),   // professional blue
                Color(red: 0.40, green: 0.68, blue: 0.82),   // trust cyan
                Color(red: 0.85, green: 0.92, blue: 0.96)    // clean bottom
            ]
        case .documents:
            // Organized, productivity palette
            return [
                Color(red: 0.14, green: 0.40, blue: 0.68),   // document blue
                Color(red: 0.38, green: 0.73, blue: 0.88),   // organized cyan
                Color(red: 0.92, green: 0.95, blue: 0.98)    // paper white
            ]
        case .insights:
            // Analytical, data-focused palette
            return [
                Color(red: 0.22, green: 0.38, blue: 0.72),   // insight blue
                Color(red: 0.42, green: 0.70, blue: 0.90),   // analytical cyan
                Color(red: 0.88, green: 0.94, blue: 0.99)    // data white
            ]
        case .profile:
            // Personal, warm palette
            return [
                Color(red: 0.16, green: 0.44, blue: 0.64),   // personal blue
                Color(red: 0.36, green: 0.72, blue: 0.84),   // warm cyan
                Color(red: 0.90, green: 0.93, blue: 0.97)    // soft bottom
            ]
        case .vision:
            // Bold, visionary palette with soft rose tones
            return [
                Color(red: 1.00, green: 0.94, blue: 0.95),  // soft rose top
                Color(red: 1.00, green: 0.86, blue: 0.88),  // blush mid
                Color(red: 0.98, green: 0.76, blue: 0.82)   // warm bottom
            ]
        case .settings:
            // Neutral, clean settings palette
            return [
                Color(red: 0.94, green: 0.95, blue: 0.97),  // light neutral
                Color(red: 0.88, green: 0.90, blue: 0.93),  // mid neutral
                Color(red: 0.80, green: 0.83, blue: 0.88)   // deeper neutral
            ]
        case .matchmaker:
            // Warm, engaging palette
            return [
                Color(red: 1.00, green: 0.96, blue: 0.92),  // warm cream
                Color(red: 1.00, green: 0.88, blue: 0.74),  // soft amber
                Color(red: 1.00, green: 0.80, blue: 0.60)   // peachy base
            ]
        default:
            return [
                Color(red: 0.94, green: 0.95, blue: 0.97),  // light neutral
                Color(red: 0.88, green: 0.90, blue: 0.93),  // mid neutral
                Color(red: 0.80, green: 0.83, blue: 0.88)   // deeper neutral
            ]
        }
    }
}

// MARK: - Atmospheric Particles
private struct CinematicParticles: View {
    let density: Double
    private let count: Int
    
    init(density: Double) {
        self.density = density
        self.count = Int(24 * density) // Scale particle count with density
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                context.blendMode = .plusLighter
                context.addFilter(.shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 0.5))

                for i in 0..<count {
                    let seed = Double(i)
                    let speed = 0.015 + (sin(seed * 1.73).magnitude) * 0.025
                    let phase = t * speed + seed * 0.37

                    let baseX = (sin(seed * 12.9898) * 43758.5453).truncatingRemainder(dividingBy: 1.0)
                    let drift = sin(phase * 0.6 + seed) * 0.06
                    let x = (baseX + drift).truncatingRemainder(dividingBy: 1.0) * size.width

                    let yProgress = (phase * 0.08).truncatingRemainder(dividingBy: 1.0)
                    let y = (1.0 - yProgress) * size.height

                    let r = 1.5 + ((cos(seed * 78.233) * 12345.6789).truncatingRemainder(dividingBy: 1.0) * 2.0)
                    let rect = CGRect(x: x, y: y, width: r, height: r)
                    let path = Path(ellipseIn: rect)

                    context.fill(path, with: .color(Color.white.opacity(0.08 * density)))
                }
            }
        }
    }
}