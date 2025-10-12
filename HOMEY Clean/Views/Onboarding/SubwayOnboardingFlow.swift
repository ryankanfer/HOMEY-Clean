import SwiftUI

struct SubwayOnboardingFlow: View {
    let onComplete: () -> Void
    
    @StateObject private var subwayProgress = SubwayLineProgress()
    @StateObject private var soundManager = SubwaySoundManager()
    @State private var showInviteSheet = false
    
    @State private var swipeFlashDirection: CGFloat = 0 // -1 for right->left (previous), +1 for left->right (next)
    @State private var showSwipeFlash: Bool = false
    
    var body: some View {
        ZStack {
            // Dark subway tunnel background
            Color.black
                .ignoresSafeArea()
            
            // Subway tunnel ambiance
            RadialGradient(
                colors: [
                    Color.gray.opacity(0.1),
                    Color.black
                ],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Rapid blurred color swipe overlay
            if showSwipeFlash {
                let currentStationType: SubwayStationType = {
                    if subwayProgress.currentStation < SubwayStation.allStations.count {
                        return SubwayStation.allStations[subwayProgress.currentStation].type
                    } else {
                        return .feature
                    }
                }()
                
                LinearGradient(
                    colors: streakColors(for: currentStationType),
                    startPoint: swipeFlashDirection > 0 ? .leading : .trailing,
                    endPoint: swipeFlashDirection > 0 ? .trailing : .leading
                )
                .blur(radius: 28)
                .blendMode(.plusLighter)
                .opacity(0.9)
                .transition(.move(edge: swipeFlashDirection > 0 ? .leading : .trailing).combined(with: .opacity))
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Enhanced interactive subway map
                EnhancedSubwayProgressLine(
                    currentStation: subwayProgress.currentStation,
                    totalStations: SubwayStation.allStations.count,
                    isMoving: subwayProgress.isMoving,
                    doorState: subwayProgress.doorState
                )
                .padding(.top, 60)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Interactive station cards with gesture support
                TabView(selection: Binding(
                    get: { subwayProgress.currentStation },
                    set: { _ in }
                )) {
                    ForEach(SubwayStation.allStations.indices, id: \.self) { index in
                        InteractiveSubwayCard(
                            station: SubwayStation.allStations[index],
                            doorState: subwayProgress.doorState,
                            onContinue: {
                                nextStation()
                            },
                            onSwipeNext: {
                                if subwayProgress.doorState == .open {
                                    nextStation()
                                }
                            },
                            onSwipePrevious: {
                                if subwayProgress.doorState == .open && subwayProgress.currentStation > 0 {
                                    previousStation()
                                }
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .allowsHitTesting(subwayProgress.doorState == .open)
                
                Spacer()
                
                // Enhanced station info footer
                enhancedStationInfo
            }
        }
        .onAppear {
            subwayProgress.startJourney()
            soundManager.startAmbientSounds()
        }
        .onChange(of: subwayProgress.currentStation) { _ in
            Task { @MainActor in
                handleStationChange()
            }
        }
        .onChange(of: subwayProgress.isMoving) { moving in
            Task { @MainActor in
                if moving {
                    soundManager.playTrainMovement()
                } else {
                    soundManager.stopTrainMovement()
                }
            }
        }
        .onChange(of: subwayProgress.doorState) { doorState in
            Task { @MainActor in
                handleDoorStateChange(doorState)
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteAgentSheet()
        }
        .onDisappear {
            soundManager.stopAmbientSounds()
            soundManager.stopTrainMovement()
        }
    }
    
    private var enhancedStationInfo: some View {
        VStack(spacing: 12) {
            // Journey status with animations
            HStack {
                ZStack {
                    Circle()
                        .fill(.orange.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: subwayProgress.isMoving ? "train.side.front.car" : "building.2")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .bold))
                        .scaleEffect(subwayProgress.isMoving ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatCount(subwayProgress.isMoving ? 3 : 1), value: subwayProgress.isMoving)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Line 🏠")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    
                    Text(subwayProgress.isMoving ? "Express Service" : "Local Service")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Door status with enhanced visuals
                doorStatusView
            }
            
            // Current station info with typing animation
            if subwayProgress.currentStation < SubwayStation.allStations.count {
                let currentStation = SubwayStation.allStations[subwayProgress.currentStation]
                
                VStack(spacing: 4) {
                    Text("Now Arriving:")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    AnimatedText(
                        text: currentStation.name,
                        isVisible: subwayProgress.doorState != .closed
                    )
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                }
            }
            
            // Gesture hints
            if subwayProgress.doorState == .open {
                HStack(spacing: 16) {
                    gestureHint(icon: "arrow.up", text: "Swipe up")
                    gestureHint(icon: "arrow.left", text: "Swipe left")
                    if subwayProgress.currentStation > 0 {
                        gestureHint(icon: "arrow.right", text: "Swipe right")
                    }
                }
                .opacity(0.6)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: subwayProgress.doorState)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.5), .cyan.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
    
    private var doorStatusView: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(doorStatusColor.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Image(systemName: doorStatusIcon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(doorStatusColor)
            }
            
            VStack(alignment: .trailing, spacing: 1) {
                Text(doorStatusText)
                    .font(.caption2.bold())
                    .foregroundColor(doorStatusColor)
                
                if subwayProgress.doorState == .opening || subwayProgress.doorState == .closing {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: doorStatusColor))
                }
            }
        }
    }
    
    private var doorStatusColor: Color {
        switch subwayProgress.doorState {
        case .opening, .open:
            return .green
        case .closing:
            return .orange
        case .closed:
            return .red
        }
    }
    
    private var doorStatusIcon: String {
        switch subwayProgress.doorState {
        case .opening, .open:
            return "door.left.hand.open"
        case .closing, .closed:
            return "door.left.hand.closed"
        }
    }
    
    private var doorStatusText: String {
        switch subwayProgress.doorState {
        case .opening:
            return "Opening"
        case .open:
            return "Doors Open"
        case .closing:
            return "Closing"
        case .closed:
            return "Doors Closed"
        }
    }
    
    private func streakColors(for stationType: SubwayStationType) -> [Color] {
        switch stationType {
        case .feature:
            return [Color.cyan.opacity(0.0), Color.cyan.opacity(0.35), Color.blue.opacity(0.5), Color.cyan.opacity(0.35), Color.cyan.opacity(0.0)]
        case .question:
            return [Color.purple.opacity(0.0), Color.purple.opacity(0.35), Color.orange.opacity(0.5), Color.purple.opacity(0.35), Color.purple.opacity(0.0)]
        case .welcome:
            return [Color.mint.opacity(0.0), Color.mint.opacity(0.35), Color.cyan.opacity(0.5), Color.mint.opacity(0.35), Color.mint.opacity(0.0)]
        case .arrival:
            return [Color.green.opacity(0.0), Color.green.opacity(0.45), Color.yellow.opacity(0.55), Color.green.opacity(0.45), Color.green.opacity(0.0)]
        case .vibeCheck:
            return [Color.orange.opacity(0.0), Color.orange.opacity(0.35), Color.red.opacity(0.45), Color.orange.opacity(0.35), Color.orange.opacity(0.0)]
        }
    }
    
    private func gestureHint(icon: String, text: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.cyan)
            
            Text(text)
                .font(.system(size: 8))
                .foregroundColor(.cyan)
        }
    }
    
    private func previousStation() {
        guard subwayProgress.currentStation > 0 else { return }
        
        triggerSwipeFlash(direction: -1)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            subwayProgress.doorState = .closing
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.8)) {
                subwayProgress.isMoving = true
                subwayProgress.currentStation -= 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                subwayProgress.isMoving = false
                subwayProgress.doorState = .opening
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.2)) {
                subwayProgress.doorState = .open
            }
        }
    }
    
    private func nextStation() {
        triggerSwipeFlash(direction: 1)
        
        let nextIndex = subwayProgress.currentStation + 1
        
        if nextIndex < SubwayStation.allStations.count {
            subwayProgress.moveToNextStation()
        } else {
            subwayProgress.completeJourney()
        }
    }
    
    private func triggerSwipeFlash(direction: CGFloat) {
        swipeFlashDirection = direction
        withAnimation(.linear(duration: 0.18)) {
            showSwipeFlash = true
        }
        // Fade out slightly slower for premium feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeOut(duration: 0.22)) {
                showSwipeFlash = false
            }
        }
    }
    
    private func handleStationChange() {
        // Play arrival sound when doors open
        if subwayProgress.doorState == .opening {
            soundManager.playStationArrival()
        }
        
        // Update responses manager for current station
        let currentStation = SubwayStation.allStations[subwayProgress.currentStation]
        
        // Handle special stations
        switch currentStation.type {
        case .arrival:
            // Final station - complete onboarding with celebration
            soundManager.playJourneyComplete()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        default:
            break
        }
    }
    
    private func handleDoorStateChange(_ doorState: SubwayLineProgress.DoorState) {
        switch doorState {
        case .opening:
            soundManager.playDoorOpening()
        case .closing:
            soundManager.playDoorClosing()
        case .open:
            // Doors are fully open - subtle confirmation
            break
        case .closed:
            // Doors are fully closed - prepare for departure
            if subwayProgress.isMoving {
                soundManager.playDepartureSound()
            }
        }
    }
}

// MARK: - Subway Onboarding Integration
extension SubwayOnboardingFlow {
    /// Factory method to create subway onboarding with completion handler
    static func create(onComplete: @escaping () -> Void) -> some View {
        SubwayOnboardingFlow(onComplete: onComplete)
    }
}

// MARK: - Preview
#Preview {
    SubwayOnboardingFlow(onComplete: {
        print("Subway onboarding completed!")
    })
}

