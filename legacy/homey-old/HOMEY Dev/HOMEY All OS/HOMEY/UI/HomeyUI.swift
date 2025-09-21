import SwiftUI

// Placeholder for a model used by the GlassScaffold view.
// You should replace this with your actual model.
struct GlassScaffoldItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

// Placeholder for a UI utility struct that seems to be missing.
// This is based on its usage in RootView.swift
enum HomeyUI {
    static let footerItems: [GlassScaffoldItem] = [
        .init(title: "Charlie", icon: "charlie_icon"),
        .init(title: "Paige", icon: "paige_icon"),
        .init(title: "Scout", icon: "scout_icon"),
        .init(title: "Isla", icon: "isla_icon"),
        .init(title: "Viza", icon: "viza_icon"),
        .init(title: "Drew", icon: "drew_icon"),
    ]
}
