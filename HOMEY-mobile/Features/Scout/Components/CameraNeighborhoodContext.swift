import SwiftUI
import ARKit
import Vision
import CoreLocation
import MapKit

struct CameraNeighborhoodContextView: View {
    @StateObject private var viewModel = NeighborhoodContextViewModel()
    @State private var showingSettings = false
    @State private var selectedAmenity: LocalAmenity?
    
    var body: some View {
        ZStack {
            // AR Camera View
            ARViewContainer(viewModel: viewModel)
                .ignoresSafeArea()
            
            // Top Controls
            VStack {
                HStack {
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Detection Status
                    HStack {
                        Circle()
                            .fill(viewModel.isDetecting ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(viewModel.isDetecting ? "Detecting" : "Paused")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Capsule())
                }
                .padding()
                
                Spacer()
            }
            
            // AR Overlays
            ForEach(viewModel.detectedBuildings) { building in
                BuildingOverlay(building: building)
            }
            
            ForEach(viewModel.nearbyAmenities) { amenity in
                AmenityOverlay(amenity: amenity) {
                    selectedAmenity = amenity
                }
            }
            
            // Bottom Information Panel
            VStack {
                Spacer()
                
                if !viewModel.contextInfo.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.contextInfo, id: \.title) { info in
                                ContextInfoCard(info: info)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                    .background(Color.black.opacity(0.3))
                }
            }
        }
        .onAppear {
            viewModel.startDetection()
        }
        .onDisappear {
            viewModel.stopDetection()
        }
        .sheet(isPresented: $showingSettings) {
            NeighborhoodSettingsView(viewModel: viewModel)
        }
        .sheet(item: $selectedAmenity) { amenity in
            AmenityDetailView(amenity: amenity)
        }
    }
}

struct BuildingOverlay: View {
    let building: DetectedBuilding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(building.name)
                .font(.headline)
                .foregroundColor(.white)
            
