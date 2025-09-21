//
//  TRAEHapticFeedback.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Comprehensive haptic feedback integration for uploads, completions, and card flips
//

import SwiftUI
import UIKit

// MARK: - Haptic Types

enum TRAEHapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
    case impact(intensity: CGFloat)
    case notification(type: UINotificationFeedbackGenerator.FeedbackType)
    case custom(pattern: [TRAEHapticEvent])
    
    var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        default: return nil
        }
    }
    
    var notificationType: UINotificationFeedbackGenerator.FeedbackType? {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        case .notification(let type): return type
        default: return nil
        }
    }
}

// MARK: - Haptic Event for Custom Patterns

struct TRAEHapticEvent {
    let type: TRAEHapticType
    let delay: TimeInterval
    let intensity: CGFloat
    
    init(type: TRAEHapticType, delay: TimeInterval = 0, intensity: CGFloat = 1.0) {
        self.type = type
        self.delay = delay
        self.intensity = intensity
    }
}

// MARK: - Haptic Context

enum TRAEHapticContext {
    case upload(stage: UploadStage)
    case completion(type: CompletionType)
    case cardFlip(direction: FlipDirection)
    case navigation(action: NavigationAction)
    case interaction(element: InteractionElement)
    case error(severity: ErrorSeverity)
    case progress(milestone: ProgressMilestone)
    
    enum UploadStage {
        case start, progress, success, failure, cancelled
    }
    
    enum CompletionType {
        case task, form, process, achievement, milestone
    }
    
    enum FlipDirection {
        case forward, backward, reveal, hide
    }
    
    enum NavigationAction {
        case swipe, tap, longPress, drag, drop
    }
    
    enum InteractionElement {
        case button, toggle, slider, picker, card, modal
    }
    
    enum ErrorSeverity {
        case minor, moderate, critical, fatal
    }
    
    enum ProgressMilestone {
        case quarter, half, threeQuarters, complete
    }
    
    var hapticPattern: TRAEHapticType {
        switch self {
        case .upload(let stage):
            switch stage {
            case .start: return .light
            case .progress: return .selection
            case .success: return .success
            case .failure: return .error
            case .cancelled: return .warning
            }
            
        case .completion(let type):
            switch type {
            case .task: return .success
            case .form: return .custom(pattern: [
                TRAEHapticEvent(type: .medium, delay: 0),
                TRAEHapticEvent(type: .light, delay: 0.1),
                TRAEHapticEvent(type: .success, delay: 0.3)
            ])
            case .process: return .custom(pattern: [
                TRAEHapticEvent(type: .light, delay: 0),
                TRAEHapticEvent(type: .medium, delay: 0.15),
                TRAEHapticEvent(type: .heavy, delay: 0.3),
                TRAEHapticEvent(type: .success, delay: 0.5)
            ])
            case .achievement: return .custom(pattern: [
                TRAEHapticEvent(type: .heavy, delay: 0),
                TRAEHapticEvent(type: .medium, delay: 0.1),
                TRAEHapticEvent(type: .light, delay: 0.2),
                TRAEHapticEvent(type: .success, delay: 0.4)
            ])
            case .milestone: return .custom(pattern: [
                TRAEHapticEvent(type: .success, delay: 0),
                TRAEHapticEvent(type: .success, delay: 0.2)
            ])
            }
            
        case .cardFlip(let direction):
            switch direction {
            case .forward: return .medium
            case .backward: return .light
            case .reveal: return .custom(pattern: [
                TRAEHapticEvent(type: .light, delay: 0),
                TRAEHapticEvent(type: .medium, delay: 0.2)
            ])
            case .hide: return .light
            }
            
        case .navigation(let action):
            switch action {
            case .swipe: return .light
            case .tap: return .selection
            case .longPress: return .medium
            case .drag: return .light
            case .drop: return .heavy
            }
            
        case .interaction(let element):
            switch element {
            case .button: return .light
            case .toggle: return .medium
            case .slider: return .selection
            case .picker: return .light
            case .card: return .light
            case .modal: return .medium
            }
            
        case .error(let severity):
            switch severity {
            case .minor: return .warning
            case .moderate: return .error
            case .critical: return .custom(pattern: [
                TRAEHapticEvent(type: .error, delay: 0),
                TRAEHapticEvent(type: .heavy, delay: 0.2)
            ])
            case .fatal: return .custom(pattern: [
                TRAEHapticEvent(type: .heavy, delay: 0),
                TRAEHapticEvent(type: .error, delay: 0.1),
                TRAEHapticEvent(type: .heavy, delay: 0.3)
            ])
            }
            
        case .progress(let milestone):
            switch milestone {
            case .quarter: return .light
            case .half: return .medium
            case .threeQuarters: return .heavy
            case .complete: return .success
            }
        }
    }
}

// MARK: - TRAE Haptic Manager

