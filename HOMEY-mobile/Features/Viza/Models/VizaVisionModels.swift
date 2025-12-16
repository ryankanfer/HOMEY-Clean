//
//  VizaVisionModels.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI
import Foundation

// MARK: - Furniture Item

struct FurnitureItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let category: FurnitureCategory
    let shadowType: ShadowType
    var position: CGPoint = .zero
    var isPlaced: Bool = false
    var rotation: Double = 0
    var scale: Double = 1.0
    
    // Color customization - using String for Codable conformance
    var primaryColorHex: String = "#000000"
    var accentColorHex: String = "#666666"
    var canRecolor: Bool = true
    
    // Computed properties for SwiftUI Colors
    var primaryColor: Color {
        Color(hex: primaryColorHex)
    }
    
    var accentColor: Color {
        Color(hex: accentColorHex)
    }
}

enum FurnitureCategory: String, CaseIterable, Codable {
    case seating = "Seating"
    case tables = "Tables"
    case lighting = "Lighting"
    case decor = "Decor"
    case storage = "Storage"
    
    var icon: String {
        switch self {
        case .seating: return "sofa"
        case .tables: return "table"
        case .lighting: return "lightbulb"
        case .decor: return "leaf"
        case .storage: return "cabinet"
        }
    }
}

enum ShadowType: String, Codable {
    case soft = "shadow_soft_med"
    case long = "shadow_soft_long"
    case none = ""
}

// MARK: - Color Palette

struct ColorPalette: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let colors: [PaletteColor]
    let vision: PaletteVision
    
    var primaryColor: Color {
        Color(hex: colors.first?.hex ?? "#FFFFFF")
    }
    
    var secondaryColor: Color {
        Color(hex: colors.dropFirst().first?.hex ?? colors.first?.hex ?? "#FFFFFF")
    }
    
    var accentColor: Color {
        Color(hex: colors.first(where: { $0.role == .accent })?.hex ?? "#FFFFFF")
    }
    
    var wallColor: Color {
        Color(hex: colors.first(where: { $0.role == .wall })?.hex ?? "#FFFFFF")
    }
    
    var furnitureAccentColor: Color {
        Color(hex: colors.first(where: { $0.role == .furniture })?.hex ?? "#FFFFFF")
    }
}

struct PaletteColor: Codable, Hashable {
    let name: String
    let hex: String
    let role: ColorRole
    
    var color: Color {
        Color(hex: hex)
    }
}

enum ColorRole: String, Codable {
    case wall = "Wall"
    case accent = "Accent"
    case furniture = "Furniture"
    case lighting = "Lighting"
}

enum PaletteVision: String, CaseIterable, Codable {
    case neutrals = "Neutrals"
    case industrial = "Industrial"
    case cozy = "Cozy"
    
    var imageName: String {
        switch self {
        case .neutrals: return "palette_row_neutrals"
        case .industrial: return "palette_row_industrial"
        case .cozy: return "palette_row_cozy"
        }
    }
}

// MARK: - Scene Preset

enum StyleType: String, CaseIterable, Codable {
    case cozyLuxe = "cozy_luxe"
    case minimal = "minimal"
    case industrial = "industrial"
    
    var name: String {
        switch self {
        case .cozyLuxe:
            return "Cozy Luxe"
        case .minimal:
            return "Minimal"
        case .industrial:
            return "Industrial"
        }
    }
    
    var description: String {
        switch self {
        case .cozyLuxe:
            return "Warm, intimate luxury"
        case .minimal:
            return "Clean, focused simplicity"
        case .industrial:
            return "Raw, urban edge"
        }
    }
    
    var icon: String {
        switch self {
        case .cozyLuxe:
            return "flame.fill"
        case .minimal:
            return "circle"
        case .industrial:
            return "gear.circle.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .cozyLuxe:
            return .orange
        case .minimal:
            return .blue
        case .industrial:
            return .gray
        }
    }
}

