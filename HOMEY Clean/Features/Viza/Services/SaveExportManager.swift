//
//  SaveExportManager.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI
import UIKit
import PDFKit

class SaveExportManager: ObservableObject {
    @Published var savedLooks: [SavedLook] = []
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var lastExportedURL: URL?
    
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // MARK: - Save Look Functionality
    
    func saveLook(from session: StylingSession, snapshot: UIImage, onSaved: (() -> Void)? = nil) -> SavedLook {
        let savedLook = SavedLook(
            id: UUID().uuidString,
            name: generateLookName(),
            timestamp: Date(),
            snapshot: snapshot,
            session: session,
            tags: generateTags(from: session)
        )
        
        savedLooks.append(savedLook)
        saveLookToDisk(savedLook)
        
        // Trigger progression tracking
        onSaved?()
        
        return savedLook
    }
    
    func deleteSavedLook(_ look: SavedLook) {
        savedLooks.removeAll { $0.id == look.id }
        deleteLookFromDisk(look)
    }
    
    // MARK: - Snapshot Generation
    
    func captureSnapshot(of view: some View, size: CGSize = CGSize(width: 400, height: 300)) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = UIColor.clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    // MARK: - Before/After Comparison
    
    func createBeforeAfterComparison(before: UIImage, after: UIImage) -> UIImage? {
        let size = CGSize(width: 800, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Before image (left side)
            let beforeRect = CGRect(x: 0, y: 0, width: size.width / 2, height: size.height)
            before.draw(in: beforeRect)
            
            // After image (right side)
            let afterRect = CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height)
            after.draw(in: afterRect)
            
            // Divider line
            UIColor.white.setStroke()
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: size.width / 2, y: 0))
            dividerPath.addLine(to: CGPoint(x: size.width / 2, y: size.height))
            dividerPath.lineWidth = 2
            dividerPath.stroke()
            
            // Labels
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            
            "BEFORE".draw(at: CGPoint(x: 20, y: 20), withAttributes: labelAttributes)
            "AFTER".draw(at: CGPoint(x: size.width / 2 + 20, y: 20), withAttributes: labelAttributes)
        }
    }
    
    // MARK: - PDF Export
    
    func exportToPDF(look: SavedLook, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let pdfURL = try self.generatePDF(for: look)
                
                DispatchQueue.main.async {
                    self.lastExportedURL = pdfURL
                    completion(.success(pdfURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func generatePDF(for look: SavedLook) throws -> URL {
        let pdfMetaData = [
            kCGPDFContextCreator: "HOMEY Clean - Viza Vision Studio",
            kCGPDFContextAuthor: "HOMEY Clean",
            kCGPDFContextTitle: "Vision Moodboard - \(look.name)"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // 8.5" x 11"
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let fileName = "viza_moodboard_\(look.id).pdf"
        let pdfURL = documentsDirectory.appendingPathComponent(fileName)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw PDF content
            drawPDFContent(for: look, in: pageRect, context: context.cgContext)
        }
        
        try data.write(to: pdfURL)
        return pdfURL
    }
    
    private func drawPDFContent(for look: SavedLook, in rect: CGRect, context: CGContext) {
        // Background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Header
        drawPDFHeader(in: rect, context: context)
        
        // Main snapshot
        if let snapshot = look.snapshot {
            let imageRect = CGRect(x: 50, y: 150, width: rect.width - 100, height: 300)
            snapshot.draw(in: imageRect)
        }
        
        // Vision details
        drawStyleDetails(for: look, in: rect, context: context)
        
        // Footer
        drawPDFFooter(in: rect, context: context)
    }
    
    private func drawPDFHeader(in rect: CGRect, context: CGContext) {
        // HOMEY Clean logo area
        let logoRect = CGRect(x: 50, y: 50, width: 100, height: 40)
        context.setFillColor(UIColor.black.cgColor)
        context.fill(logoRect)
        
        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        
        "VIZA VISION STUDIO".draw(at: CGPoint(x: 200, y: 60), withAttributes: titleAttributes)
        
        // Subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.gray
        ]
        
        "Vision Moodboard".draw(at: CGPoint(x: 200, y: 85), withAttributes: subtitleAttributes)
    }
    
    private func drawStyleDetails(for look: SavedLook, in rect: CGRect, context: CGContext) {
        let startY: CGFloat = 480
        let leftColumn: CGFloat = 50
        let rightColumn: CGFloat = 320
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        // Look name
        "Look Name:".draw(at: CGPoint(x: leftColumn, y: startY), withAttributes: titleAttributes)
        look.name.draw(at: CGPoint(x: leftColumn, y: startY + 25), withAttributes: detailAttributes)
        
        // Date created
        "Created:".draw(at: CGPoint(x: rightColumn, y: startY), withAttributes: titleAttributes)
        DateFormatter.localizedString(from: look.timestamp, dateStyle: .medium, timeStyle: .short)
            .draw(at: CGPoint(x: rightColumn, y: startY + 25), withAttributes: detailAttributes)
        
        // Vision preset
        if let preset = look.session.selectedPreset {
            "Vision Preset:".draw(at: CGPoint(x: leftColumn, y: startY + 60), withAttributes: titleAttributes)
            preset.name.draw(at: CGPoint(x: leftColumn, y: startY + 85), withAttributes: detailAttributes)
        }
        
        // Color palette
        if let palette = look.session.selectedPalette {
            "Color Palette:".draw(at: CGPoint(x: rightColumn, y: startY + 60), withAttributes: titleAttributes)
            palette.name.draw(at: CGPoint(x: rightColumn, y: startY + 85), withAttributes: detailAttributes)
        }
        
        // Furniture count
        "Furniture Items:".draw(at: CGPoint(x: leftColumn, y: startY + 120), withAttributes: titleAttributes)
        "\(look.session.furnitureItems.count) pieces".draw(at: CGPoint(x: leftColumn, y: startY + 145), withAttributes: detailAttributes)
    }
    
    private func drawPDFFooter(in rect: CGRect, context: CGContext) {
        let footerY = rect.height - 80
        
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        
        "Created with HOMEY Clean - Viza Vision Studio".draw(
            at: CGPoint(x: 50, y: footerY),
            withAttributes: footerAttributes
        )
        
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        dateString.draw(
            at: CGPoint(x: rect.width - 150, y: footerY),
            withAttributes: footerAttributes
        )
    }
    
    // MARK: - Disk Management
    
    private func saveLookToDisk(_ look: SavedLook) {
        // Save snapshot image
        if let imageData = look.snapshot?.pngData() {
            let imageURL = documentsDirectory.appendingPathComponent("\(look.id)_snapshot.png")
            try? imageData.write(to: imageURL)
        }
        
        // Save look metadata
        let encoder = JSONEncoder()
        if let lookData = try? encoder.encode(look) {
            let lookURL = documentsDirectory.appendingPathComponent("\(look.id)_metadata.json")
            try? lookData.write(to: lookURL)
        }
    }
    
    private func deleteLookFromDisk(_ look: SavedLook) {
        let imageURL = documentsDirectory.appendingPathComponent("\(look.id)_snapshot.png")
        let lookURL = documentsDirectory.appendingPathComponent("\(look.id)_metadata.json")
        
        try? FileManager.default.removeItem(at: imageURL)
        try? FileManager.default.removeItem(at: lookURL)
    }
    
    // MARK: - Helper Methods
    
    private func generateLookName() -> String {
        let adjectives = ["Elegant", "Modern", "Cozy", "Luxurious", "Minimalist", "Bold", "Serene", "Vibrant"]
        let nouns = ["Living", "Space", "Haven", "Retreat", "Sanctuary", "Oasis", "Studio", "Loft"]
        
        let adjective = adjectives.randomElement() ?? "Beautiful"
        let noun = nouns.randomElement() ?? "Space"
        
        return "\(adjective) \(noun)"
    }
    
    private func generateTags(from session: StylingSession) -> [String] {
        var tags: [String] = []
        
        if let preset = session.selectedPreset {
            tags.append(preset.vision.rawValue)
        }
        
        if let palette = session.selectedPalette {
            tags.append(palette.name.lowercased())
        }
        
        if session.furnitureItems.count > 5 {
            tags.append("furnished")
        } else if !session.furnitureItems.isEmpty {
            tags.append("minimal")
        }
        
        return tags
    }
}

// MARK: - SavedLook Model

struct SavedLook: Identifiable, Codable {
    let id: String
    let name: String
    let timestamp: Date
    let snapshot: UIImage?
    let session: StylingSession
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, timestamp, session, tags
    }
    
    init(id: String, name: String, timestamp: Date, snapshot: UIImage?, session: StylingSession, tags: [String]) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.snapshot = snapshot
        self.session = session
        self.tags = tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        session = try container.decode(StylingSession.self, forKey: .session)
        tags = try container.decode([String].self, forKey: .tags)
        
        // Load snapshot from disk
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsDirectory.appendingPathComponent("\(id)_snapshot.png")
        
        if let imageData = try? Data(contentsOf: imageURL) {
            snapshot = UIImage(data: imageData)
        } else {
            snapshot = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(session, forKey: .session)
        try container.encode(tags, forKey: .tags)
    }
}

// MARK: - Export Error

enum ExportError: LocalizedError {
    case snapshotFailed
    case pdfGenerationFailed
    case fileWriteFailed
    
    var errorDescription: String? {
        switch self {
        case .snapshotFailed:
            return "Failed to capture snapshot"
        case .pdfGenerationFailed:
            return "Failed to generate PDF"
        case .fileWriteFailed:
            return "Failed to save file"
        }
    }
}