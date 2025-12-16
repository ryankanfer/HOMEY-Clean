//
//  TRAEProgressiveDisclosure.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Progressive disclosure animations for staged reveals of steps, cards, and nudges
//

import SwiftUI

// MARK: - Disclosure Types

enum TRAEDisclosureType {
    case sequential
    case cascading
    case radial
    case wave
    case spiral
    case typewriter
    case morphing
    case liquid
    
    var baseDelay: Double {
        switch self {
        case .sequential: return 0.2
        case .cascading: return 0.15
        case .radial: return 0.1
        case .wave: return 0.12
        case .spiral: return 0.18
        case .typewriter: return 0.05
        case .morphing: return 0.25
        case .liquid: return 0.3
        }
    }
}

// MARK: - Disclosure Item

struct TRAEDisclosureItem: Identifiable {
    let id = UUID()
    let content: AnyView
    let priority: Int
    let category: String
    var isRevealed: Bool = false
    var animationDelay: Double = 0
    
    init<Content: View>(
        priority: Int = 0,
        category: String = "default",
        @ViewBuilder content: () -> Content
    ) {
        self.priority = priority
        self.category = category
        self.content = AnyView(content())
    }
}

// MARK: - TRAE Progressive Disclosure Container

struct TRAEProgressiveDisclosure: View {
    @State private var items: [TRAEDisclosureItem]
    let disclosureType: TRAEDisclosureType
    let autoReveal: Bool
    let onItemRevealed: ((TRAEDisclosureItem) -> Void)?
    let onAllRevealed: (() -> Void)?
    
    @State private var revealedCount: Int = 0
    @State private var isRevealing: Bool = false
    @State private var currentWave: Int = 0
    
