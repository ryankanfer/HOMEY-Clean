import SwiftUI
import Combine

// MARK: - Performance Optimization System
struct PerformanceOptimizationSystem {
    
    // MARK: - Performance Configuration
    struct PerformanceConfig: Equatable {
        let maxParticleCount: Int
        let animationQuality: AnimationQuality
        let enableGPUAcceleration: Bool
        let enableReducedMotion: Bool
        let frameRateTarget: Double
        let memoryThreshold: Double
        let batteryOptimization: Bool
        
        enum AnimationQuality: CaseIterable {
            case low, medium, high, ultra
            
            var particleMultiplier: Double {
                switch self {
                case .low: return 0.3
                case .medium: return 0.6
                case .high: return 1.0
                case .ultra: return 1.5
                }
            }
            
            var effectIntensity: Double {
                switch self {
                case .low: return 0.4
                case .medium: return 0.7
                case .high: return 1.0
                case .ultra: return 1.3
                }
            }
        }
        
        static let auto = PerformanceConfig(
            maxParticleCount: 50,
            animationQuality: .medium,
            enableGPUAcceleration: true,
            enableReducedMotion: false,
            frameRateTarget: 60.0,
            memoryThreshold: 0.8,
            batteryOptimization: false
        )
        
        static let lowPower = PerformanceConfig(
            maxParticleCount: 20,
            animationQuality: .low,
            enableGPUAcceleration: false,
            enableReducedMotion: true,
            frameRateTarget: 30.0,
            memoryThreshold: 0.6,
            batteryOptimization: true
        )
        
        static let highPerformance = PerformanceConfig(
            maxParticleCount: 100,
            animationQuality: .ultra,
            enableGPUAcceleration: true,
            enableReducedMotion: false,
            frameRateTarget: 120.0,
            memoryThreshold: 0.9,
            batteryOptimization: false
        )
    }
    
    // MARK: - Performance Monitor
    class PerformanceMonitor: ObservableObject {
        @Published var currentFPS: Double = 60.0
        @Published var memoryUsage: Double = 0.0
        @Published var batteryLevel: Double = 1.0
        @Published var thermalState: ProcessInfo.ThermalState = .nominal
        @Published var recommendedConfig: PerformanceConfig = .auto
        
        private var frameTimer: Timer?
        private var frameCount: Int = 0
        private var lastFrameTime: CFTimeInterval = 0
        private var fpsHistory: [Double] = []
        
        init() {
            startMonitoring()
            updateRecommendedConfig()
        }
        
        private func startMonitoring() {
            frameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.updateMetrics()
            }
            
            // Monitor thermal state
            NotificationCenter.default.addObserver(
                forName: ProcessInfo.thermalStateDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                self.thermalState = ProcessInfo.processInfo.thermalState
                self.updateRecommendedConfig()
            }
        }
        
        private func updateMetrics() {
            // Update FPS
            let currentTime = CACurrentMediaTime()
            if lastFrameTime > 0 {
                let deltaTime = currentTime - lastFrameTime
                let fps = 1.0 / deltaTime
                fpsHistory.append(fps)
                
                if fpsHistory.count > 10 {
                    fpsHistory.removeFirst()
                }
                
                currentFPS = fpsHistory.reduce(0, +) / Double(fpsHistory.count)
            }
            lastFrameTime = currentTime
            
            // Update memory usage (simplified)
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
            
            let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_,
                             task_flavor_t(MACH_TASK_BASIC_INFO),
                             $0,
                             &count)
                }
            }
            
            if kerr == KERN_SUCCESS {
                memoryUsage = Double(info.resident_size) / (1024 * 1024 * 1024) // GB
            }
            
            updateRecommendedConfig()
        }
        
        private func updateRecommendedConfig() {
            if thermalState == .critical || currentFPS < 30 || memoryUsage > 2.0 {
                recommendedConfig = .lowPower
            } else if thermalState == .nominal && currentFPS > 55 && memoryUsage < 1.0 {
                recommendedConfig = .highPerformance
            } else {
                recommendedConfig = .auto
            }
        }
        
        deinit {
            frameTimer?.invalidate()
        }
    }
    
    // MARK: - GPU Acceleration Manager
    struct GPUAccelerationManager {
        static func optimizeForGPU<Content: View>(_ content: Content) -> some View {
            content
                .drawingGroup() // Force GPU rendering
                .compositingGroup() // Optimize compositing
        }
        
        static func optimizeTransforms<Content: View>(_ content: Content) -> some View {
            content
                .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8), value: UUID())
                .preferredColorScheme(.dark) // Optimize for OLED
        }
    }
    
    // MARK: - Accessibility Manager
    struct AccessibilityManager {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
        @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
        
        static func adaptiveConfig(
            baseConfig: PerformanceConfig,
            reduceMotion: Bool,
            reduceTransparency: Bool
        ) -> PerformanceConfig {
            var adaptedConfig = baseConfig
            
            if reduceMotion {
                adaptedConfig = PerformanceConfig(
                    maxParticleCount: max(5, baseConfig.maxParticleCount / 4),
                    animationQuality: .low,
                    enableGPUAcceleration: baseConfig.enableGPUAcceleration,
                    enableReducedMotion: true,
                    frameRateTarget: 30.0,
                    memoryThreshold: baseConfig.memoryThreshold,
                    batteryOptimization: true
                )
            }
            
            return adaptedConfig
        }
    }
    
    // MARK: - Memory Manager
    class MemoryManager: ObservableObject {
        @Published var isOptimizing: Bool = false
        
        private var cleanupTimer: Timer?
        private var particlePool: [UUID: Any] = [:]
        
        init() {
            startMemoryManagement()
        }
        
        private func startMemoryManagement() {
            cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
                self.performCleanup()
            }
        }
        
        private func performCleanup() {
            isOptimizing = true
            
            // Clean up particle pool
            let currentTime = Date()
            particlePool = particlePool.filter { _, _ in
                // Keep particles that are still active
                return true // Simplified logic
            }
            
            // Force garbage collection hint
            autoreleasepool {
                // Perform memory-intensive cleanup
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isOptimizing = false
            }
        }
        
        func recycleParticle(id: UUID, particle: Any) {
            particlePool[id] = particle
        }
        
        func getRecycledParticle(id: UUID) -> Any? {
            return particlePool.removeValue(forKey: id)
        }
        
        deinit {
            cleanupTimer?.invalidate()
        }
    }
}

