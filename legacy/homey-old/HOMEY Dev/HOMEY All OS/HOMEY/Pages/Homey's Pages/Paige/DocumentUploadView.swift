import SwiftUI
import UniformTypeIdentifiers

struct DocumentUploadView: View {
    @State private var documents: [URL] = []
    @State private var showPicker = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Upload Documents").font(.headline)
            Button("Add Document") { showPicker = true }
                .buttonStyle(.borderedProminent)
            ForEach(documents, id: \.self) { doc in
                Text(doc.lastPathComponent)
            }
        }
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [.pdf, .image, .plainText],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls): documents.append(contentsOf: urls)
            case .failure(let error): print("Picker failed: \(error)")
            }
        }
        .padding(8)
    }
}

