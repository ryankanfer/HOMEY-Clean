import SwiftUI

struct Document: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
}

struct DocumentPreviewView: View {
    let documents: [Document] = [
        Document(name: "Pay Stub.pdf", iconName: "doc.richtext"),
        Document(name: "ID Scan.jpg", iconName: "photo"),
        Document(name: "Board Package.zip", iconName: "archivebox"),
    ]
    var body: some View {
        VStack(alignment: .leading) {
            Text("Client Documents").font(.headline)
            List(documents) { doc in
                HStack {
                    Image(systemName: doc.iconName)
                    Text(doc.name)
                    Spacer()
                    Button("Download") {
                        // Download logic stub
                    }
                }
            }
            .frame(height: 140)
        }
    }
}