struct ScenePreset: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let vision: SceneVision
    let palette: ColorPalette
    let furnitureLayout: [FurnitureItem]
    let domeEffect: DomeEffect
    let description: String
}

enum SceneVision: String, CaseIterable, Codable {
    case cozyLuxe = "Cozy Luxe"
    case minimal = "Minimal"
    case industrial = "Industrial"
    
    var icon: String {
        switch self {
        case .cozyLuxe: return "flame"
        case .minimal: return "circle"
        case .industrial: return "gearshape"
        }
    }
    
    var description: String {
        switch self {
        case .cozyLuxe: return "Warm textures, rich colors, intimate lighting"
        case .minimal: return "Clean lines, neutral tones, open space"
        case .industrial: return "Raw materials, bold contrasts, urban edge"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .cozyLuxe: return .orange
        case .minimal: return .blue
        case .industrial: return .gray
        }
    }
}

// MARK: - Projection Dome

struct DomeEffect: Codable, Hashable {
    let name: String
    let overlayImageName: String?
    let lightingEffect: LightingEffect
    let ambientColorHex: String
    let intensity: Double
    
    // Computed property for SwiftUI Color
    var ambientColor: Color {
        Color(hex: ambientColorHex)
    }
    
    init(name: String, overlayImageName: String? = nil, lightingEffect: LightingEffect, ambientColor: Color, intensity: Double = 1.0) {
        self.name = name
        self.overlayImageName = overlayImageName
        self.lightingEffect = lightingEffect
        self.ambientColorHex = ambientColor.toHex()
        self.intensity = intensity
    }
    
    init(name: String, overlayImageName: String? = nil, lightingEffect: LightingEffect, ambientColorHex: String, intensity: Double = 1.0) {
        self.name = name
        self.overlayImageName = overlayImageName
        self.lightingEffect = lightingEffect
        self.ambientColorHex = ambientColorHex
        self.intensity = intensity
    }
}

// MARK: - Dome Vision

enum DomeVision: String, CaseIterable, Codable {
    case ambient = "ambient"
    case dramatic = "dramatic"
    case cozy = "cozy"
    case industrial = "industrial"
    case minimal = "minimal"
    
    var name: String {
        switch self {
        case .ambient:
            return "Ambient"
        case .dramatic:
            return "Dramatic"
        case .cozy:
            return "Cozy"
        case .industrial:
            return "Industrial"
        case .minimal:
            return "Minimal"
        }
    }
}

// MARK: - Dome Style

enum DomeStyle: String, CaseIterable, Codable {
    case ambient = "ambient"
    case dramatic = "dramatic"
    case cozy = "cozy"
    case industrial = "industrial"
    case minimal = "minimal"
    
    var name: String {
        switch self {
        case .ambient:
            return "Ambient"
        case .dramatic:
            return "Dramatic"
        case .cozy:
            return "Cozy"
        case .industrial:
            return "Industrial"
        case .minimal:
            return "Minimal"
        }
    }
}

enum LightingEffect: String, Codable {
    case warm = "Warm"
    case cool = "Cool"
    case dramatic = "Dramatic"
    case natural = "Natural"
    
    var color: Color {
        switch self {
        case .warm: return .orange.opacity(0.3)
        case .cool: return .blue.opacity(0.3)
        case .dramatic: return .purple.opacity(0.4)
        case .natural: return .yellow.opacity(0.2)
        }
    }
}

// MARK: - Styling Session

struct StylingSession: Identifiable, Codable {
    let id = UUID()
    let name: String
    let createdAt: Date
    var lastModified: Date
    var furnitureItems: [FurnitureItem]
    var selectedPalette: ColorPalette?
    var selectedPreset: ScenePreset?
    var domeEffect: DomeEffect?
    var isBookmarked: Bool = false
    var exportedAt: Date?
    
    mutating func updateLastModified() {
        lastModified = Date()
    }
    
    var hasChanges: Bool {
        !furnitureItems.isEmpty || selectedPalette != nil
    }
}