            if let type = building.type {
                Text(type)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if let distance = building.distance {
                Text("\(Int(distance))m away")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .position(building.screenPosition)
    }
}

struct AmenityOverlay: View {
    let amenity: LocalAmenity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Image(systemName: amenity.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(amenity.name)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(6)
            .background(amenity.category.color.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .position(amenity.screenPosition)
    }
}

struct ContextInfoCard: View {
    let info: ContextInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: info.icon)
                    .foregroundColor(.white)
                Text(info.title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(info.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(width: 200, height: 80)
        .background(Color.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct NeighborhoodSettingsView: View {
    @ObservedObject var viewModel: NeighborhoodContextViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detection Settings") {
                    Toggle("Building Recognition", isOn: $viewModel.buildingDetectionEnabled)
                    Toggle("Amenity Detection", isOn: $viewModel.amenityDetectionEnabled)
                    Toggle("Distance Labels", isOn: $viewModel.showDistanceLabels)
                }
                
                Section("Detection Range") {
                    HStack {
                        Text("Range: \(Int(viewModel.detectionRange))m")
                        Spacer()
                        Slider(value: $viewModel.detectionRange, in: 100...1000, step: 50)
                    }
                }
                
                Section("Amenity Categories") {
                    ForEach(AmenityCategory.allCases, id: \.self) { category in
                        Toggle(category.displayName, isOn: binding(for: category))
                    }
                }
            }
            .navigationTitle("Neighborhood Context")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func binding(for category: AmenityCategory) -> Binding<Bool> {
        Binding(
            get: { viewModel.enabledCategories.contains(category) },
            set: { enabled in
                if enabled {
                    viewModel.enabledCategories.insert(category)
                } else {
                    viewModel.enabledCategories.remove(category)
                }
            }
        )
    }
}

struct AmenityDetailView: View {
    let amenity: LocalAmenity
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: amenity.icon)
                            .font(.largeTitle)
                            .foregroundColor(amenity.category.color)
                        
                        VStack(alignment: .leading) {
                            Text(amenity.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(amenity.category.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        if let address = amenity.address {
                            NeighborhoodDetailRow(icon: "location", title: "Address", value: address)
                        }
                        
                        if let distance = amenity.distance {
                            NeighborhoodDetailRow(icon: "ruler", title: "Distance", value: "\(Int(distance))m away")
                        }
                        
                        if let rating = amenity.rating {
                            NeighborhoodDetailRow(icon: "star.fill", title: "Rating", value: String(format: "%.1f", rating))
                        }
                        
                        if let hours = amenity.openingHours {
                            NeighborhoodDetailRow(icon: "clock", title: "Hours", value: hours)
                        }
                    }
                    .padding()
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            // Open in Maps
                        }) {
                            HStack {
                                Image(systemName: "map")
                                Text("Open in Maps")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if amenity.category == .restaurant || amenity.category == .cafe {
                            Button(action: {
                                // Call or visit website
                            }) {
                                HStack {
                                    Image(systemName: "phone")
                                    Text("Contact")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Amenity Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NeighborhoodDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Models

struct DetectedBuilding: Identifiable {
    let id = UUID()
    let name: String
    let type: String?
    let screenPosition: CGPoint
    let distance: Double?
    let confidence: Float
}

struct LocalAmenity: Identifiable {
    let id = UUID()
    let name: String
    let category: AmenityCategory
    let screenPosition: CGPoint
    let distance: Double?
    let address: String?
    let rating: Double?
    let openingHours: String?
    
    var icon: String {
        category.icon
    }
}

enum AmenityCategory: CaseIterable {
    case restaurant, cafe, shopping, hospital, school, park, transport, bank
    
    var displayName: String {
        switch self {
        case .restaurant: return "Restaurants"
        case .cafe: return "Cafes"
        case .shopping: return "Shopping"
        case .hospital: return "Healthcare"
        case .school: return "Education"
        case .park: return "Parks"
        case .transport: return "Transport"
        case .bank: return "Banking"
        }
    }
    
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer"
        case .shopping: return "bag"
        case .hospital: return "cross.case"
        case .school: return "book"
        case .park: return "tree"
        case .transport: return "bus"
        case .bank: return "banknote"
        }
    }
    
    var color: Color {
        switch self {
        case .restaurant: return .orange
        case .cafe: return .brown
        case .shopping: return .purple
        case .hospital: return .red
        case .school: return .blue
        case .park: return .green
        case .transport: return .indigo
        case .bank: return .yellow
        }
    }
}

struct ContextInfo {
    let title: String
    let description: String
    let icon: String
}

// MARK: - ARView Container

struct ARViewContainer: UIViewRepresentable {
    let viewModel: NeighborhoodContextViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        viewModel.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        let viewModel: NeighborhoodContextViewModel
        
        init(_ viewModel: NeighborhoodContextViewModel) {
            self.viewModel = viewModel
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            viewModel.processFrame(frame)
        }
    }
}

// MARK: - ViewModel

class NeighborhoodContextViewModel: NSObject, ObservableObject {
    @Published var detectedBuildings: [DetectedBuilding] = []
    @Published var nearbyAmenities: [LocalAmenity] = []
    @Published var contextInfo: [ContextInfo] = []
    @Published var isDetecting = false
    
    // Settings
    @Published var buildingDetectionEnabled = true
    @Published var amenityDetectionEnabled = true
    @Published var showDistanceLabels = true
    @Published var detectionRange: Double = 500
    @Published var enabledCategories: Set<AmenityCategory> = Set(AmenityCategory.allCases)
    
    var arView: ARSCNView?
    private let locationManager = CLLocationManager()
    private let visionQueue = DispatchQueue(label: "vision.queue")
    
    override init() {
        super.init()
        setupLocationManager()
        loadSampleData()
    }
    
    func startDetection() {
        isDetecting = true
        locationManager.startUpdatingLocation()
    }
    
    func stopDetection() {
        isDetecting = false
        locationManager.stopUpdatingLocation()
    }
    
    func processFrame(_ frame: ARFrame) {
        guard isDetecting else { return }
        
        visionQueue.async { [weak self] in
            self?.performBuildingDetection(frame)
            self?.updateAmenityPositions(frame)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func performBuildingDetection(_ frame: ARFrame) {
        // Simulate building detection using Vision framework
        // In a real implementation, you would use ML models for building recognition
        
        DispatchQueue.main.async { [weak self] in
            // Sample detected buildings
            self?.detectedBuildings = [
                DetectedBuilding(
                    name: "Office Complex",
                    type: "Commercial",
                    screenPosition: CGPoint(x: 200, y: 300),
                    distance: 150,
                    confidence: 0.85
                ),
                DetectedBuilding(
                    name: "Residential Tower",
                    type: "Residential",
                    screenPosition: CGPoint(x: 300, y: 250),
                    distance: 200,
                    confidence: 0.92
                )
            ]
        }
    }
    
    private func updateAmenityPositions(_ frame: ARFrame) {
        // Update screen positions of amenities based on camera movement
        DispatchQueue.main.async { [weak self] in
            // This would calculate real positions based on GPS and AR tracking
        }
    }
    
    private func loadSampleData() {
        // Sample amenities data
        nearbyAmenities = [
            LocalAmenity(
                name: "Starbucks Coffee",
                category: .cafe,
                screenPosition: CGPoint(x: 100, y: 400),
                distance: 120,
                address: "123 Main St",
                rating: 4.2,
                openingHours: "6:00 AM - 10:00 PM"
            ),
            LocalAmenity(
                name: "Central Park",
                category: .park,
                screenPosition: CGPoint(x: 250, y: 350),
                distance: 300,
                address: "Central Park Ave",
                rating: 4.8,
                openingHours: "24 hours"
            ),
            LocalAmenity(
                name: "Metro Station",
                category: .transport,
                screenPosition: CGPoint(x: 150, y: 500),
                distance: 80,
                address: "Metro Plaza",
                rating: nil,
                openingHours: "5:00 AM - 12:00 AM"
            )
        ]
        
        // Sample context information
        contextInfo = [
            ContextInfo(
                title: "Neighborhood Score",
                description: "Walkability: 85/100\nSafety: 92/100",
                icon: "chart.bar"
            ),
            ContextInfo(
                title: "Property Values",
                description: "Avg: $450/sqft\nTrend: +5.2%",
                icon: "house"
            ),
            ContextInfo(
                title: "Transit Access",
                description: "3 bus lines\n1 metro station",
                icon: "tram"
            )
        ]
    }
}

extension NeighborhoodContextViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Update nearby amenities based on location
        fetchNearbyAmenities(for: location)
    }
    
    private func fetchNearbyAmenities(for location: CLLocation) {
        // In a real implementation, this would query a places API
        // For now, we'll use the sample data
    }
}