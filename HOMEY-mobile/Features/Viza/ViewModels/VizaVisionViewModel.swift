//
//  VizaVisionViewModel.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI
import Combine

@MainActor
class VizaVisionViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentSession: StylingSession
    @Published var availableFurniture: [FurnitureItem] = FurnitureItem.sampleItems
    @Published var availablePalettes: [ColorPalette] = ColorPalette.samplePalettes
    @Published var availablePresets: [ScenePreset] = ScenePreset.samplePresets
    
    // UI State
    @Published var selectedFurniture: FurnitureItem?
    @Published var isDragging = false
    @Published var dragOffset: CGSize = .zero
    @Published var selectedPalette: ColorPalette?
    @Published var selectedPreset: ScenePreset?
    @Published var isOverValidDropZone = false
    @Published var showingExportSheet = false
    @Published var showingBeforeAfter = false
    
    // Progression System
    @Published var userStats = UserStats()
    @Published var unlockedAchievements: Set<ProgressionType> = []
    
    // Dome Effects
    @Published var currentDomeEffect: DomeEffect?
    @Published var domeTransitionProgress: Double = 1.0
    @Published var isTransitioning = false
    
    // Progression
    @Published var savedLooksCount = 0
    @Published var exportCount = 0
    @Published var showingProgressionMoment = false
    @Published var currentProgressionMoment: ProgressionMoment?
    
    // Save/Export Manager
    @Published var saveExportManager = SaveExportManager()
    
    // Grid System
    let gridSize: CGFloat = 20
    let stageSize = CGSize(width: 300, height: 200)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        self.currentSession = StylingSession(
            name: "New Vision",
            createdAt: Date(),
            lastModified: Date(),
            furnitureItems: []
        )
        
        setupBindings()
        loadUserProgress()
    }
    
    private func setupBindings() {
        // Auto-save when session changes
        $currentSession
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] session in
                self?.autoSave()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Furniture Management
    
    func addFurnitureToStage(_ furniture: FurnitureItem) {
        var newFurniture = furniture
        newFurniture.position = snapToGrid(furniture.position)
        currentSession.furnitureItems.append(newFurniture)
        
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func selectFurniture(_ item: FurnitureItem) {
        selectedFurniture = item
    }
    
    func startDragging(_ item: FurnitureItem, at location: CGPoint) {
        selectedFurniture = item
        isDragging = true
        dragOffset = .zero
    }
    
    func updateDrag(translation: CGSize) {
        dragOffset = translation
    }
    
    func endDrag(at location: CGPoint) {
        guard let furniture = selectedFurniture else { return }
        
        let snappedPosition = snapToGrid(location)
        
        if isValidPosition(snappedPosition) {
            placeFurniture(furniture, at: snappedPosition)
        }
        
        isDragging = false
        dragOffset = .zero
        selectedFurniture = nil
    }
    
    func updateFurniturePosition(_ furniture: FurnitureItem, to position: CGPoint) {
        if let index = currentSession.furnitureItems.firstIndex(where: { $0.id == furniture.id }) {
            currentSession.furnitureItems[index].position = snapToGrid(position)
        }
    }
    
    private func snapToGrid(_ point: CGPoint) -> CGPoint {
        let gridX = round(point.x / gridSize) * gridSize
        let gridY = round(point.y / gridSize) * gridSize
        return CGPoint(x: gridX, y: gridY)
    }
    
    private func isValidPosition(_ point: CGPoint) -> Bool {
        // Check if position is within stage bounds
        let stageRect = CGRect(origin: .zero, size: stageSize)
        return stageRect.contains(point)
    }
    
    private func placeFurniture(_ item: FurnitureItem, at position: CGPoint) {
        var placedItem = item
        placedItem.position = position
        placedItem.isPlaced = true
        
        // Remove existing item if updating position
        currentSession.furnitureItems.removeAll { $0.id == item.id }
        
        // Add new/updated item
        currentSession.furnitureItems.append(placedItem)
        currentSession.updateLastModified()
        
        // Check for progression moments
        checkProgressionTriggers()
    }
    
    func removeFurniture(_ item: FurnitureItem) {
        currentSession.furnitureItems.removeAll { $0.id == item.id }
        currentSession.updateLastModified()
    }
    
    func rotateFurniture(_ item: FurnitureItem, by angle: Double) {
        if let index = currentSession.furnitureItems.firstIndex(where: { $0.id == item.id }) {
            currentSession.furnitureItems[index].rotation += angle
            currentSession.updateLastModified()
        }
    }
    
    // MARK: - Palette Management
    
    func selectPalette(_ palette: ColorPalette) {
        selectedPalette = palette
        currentSession.selectedPalette = palette
        currentSession.updateLastModified()
        
        // Trigger recoloring animation
        withAnimation(.easeInOut(duration: 0.8)) {
            applyPaletteToFurniture(palette)
            updateDomeForPalette(palette)
        }
    }
    
    private func applyPaletteToFurniture(_ palette: ColorPalette) {
        for i in 0..<currentSession.furnitureItems.count {
            let item = currentSession.furnitureItems[i]
            if item.canRecolor {
                // Apply palette colors based on furniture category
                if let furnitureColor = palette.colors.first(where: { $0.role == .furniture }) {
                    currentSession.furnitureItems[i].primaryColorHex = furnitureColor.hex
                }
                if let accentColor = palette.colors.first(where: { $0.role == .accent }) {
                    currentSession.furnitureItems[i].accentColorHex = accentColor.hex
                }
            }
        }
    }
    
    private func updateDomeForPalette(_ palette: ColorPalette) {
        // Create dome effect based on palette vision
        let domeStyle: DomeStyle = {
            switch palette.vision {
            case .industrial:
                return .industrial
            case .cozy:
                return .cozy
            default:
                return .minimal
            }
        }()
        
        let domeEffect = DomeEffect(
            name: "\(palette.name) Ambiance",
            lightingEffect: .natural,
            ambientColor: palette.primaryColor.opacity(0.2)
        )
        
        animateDomeTransition(to: domeEffect)
    }
    
    // MARK: - Scene Presets
    
    func applyPreset(_ preset: ScenePreset) {
        selectedPreset = preset
        
        // Apply preset's color palette
        selectPalette(preset.palette)
        
        // Apply preset's dome effect
        currentDomeEffect = preset.domeEffect
        
        // Clear existing furniture and apply preset furniture
        currentSession.furnitureItems.removeAll()
        
        for furniture in preset.furnitureLayout {
            var placedFurniture = furniture
            if placedFurniture.position == .zero {
                placedFurniture.position = CGPoint(
                    x: CGFloat(Int.random(in: 1...4)) * gridSize,
                    y: CGFloat(Int.random(in: 1...3)) * gridSize
                )
            }
            placedFurniture.isPlaced = true
            currentSession.furnitureItems.append(placedFurniture)
        }
        
        // Trigger dome transition
        animateDomeTransition(to: preset.domeEffect)
        
        currentSession.updateLastModified()
    }
    
    // MARK: - Dome Effects
    
    private func animateDomeTransition(to effect: DomeEffect) {
        guard !isTransitioning else { return }
        
        isTransitioning = true
        domeTransitionProgress = 0
        
        withAnimation(.easeInOut(duration: 1.5)) {
            domeTransitionProgress = 1.0
            currentDomeEffect = effect
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isTransitioning = false
        }
    }
    
    // MARK: - Save & Export
    
    func saveCurrentLook() {
        savedLooksCount += 1
        currentSession.updateLastModified()
        
        // Trigger progression moments
        if savedLooksCount == 1 {
            showProgressionMoment(.firstSave)
        } else if savedLooksCount == 3 {
            showProgressionMoment(.threeStyles)
        }
        
        autoSave()
    }
    
    func exportCurrentLook() {
        exportCount += 1
        currentSession.exportedAt = Date()
        
        // Update stats and check for progression
        userStats.totalExports += 1
        checkForProgressionMoments()
        
        // Trigger progression moments
        if exportCount == 1 {
            showProgressionMoment(.firstExport)
        } else if exportCount == 10 {
            showProgressionMoment(.tenExports)
        }
        
        showingExportSheet = true
        
        // Trigger dome fade out effect
        triggerExportDomeEffect()
    }
    
    private func triggerExportDomeEffect() {
        withAnimation(.easeOut(duration: 2.0)) {
            domeTransitionProgress = 0.0
        }
        
        // Reset after export
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 1.0)) {
                self.domeTransitionProgress = 1.0
            }
        }
    }
    
    private func loadUserProgress() {
        // Load saved user statistics and achievements
        // In a real app, this would load from UserDefaults or a database
        if let savedStats = UserDefaults.standard.data(forKey: "userStats"),
           let decodedStats = try? JSONDecoder().decode(UserStats.self, from: savedStats) {
            userStats = decodedStats
        }
        
        if let savedAchievements = UserDefaults.standard.array(forKey: "unlockedAchievements") as? [String] {
            unlockedAchievements = Set(savedAchievements.compactMap { ProgressionType(rawValue: $0) })
        }
    }
    
    private func saveUserProgress() {
        // Save user statistics and achievements
        if let encodedStats = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(encodedStats, forKey: "userStats")
        }
        
        let achievementStrings = unlockedAchievements.map { $0.rawValue }
        UserDefaults.standard.set(achievementStrings, forKey: "unlockedAchievements")
    }
    
    func checkForProgressionMoments() {
        var newAchievements: [ProgressionType] = []
        
        // Check for first save
        if userStats.totalSaves == 1 && !unlockedAchievements.contains(.firstSave) {
            newAchievements.append(.firstSave)
        }
        
        // Check for three styles
        if userStats.totalSaves == 3 && !unlockedAchievements.contains(.threeStyles) {
            newAchievements.append(.threeStyles)
        }
        
        // Check for first export
        if userStats.totalExports == 1 && !unlockedAchievements.contains(.firstExport) {
            newAchievements.append(.firstExport)
        }
        
        // Check for ten saves
        if userStats.totalSaves == 10 && !unlockedAchievements.contains(.tenSaves) {
            newAchievements.append(.tenSaves)
        }
        
        // Check for master stylist (20+ saves, 5+ exports, all palettes used)
        if userStats.totalSaves >= 20 && userStats.totalExports >= 5 && 
           userStats.palettesUsed.count >= 3 && !unlockedAchievements.contains(.masterStylist) {
            newAchievements.append(.masterStylist)
        }
        
        // Show progression moment for the first new achievement
        if let firstAchievement = newAchievements.first {
            showProgressionMoment(for: firstAchievement)
            unlockedAchievements.formUnion(newAchievements)
            saveUserProgress()
        }
    }
    
    private func showProgressionMoment(for type: ProgressionType) {
        let moment = ProgressionMoment(
            type: type,
            title: type.title,
            subtitle: type.subtitle,
            domeProjection: "ACHIEVEMENT"
        )
        
        currentProgressionMoment = moment
        
        // Delay to allow current animations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                self.showingProgressionMoment = true
            }
        }
    }
    
    func onLookSaved() {
        userStats.totalSaves += 1
        if let palette = selectedPalette {
            userStats.palettesUsed.insert(palette.name)
        }
        checkForProgressionMoments()
        saveUserProgress()
    }
    
    func toggleBeforeAfter() {
        showingBeforeAfter.toggle()
    }
    
    private func autoSave() {
        // In a real app, this would save to persistent storage
        print("Auto-saving session: \(currentSession.name)")
    }
    
    // MARK: - Progression System
    
    private func checkProgressionTriggers() {
        // Check if we should trigger any progression moments
        // This is called after significant actions
    }
    
    private func showProgressionMoment(_ trigger: ProgressionTrigger) {
        let moment: ProgressionMoment
        
        switch trigger {
        case .firstSave:
            moment = ProgressionMoment(
                trigger: .firstSave,
                title: "Styled",
                subtitle: "Your first look is saved",
                domeProjection: "STYLED",
                duration: 2.0,
                type: .firstSave
            )
        case .threeStyles:
            moment = ProgressionMoment(
                trigger: .threeStyles,
                title: "Collection",
                subtitle: "You've created 3 unique styles",
                domeProjection: "COLLECTION",
                duration: 3.0,
                type: .threeStyles
            )
        case .firstExport:
            moment = ProgressionMoment(
                trigger: .firstExport,
                title: "Exported",
                subtitle: "Your vision is ready to share",
                domeProjection: "EXPORTED",
                duration: 2.5,
                type: .firstExport
            )
        case .tenExports:
            moment = ProgressionMoment(
                trigger: .tenExports,
                title: "Vision Master",
                subtitle: "10 exports and counting!",
                domeProjection: "MASTER",
                duration: 4.0,
                type: .tenSaves
            )
        case .tenSaves:
            moment = ProgressionMoment(
                trigger: .tenSaves,
                title: "Curator",
                subtitle: "10 saves achieved!",
                domeProjection: "CURATOR",
                duration: 3.0,
                type: .tenSaves
            )
        case .masterStylist:
            moment = ProgressionMoment(
                trigger: .masterStylist,
                title: "Master Stylist",
                subtitle: "All features unlocked!",
                domeProjection: "MASTER",
                duration: 4.0,
                type: .masterStylist
            )
        }
        
        currentProgressionMoment = moment
        showingProgressionMoment = true
        
        // Auto-hide after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + moment.duration) {
            self.showingProgressionMoment = false
            self.currentProgressionMoment = nil
        }
    }
    
    // MARK: - Session Management
    
    func createNewSession() {
        currentSession = StylingSession(
            name: "New Vision \(Date().formatted(date: .omitted, time: .shortened))",
            createdAt: Date(),
            lastModified: Date(),
            furnitureItems: []
        )
        
        selectedPalette = nil
        selectedPreset = nil
        currentDomeEffect = nil
    }
    
    func clearStage() {
        currentSession.furnitureItems.removeAll()
        selectedPalette = nil
        selectedPreset = nil
        currentDomeEffect = nil
        currentSession.updateLastModified()
    }
    
    // MARK: - Vision Tools Methods
    
    func createNewProject() {
        createNewSession()
    }
    
    func addToMoodboard() {
        // Add functionality for moodboard
        print("Adding to moodboard")
    }
    
    func generateColorPalette() {
        // Generate a new random color palette
        let newColors: [Color] = [
            Color.random(),
            Color.random(),
            Color.random(),
            Color.random(),
            Color.random()
        ]
        colorPalette = newColors
    }
    
    func startFloorPlanDesign() {
        // Start floor plan design functionality
        print("Starting floor plan design")
    }
    
    func launchARExperience() {
        // Launch AR experience
        print("Launching AR experience")
    }
    
    func showAllProjects() {
        // Show all projects functionality
        print("Showing all projects")
    }
    
    func openProject(_ project: VisionProject) {
        // Open specific project
        print("Opening project: \(project.name)")
    }
    
    // MARK: - Computed Properties
    
    var colorPalette: [Color] {
        get {
            if let palette = selectedPalette {
                return palette.colors.map { $0.color }
            } else {
                return [.blue, .green, .purple, .orange, .red]
            }
        }
        set {
            let paletteColors: [PaletteColor] = newValue.enumerated().map { index, color in
                let role: ColorRole
                switch index {
                case 0: role = .wall
                case 1: role = .accent
                default: role = .furniture
                }
                return PaletteColor(name: "Color \(index + 1)", hex: color.toHex(), role: role)
            }
            let newPalette = ColorPalette(
                name: "Custom Palette",
                imageName: "palette_row_custom",
                colors: paletteColors,
                vision: .neutrals
            )
            selectedPalette = newPalette
            currentSession.selectedPalette = newPalette
            currentSession.updateLastModified()
        }
    }
    
    var recentProjects: [VisionProject] {
        return [
            VisionProject(name: "Living Room Redesign", lastModified: "2 hours ago", icon: "sofa"),
            VisionProject(name: "Kitchen Makeover", lastModified: "1 day ago", icon: "fork.knife"),
            VisionProject(name: "Bedroom Refresh", lastModified: "3 days ago", icon: "bed.double"),
            VisionProject(name: "Office Space", lastModified: "1 week ago", icon: "desktopcomputer")
        ]
    }
}

// MARK: - Color Extension

extension Color {
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}