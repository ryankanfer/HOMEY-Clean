import SwiftUI
import UniformTypeIdentifiers

struct PaigesPlace: View {
    var openChat: () -> Void
    var openDocuments: () -> Void

    @State private var uploads: [String] = ["Pre-approval.pdf", "W2-2024.pdf"]
    @State private var searchText: String = ""
    @State private var readiness: Double = 0.0
    @State private var showingUploader = false

    private var filteredUploads: [String] {
        searchText.isEmpty ? uploads : uploads.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Document Readiness
            VStack(alignment: .leading, spacing: 6) {
                Text("Document Readiness").font(.headline)
                ProgressView(value: readiness, total: 100).tint(.purple)
                Text("\(Int(readiness))% complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)

            // Search
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search documents", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .padding(.horizontal, 16)

            // Upload Section
            GroupBox {
                VStack(spacing: 8) {
                    Text("Smart Document Upload").font(.headline)
                    Text("Tap below to upload or scan a document — Paige will sort it for you.")
                        .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)

                    Button { showingUploader = true } label: {
                        VStack {
                            Image(systemName: "tray.and.arrow.up.fill").font(.system(size: 28))
                            Text("Upload a Document").font(.body.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .foregroundColor(.purple.opacity(0.8))
                        )
                    }
                    .tint(.purple)
                }
                .padding()
            }
            .padding(.horizontal, 16)

            // Uploaded documents list
            GroupBox {
                HStack {
                    Text("Documents").font(.headline)
                    Spacer()
                    Button("Open All", action: openDocuments)
                }
                Divider()
                ForEach(filteredUploads, id: \.self) { file in
                    HStack {
                        Image(systemName: "doc.text")
                        Text(file)
                        Spacer()
                        Button("View") { /* open viewer */ }
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 20)

            // Bottom Button (still shows above footer nicely)
        
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
     
        .sheet(isPresented: $showingUploader) {
            Text("Uploader UI goes here")
                .presentationDetents([.medium])
        }
    }
}
