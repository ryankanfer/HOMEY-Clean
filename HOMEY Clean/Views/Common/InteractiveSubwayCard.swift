import SwiftUI

// MARK: - Interactive Subway Station Card
struct InteractiveSubwayCard: View {
    let station: SubwayStation
    let doorState: SubwayLineProgress.DoorState
    let onContinue: () -> Void
    let onSwipeNext: (() -> Void)?
    let onSwipePrevious: (() -> Void)?
    
    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var cardScale: Double = 1.0
    @State private var showParticles = false
    
    private let swipeThreshold: CGFloat = 100
    
    init(
        station: SubwayStation,
        doorState: SubwayLineProgress.DoorState,
        onContinue: @escaping () -> Void,
        onSwipeNext: (() -> Void)? = nil,
        onSwipePrevious: (() -> Void)? = nil
    ) {
        self.station = station
        self.doorState = doorState
        self.onContinue = onContinue
        self.onSwipeNext = onSwipeNext
        self.onSwipePrevious = onSwipePrevious
    }
    
    var body: some View {
        ZStack {
            // Background particle effect
            if showParticles {
                InteractiveCardParticleView()
                    .allowsHitTesting(false)
            }
            
            // Main card content
            cardContent
                .scaleEffect(cardScale)
                .rotationEffect(.degrees(cardRotation))
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { value in
                            handleDragEnded(value)
                        }
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: dragOffset)
                .animation(.spring(response: 0.4), value: cardScale)
                .animation(.spring(response: 0.3), value: cardRotation)
        }
        .onAppear {
            animateCardEntrance()
        }
        .onChange(of: doorState) { newState in
            handleDoorStateChange(newState)
        }
    }
    
    private var cardContent: some View {
        VStack(spacing: 24) {
            // Enhanced station header with depth
            stationHeader
            
            Spacer()
            
            // Interactive content area
            contentArea
                .interactiveCardTransition(doorState: doorState)
            
            Spacer()
            
            // Enhanced continue button
            if !station.type.hasCustomButton {
                InteractiveContinueButton(
                    text: station.buttonText,
                    isEnabled: doorState == .open,
                    action: onContinue
                )
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Depth layers for 3D effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.6), .orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                
                // Animated border glow
                if doorState == .open {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.cyan, lineWidth: 1)
                        .opacity(0.8)
                        .scaleEffect(1.02)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: doorState)
                }
            }
        )
        .overlay(
            SubwayDoorWipeOverlay(doorState: doorState)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .allowsHitTesting(false)
        )
        .padding(.horizontal, 20)
    }
    
    private var stationHeader: some View {
        VStack(spacing: 8) {
            // Station number with animated ring
            ZStack {
                Circle()
                    .stroke(.cyan.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                if doorState == .open {
                    Circle()
                        .stroke(.cyan, lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .scaleEffect(1.2)
                        .opacity(0.6)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: doorState)
                }
                
                Text("\(station.stationNumber + 1)")
                    .font(.headline.bold())
                    .foregroundColor(.cyan)
            }
            
            // Station name with typing effect
            AnimatedText(
                text: station.name,
                isVisible: doorState != .closed
            )
            .font(.title2.bold())
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        }
    }
    
    private var contentArea: some View {
        Group {
            switch station.type {
            case .welcome:
                WelcomeStationContent(station: station)
            case .vibeCheck:
                VibeCheckStationContent(station: station, onContinue: onContinue)
            case .feature:
                EnhancedFeatureContent(station: station)
            case .question:
                QuestionStationContent(station: station, onContinue: onContinue)
            case .arrival:
                ArrivalStationContent(station: station)
            }
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        guard doorState == .open else { return }
        
        dragOffset = value.translation
        
        // Add rotation based on horizontal drag
        cardRotation = Double(value.translation.width / 20)
        
        // Scale effect based on drag distance
        let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
        cardScale = max(0.9, 1.0 - dragDistance / 1000)
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        guard doorState == .open else {
            resetCardPosition()
            return
        }
        
        let horizontalDrag = value.translation.width
        let verticalDrag = value.translation.height
        
        // Handle horizontal swipes
        if abs(horizontalDrag) > swipeThreshold {
            if horizontalDrag > 0 {
                // Swipe right - previous station (if available)
                onSwipePrevious?()
            } else {
                // Swipe left - next station
                onSwipeNext?()
            }
        }
        
        // Handle vertical swipes (up for continue)
        if verticalDrag < -swipeThreshold {
            onContinue()
        }
        
        resetCardPosition()
    }
    
    private func resetCardPosition() {
        dragOffset = .zero
        cardRotation = 0
        cardScale = 1.0
    }
    
    private func animateCardEntrance() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            cardScale = 1.0
        }
        
        // Trigger particle effect for special stations
        if station.type == .arrival || station.stationNumber == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showParticles = true
            }
        }
    }
    
    private func handleDoorStateChange(_ newState: SubwayLineProgress.DoorState) {
        switch newState {
        case .opening:
            withAnimation(.spring(response: 0.4)) {
                cardScale = 1.05
            }
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
        case .open:
            withAnimation(.spring(response: 0.3)) {
                cardScale = 1.0
            }
            
        case .closing:
            withAnimation(.easeInOut(duration: 0.3)) {
                cardScale = 0.95
            }
            
        case .closed:
            withAnimation(.easeInOut(duration: 0.2)) {
                cardScale = 0.9
            }
        }
    }
}

