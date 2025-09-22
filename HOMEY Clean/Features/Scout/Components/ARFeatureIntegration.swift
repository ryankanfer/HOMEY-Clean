import SwiftUI
import VisionKit
import OSLog

struct ARFeatureIntegration: View {
    @State private var showingARPropertyVisualization = false
    @State private var showingCameraNeighborhoodContext = false
    @State private var showingARDocumentScanner = false
    @State private var scannedDocuments: [ScannedDocument] = []
    
    let selectedListing: PropertyListing?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("AR Features")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                // AR Property Visualization
                ARFeatureButton(
                    title: "Property AR",
                    icon: "cube.transparent",
                    color: .blue,
                    isEnabled: selectedListing != nil
                ) {
                    Loggers.sheets.info("Presenting Property Visualization (inline)")
                    showingARPropertyVisualization = true
                }
                
                // Camera Neighborhood Context
                ARFeatureButton(
                    title: "Neighborhood",
                    icon: "camera.viewfinder",
                    color: .green,
                    isEnabled: true
                ) {
                    Loggers.sheets.info("Presenting Neighborhood Context (inline)")
                    showingCameraNeighborhoodContext = true
                }
                
                // AR Document Scanner
                ARFeatureButton(
                    title: "Documents",
                    icon: "doc.viewfinder",
                    color: .orange,
                    isEnabled: VNDocumentCameraViewController.isSupported
                ) {
                    Loggers.sheets.info("Attempting to present Document Scanner (inline); supported: \(VNDocumentCameraViewController.isSupported, privacy: .public)")
                    showingARDocumentScanner = true
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showingARPropertyVisualization, onDismiss: {
            Loggers.sheets.info("Dismissed Property Visualization (inline)")
        }) {
            if let listing = selectedListing {
                ARPropertyVisualizationView(listing: listing)
            }
        }
        .sheet(isPresented: $showingCameraNeighborhoodContext, onDismiss: {
            Loggers.sheets.info("Dismissed Neighborhood Context (inline)")
        }) {
            CameraNeighborhoodContextView()
        }
        .sheet(isPresented: $showingARDocumentScanner, onDismiss: {
            Loggers.sheets.info("Dismissed Document Scanner (inline)")
        }) {
            if #available(iOS 16.0, *), VNDocumentCameraViewController.isSupported {
                ARDocumentScannerView(
                    scannedDocuments: $scannedDocuments,
                    isPresented: $showingARDocumentScanner
                ) { document in
                    Loggers.vision.info("Captured document (inline): \(document.documentType.rawValue, privacy: .public) confidence \(document.confidence, privacy: .public)")
                }
            } else {
                FallbackUnavailableView(
                    isPresented: $showingARDocumentScanner,
                    title: "Document Scanner Unavailable",
                    message: "This feature requires iOS 16 or later and a device with VisionKit scanning support."
                )
            }
        }
    }
}

struct ARFeatureButton: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isEnabled ? color : .gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isEnabled ? .white : .gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEnabled ? color.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - AR Quick Actions for Property Cards

struct ARQuickActions: View {
    let listing: PropertyListing
    @State private var showingARVisualization = false
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                showingARVisualization = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "cube.transparent")
                        .font(.caption)
                    Text("AR View")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
            
            Button(action: {
                // Quick measure action
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "ruler")
                        .font(.caption)
                    Text("Measure")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .sheet(isPresented: $showingARVisualization) {
            ARPropertyVisualizationView(listing: listing)
        }
    }
}

// MARK: - AR Navigation Menu

struct ARNavigationMenu: View {
    @State private var showingARPropertyVisualization = false
    @State private var showingCameraNeighborhoodContext = false
    @State private var showingARDocumentScanner = false
    @State private var scannedDocuments: [ScannedDocument] = []
    
    let selectedListing: PropertyListing?
    
    var body: some View {
        Menu {
            Button(action: {
                Loggers.sheets.info("Presenting Property Visualization (menu)")
                showingARPropertyVisualization = true
            }) {
                Label("Property Visualization", systemImage: "cube.transparent")
            }
            .disabled(selectedListing == nil)
            
            Button(action: {
                Loggers.sheets.info("Presenting Neighborhood Context (menu)")
                showingCameraNeighborhoodContext = true
            }) {
                Label("Neighborhood Context", systemImage: "camera.viewfinder")
            }
            
            Button(action: {
                Loggers.sheets.info("Attempting to present Document Scanner (menu); supported: \(VNDocumentCameraViewController.isSupported, privacy: .public)")
                showingARDocumentScanner = true
            }) {
                Label("Document Scanner", systemImage: "doc.viewfinder")
            }
            .disabled(!VNDocumentCameraViewController.isSupported)
            
        } label: {
            Image(systemName: "arkit")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .sheet(isPresented: $showingARPropertyVisualization) {
            if let listing = selectedListing {
                ARPropertyVisualizationView(listing: listing)
            }
        }
        .sheet(isPresented: $showingCameraNeighborhoodContext) {
            CameraNeighborhoodContextView()
        }
        .sheet(isPresented: $showingARDocumentScanner) {
            if #available(iOS 16.0, *), VNDocumentCameraViewController.isSupported {
                ARDocumentScannerView(
                    scannedDocuments: $scannedDocuments,
                    isPresented: $showingARDocumentScanner
                ) { document in
                    Loggers.vision.info("Captured document (menu): \(document.documentType.rawValue, privacy: .public) confidence \(document.confidence, privacy: .public)")
                }
            } else {
                FallbackUnavailableView(
                    isPresented: $showingARDocumentScanner,
                    title: "Document Scanner Unavailable",
                    message: "This feature requires iOS 16 or later and a device with VisionKit scanning support."
                )
            }
        }
    }
}

// MARK: - AR Feature Discovery Card

struct ARFeatureDiscoveryCard: View {
    @State private var currentFeatureIndex = 0
    @State private var showingDemo = false
    
    let features = [
        ARFeatureInfo(
            title: "Property Visualization",
            description: "See furniture placement and room measurements in AR",
            icon: "cube.transparent",
            color: .blue
        ),
        ARFeatureInfo(
            title: "Neighborhood Context",
            description: "Discover local amenities and building information",
            icon: "camera.viewfinder",
            color: .green
        ),
        ARFeatureInfo(
            title: "Document Scanner",
            description: "Scan and organize property documents with AR",
            icon: "doc.viewfinder",
            color: .orange
        )
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("New AR Features")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Try Now") {
                    showingDemo = true
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
            
            TabView(selection: $currentFeatureIndex) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    ARFeaturePreview(feature: feature)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 120)
            
            // Custom page indicator
            HStack(spacing: 8) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentFeatureIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentFeatureIndex)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showingDemo) {
            ARFeatureDemoView(features: features)
        }
    }
}

struct ARFeatureInfo {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct ARFeaturePreview: View {
    let feature: ARFeatureInfo
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title)
                .foregroundColor(feature.color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(feature.color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ARFeatureDemoView: View {
    let features: [ARFeatureInfo]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        ARFeatureDemoCard(feature: feature)
                    }
                }
                .padding()
            }
            .navigationTitle("AR Features")
            .navigationBarTitleDisplayMode(.large)
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

struct ARFeatureDemoCard: View {
    let feature: ARFeatureInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: feature.icon)
                    .font(.largeTitle)
                    .foregroundColor(feature.color)
                
                VStack(alignment: .leading) {
                    Text(feature.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(feature.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Demo content placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(feature.color.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: feature.icon)
                            .font(.system(size: 40))
                            .foregroundColor(feature.color.opacity(0.5))
                        
                        Text("Demo Preview")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}