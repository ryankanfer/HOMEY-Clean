import SwiftUI

public struct PaigeDashboardView: View {
    public init() {}
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Paige").font(.title2.bold())
                Text("Paperwork & tasks").foregroundStyle(.secondary)
                // Drop legacy Paige UI here
                Label("Document readiness", systemImage: "checkmark.seal.fill")
                Label("Smart upload", systemImage: "square.and.arrow.up.fill")
                Label("Documents", systemImage: "doc.text.fill")
            }
            .padding()
        }
    }
}