// MARK: - Enhanced Feature Content
struct EnhancedFeatureContent: View {
    let station: SubwayStation
    @State private var animateFeature = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text(station.headline)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if let subline = station.subline {
                    Text(subline)
                        .font(.title3)
                        .foregroundColor(.cyan)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Enhanced feature illustration
            enhancedFeatureIllustration
                .scaleEffect(animateFeature ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFeature)
            
            Text(station.copy)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .onAppear {
            animateFeature = true
        }
    }
    
    @ViewBuilder
    private var enhancedFeatureIllustration: some View {
        switch station.stationNumber {
        case 2: // HOMEY explanation
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Text("🐀")
                        .font(.system(size: 40))
                        .scaleEffect(animateFeature ? 1.2 : 1.0)
                    
                    Image(systemName: "arrow.right")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("🚇")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(animateFeature ? 5 : -5))
                    
                    Image(systemName: "arrow.right")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("🏠")
                        .font(.system(size: 40))
                        .scaleEffect(animateFeature ? 1.2 : 1.0)
                }
                
                Text("rats → express → home")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
            }
            
        case 7: // Search features
            VStack(spacing: 8) {
                ForEach(["🛒 Whole Foods nearby", "⏱️ Quick commute", "🚫 Ex-free zone"], id: \.self) { feature in
                    HStack {
                        Text("✅")
                            .scaleEffect(animateFeature ? 1.3 : 1.0)
                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.green.opacity(0.3), lineWidth: 1)
                    )
            )
            
        default:
            // Default illustration
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.cyan)
        }
    }
}

// MARK: - Interactive Continue Button
struct InteractiveContinueButton: View {
    let text: String
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: {
            if isEnabled {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                action()
            }
        }) {
            HStack {
                Text(text)
                    .font(.headline.bold())
                    .foregroundColor(isEnabled ? .black : .gray)
                
                Image(systemName: "arrow.right")
                    .font(.headline.bold())
                    .foregroundColor(isEnabled ? .black : .gray)
                    .offset(x: isPressed ? 5 : 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isEnabled ? .cyan : .gray.opacity(0.3))
                    
                    if isEnabled && pulseAnimation {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.cyan, lineWidth: 2)
                            .scaleEffect(1.1)
                            .opacity(0.6)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(!isEnabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            if isEnabled {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: isEnabled) { enabled in
            pulseAnimation = enabled
        }
    }
}

// MARK: - Animated Text
struct AnimatedText: View {
    let text: String
    let isVisible: Bool
    
    @State private var displayedText = ""
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                if isVisible {
                    animateText()
                }
            }
            .onChange(of: isVisible) { visible in
                if visible {
                    animateText()
                } else {
                    displayedText = ""
                }
            }
    }
    
    private func animateText() {
        displayedText = ""
        
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                displayedText += String(character)
            }
        }
    }
}

