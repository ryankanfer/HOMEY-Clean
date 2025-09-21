//
//  DocumentsView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 9/16/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentsView: View {
    @StateObject var vm: DocumentsViewModel
    @State private var showImporter = false
    @State private var alertMessage: String?

    var body: some View {
        VStack {
            List {
                ForEach(vm.rows) { r in
                    HStack {
                        Text(r.name)
                        Spacer()
                        Text(r.displayStatus)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(color(for: r.displayStatus))
                            )
                    }
                }
            }

            Button(action: { showImporter = true }) {
                Text(vm.isUploading ? "Uploading…" : "Upload")
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isUploading)
            .fileImporter(isPresented: $showImporter,
                          allowedContentTypes: [.pdf, .image, .plainText]) { result in
                switch result {
                case .success(let url):
                    guard let data = try? Data(contentsOf: url) else {
                        let message = "Failed to read data from file."
                        print(message)
                        alertMessage = message
                        return
                    }
                    let mime: String = {
                        if url.pathExtension.lowercased() == "pdf" { return "application/pdf" }
                        if ["png","jpg","jpeg","heic","gif"].contains(url.pathExtension.lowercased()) { return "image/\(url.pathExtension.lowercased())" }
                        return "application/octet-stream"
                    }()
                    Task {
                        do {
                            try await vm.upload(data: data, filename: url.lastPathComponent, mime: mime)
                        } catch {
                            print(error.localizedDescription)
                            alertMessage = error.localizedDescription
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    alertMessage = error.localizedDescription
                }
            }
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
        .task { await vm.refresh() }
    }
    
    private func color(for status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .gray
        case "needs_attention": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
