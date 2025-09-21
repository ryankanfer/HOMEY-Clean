import SwiftUI

struct VizasVision: View {
    var openChat: (() -> Void)?
    var showAR: () -> Void
    var uploadPhoto: () -> Void

    init(
        openChat: (() -> Void)? = nil,
        showAR: @escaping () -> Void,
        uploadPhoto: @escaping () -> Void
    ) {
        self.openChat = openChat
        self.showAR = showAR
        self.uploadPhoto = uploadPhoto
    }

    var body: some View {
        GroupBox {
            HStack {
                Text("Design Inspiration").font(.headline)
                Spacer()
                Button("Chat") { openChat!() }
            }
            Text("Modern Cozy board ready. Want to see colorways?")
                .foregroundStyle(.secondary)
        }
    }
}