    init(
        items: [TRAEDisclosureItem],
        type: TRAEDisclosureType = .sequential,
        autoReveal: Bool = true,
        onItemRevealed: ((TRAEDisclosureItem) -> Void)? = nil,
        onAllRevealed: (() -> Void)? = nil
    ) {
        self._items = State(initialValue: items)
        self.disclosureType = type
        self.autoReveal = autoReveal
        self.onItemRevealed = onItemRevealed
        self.onAllRevealed = onAllRevealed
    }
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                TRAEDisclosureItemView(
                    item: item,
                    index: index,
                    disclosureType: disclosureType,
                    isRevealed: item.isRevealed
                )
            }
        }
        .onAppear {
            if autoReveal {
                startProgressiveReveal()
            }
        }
    }
    
    // MARK: - Revelation Logic
    
    private func startProgressiveReveal() {
        guard !isRevealing else { return }
        isRevealing = true
        
        switch disclosureType {
        case .sequential:
            revealSequentially()
        case .cascading:
            revealCascading()
        case .radial:
            revealRadially()
        case .wave:
            revealInWaves()
        case .spiral:
            revealSpirally()
        case .typewriter:
            revealTypewriter()
        case .morphing:
            revealMorphing()
        case .liquid:
            revealLiquid()
        }
    }
    
    private func revealSequentially() {
        let sortedItems = items.sorted { $0.priority < $1.priority }
        
        for (index, _) in sortedItems.enumerated() {
            let delay = Double(index) * disclosureType.baseDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                revealItem(at: index)
            }
        }
    }
    
    private func revealCascading() {
        let groupedItems = Dictionary(grouping: items) { $0.category }
        var totalDelay: Double = 0
        
        for (_, categoryItems) in groupedItems {
            for (index, _) in categoryItems.enumerated() {
                let delay = totalDelay + Double(index) * disclosureType.baseDelay
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if let itemIndex = items.firstIndex(where: { $0.id == categoryItems[index].id }) {
                        revealItem(at: itemIndex)
                    }
                }
            }
            totalDelay += Double(categoryItems.count) * disclosureType.baseDelay + 0.3
        }
    }
    
    private func revealRadially() {
        let center = items.count / 2
        var revealed = Set<Int>()
        
        func revealAtDistance(_ distance: Int) {
            let indices = [center - distance, center + distance].filter { $0 >= 0 && $0 < items.count && !revealed.contains($0) }
            
            for index in indices {
                revealed.insert(index)
                let delay = Double(distance) * disclosureType.baseDelay
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    revealItem(at: index)
                }
            }
            
            if revealed.count < items.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + disclosureType.baseDelay) {
                    revealAtDistance(distance + 1)
                }
            }
        }
        
        // Start with center item
        revealItem(at: center)
        revealed.insert(center)
        
        if items.count > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + disclosureType.baseDelay) {
                revealAtDistance(1)
            }
        }
    }
    
    private func revealInWaves() {
        let waveSize = 3
        let totalWaves = (items.count + waveSize - 1) / waveSize
        
        for wave in 0..<totalWaves {
            let waveDelay = Double(wave) * disclosureType.baseDelay * 3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + waveDelay) {
                let startIndex = wave * waveSize
                let endIndex = min(startIndex + waveSize, items.count)
                
                for index in startIndex..<endIndex {
                    let itemDelay = Double(index - startIndex) * disclosureType.baseDelay
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + itemDelay) {
                        revealItem(at: index)
                    }
                }
            }
        }
    }
    
    private func revealSpirally() {
        // Simulate spiral pattern by alternating between start and end
        var leftIndex = 0
        var rightIndex = items.count - 1
        var delay: Double = 0
        var fromLeft = true
        
        while leftIndex <= rightIndex {
            let currentIndex = fromLeft ? leftIndex : rightIndex
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                revealItem(at: currentIndex)
            }
            
            if fromLeft {
                leftIndex += 1
            } else {
                rightIndex -= 1
            }
            
            fromLeft.toggle()
            delay += disclosureType.baseDelay
        }
    }
    
    private func revealTypewriter() {
        for (index, _) in items.enumerated() {
            let delay = Double(index) * disclosureType.baseDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                revealItem(at: index, withTypewriter: true)
            }
        }
    }
    
    private func revealMorphing() {
        for (index, _) in items.enumerated() {
            let delay = Double(index) * disclosureType.baseDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                revealItem(at: index, withMorphing: true)
            }
        }
    }
    
    private func revealLiquid() {
        for (index, _) in items.enumerated() {
            let delay = Double(index) * disclosureType.baseDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                revealItem(at: index, withLiquid: true)
            }
        }
    }
    
    private func revealItem(
        at index: Int,
        withTypewriter: Bool = false,
        withMorphing: Bool = false,
        withLiquid: Bool = false
    ) {
        guard index < items.count else { return }
        
        items[index].isRevealed = true
        revealedCount += 1
        
        // Trigger haptic feedback
        TRAEMotionSystem.shared.triggerHaptic(.light)
        
        // Call callbacks
        onItemRevealed?(items[index])
        
        if revealedCount == items.count {
            isRevealing = false
            onAllRevealed?()
            TRAEMotionSystem.shared.triggerHaptic(.success)
        }
    }
    
    // MARK: - Public Methods
    
    func revealAll() {
        for index in items.indices {
            items[index].isRevealed = true
        }
        revealedCount = items.count
        onAllRevealed?()
    }
    
    func hideAll() {
        for index in items.indices {
            items[index].isRevealed = false
        }
        revealedCount = 0
    }
    
    func revealNext() {
        if let nextIndex = items.firstIndex(where: { !$0.isRevealed }) {
            revealItem(at: nextIndex)
        }
    }
}

// MARK: - Disclosure Item View

struct TRAEDisclosureItemView: View {
    let item: TRAEDisclosureItem
    let index: Int
    let disclosureType: TRAEDisclosureType
    let isRevealed: Bool
    
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0.0
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var blur: CGFloat = 10
    @State private var typewriterProgress: Double = 0
    @State private var morphingScale: CGFloat = 0.1
    @State private var liquidOffset: CGFloat = -100
    