// MARK: - Progression System

struct ProgressionMoment: Identifiable, Codable {
    let id = UUID()
    let trigger: ProgressionTrigger
    let title: String
    let subtitle: String
    let domeProjection: String
    let duration: TimeInterval
    let timestamp: Date = Date()
    let type: ProgressionType
    
    init(trigger: ProgressionTrigger, title: String, subtitle: String, domeProjection: String, duration: TimeInterval, type: ProgressionType) {
        self.trigger = trigger
        self.title = title
        self.subtitle = subtitle
        self.domeProjection = domeProjection
        self.duration = duration
        self.type = type
    }
    
    init(type: ProgressionType, title: String, subtitle: String, domeProjection: String, duration: TimeInterval = 3.0) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.domeProjection = domeProjection
        self.duration = duration
        // Map type to trigger for backward compatibility
        switch type {
        case .firstSave:
            self.trigger = .firstSave
        case .threeStyles:
            self.trigger = .threeStyles
        case .firstExport:
            self.trigger = .firstExport
        case .tenSaves:
            self.trigger = .tenSaves
        case .masterStylist:
            self.trigger = .tenExports
        }
    }
    
    var celebrationColor: Color {
        switch type {
        case .firstSave:
            return .green
        case .threeStyles:
            return .blue
        case .firstExport:
            return .orange
        case .tenSaves:
            return .purple
        case .masterStylist:
            return .gold
        }
    }
}

enum ProgressionTrigger: String, Codable {
    case firstSave
    case threeStyles
    case firstExport
    case tenExports
    case tenSaves
    case masterStylist
}

// MARK: - Grid System

struct GridPosition: Codable, Hashable {
    let x: Int
    let y: Int
    
    func toCGPoint(gridSize: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(x) * gridSize, y: CGFloat(y) * gridSize)
    }
    
    static func fromCGPoint(_ point: CGPoint, gridSize: CGFloat) -> GridPosition {
        GridPosition(
            x: Int(round(point.x / gridSize)),
            y: Int(round(point.y / gridSize))
        )
    }
}

// MARK: - Sample Data

extension FurnitureItem {
    static let sampleItems: [FurnitureItem] = [
        // Seating
        FurnitureItem(name: "Modern Sofa", imageName: "sofa_modern", category: .seating, shadowType: .long),
        FurnitureItem(name: "Curved Armchair", imageName: "armchair_curve", category: .seating, shadowType: .soft),
        
        // Tables
        FurnitureItem(name: "Oak Coffee Table", imageName: "coffee_table_oak", category: .tables, shadowType: .soft),
        
        // Lighting
        FurnitureItem(name: "Arc Lamp", imageName: "lamp_arc", category: .lighting, shadowType: .long),
        
        // Decor
        FurnitureItem(name: "Fiddle Leaf Plant", imageName: "plant_fiddleleaf", category: .decor, shadowType: .soft),
        FurnitureItem(name: "Textured Rug", imageName: "rug_textured", category: .decor, shadowType: .none)
    ]
}

extension ColorPalette {
    static let samplePalettes: [ColorPalette] = [
        ColorPalette(
            name: "Neutrals",
            imageName: "palette_row_neutrals",
            colors: [
                PaletteColor(name: "Warm White", hex: "#F8F6F0", role: .wall),
                PaletteColor(name: "Soft Beige", hex: "#E8E2D5", role: .accent),
                PaletteColor(name: "Charcoal", hex: "#3A3A3A", role: .furniture)
            ],
            vision: .neutrals
        ),
        ColorPalette(
            name: "Industrial",
            imageName: "palette_row_industrial",
            colors: [
                PaletteColor(name: "Concrete Gray", hex: "#95A5A6", role: .wall),
                PaletteColor(name: "Steel Blue", hex: "#34495E", role: .accent),
                PaletteColor(name: "Iron Black", hex: "#2C3E50", role: .furniture)
            ],
            vision: .industrial
        ),
        ColorPalette(
            name: "Cozy",
            imageName: "palette_row_cozy",
            colors: [
                PaletteColor(name: "Cream", hex: "#FDF6E3", role: .wall),
                PaletteColor(name: "Terracotta", hex: "#D35400", role: .accent),
                PaletteColor(name: "Forest Green", hex: "#27AE60", role: .furniture)
            ],
            vision: .cozy
        )
    ]
}

