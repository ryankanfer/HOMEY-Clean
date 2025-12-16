import SwiftUI
import ARKit
import RealityKit
import simd

// MARK: - AR Property Visualization View
struct ARPropertyVisualizationView: View {
    let listing: PropertyListing
    @StateObject private var arViewModel = ARPropertyViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingMeasurements = false
    @State private var showingFurniture = false
    @State private var showingStaging = false
    
    var body: some View {
        ZStack {
            ARPropertyViewContainer(viewModel: arViewModel)
                .ignoresSafeArea()
            
            VStack {
                // Top Controls
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    Text(listing.address)
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                }
                .padding()
                
                Spacer()
                
                // Bottom Controls
                VStack(spacing: 16) {
                    // Mode Selection
                    HStack(spacing: 20) {
                        ARModeButton(
                            title: "Measure",
                            icon: "ruler",
                            isActive: showingMeasurements,
                            action: {
                                showingMeasurements.toggle()
                                arViewModel.setMode(.measurement)
                            }
                        )
                        
                        ARModeButton(
                            title: "Furniture",
                            icon: "sofa",
                            isActive: showingFurniture,
                            action: {
                                showingFurniture.toggle()
                                arViewModel.setMode(.furniture)
                            }
                        )
                        
                        ARModeButton(
                            title: "Staging",
                            icon: "house.fill",
                            isActive: showingStaging,
                            action: {
                                showingStaging.toggle()
                                arViewModel.setMode(.staging)
                            }
                        )
                    }
                    
                    // Action Buttons
                    if showingFurniture || showingStaging {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ARFurnitureItem.sampleItems) { item in
                                    FurnitureButton(item: item) {
                                        arViewModel.placeFurniture(item)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Measurement Display
                    if showingMeasurements && !arViewModel.measurements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Room Measurements")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(arViewModel.measurements, id: \.id) { measurement in
                                HStack {
                                    Text(measurement.label)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(measurement.formattedDistance)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            arViewModel.startARSession()
        }
        .onDisappear {
            arViewModel.stopARSession()
        }
    }
}

// MARK: - AR Mode Button
struct ARModeButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isActive ? .white : .secondary)
            .padding()
            .background(isActive ? Color.blue : Color.clear)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}

// MARK: - Furniture Button
struct FurnitureButton: View {
    let item: ARFurnitureItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.title2)
                Text(item.name)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}

// MARK: - AR View Container
struct ARPropertyViewContainer: UIViewRepresentable {
    let viewModel: ARPropertyViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.setupARView(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update AR view if needed
    }
}

// MARK: - AR Property View Model
class ARPropertyViewModel: ObservableObject {
    @Published var measurements: [RoomMeasurement] = []
    @Published var placedFurniture: [PlacedFurniture] = []
    @Published var currentMode: ARMode = .measurement
    
    private var arView: ARView?
    private var arSession: ARSession?
    private var planeDetection = true
    
    enum ARMode {
        case measurement
        case furniture
        case staging
    }
    
    func setupARView(_ arView: ARView) {
        self.arView = arView
        self.arSession = arView.session
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
        
        // Add tap gesture for placing objects
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
    
    func startARSession() {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
    }
    
    func stopARSession() {
        arView?.session.pause()
    }
    
    func setMode(_ mode: ARMode) {
        currentMode = mode
    }
    
    func placeFurniture(_ item: ARFurnitureItem) {
        // Implementation for placing furniture in AR
        print("Placing furniture: \(item.name)")
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let location = gesture.location(in: arView)
        
        switch currentMode {
        case .measurement:
            performMeasurement(at: location, in: arView)
        case .furniture, .staging:
            placeFurnitureAtLocation(location, in: arView)
        }
    }
    
    private func performMeasurement(at location: CGPoint, in arView: ARView) {
        let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .any)
        
        if let result = results.first {
            let position = result.worldTransform.translation
            
            // Create measurement between two points
            if measurements.count % 2 == 0 {
                // Start new measurement
                let measurement = RoomMeasurement(
                    id: UUID(),
                    startPoint: position,
                    endPoint: position,
                    label: "Distance \(measurements.count / 2 + 1)"
                )
                measurements.append(measurement)
            } else {
                // Complete measurement
                if var lastMeasurement = measurements.last {
                    lastMeasurement.endPoint = position
                    measurements[measurements.count - 1] = lastMeasurement
                }
            }
        }
    }
    
    private func placeFurnitureAtLocation(_ location: CGPoint, in arView: ARView) {
        // Implementation for placing furniture at tapped location
        print("Placing furniture at location")
    }
}

// MARK: - Models
struct RoomMeasurement: Identifiable {
    let id: UUID
    let startPoint: SIMD3<Float>
    var endPoint: SIMD3<Float>
    let label: String
    
    var distance: Float {
        return simd_distance(startPoint, endPoint)
    }
    
    var formattedDistance: String {
        let meters = distance
        let feet = meters * 3.28084
        return String(format: "%.2f ft (%.2f m)", feet, meters)
    }
}

struct PlacedFurniture: Identifiable {
    let id = UUID()
    let item: ARFurnitureItem
    let position: SIMD3<Float>
    let rotation: Float
}

struct ARFurnitureItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: FurnitureCategory
    let modelName: String
    
    enum FurnitureCategory {
        case seating
        case tables
        case storage
        case decor
        case lighting
    }
    
    static let sampleItems: [ARFurnitureItem] = [
        ARFurnitureItem(name: "Sofa", icon: "sofa", category: .seating, modelName: "sofa_model"),
        ARFurnitureItem(name: "Chair", icon: "chair", category: .seating, modelName: "chair_model"),
        ARFurnitureItem(name: "Table", icon: "table", category: .tables, modelName: "table_model"),
        ARFurnitureItem(name: "Bed", icon: "bed.double", category: .seating, modelName: "bed_model"),
        ARFurnitureItem(name: "Lamp", icon: "lamp.desk", category: .lighting, modelName: "lamp_model"),
        ARFurnitureItem(name: "Plant", icon: "leaf", category: .decor, modelName: "plant_model")
    ]
}

// MARK: - Extensions
extension simd_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}

#Preview {
    ARPropertyVisualizationView(listing: PropertyListing.sampleListings[0])
}
