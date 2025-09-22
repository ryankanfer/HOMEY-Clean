import SwiftUI
import VisionKit
import OSLog

struct ARFeaturesView: View {
    @State private var showingARPropertyVisualization = false
    @State private var showingCameraNeighborhoodContext = false
    @State private var showingARDocumentScanner = false
    @State private var scannedDocuments: [ScannedDocument] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "arkit")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("AR Features")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Experience properties in augmented reality")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Feature Cards
                    VStack(spacing: 16) {
                        // Property Visualization
                        ARFeatureCard(
                            title: "Property Visualization",
                            description: "View furniture placement, room measurements, and staging in AR",
                            icon: "cube.transparent",
                            color: .blue,
                            isAvailable: true
                        ) {
                            Loggers.sheets.info("Presenting Property Visualization")
                            showingARPropertyVisualization = true
                        }
                        
                        // Neighborhood Context
                        ARFeatureCard(
                            title: "Neighborhood Context",
                            description: "Discover local amenities and building information through your camera",
                            icon: "camera.viewfinder",
                            color: .green,
                            isAvailable: true
                        ) {
                            Loggers.sheets.info("Presenting Neighborhood Context")
                            showingCameraNeighborhoodContext = true
                        }
                        
                        // Document Scanner
                        ARFeatureCard(
                            title: "Document Scanner",
                            description: "Scan and organize property documents with advanced AR technology",
                            icon: "doc.viewfinder",
                            color: .orange,
                            isAvailable: VNDocumentCameraViewController.isSupported
                        ) {
                            Loggers.sheets.info("Attempting to present Document Scanner; VisionKit supported: \(VNDocumentCameraViewController.isSupported, privacy: .public)")
                            showingARDocumentScanner = true
                        }
                    }
                    
                    // Tips Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tips for Best AR Experience")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ARTipRow(icon: "lightbulb", text: "Use in well-lit environments")
                            ARTipRow(icon: "iphone", text: "Hold device steady for better tracking")
                            ARTipRow(icon: "move.3d", text: "Move slowly to allow AR to calibrate")
                            ARTipRow(icon: "eye", text: "Point camera at flat surfaces first")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("AR Features")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingARPropertyVisualization, onDismiss: {
            Loggers.sheets.info("Dismissed Property Visualization")
        }) {
            ARPropertyVisualizationView(listing: PropertyListing.sampleListings[0])
        }
        .sheet(isPresented: $showingCameraNeighborhoodContext, onDismiss: {
            Loggers.sheets.info("Dismissed Neighborhood Context")
        }) {
            CameraNeighborhoodContextView()
        }
        .sheet(isPresented: $showingARDocumentScanner, onDismiss: {
            Loggers.sheets.info("Dismissed Document Scanner")
        }) {
            if #available(iOS 16.0, *), VNDocumentCameraViewController.isSupported {
                ARDocumentScannerView(
                    scannedDocuments: $scannedDocuments,
                    isPresented: $showingARDocumentScanner
                ) { document in
                    scannedDocuments.append(document)
                    Loggers.vision.info("Captured document: \(document.documentType.rawValue, privacy: .public) confidence \(document.confidence, privacy: .public)")
                }
            } else {
                FallbackUnavailableView(
                    isPresented: $showingARDocumentScanner,
                    title: "Document Scanner Unavailable",
                    message: "This feature requires iOS 16 or later and a device that supports VisionKit document scanning."
                )
            }
        }
        .onChange(of: showingARDocumentScanner) { _, newValue in
            Loggers.sheets.info("AR Document Scanner visibility changed: \(newValue, privacy: .public)")
        }
        .onChange(of: showingARPropertyVisualization) { _, newValue in
            Loggers.sheets.info("Property Visualization visibility changed: \(newValue, privacy: .public)")
        }
        .onChange(of: showingCameraNeighborhoodContext) { _, newValue in
            Loggers.sheets.info("Neighborhood Context visibility changed: \(newValue, privacy: .public)")
        }
    }
}

struct ARFeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isAvailable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(isAvailable ? color : .gray)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    if !isAvailable {
                        Text("Not available on this device")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}

struct ARTipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    ARFeaturesView()
}