    var body: some View {
        item.content
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .blur(radius: blur)
            .mask(
                // Typewriter effect mask
                Group {
                    if disclosureType == .typewriter {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * typewriterProgress)
                            .animation(.easeInOut(duration: 0.8), value: typewriterProgress)
                    } else {
                        Rectangle()
                    }
                }
            )
            .overlay(
                // Morphing particles
                Group {
                    if disclosureType == .morphing && isRevealed {
                        MorphingRevealOverlay()
                            .allowsHitTesting(false)
                    } else {
                        EmptyView()
                    }
                }
            )
            .overlay(
                // Liquid reveal effect
                Group {
                    if disclosureType == .liquid && isRevealed {
                        LiquidRevealOverlay(offset: liquidOffset)
                            .allowsHitTesting(false)
                    } else {
                        EmptyView()
                    }
                }
            )
            .onChange(of: isRevealed) { revealed in
                if revealed {
                    startRevealAnimation()
                } else {
                    startHideAnimation()
                }
            }
    }
    
    private func startRevealAnimation() {
        switch disclosureType {
        case .sequential, .cascading:
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
                offset = .zero
                blur = 0
            }
            
        case .radial:
            offset = CGSize(width: 0, height: -50)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                offset = .zero
                blur = 0
            }
            
        case .wave:
            offset = CGSize(width: -100, height: 0)
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                offset = .zero
                blur = 0
            }
            
        case .spiral:
            rotation = index % 2 == 0 ? -180 : 180
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
                blur = 0
            }
            
        case .typewriter:
            withAnimation(.easeInOut(duration: 0.8)) {
                typewriterProgress = 1.0
                opacity = 1.0
                scale = 1.0
                blur = 0
            }
            
        case .morphing:
            withAnimation(.spring(response: 0.9, dampingFraction: 0.6)) {
                morphingScale = 1.0
                opacity = 1.0
                scale = 1.0
                blur = 0
            }
            
        case .liquid:
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                liquidOffset = 0
                opacity = 1.0
                scale = 1.0
                blur = 0
            }
        }
    }
    
    private func startHideAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.1
            opacity = 0.0
            blur = 10
            typewriterProgress = 0
            morphingScale = 0.1
            liquidOffset = -100
        }
    }
}

// MARK: - Morphing Reveal Overlay

struct MorphingRevealOverlay: View {
    @State private var particles: [RevealParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [particle.color, particle.color.opacity(0.3)],
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size / 2
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<8).map { _ in
            RevealParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...300),
                    y: CGFloat.random(in: 0...100)
                ),
                size: CGFloat.random(in: 3...8),
                color: [.blue, .purple, .pink].randomElement() ?? .blue,
                opacity: Double.random(in: 0.4...0.8),
                scale: 0.1
            )
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            let delay = Double(i) * 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    particles[i].scale = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        particles[i].opacity = 0.0
                        particles[i].scale = 1.5
                    }
                }
            }
        }
    }
}

struct RevealParticle {
    let id: UUID
    let position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
    var scale: CGFloat
}

// MARK: - Liquid Reveal Overlay

struct LiquidRevealOverlay: View {
    let offset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                path.move(to: CGPoint(x: offset, y: 0))
                
                for y in stride(from: 0, through: height, by: 2) {
                    let wave = sin(y * 0.02) * 10
                    path.addLine(to: CGPoint(x: offset + wave, y: y))
                }
                
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: width, y: 0))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

// MARK: - Convenience Builders

struct TRAEStepDisclosure: View {
    let steps: [String]
    let type: TRAEDisclosureType
    
    var body: some View {
        TRAEProgressiveDisclosure(
            items: steps.enumerated().map { index, step in
                TRAEDisclosureItem(priority: index, category: "step") {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        Text(step)
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
            },
            type: type
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply progressive disclosure to any view
    func traeProgressiveDisclosure(
        type: TRAEDisclosureType = .sequential,
        autoReveal: Bool = true
    ) -> some View {
        TRAEProgressiveDisclosure(
            items: [TRAEDisclosureItem { self }],
            type: type,
            autoReveal: autoReveal
        )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 30) {
            Text("Progressive Disclosure Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TRAEStepDisclosure(
                steps: [
                    "Upload your documents",
                    "Review and verify information",
                    "Complete your profile",
                    "Submit for approval",
                    "Receive confirmation"
                ],
                type: .cascading
            )
        }
        .padding()
    }
}