// MARK: - Optimized Immersive Container
struct OptimizedImmersiveContainer<Content: View>: View {
    let content: Content
    let config: PerformanceOptimizationSystem.PerformanceConfig
    
    @StateObject private var performanceMonitor = PerformanceOptimizationSystem.PerformanceMonitor()
    @StateObject private var memoryManager = PerformanceOptimizationSystem.MemoryManager()
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    @State private var adaptiveConfig: PerformanceOptimizationSystem.PerformanceConfig
    @State private var isVisible: Bool = true
    
    init(
        config: PerformanceOptimizationSystem.PerformanceConfig = .auto,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.config = config
        self._adaptiveConfig = State(initialValue: config)
    }
    
    var body: some View {
        Group {
            if isVisible && !memoryManager.isOptimizing {
                if adaptiveConfig.enableGPUAcceleration {
                    PerformanceOptimizationSystem.GPUAccelerationManager.optimizeForGPU(
                        PerformanceOptimizationSystem.GPUAccelerationManager.optimizeTransforms(content)
                    )
                } else {
                    content
                }
            } else {
                // Fallback minimal view
                Rectangle()
                    .fill(.clear)
                    .overlay(
                        Text("Optimizing...")
                            .foregroundColor(.secondary)
                            .opacity(memoryManager.isOptimizing ? 1 : 0)
                    )
            }
        }
        .onAppear {
            updateAdaptiveConfig()
        }
        .onChange(of: reduceMotion) { _ in
            updateAdaptiveConfig()
        }
        .onChange(of: performanceMonitor.recommendedConfig) { _ in
            updateAdaptiveConfig()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isVisible = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            isVisible = true
        }
    }
    
    private func updateAdaptiveConfig() {
        adaptiveConfig = PerformanceOptimizationSystem.AccessibilityManager.adaptiveConfig(
            baseConfig: performanceMonitor.recommendedConfig,
            reduceMotion: reduceMotion,
            reduceTransparency: reduceTransparency
        )
    }
}

// MARK: - Performance Metrics Overlay
struct PerformanceMetricsOverlay: View {
    @StateObject private var monitor = PerformanceOptimizationSystem.PerformanceMonitor()
    @State private var showMetrics: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                if showMetrics {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("FPS: \(Int(monitor.currentFPS))")
                        Text("Memory: \(String(format: "%.1f", monitor.memoryUsage))GB")
                        Text("Thermal: \(thermalStateText)")
                        
                        Rectangle()
                            .fill(fpsColor)
                            .frame(width: 60, height: 4)
                            .cornerRadius(2)
                    }
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.black.opacity(0.7))
                    .cornerRadius(8)
                }
                
                Button(action: { showMetrics.toggle() }) {
                    Image(systemName: "speedometer")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var thermalStateText: String {
        switch monitor.thermalState {
        case .nominal: return "Normal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }
    
    private var fpsColor: Color {
        if monitor.currentFPS > 50 { return .green }
        else if monitor.currentFPS > 30 { return .yellow }
        else { return .red }
    }
}

// MARK: - View Extensions
extension View {
    func optimizedImmersive(
        config: PerformanceOptimizationSystem.PerformanceConfig = .auto
    ) -> some View {
        OptimizedImmersiveContainer(config: config) {
            self
        }
    }
    
    func performanceMetrics() -> some View {
        self.overlay(
            PerformanceMetricsOverlay(),
            alignment: .topTrailing
        )
    }
    
    func adaptiveQuality(
        _ config: PerformanceOptimizationSystem.PerformanceConfig
    ) -> some View {
        self
            .scaleEffect(config.animationQuality.effectIntensity)
            .opacity(config.enableReducedMotion ? 0.8 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 30) {
            Text("Performance Optimized Interface")
                .font(.title)
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 100)
                .optimizedImmersive()
            
            Circle()
                .fill(.blue.opacity(0.6))
                .frame(width: 80, height: 80)
                .optimizedImmersive(config: .highPerformance)
        }
    }
    .performanceMetrics()
}