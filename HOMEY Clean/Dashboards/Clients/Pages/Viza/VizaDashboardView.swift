import SwiftUI

public struct VizaDashboardView: View {
    public init() {}
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Viza").font(.title2.bold())
                Text("Design & vibes").foregroundStyle(.secondary)
                // Drop legacy Viza UI here
                Label("Design inspiration", systemImage: "paintpalette.fill")
                Label("Chat with Viza", systemImage: "message.fill")
                Label("Upload photo", systemImage: "photo.fill.on.rectangle.fill")
            }
            .padding()
        }
    }
}