// MARK: - Interactive Card Particle Effect
struct InteractiveCardParticleView: View {
    @State private var particles: [InteractiveCardParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        particles = []
        
        for _ in 0..<20 {
            let particle = InteractiveCardParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                color: [.cyan, .orange, .yellow, .green].randomElement() ?? .cyan,
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.8)
            )
            particles.append(particle)
        }
        
        // Animate particles
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            for index in particles.indices {
                particles[index].position.y += CGFloat.random(in: -50...50)
                particles[index].opacity = Double.random(in: 0.1...0.9)
            }
        }
    }
}

struct InteractiveCardParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

// MARK: - Interactive Card Transition
struct InteractiveCardTransition: ViewModifier {
    let doorState: SubwayLineProgress.DoorState
    
    func body(content: Content) -> some View {
        content
            .opacity(contentOpacity)
            .scaleEffect(contentScale)
            .blur(radius: contentBlur)
            .animation(.easeInOut(duration: 0.4), value: doorState)
    }
    
    private var contentOpacity: Double {
        switch doorState {
        case .closed, .closing:
            return 0.4
        case .opening, .open:
            return 1.0
        }
    }
    
    private var contentScale: Double {
        switch doorState {
        case .closed, .closing:
            return 0.9
        case .opening, .open:
            return 1.0
        }
    }
    
    private var contentBlur: CGFloat {
        switch doorState {
        case .closed, .closing:
            return 2
        case .opening, .open:
            return 0
        }
    }
}

extension View {
    func interactiveCardTransition(doorState: SubwayLineProgress.DoorState) -> some View {
        modifier(InteractiveCardTransition(doorState: doorState))
    }
}

// MARK: - Door Wipe Overlay (Subway doors)
struct SubwayDoorWipeOverlay: View {
    let doorState: SubwayLineProgress.DoorState
    @State private var openProgress: CGFloat = 1.0 // 0 = closed (panels meet), 1 = open (panels offscreen)

    var body: some View {
        GeometryReader { geo in
            let travel = geo.size.width / 2 + 4
            ZStack {
                // Left door panel
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LinearGradient(colors: [.white.opacity(0.18), .cyan.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    )
                    .frame(width: geo.size.width / 2 + 2)
                    .offset(x: -travel * openProgress)

                // Right door panel
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LinearGradient(colors: [.white.opacity(0.18), .orange.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    )
                    .frame(width: geo.size.width / 2 + 2)
                    .offset(x: travel * openProgress)

                // Center seam when closed
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1)
                    .opacity(1 - openProgress)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.28), value: openProgress)
            .onAppear { syncToDoorState(animated: false) }
            .onChange(of: doorState) { _ in syncToDoorState(animated: true) }
        }
    }

    private func syncToDoorState(animated: Bool) {
        let target: CGFloat
        switch doorState {
        case .closed, .closing: target = 0.0
        case .opening, .open:   target = 1.0
        }
        if animated {
            withAnimation(.easeInOut(duration: 0.28)) { openProgress = target }
        } else {
            openProgress = target
        }
    }
}

// MARK: - Preview
#Preview {
    InteractiveSubwayCard(
        station: SubwayStation.allStations[0],
        doorState: .open,
        onContinue: { print("Continue tapped") },
        onSwipeNext: { print("Swiped next") },
        onSwipePrevious: { print("Swiped previous") }
    )
    .background(Color.black)
}
