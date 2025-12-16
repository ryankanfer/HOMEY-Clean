//
//  TRAEDragDrop.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//  Enhanced drag & drop functionality for Paige's doc vault and Drew's Rolodex
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Drag & Drop Types

enum TRAEDragType {
    case document(DocumentItem)
    case contact(ContactItem)
    case folder(FolderItem)
    case image(ImageItem)
    case custom(CustomDragItem)
    
    var typeIdentifier: String {
        switch self {
        case .document: return UTType.fileURL.identifier
        case .contact: return UTType.vCard.identifier
        case .folder: return UTType.folder.identifier
        case .image: return UTType.image.identifier
        case .custom(let item): return item.typeIdentifier
        }
    }
    
    var dragPreview: AnyView {
        switch self {
        case .document(let doc): return AnyView(DocumentDragPreview(document: doc))
        case .contact(let contact): return AnyView(ContactDragPreview(contact: contact))
        case .folder(let folder): return AnyView(FolderDragPreview(folder: folder))
        case .image(let image): return AnyView(ImageDragPreview(image: image))
        case .custom(let item): return AnyView(item.preview)
        }
    }
}

// MARK: - Drag Item Models

struct DocumentItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: String
    let size: Int64
    let dateModified: Date
    let thumbnailURL: URL?
    let fileURL: URL
    let tags: [String]
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct ContactItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let company: String?
    let email: String?
    let phone: String?
    let avatarURL: URL?
    let role: String?
    let tags: [String]
}

struct FolderItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let itemCount: Int
    let dateCreated: Date
    let color: String
    let icon: String
}

struct ImageItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let imageURL: URL
    let thumbnailURL: URL?
    let dimensions: CGSize
    let fileSize: Int64
}

protocol CustomDragItem {
    var id: UUID { get }
    var typeIdentifier: String { get }
    var preview: AnyView { get }
    var data: Data { get }
}

// MARK: - Drop Zone Types

enum TRAEDropZoneType {
    case vault(VaultZone)
    case rolodex(RolodexZone)
    case trash
    case archive
    case favorites
    case custom(CustomDropZone)
    
    enum VaultZone {
        case documents, images, archives, recent, favorites
    }
    
    enum RolodexZone {
        case contacts, companies, favorites, groups
    }
    
    var acceptedTypes: [TRAEDragType] {
        switch self {
        case .vault(let zone):
            switch zone {
            case .documents: 
                return [.document(DocumentItem(id: UUID(), name: "", type: "", size: 0, dateModified: Date(), 
                                              thumbnailURL: nil, fileURL: URL(fileURLWithPath: ""), tags: []))]
            case .images: 
                return [.image(ImageItem(id: UUID(), name: "", imageURL: URL(fileURLWithPath: ""), 
                                        thumbnailURL: nil, dimensions: .zero, fileSize: 0))]
            case .archives, .recent, .favorites: 
                let doc = DocumentItem(id: UUID(), name: "", type: "", size: 0, dateModified: Date(), 
                                      thumbnailURL: nil, fileURL: URL(fileURLWithPath: ""), tags: [])
                let folder = FolderItem(id: UUID(), name: "", itemCount: 0, dateCreated: Date(), color: "", icon: "")
                return [.document(doc), .folder(folder)]
            }
        case .rolodex(let zone):
            switch zone {
            case .contacts, .companies, .favorites, .groups: 
                return [.contact(ContactItem(id: UUID(), name: "", company: nil, email: nil, 
                                           phone: nil, avatarURL: nil, role: nil, tags: []))]
            }
        case .trash, .archive, .favorites:
            let doc = DocumentItem(id: UUID(), name: "", type: "", size: 0, dateModified: Date(), 
                                  thumbnailURL: nil, fileURL: URL(fileURLWithPath: ""), tags: [])
            let contact = ContactItem(id: UUID(), name: "", company: nil, email: nil, 
                                    phone: nil, avatarURL: nil, role: nil, tags: [])
            let folder = FolderItem(id: UUID(), name: "", itemCount: 0, dateCreated: Date(), color: "", icon: "")
            return [.document(doc), .contact(contact), .folder(folder)]
        case .custom(let zone):
            return zone.acceptedTypes
        }
    }
    
    var dropFeedback: TRAEHapticType {
        switch self {
        case .vault: return .medium
        case .rolodex: return .light
        case .trash: return .heavy
        case .archive: return .medium
        case .favorites: return .success
        case .custom(let zone): return zone.hapticFeedback
        }
    }
}