extension ScenePreset {
    static let samplePresets: [ScenePreset] = [
        ScenePreset(
            name: "Cozy Luxe",
            vision: .cozyLuxe,
            palette: ColorPalette.samplePalettes[2],
            furnitureLayout: [],
            domeEffect: DomeEffect(
                name: "Warm Embrace",
                lightingEffect: .warm,
                ambientColor: .orange.opacity(0.2)
            ),
            description: "Intimate and luxurious with warm textures"
        ),
        ScenePreset(
            name: "Minimal",
            vision: .minimal,
            palette: ColorPalette.samplePalettes[0],
            furnitureLayout: [],
            domeEffect: DomeEffect(
                name: "Clean Light",
                lightingEffect: .natural,
                ambientColor: .white.opacity(0.1)
            ),
            description: "Clean, open, and serene"
        ),
        ScenePreset(
            name: "Industrial",
            vision: .industrial,
            palette: ColorPalette.samplePalettes[1],
            furnitureLayout: [],
            domeEffect: DomeEffect(
                name: "Urban Edge",
                lightingEffect: .cool,
                ambientColor: .blue.opacity(0.2)
            ),
            description: "Bold, raw, and contemporary"
        )
    ]
}

// MARK: - Extensions

// MARK: - Progression System Models

struct UserStats: Codable {
    var totalSaves: Int = 0
    var totalExports: Int = 0
    var palettesUsed: Set<String> = []
    var furnitureItemsUsed: Set<String> = []
    var sessionCount: Int = 0
    var totalTimeSpent: TimeInterval = 0
    var lastActiveDate: Date = Date()
    
    mutating func incrementSession() {
        sessionCount += 1
        lastActiveDate = Date()
    }
}

enum ProgressionType: String, CaseIterable, Codable {
    case firstSave = "first_save"
    case threeStyles = "three_styles"
    case firstExport = "first_export"
    case tenSaves = "ten_saves"
    case masterStylist = "master_stylist"
    
    var title: String {
        switch self {
        case .firstSave:
            return "First Vision Saved!"
        case .threeStyles:
            return "Collection Unlocked!"
        case .firstExport:
            return "Vision Shared!"
        case .tenSaves:
            return "Vision Curator!"
        case .masterStylist:
            return "Master Stylist!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .firstSave:
            return "You've created your first look. Your vision journey begins now."
        case .threeStyles:
            return "You've created 3 unique styles. The runway lights are now yours to command."
        case .firstExport:
            return "Your first moodboard is ready to share with the world."
        case .tenSaves:
            return "10 looks in your collection! You're becoming a true vision curator."
        case .masterStylist:
            return "You've mastered the art of styling. All features are now unlocked."
        }
    }
}



extension Color {
    
    init(_ colorName: String) {
        switch colorName.lowercased() {
        case "brown":
            self = .brown
        case "clear":
            self = .clear
        case "red":
            self = .red
        case "blue":
            self = .blue
        case "green":
            self = .green
        case "yellow":
            self = .yellow
        case "orange":
            self = .orange
        case "purple":
            self = .purple
        case "pink":
            self = .pink
        case "gray", "grey":
            self = .gray
        case "black":
            self = .black
        case "white":
            self = .white
        case "gold":
            self = .gold
        default:
            if colorName.hasPrefix("#") {
                self.init(hex: colorName)
            } else {
                self = .primary
            }
        }
    }
    
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    
    func toHex() -> String {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        let a = Int(components[3] * 255)
        
        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }
}