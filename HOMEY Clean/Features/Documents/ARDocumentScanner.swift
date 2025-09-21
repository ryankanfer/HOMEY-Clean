import SwiftUI
import VisionKit
import Vision
import ARKit
import AVFoundation

@available(iOS 16.0, *)
struct ARDocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedDocuments: [ScannedDocument]
    @Binding var isPresented: Bool
    let onDocumentScanned: (ScannedDocument) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: ARDocumentScannerView
        
        init(_ parent: ARDocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            Task {
                await processScannedDocuments(scan)
            }
            parent.isPresented = false
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.isPresented = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scanning failed: \(error.localizedDescription)")
            parent.isPresented = false
        }
        
        @MainActor
        private func processScannedDocuments(_ scan: VNDocumentCameraScan) async {
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                
                // Perform OCR and document classification
                let scannedDoc = await analyzeDocument(image: image, pageIndex: pageIndex)
                parent.scannedDocuments.append(scannedDoc)
                parent.onDocumentScanned(scannedDoc)
            }
        }
        
        private func analyzeDocument(image: UIImage, pageIndex: Int) async -> ScannedDocument {
            let documentType = await classifyDocument(image: image)
            let extractedText = await extractText(from: image)
            let confidence = await calculateConfidence(for: documentType, text: extractedText)
            
            return ScannedDocument(
                id: UUID(),
                image: image,
                pageIndex: pageIndex,
                documentType: documentType,
                extractedText: extractedText,
                confidence: confidence,
                scanDate: Date(),
                suggestedVault: suggestVault(for: documentType)
            )
        }
        
        private func classifyDocument(image: UIImage) async -> ARDocumentType {
            guard let cgImage = image.cgImage else { return .unknown }
            
            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            do {
                try handler.perform([request])
                
                if let results = request.results {
                    // Analyze classification results to determine document type
                    return classifyFromVisionResults(results)
                }
            } catch {
                print("Document classification failed: \(error)")
            }
            
            return .unknown
        }
        
        private func extractText(from image: UIImage) async -> String {
            guard let cgImage = image.cgImage else { return "" }
            
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            do {
                try handler.perform([request])
                
                let recognizedStrings = request.results?.compactMap { observation in
                    observation.topCandidates(1).first?.string
                } ?? []
                
                return recognizedStrings.joined(separator: "\n")
            } catch {
                print("Text extraction failed: \(error)")
                return ""
            }
        }
        
        private func calculateConfidence(for documentType: ARDocumentType, text: String) async -> Double {
            // Calculate confidence based on document type keywords and text quality
            let keywords = documentType.keywords
            let foundKeywords = keywords.filter { keyword in
                text.lowercased().contains(keyword.lowercased())
            }
            
            let keywordConfidence = Double(foundKeywords.count) / Double(keywords.count)
            let textQualityConfidence = min(Double(text.count) / 100.0, 1.0) // Normalize text length
            
            return (keywordConfidence + textQualityConfidence) / 2.0
        }
        
        private func classifyFromVisionResults(_ results: [VNClassificationObservation]) -> ARDocumentType {
            // Analyze Vision results and map to document types
            let text = results.compactMap { $0.identifier }.joined(separator: " ").lowercased()
            
            if text.contains("tax") || text.contains("w2") || text.contains("1099") {
                return .tax
            } else if text.contains("bank") || text.contains("statement") {
                return .bankStatement
            } else if text.contains("insurance") || text.contains("policy") {
                return .insurance
            } else if text.contains("employment") || text.contains("pay") || text.contains("salary") {
                return .employment
            } else if text.contains("loan") || text.contains("mortgage") {
                return .loan
            } else if text.contains("id") || text.contains("license") || text.contains("passport") {
                return .identification
            }
            
            return .unknown
        }
        
        private func suggestVault(for documentType: ARDocumentType) -> String {
            switch documentType {
            case .tax:
                return "Tax Documents"
            case .bankStatement:
                return "Financial Documents"
            case .insurance:
                return "Insurance Documents"
            case .employment:
                return "Employment Documents"
            case .loan:
                return "Loan Documents"
            case .identification:
                return "Personal Documents"
            case .unknown:
                return "General Documents"
            }
        }
    }
}

// MARK: - Supporting Models

struct ScannedDocument: Identifiable, Codable {
    let id: UUID
    let image: UIImage
    let pageIndex: Int
    let documentType: ARDocumentType
    let extractedText: String
    let confidence: Double
    let scanDate: Date
    let suggestedVault: String
    