class TRAEHapticManager: ObservableObject {
    static let shared = TRAEHapticManager()
    
    @Published var isEnabled: Bool = true
    @Published var intensity: CGFloat = 1.0
    
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    private var selectionGenerator = UISelectionFeedbackGenerator()
    private var notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        setupGenerators()
    }
    
    private func setupGenerators() {
        // Pre-create impact generators for better performance
        impactGenerators[.light] = UIImpactFeedbackGenerator(style: .light)
        impactGenerators[.medium] = UIImpactFeedbackGenerator(style: .medium)
        impactGenerators[.heavy] = UIImpactFeedbackGenerator(style: .heavy)
        
        // Prepare generators
        impactGenerators.values.forEach { $0.prepare() }
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    func trigger(_ type: TRAEHapticType) {
        guard isEnabled else { return }
        
        switch type {
        case .light, .medium, .heavy:
            if let style = type.impactStyle,
               let generator = impactGenerators[style] {
                generator.impactOccurred(intensity: intensity)
            }
            
        case .success, .warning, .error:
            if let notificationType = type.notificationType {
                notificationGenerator.notificationOccurred(notificationType)
            }
            
        case .selection:
            selectionGenerator.selectionChanged()
            
        case .impact(let customIntensity):
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred(intensity: customIntensity * intensity)
            
        case .notification(let notificationType):
            notificationGenerator.notificationOccurred(notificationType)
            
        case .custom(let pattern):
            executeCustomPattern(pattern)
        }
    }
    
    func trigger(context: TRAEHapticContext) {
        trigger(context.hapticPattern)
    }
    
    private func executeCustomPattern(_ pattern: [TRAEHapticEvent]) {
        for event in pattern {
            DispatchQueue.main.asyncAfter(deadline: .now() + event.delay) {
                let adjustedIntensity = self.intensity * event.intensity
                
                switch event.type {
                case .impact(let baseIntensity):
                    self.trigger(.impact(intensity: baseIntensity * adjustedIntensity))
                default:
                    self.trigger(event.type)
                }
            }
        }
    }
}

// MARK: - TRAE Haptic Upload Progress

struct TRAEHapticUploadProgress: View {
    @State private var progress: Double = 0.0
    @State private var isUploading: Bool = false
    @State private var uploadStage: TRAEHapticContext.UploadStage = .start
    
    let onUploadComplete: (() -> Void)?
    
    init(onUploadComplete: (() -> Void)? = nil) {
        self.onUploadComplete = onUploadComplete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Upload progress ring
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Image(systemName: getUploadIcon())
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(getUploadColor())
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            // Upload status
            Text(getUploadStatusText())
                .font(.headline)
                .foregroundColor(getUploadColor())
            
            // Control buttons
            HStack(spacing: 16) {
                Button("Start Upload") {
                    startUpload()
                }
                .traeButtonStyle()
                .disabled(isUploading)
                
                Button("Cancel") {
                    cancelUpload()
                }
                .traeButtonStyle(isDestructive: true)
                .disabled(!isUploading)
            }
        }
        .padding()
    }
    
    private func startUpload() {
        isUploading = true
        uploadStage = .start
        progress = 0.0
        
        // Trigger start haptic
        TRAEHapticManager.shared.trigger(context: .upload(stage: .start))
        
        // Simulate upload progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.02
            
            // Progress haptics at milestones
            if progress >= 0.25 && progress < 0.27 {
                TRAEHapticManager.shared.trigger(context: .progress(milestone: .quarter))
            } else if progress >= 0.5 && progress < 0.52 {
                TRAEHapticManager.shared.trigger(context: .progress(milestone: .half))
            } else if progress >= 0.75 && progress < 0.77 {
                TRAEHapticManager.shared.trigger(context: .progress(milestone: .threeQuarters))
            }
            
            if progress >= 1.0 {
                timer.invalidate()
                completeUpload()
            }
        }
    }
    
    private func completeUpload() {
        uploadStage = .success
        isUploading = false
        
        // Trigger success haptic
        TRAEHapticManager.shared.trigger(context: .upload(stage: .success))
        TRAEHapticManager.shared.trigger(context: .completion(type: .process))
        
        onUploadComplete?()
    }
    
    private func cancelUpload() {
        uploadStage = .cancelled
        isUploading = false
        progress = 0.0
        
        // Trigger cancel haptic
        TRAEHapticManager.shared.trigger(context: .upload(stage: .cancelled))
    }
    
    private func getUploadIcon() -> String {
        switch uploadStage {
        case .start, .progress: return "icloud.and.arrow.up"
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        case .cancelled: return "stop.circle.fill"
        }
    }
    
    private func getUploadColor() -> Color {
        switch uploadStage {
        case .start, .progress: return .blue
        case .success: return .green
        case .failure: return .red
        case .cancelled: return .orange
        }
    }
    
    private func getUploadStatusText() -> String {
        switch uploadStage {
        case .start: return "Ready to Upload"
        case .progress: return "Uploading..."
        case .success: return "Upload Complete!"
        case .failure: return "Upload Failed"
        case .cancelled: return "Upload Cancelled"
        }
    }
}

