import SwiftUI
import UniformTypeIdentifiers

struct EnhancedDocumentsView: View {
    @StateObject var vm: DocumentsViewModel
    @State private var showImporter = false
    @State private var alertMessage: String?
    @State private var uploadProgress: Double = 0.0
    @State private var showUploadProgress = false

    var body: some View {
        VStack(spacing: 0) {
            // Upload Progress Bar (when uploading)
            if showUploadProgress {
                VStack(spacing: 8) {
                    HStack {
                        Text("Uploading document...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(uploadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: uploadProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
                .padding()
                .background(.ultraThinMaterial)
                .transition(.opacity)
            }
            
            // Documents List
            List {
                ForEach(vm.rows) { document in
                    EnhancedDocumentRowView(
                        document: document,
                        onDelete: { vm.deleteDocument(document.id) }
                    )
                }
                .onDelete(perform: deleteDocuments)
            }
            
            // Upload Button
            VStack(spacing: 16) {
                Button(action: { showImporter = true }) {
                    HStack {
                        Image(systemName: vm.isUploading ? "arrow.up.circle" : "plus.circle.fill")
                            .font(.title3)
                        Text(vm.isUploading ? "Uploading..." : "Upload Document")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.isUploading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(vm.isUploading)
                .fileImporter(
                    isPresented: $showImporter,
                    allowedContentTypes: [.pdf, .image, .plainText]
                ) { result in
                    handleFileImport(result)
                }
                
                Text("Supported: PDF, Images (PNG, JPG, HEIC)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.regularMaterial)
        }
        .alert("Error", isPresented: .constant(alertMessage != nil)) {
            Button("Dismiss") {
                alertMessage = nil
            }
        } message: {
            if let message = alertMessage {
                Text(message)
            }
        }
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.large)
        .task { 
            await vm.refresh() 
        }
        .onChange(of: vm.isUploading) { isUploading in
            withAnimation(.easeInOut(duration: 0.3)) {
                showUploadProgress = isUploading
                if isUploading {
                    startUploadProgressAnimation()
                }
            }
        }
    }
    
    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard let data = try? Data(contentsOf: url) else {
                alertMessage = "Failed to read data from file."
                return
            }
            
            let mime = determineMimeType(for: url)
            
            Task {
                do {
                    try await vm.upload(
                        data: data, 
                        filename: url.lastPathComponent, 
                        mime: mime
                    )
                } catch {
                    await MainActor.run {
                        alertMessage = error.localizedDescription
                    }
                }
            }
            
        case .failure(let error):
            alertMessage = error.localizedDescription
        }
    }
    
    private func determineMimeType(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf": return "application/pdf"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "heic": return "image/heic"
        case "gif": return "image/gif"
        default: return "application/octet-stream"
        }
    }
    
    private func startUploadProgressAnimation() {
        uploadProgress = 0.0
        withAnimation(.linear(duration: 2.0)) {
            uploadProgress = 1.0
        }
    }
    
    private func deleteDocuments(offsets: IndexSet) {
        for index in offsets {
            let document = vm.rows[index]
            vm.deleteDocument(document.id)
        }
    }
}

// MARK: - Document Row View
struct EnhancedDocumentRowView: View {
    let document: DocumentListItem
    let onDelete: () -> Void
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let docType = document.docType {
                        Text(docType.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                StatusChip(status: document.displayStatus)
            }
            
            // AI Extraction Preview (if available)
            if let extraction = document.extractedData, !extraction.isEmpty {
                ExtractionPreviewView(extraction: extraction)
            }
            
            // Action buttons
            HStack {
                Button("Details") {
                    showDetails = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                if document.canDelete {
                    Button("Delete") {
                        onDelete()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .foregroundColor(.red)
                }
                
                Text(document.uploadedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showDetails) {
            DocumentDetailView(document: document)
        }
    }
}

// MARK: - Status Chip
struct StatusChip: View {
    let status: String
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(colorForStatus(status))
            )
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "needs_attention": return .red
        case "approved": return .green
        case "rejected": return .gray
        case "processing": return .blue
        default: return .gray
        }
    }
}

// MARK: - Extraction Preview
struct ExtractionPreviewView: View {
    let extraction: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("AI Extracted")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(Array(extraction.prefix(4)), id: \.key) { key, value in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(key.capitalized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(value)")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(.blue.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Document Detail View
struct DocumentDetailView: View {
    let document: DocumentListItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Document Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Document Information")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        InfoRow(label: "Name", value: document.name)
                        InfoRow(label: "Status", value: document.displayStatus)
                        InfoRow(label: "Type", value: document.docType?.displayName ?? "Unknown")
                        InfoRow(label: "Uploaded", value: document.uploadedAt.formatted())
                    }
                    
                    // AI Extraction (if available)
                    if let extraction = document.extractedData, !extraction.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Extracted Data")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(Array(extraction), id: \.key) { key, value in
                                InfoRow(label: key.capitalized, value: "\(value)")
                            }
                        }
                    }
                    
                    // Agent Notes (if any)
                    if let notes = document.agentNotes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Agent Notes")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(notes)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    EnhancedDocumentsView(vm: DocumentsViewModel())
}