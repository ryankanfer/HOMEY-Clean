import SwiftUI
import AVFoundation

// MARK: - Subway Door Animation
struct SubwayDoorView: View {
    let doorState: SubwayLineProgress.DoorState
    let isMoving: Bool
    @State private var isAccelerating: Bool = false
    @State private var isDecelerating: Bool = false
    @State private var currentSpeed: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background track/tunnel
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.black, .gray.opacity(0.3), .black],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Immersive train experience overlay
                ImmersiveTrainExperience(
                    isMoving: isMoving,
                    isAccelerating: isAccelerating,
                    isDecelerating: isDecelerating,
                    speed: currentSpeed
                )
                
                // Moving train effect when traveling
                if isMoving {
                    trainMovementEffect
                }
                
                // Subway doors
                HStack(spacing: 0) {
                    // Left door
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.gray.opacity(0.8), .white.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            doorDetails
                        )
                        .offset(x: leftDoorOffset)
                    
                    // Right door
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .gray.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            doorDetails
                        )
                        .offset(x: rightDoorOffset)
                }
                .frame(height: geometry.size.height)
            }
        }
        .clipped()
        .onAppear {
            if isMoving {
                startMovementSequence()
            }
        }
        .onChange(of: isMoving) { moving in
            if moving {
                startMovementSequence()
            } else {
                stopMovementSequence()
            }
        }
    }
    
    private func startMovementSequence() {
        // Acceleration phase
        withAnimation(.easeIn(duration: 0.5)) {
            isAccelerating = true
            currentSpeed = 0.3
        }
        
        // Maintain speed phase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 0.3)) {
                isAccelerating = false
                currentSpeed = 1.0
            }
        }
    }
    
    private func stopMovementSequence() {
        // Deceleration phase
        withAnimation(.easeOut(duration: 0.4)) {
            isDecelerating = true
            currentSpeed = 0.3
        }
        
        // Complete stop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.2)) {
                isDecelerating = false
                currentSpeed = 0
            }
        }
    }
    
    private var doorDetails: some View {
        VStack {
            Spacer()
            
            // Door handle
            RoundedRectangle(cornerRadius: 2)
                .fill(.gray.opacity(0.6))
                .frame(width: 8, height: 40)
            
            Spacer()
            
            // Door window
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.3))
                .frame(height: 120)
                .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private var trainMovementEffect: some View {
        ZStack {
            // Background tunnel lights (slow parallax)
            HStack(spacing: 80) {
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(.orange.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .blur(radius: 2)
                }
            }
            .offset(x: isMoving ? -400 : 0)
            .animation(
                .linear(duration: 2.0).repeatForever(autoreverses: false),
                value: isMoving
            )
            
            // Middle layer - support beams (medium parallax)
            HStack(spacing: 40) {
                ForEach(0..<20, id: \.self) { _ in
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 3, height: 60)
                }
            }
            .offset(x: isMoving ? -300 : 0)
            .animation(
                .linear(duration: 1.2).repeatForever(autoreverses: false),
                value: isMoving
            )
            
            // Foreground - track details (fast parallax)
            HStack(spacing: 20) {
                ForEach(0..<25, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 2, height: 20)
                }
            }
            .offset(x: isMoving ? -200 : 0)
            .animation(
                .linear(duration: 0.5).repeatForever(autoreverses: false),
                value: isMoving
            )
            
            // Speed blur effect
            if isMoving {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 100)
                    .offset(x: -150)
                    .animation(
                        .linear(duration: 0.3).repeatForever(autoreverses: false),
                        value: isMoving
                    )
            }
        }
    }
    
    private var leftDoorOffset: CGFloat {
        switch doorState {
        case .closed, .closing:
            return 0
        case .opening, .open:
            return -150
        }
    }
    
    private var rightDoorOffset: CGFloat {
        switch doorState {
        case .closed, .closing:
            return 0
        case .opening, .open:
            return 150
        }
    }
}