protocol CustomDropZone {
    var id: UUID { get }
    var acceptedTypes: [TRAEDragType] { get }
    var hapticFeedback: TRAEHapticType { get }
    func handleDrop(_ items: [TRAEDragType]) -> Bool
}

// MARK: - TRAE Draggable View

struct TRAEDraggable<Content: View>: View {
    let dragType: TRAEDragType
    let content: Content
    let onDragStarted: (() -> Void)?
    let onDragEnded: ((Bool) -> Void)?
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var dragScale: CGFloat = 1.0
    @State private var dragRotation: Double = 0
    @State private var dragOpacity: Double = 1.0
    
    init(
        dragType: TRAEDragType,
        onDragStarted: (() -> Void)? = nil,
        onDragEnded: ((Bool) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.dragType = dragType
        self.onDragStarted = onDragStarted
        self.onDragEnded = onDragEnded
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(dragScale)
            .rotationEffect(.degrees(dragRotation))
            .opacity(dragOpacity)
            .offset(dragOffset)
            .draggable(dragType.typeIdentifier) {
                dragType.dragPreview
                    .scaleEffect(0.8)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .onDrag {
                startDragAnimation()
                return NSItemProvider(object: dragData())
            }
            .simultaneousGesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            onDragStarted?()
                            TRAEHapticManager.shared.trigger(context: .navigation(action: .drag))
                        }
                        
                        dragOffset = value.translation
                        
                        // Dynamic scaling based on drag distance
                        let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        dragScale = max(0.8, 1.0 - distance / 1000)
                        
                        // Subtle rotation based on horizontal movement
                        dragRotation = Double(value.translation.width / 20)
                    }
                    .onEnded { value in
                        endDragAnimation()
                        isDragging = false
                        onDragEnded?(false) // Will be updated by drop zone
                    }
            )
    }
    
    private func startDragAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            dragScale = 1.05
            dragOpacity = 0.9
        }
    }
    
    private func endDragAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            dragOffset = .zero
            dragScale = 1.0
            dragRotation = 0
            dragOpacity = 1.0
        }
    }
    
    private func dragData() -> NSString {
        switch dragType {
        case .document(let doc):
            return NSString(string: doc.fileURL.absoluteString)
        case .contact(let contact):
            if let data = try? JSONEncoder().encode(contact),
               let string = String(data: data, encoding: .utf8) {
                return NSString(string: string)
            }
        case .folder(let folder):
            if let data = try? JSONEncoder().encode(folder),
               let string = String(data: data, encoding: .utf8) {
                return NSString(string: string)
            }
        case .image(let image):
            return NSString(string: image.imageURL.absoluteString)
        case .custom(let item):
            if let string = String(data: item.data, encoding: .utf8) {
                return NSString(string: string)
            }
        }
        return NSString(string: "")
    }
}

// MARK: - TRAE Drop Zone

struct TRAEDropZone<Content: View>: View {
    let dropZoneType: TRAEDropZoneType
    let content: Content
    let onDrop: (([TRAEDragType]) -> Bool)?
    
    @State private var isDropTarget: Bool = false
    @State private var dropScale: CGFloat = 1.0
    @State private var dropGlow: Double = 0.0
    @State private var dropBorderWidth: CGFloat = 0
    @State private var dropParticles: [DropParticle] = []
    
    init(
        dropZoneType: TRAEDropZoneType,
        onDrop: (([TRAEDragType]) -> Bool)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.dropZoneType = dropZoneType
        self.onDrop = onDrop
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .scaleEffect(dropScale)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: isDropTarget ? [.blue, .purple] : [.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: dropBorderWidth
                        )
                        .shadow(color: .blue.opacity(dropGlow), radius: 10)
                )
            
            // Drop particles
            ForEach(dropParticles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onDrop(of: [dropZoneType.acceptedTypes.first?.typeIdentifier ?? UTType.data.identifier], isTargeted: $isDropTarget) { providers in
            handleDrop(providers)
        }
        .onChange(of: isDropTarget) { _, newValue in
            if newValue {
                startDropTargetAnimation()
            } else {
                endDropTargetAnimation()
            }
        }
    }
    
    private func startDropTargetAnimation() {
        // Haptic feedback for entering drop zone
        TRAEHapticManager.shared.trigger(.light)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            dropScale = 1.05
            dropGlow = 0.6
            dropBorderWidth = 2
        }
        