    enum CodingKeys: String, CodingKey {
        case id, pageIndex, documentType, extractedText, confidence, scanDate, suggestedVault
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(pageIndex, forKey: .pageIndex)
        try container.encode(documentType, forKey: .documentType)
        try container.encode(extractedText, forKey: .extractedText)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(scanDate, forKey: .scanDate)
        try container.encode(suggestedVault, forKey: .suggestedVault)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        pageIndex = try container.decode(Int.self, forKey: .pageIndex)
        documentType = try container.decode(ARDocumentType.self, forKey: .documentType)
        extractedText = try container.decode(String.self, forKey: .extractedText)
        confidence = try container.decode(Double.self, forKey: .confidence)
        scanDate = try container.decode(Date.self, forKey: .scanDate)
        suggestedVault = try container.decode(String.self, forKey: .suggestedVault)
        
        // Create a placeholder image for decoded documents
        image = UIImage(systemName: "doc.fill") ?? UIImage()
    }
    
    init(id: UUID, image: UIImage, pageIndex: Int, documentType: ARDocumentType, extractedText: String, confidence: Double, scanDate: Date, suggestedVault: String) {
        self.id = id
        self.image = image
        self.pageIndex = pageIndex
        self.documentType = documentType
        self.extractedText = extractedText
        self.confidence = confidence
        self.scanDate = scanDate
        self.suggestedVault = suggestedVault
    }
}

enum ARDocumentType: String, CaseIterable, Codable {
    case tax = "Tax Document"
    case bankStatement = "Bank Statement"
    case insurance = "Insurance"
    case employment = "Employment"
    case loan = "Loan Document"
    case identification = "ID Document"
    case unknown = "Unknown"
    
    var keywords: [String] {
        switch self {
        case .tax:
            return ["tax", "w2", "w-2", "1099", "irs", "return", "refund"]
        case .bankStatement:
            return ["bank", "statement", "account", "balance", "deposit", "withdrawal"]
        case .insurance:
            return ["insurance", "policy", "coverage", "premium", "claim"]
        case .employment:
            return ["employment", "pay", "salary", "wage", "payroll", "stub"]
        case .loan:
            return ["loan", "mortgage", "credit", "debt", "payment", "interest"]
        case .identification:
            return ["id", "identification", "license", "passport", "social security"]
        case .unknown:
            return []
        }
    }
    
    var icon: String {
        switch self {
        case .tax:
            return "doc.text.fill"
        case .bankStatement:
            return "banknote.fill"
        case .insurance:
            return "shield.fill"
        case .employment:
            return "briefcase.fill"
        case .loan:
            return "house.fill"
        case .identification:
            return "person.crop.rectangle.fill"
        case .unknown:
            return "doc.fill"
        }
    }
    
    var color: String {
        switch self {
        case .tax:
            return "blue"
        case .bankStatement:
            return "green"
        case .insurance:
            return "orange"
        case .employment:
            return "purple"
        case .loan:
            return "red"
        case .identification:
            return "gray"
        case .unknown:
            return "secondary"
        }
    }
}

// MARK: - AR Document Scanner UI

@available(iOS 16.0, *)
struct ARDocumentScannerButton: View {
    @State private var showingScanner = false
    @State private var scannedDocuments: [ScannedDocument] = []
    let onDocumentScanned: (ScannedDocument) -> Void
    
    var body: some View {
        Button(action: {
            showingScanner = true
        }) {
            HStack {
                Image(systemName: "camera.viewfinder")
                    .font(.title2)
                Text("Scan Document")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .sheet(isPresented: $showingScanner) {
            ARDocumentScannerView(
                scannedDocuments: $scannedDocuments,
                isPresented: $showingScanner,
                onDocumentScanned: onDocumentScanned
            )
        }
    }
}

// MARK: - Scanned Document Preview

@available(iOS 16.0, *)
struct ScannedDocumentPreview: View {
    let document: ScannedDocument
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: document.documentType.icon)
                    .foregroundColor(Color(document.documentType.color))
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(document.documentType.rawValue)
                        .font(.headline)
                    Text("Confidence: \(Int(document.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("View") {
                    showingFullScreen = true
                }
                .buttonStyle(.bordered)
            }
            
            if !document.extractedText.isEmpty {
                Text(document.extractedText.prefix(100) + (document.extractedText.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Text("Suggested: \(document.suggestedVault)")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(document.scanDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingFullScreen) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Image(uiImage: document.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Extracted Text")
                                .font(.headline)
                            
                            Text(document.extractedText)
                                .font(.body)
                                .textSelection(.enabled)
                        }
                    }
                    .padding()
                }
                .navigationTitle(document.documentType.rawValue)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingFullScreen = false
                        }
                    }
                }
            }
        }
    }
}