// MARK: - TRAE Haptic Card Flip

struct TRAEHapticCardFlip<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    
    @State private var isFlipped: Bool = false
    @State private var flipAngle: Double = 0
    
    init(@ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self.front = front()
        self.back = back()
    }
    
    var body: some View {
        ZStack {
            // Front of card
            front
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(flipAngle),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            // Back of card
            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(flipAngle + 180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .onTapGesture {
            flipCard()
        }
    }
    
    private func flipCard() {
        let direction: TRAEHapticContext.FlipDirection = isFlipped ? .backward : .forward
        
        // Trigger haptic at start of flip
        TRAEHapticManager.shared.trigger(context: .cardFlip(direction: direction))
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            flipAngle += 180
            isFlipped.toggle()
        }
        
        // Trigger haptic at end of flip
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let revealDirection: TRAEHapticContext.FlipDirection = isFlipped ? .reveal : .hide
            TRAEHapticManager.shared.trigger(context: .cardFlip(direction: revealDirection))
        }
    }
}

// MARK: - TRAE Haptic Completion Celebration

struct TRAEHapticCompletion: View {
    let completionType: TRAEHapticContext.CompletionType
    let title: String
    let subtitle: String?
    
    @State private var isAnimating: Bool = false
    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = 0
    @State private var particles: [CompletionParticle] = []
    
    init(
        type: TRAEHapticContext.CompletionType,
        title: String,
        subtitle: String? = nil
    ) {
        self.completionType = type
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        ZStack {
            // Background blur
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(width: 280, height: 200)
            
            VStack(spacing: 16) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.green, .green.opacity(0.7)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(isAnimating ? 1.0 : 0.0)
            }
            
            // Celebration particles
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            startCompletionAnimation()
        }
    }
    
    private func startCompletionAnimation() {
        // Trigger completion haptic
        TRAEHapticManager.shared.trigger(context: .completion(type: completionType))
        
        // Scale animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
            isAnimating = true
        }
        
        // Rotation animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
            rotation = 360
        }
        
        // Generate and animate particles
        generateParticles()
        animateParticles()
    }
    
    private func generateParticles() {
        particles = (0..<20).map { _ in
            CompletionParticle(
                id: UUID(),
                position: CGPoint(x: 140, y: 100), // Center position
                size: CGFloat.random(in: 4...12),
                color: [.yellow, .orange, .green, .blue, .purple].randomElement() ?? .yellow,
                opacity: 1.0,
                scale: 0.1
            )
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            let delay = Double(i) * 0.05
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 50...120)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    particles[i].position.x += cos(angle) * distance
                    particles[i].position.y += sin(angle) * distance
                    particles[i].scale = 1.0
                }
                
                withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                    particles[i].opacity = 0.0
                    particles[i].scale = 0.1
                }
            }
        }
    }
}

struct CompletionParticle {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
    var scale: CGFloat
}

// MARK: - View Extensions

extension View {
    /// Apply haptic feedback to tap gestures
    func traeHapticTap(
        type: TRAEHapticType = .light,
        action: @escaping () -> Void = {}
    ) -> some View {
        self.onTapGesture {
            TRAEHapticManager.shared.trigger(type)
            action()
        }
    }
    
    /// Apply haptic feedback to long press gestures
    func traeHapticLongPress(
        type: TRAEHapticType = .medium,
        action: @escaping () -> Void = {}
    ) -> some View {
        self.onLongPressGesture {
            TRAEHapticManager.shared.trigger(type)
            action()
        }
    }
    
    /// Apply contextual haptic feedback
    func traeHapticContext(
        _ context: TRAEHapticContext,
        action: @escaping () -> Void = {}
    ) -> some View {
        self.onTapGesture {
            TRAEHapticManager.shared.trigger(context: context)
            action()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("TRAE Haptic Feedback Demo")
            .font(.largeTitle)
            .fontWeight(.bold)
        
        // Upload progress demo
        TRAEHapticUploadProgress()
        
        // Card flip demo
        TRAEHapticCardFlip {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.gradient)
                .frame(width: 200, height: 120)
                .overlay(
                    Text("Tap to Flip")
                        .font(.headline)
                        .foregroundColor(.white)
                )
        } back: {
            RoundedRectangle(cornerRadius: 16)
                .fill(.purple.gradient)
                .frame(width: 200, height: 120)
                .overlay(
                    Text("Back Side")
                        .font(.headline)
                        .foregroundColor(.white)
                )
        }
        
        // Completion demo
        Button("Show Completion") {
            // Demo completion
        }
        .traeButtonStyle()
    }
    .padding()
}