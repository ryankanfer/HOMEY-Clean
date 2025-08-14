import SwiftUI

/// Represents a single item in the glass footer.
struct GlassFooterItem: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String

    init(systemImage: String, title: String) {
        self.systemImage = systemImage
        self.title = title
    }
}