        // Generate drop particles
        generateDropParticles()
    }
    
    private func endDropTargetAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            dropScale = 1.0
            dropGlow = 0.0
            dropBorderWidth = 0
        }
        
        // Clear particles
        dropParticles.removeAll()
    }
    
    private func generateDropParticles() {
        dropParticles = (0..<8).map { i in
            let angle = Double(i) * (2 * .pi / 8)
            let radius: CGFloat = 60
            
            return DropParticle(
                id: UUID(),
                position: CGPoint(
                    x: 100 + CGFloat(cos(angle)) * radius,
                    y: 100 + CGFloat(sin(angle)) * radius
                ),
                size: CGFloat.random(in: 3...6),
                color: [.blue, .purple, .cyan].randomElement() ?? .blue,
                opacity: 0.8,
                scale: 0.1
            )
        }
        
        // Animate particles
        for i in dropParticles.indices {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(i) * 0.05)) {
                dropParticles[i].scale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                dropParticles[i].opacity = 0.3
            }
        }
    }
    
    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        // Trigger drop haptic
        TRAEHapticManager.shared.trigger(dropZoneType.dropFeedback)
        TRAEHapticManager.shared.trigger(context: .navigation(action: .drop))
        
        // Success animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            dropScale = 1.1
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            dropScale = 1.0
        }
        
        // Process drop items
        var dragItems: [TRAEDragType] = []
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                    // Process file URL
                }
            }
        }
        
        return onDrop?(dragItems) ?? true
    }
}

struct DropParticle {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
    var scale: CGFloat
}

// MARK: - Drag Previews

struct DocumentDragPreview: View {
    let document: DocumentItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Document icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue.gradient)
                    .frame(width: 40, height: 50)
                
                Image(systemName: documentIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(document.formattedSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .frame(width: 200)
    }
    
    private var documentIcon: String {
        switch document.type.lowercased() {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "rectangle.fill.on.rectangle.fill"
        case "txt": return "doc.plaintext.fill"
        default: return "doc.fill"
        }
    }
}

struct ContactDragPreview: View {
    let contact: ContactItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: contact.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(.gray.gradient)
                    .overlay(
                        Text(contact.name.prefix(1))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if let company = contact.company {
                    Text(company)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .frame(width: 200)
    }
}

struct FolderDragPreview: View {
    let folder: FolderItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Folder icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: folder.color).gradient)
                    .frame(width: 40, height: 32)
                
                Image(systemName: folder.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(folder.itemCount) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .frame(width: 200)
    }
}

struct ImageDragPreview: View {
    let image: ImageItem
    
    var body: some View {
        VStack(spacing: 8) {
            // Image thumbnail
            AsyncImage(url: image.thumbnailURL ?? image.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.gradient)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(image.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .frame(width: 120)
    }
}

// MARK: - Paige's Doc Vault

struct PaigeDocVault: View {
    @State private var documents: [DocumentItem] = sampleDocuments
    @State private var selectedFolder: TRAEDropZoneType.VaultZone = .documents
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Paige's Document Vault")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Add Document") {
                    // Add document action
                }
                .traeButtonStyle()
            }
            
            // Folder tabs
            HStack(spacing: 16) {
                ForEach([TRAEDropZoneType.VaultZone.documents, .images, .archives, .recent, .favorites], id: \.self) { folder in
                    Button(folderName(folder)) {
                        selectedFolder = folder
                    }
                    .traeButtonStyle(isDestructive: false)
                }
            }
            
