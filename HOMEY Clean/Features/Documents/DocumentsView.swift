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

    var body: some View {
        VStack {
            List {
                ForEach(0..<vm.rows.count, id: \.self) { i in
                    let r = vm.rows[i]
                    HStack {
                        Text((r["name"] as? String) ?? "Untitled")
                        Spacer()
                        Text((r["status"] as? String) ?? "pending")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            Button(vm.isUploading ? "Uploading…" : "Upload")
                .buttonStyle(.borderedProminent)
                .disabled(vm.isUploading)
                .onTapGesture { showImporter = true }
                .fileImporter(isPresented: $showImporter,
                              allowedContentTypes: [.pdf, .image, .plainText]) { result in
                    guard case .success(let url) = result,
                          let data = try? Data(contentsOf: url) else { return }
                    let mime: String = {
                        if url.pathExtension.lowercased() == "pdf" { return "application/pdf" }
                        if ["png","jpg","jpeg","heic","gif"].contains(url.pathExtension.lowercased()) { return "image/\(url.pathExtension.lowercased())" }
                        return "application/octet-stream"
                    }()
                    Task { await vm.upload(data: data, filename: url.lastPathComponent, mime: mime) }
                }
        }
        .navigationTitle("Documents")
        .task { await vm.refresh() }
    }
}