// DrewsDirectory.swift
// Placeholder for Drew's directory of professionals module
import SwiftUI

struct DrewsDirectory: View {
    var openChat: () -> Void
    var contactVendor: () -> Void = {}
    var body: some View {
        GroupBox {
            HStack {
                Text("Trusted Pros").font(.headline)
                Spacer()
                Button("Chat") { openChat() }
            }
            VStack(alignment: .leading, spacing: 8) {
                Label("Lenders", systemImage: "phone")
                Label("Inspectors", systemImage: "wrench.and.screwdriver")
                Label("Movers", systemImage: "truck.box")
            }
            .foregroundStyle(.secondary)
        }
    }
}