            // Document grid with drop zones
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(documents) { document in
                        TRAEDraggable(dragType: .document(document)) {
                            DocumentCard(document: document)
                        }
                    }
                }
                .padding()
            }
            
            // Drop zones
            HStack(spacing: 16) {
                TRAEDropZone(dropZoneType: .vault(.favorites)) {
                    DropZoneCard(title: "Favorites", icon: "heart.fill", color: .red)
                }
                
                TRAEDropZone(dropZoneType: .vault(.archives)) {
                    DropZoneCard(title: "Archive", icon: "archivebox.fill", color: .blue)
                }
                
                TRAEDropZone(dropZoneType: .trash) {
                    DropZoneCard(title: "Trash", icon: "trash.fill", color: .gray)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func folderName(_ folder: TRAEDropZoneType.VaultZone) -> String {
        switch folder {
        case .documents: return "Documents"
        case .images: return "Images"
        case .archives: return "Archives"
        case .recent: return "Recent"
        case .favorites: return "Favorites"
        }
    }
}

// MARK: - Drew's Rolodex

struct DrewRolodex: View {
    @State private var contacts: [ContactItem] = sampleContacts
    @State private var selectedGroup: TRAEDropZoneType.RolodexZone = .contacts
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Drew says Hi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Add Contact") {
                    // Add contact action
                }
                .traeButtonStyle()
            }
            
            // Group tabs
            HStack(spacing: 16) {
                ForEach([TRAEDropZoneType.RolodexZone.contacts, .companies, .favorites, .groups], id: \.self) { group in
                    Button(groupName(group)) {
                        selectedGroup = group
                    }
                    .traeButtonStyle(isDestructive: false)
                }
            }
            
            // Contact grid with drop zones
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(contacts) { contact in
                        TRAEDraggable(dragType: .contact(contact)) {
                            ContactCard(contact: contact)
                        }
                    }
                }
                .padding()
            }
            
            // Drop zones
            HStack(spacing: 16) {
                TRAEDropZone(dropZoneType: .rolodex(.favorites)) {
                    DropZoneCard(title: "Favorites", icon: "star.fill", color: .yellow)
                }
                
                TRAEDropZone(dropZoneType: .rolodex(.groups)) {
                    DropZoneCard(title: "Groups", icon: "person.3.fill", color: .green)
                }
                
                TRAEDropZone(dropZoneType: .archive) {
                    DropZoneCard(title: "Archive", icon: "archivebox.fill", color: .blue)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func groupName(_ group: TRAEDropZoneType.RolodexZone) -> String {
        switch group {
        case .contacts: return "Contacts"
        case .companies: return "Companies"
        case .favorites: return "Favorites"
        case .groups: return "Groups"
        }
    }
}

// MARK: - Card Views

struct DocumentCard: View {
    let document: DocumentItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Document preview
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.gradient)
                .frame(height: 120)
                .overlay(
                    Image(systemName: "doc.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(document.formattedSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Tags
                if !document.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(document.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.blue.opacity(0.2), in: Capsule())
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ContactCard: View {
    let contact: ContactItem
    
    var body: some View {
        VStack(spacing: 12) {
            // Avatar
            AsyncImage(url: contact.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(.gray.gradient)
                    .overlay(
                        Text(contact.name.prefix(1))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if let company = contact.company {
                    Text(company)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let role = contact.role {
                    Text(role)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct DropZoneCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(width: 80, height: 80)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Extensions

// MARK: - Sample Data

let sampleDocuments: [DocumentItem] = [
    DocumentItem(id: UUID(), name: "Project Proposal.pdf", type: "pdf", size: 2048000, dateModified: Date(), 
                thumbnailURL: nil, fileURL: URL(fileURLWithPath: "/documents/proposal.pdf"), tags: ["work", "important"]),
    DocumentItem(id: UUID(), name: "Meeting Notes.docx", type: "docx", size: 512000, dateModified: Date(), 
                thumbnailURL: nil, fileURL: URL(fileURLWithPath: "/documents/notes.docx"), tags: ["meeting"]),
    DocumentItem(id: UUID(), name: "Budget Spreadsheet.xlsx", type: "xlsx", size: 1024000, dateModified: Date(), 
                thumbnailURL: nil, fileURL: URL(fileURLWithPath: "/documents/budget.xlsx"), tags: ["finance"])
]

let sampleContacts: [ContactItem] = [
    ContactItem(id: UUID(), name: "John Smith", company: "Tech Corp", email: "john@techcorp.com", phone: "+1-555-0123", avatarURL: nil, role: "CEO", tags: ["client"]),
    ContactItem(id: UUID(), name: "Sarah Johnson", company: "Design Studio", email: "sarah@design.com", phone: "+1-555-0456", avatarURL: nil, role: "Designer", tags: ["partner"]),
    ContactItem(id: UUID(), name: "Mike Wilson", company: "Dev Agency", email: "mike@dev.com", phone: "+1-555-0789", avatarURL: nil, role: "Developer", tags: ["freelancer"])
]

// MARK: - Preview

#Preview {
    TabView {
        PaigeDocVault()
            .tabItem {
                Image(systemName: "folder.fill")
                Text("Doc Vault")
            }
        
        DrewRolodex()
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Rolodex")
            }
    }
}