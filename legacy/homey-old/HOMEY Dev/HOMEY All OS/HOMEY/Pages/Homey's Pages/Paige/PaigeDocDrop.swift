import SwiftUI
import UniformTypeIdentifiers

struct PaigeDocDrop: View {
    let classifier: any DocClassifier
    @State private var lastResult: DocCategory? = nil
    @State private var isTargeted = false

    // default so you can call PaigeDocDrop() with no args
    init(classifier: any DocClassifier = SmartDocClassifier()) {
        self.classifier = classifier
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Smart Document Upload").font(.headline)
            Text("Drop files or paste text — Paige will sort them.")
                .font(.footnote).foregroundStyle(.secondary)

            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(isTargeted ? .purple : .secondary)
                .frame(height: 120)
                .overlay(Text("Drop here").foregroundStyle(.secondary))
                .onDrop(of: [UTType.plainText], isTargeted: $isTargeted) { providers in
                    guard let provider = providers.first else { return false }
                    _ = provider.loadDataRepresentation(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                        guard let data, let str = String(data: data, encoding: .utf8) else { return }
                        Task { // hop off-main; update state on main
                            let result = await classifier.classify(text: str)
                            await MainActor.run { self.lastResult = result }
                        }
                    }
                    return true
                }

            if let r = lastResult {
                Label("Detected: \(r.rawValue)", systemImage: "sparkles")
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
        }
        .padding(.vertical, 4)
    }
}