// MARK: - Subway Progress Line
struct SubwayProgressLine: View {
    let currentStation: Int
    let totalStations: Int
    let isMoving: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<totalStations, id: \.self) { index in
                HStack(spacing: 0) {
                    // Station dot
                    Circle()
                        .fill(stationColor(for: index))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2)
                                .opacity(index == currentStation ? 1 : 0)
                        )
                        .scaleEffect(index == currentStation ? 1.3 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentStation)
                    
                    // Track line (except for last station)
                    if index < totalStations - 1 {
                        Rectangle()
                            .fill(trackColor(for: index))
                            .frame(height: 3)
                            .overlay(
                                // Moving train indicator
                                Rectangle()
                                    .fill(.cyan)
                                    .frame(width: 20, height: 3)
                                    .offset(x: isMoving && index == currentStation - 1 ? 50 : -50)
                                    .opacity(isMoving && index == currentStation - 1 ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.8), value: isMoving)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func stationColor(for index: Int) -> Color {
        if index < currentStation {
            return .green
        } else if index == currentStation {
            return .cyan
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func trackColor(for index: Int) -> Color {
        if index < currentStation {
            return .green.opacity(0.6)
        } else {
            return .gray.opacity(0.3)
        }
    }
}

// MARK: - Station Name Display
struct SubwayStationNameView: View {
    let station: SubwayStation
    let isArriving: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Station number and line indicator
            HStack {
                Circle()
                    .fill(.cyan)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("\(station.stationNumber)")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                    )
                
                Text("HOMEY LINE")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .tracking(2)
                
                Spacer()
            }
            
            // Station name
            HStack {
                Text(station.name.uppercased())
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .tracking(1)
                
                Spacer()
                
                if isArriving {
                    Text("ARRIVING")
                        .font(.caption2.bold())
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.cyan.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Subway Card Transition
struct SubwayCardTransition: ViewModifier {
    let isVisible: Bool
    let doorState: SubwayLineProgress.DoorState
    
    func body(content: Content) -> some View {
        content
            .opacity(cardOpacity)
            .scaleEffect(cardScale)
            .offset(y: cardOffset)
            .animation(.easeInOut(duration: 0.4), value: doorState)
    }
    
    private var cardOpacity: Double {
        switch doorState {
        case .closed, .closing:
            return 0.3
        case .opening, .open:
            return 1.0
        }
    }
    
    private var cardScale: Double {
        switch doorState {
        case .closed, .closing:
            return 0.95
        case .opening, .open:
            return 1.0
        }
    }
    
    private var cardOffset: Double {
        switch doorState {
        case .closed, .closing:
            return 20
        case .opening, .open:
            return 0
        }
    }
}

extension View {
    func subwayCardTransition(isVisible: Bool, doorState: SubwayLineProgress.DoorState) -> some View {
        modifier(SubwayCardTransition(isVisible: isVisible, doorState: doorState))
    }
}

// MARK: - Enhanced Sound Manager with Haptics

class SubwaySoundManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    private var movementPlayer: AVAudioPlayer?
    @StateObject private var hapticManager = HapticFeedbackManager()
    
    @Published var isPlayingAmbient = false
    @Published var currentVolume: Float = 0.7
    
    init() {
        setupAmbientSounds()
    }
    
    private func setupAmbientSounds() {
        // Setup ambient subway sounds
        setupAmbientLoop()
    }
    
    private func setupAmbientLoop() {
        // Create subtle ambient subway atmosphere
        if let ambientURL = Bundle.main.url(forResource: "subway_ambient", withExtension: "mp3") {
            do {
                ambientPlayer = try AVAudioPlayer(contentsOf: ambientURL)
                ambientPlayer?.numberOfLoops = -1 // Loop indefinitely
                ambientPlayer?.volume = 0.2
                ambientPlayer?.prepareToPlay()
            } catch {
                print("Could not setup ambient sounds: \(error)")
            }
        }
    }
    
    func startAmbientSounds() {
        ambientPlayer?.play()
        isPlayingAmbient = true
    }
    
    func stopAmbientSounds() {
        ambientPlayer?.stop()
        isPlayingAmbient = false
    }
    
    func playStationArrival() {
        // Play arrival sound with enhanced audio experience
        if let soundURL = Bundle.main.url(forResource: "subway_ding", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.volume = currentVolume
                audioPlayer?.play()
                
                // Add haptic feedback
                hapticManager.stationArrival()
                
                // Play announcement sound after ding
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.playAnnouncementChime()
                }
            } catch {
                print("Error playing arrival sound: \(error)")
                // Fallback to system sound with haptics
                AudioServicesPlaySystemSound(1013)
                hapticManager.stationArrival()
            }
        } else {
            // Enhanced fallback with multiple system sounds
            AudioServicesPlaySystemSound(1013)
            hapticManager.stationArrival()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AudioServicesPlaySystemSound(1016)
            }
        }
    }
    
    private func playAnnouncementChime() {
        // Play a subtle chime for station announcements
        AudioServicesPlaySystemSound(1015)
    }
    
    func playDoorClosing() {
        // Enhanced door closing sequence
        print("🚪 Stand clear of the closing doors...")
        
        // Play warning chime first
        AudioServicesPlaySystemSound(1013)
        hapticManager.doorClosing()
        
        // Play closing sound after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AudioServicesPlaySystemSound(1014)
            self.hapticManager.trainAcceleration()
        }
    }
    
    func playDoorOpening() {
        // Enhanced door opening with welcoming sound
        AudioServicesPlaySystemSound(1016)
        hapticManager.doorOpening()
        
        // Add a subtle welcome chime
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(1015)
        }
    }
    
    func playDoorSound() {
        playDoorOpening()
    }
    
    func playArrivalSound() {
        playStationArrival()
    }
    
    func playDepartureSound() {
        // Enhanced departure sequence
        AudioServicesPlaySystemSound(1014)
        hapticManager.stationDeparture()
        
        // Add acceleration sound
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.playTrainAcceleration()
        }
    }
    
    func playTrainMovement() {
        // Enhanced continuous train movement
        hapticManager.trainMovementRumble()
        
        // Start movement audio loop if available
        startMovementLoop()
    }
    
    private func startMovementLoop() {
        if let movementURL = Bundle.main.url(forResource: "train_movement", withExtension: "mp3") {
            do {
                movementPlayer = try AVAudioPlayer(contentsOf: movementURL)
                movementPlayer?.numberOfLoops = -1
                movementPlayer?.volume = currentVolume * 0.6
                movementPlayer?.play()
            } catch {
                print("Could not play movement sound: \(error)")
            }
        }
    }
    
    func stopTrainMovement() {
        movementPlayer?.stop()
        movementPlayer = nil
    }
    
    func playTrainAcceleration() {
        hapticManager.trainAcceleration()
        
        // Create acceleration sound effect
        AudioServicesPlaySystemSound(1013)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            AudioServicesPlaySystemSound(1014)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            AudioServicesPlaySystemSound(1016)
        }
    }
    
    func playTrainDeceleration() {
        hapticManager.trainDeceleration()
        
        // Create deceleration sound effect (reverse of acceleration)
        AudioServicesPlaySystemSound(1016)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(1014)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            AudioServicesPlaySystemSound(1013)
        }
    }
    
    func playJourneyComplete() {
        // Enhanced journey completion celebration
        hapticManager.journeyComplete()
        
        // Play success sequence
        AudioServicesPlaySystemSound(1016)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            AudioServicesPlaySystemSound(1015)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            AudioServicesPlaySystemSound(1013)
        }
        
        // Stop all ambient sounds
        stopAmbientSounds()
        stopTrainMovement()
    }
    
    func setVolume(_ volume: Float) {
        currentVolume = volume
        audioPlayer?.volume = volume
        ambientPlayer?.volume = volume * 0.3
        movementPlayer?.volume = volume * 0.6
    }
    
    func playEmergencyBrake() {
        // Emergency brake sound and haptics
        hapticManager.emergencyBrake()
        
        // Rapid sequence of alert sounds
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                AudioServicesPlaySystemSound(1013)
            }
        }
        
        stopTrainMovement()
    }
}

// MARK: - Quantum Glow Effect (for special stations)
struct QuantumGlowEffect: View {
    @State private var glowIntensity: Double = 0.5
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.1), .blue.opacity(0.3), .cyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100 + CGFloat(index * 30))
                    .rotationEffect(.degrees(rotationAngle + Double(index * 120)))
                    .opacity(glowIntensity)
            }
            
            // Center core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.cyan.opacity(0.8), .blue.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .scaleEffect(glowIntensity + 0.5)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 1.0
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}