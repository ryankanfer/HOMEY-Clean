//
//  LogTailView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//
import SwiftUI
import UIKit
#if canImport(HomeyCoreLogging)
import HomeyCoreLogging
#endif

struct LogTailView: View {
    @State private var lines: [String] = []

    private func loadLogs() -> [String] {
#if canImport(HomeyCoreLogging)
        return HomeyLog.shared.recent()
#else
        return []
#endif
    }

    var body: some View {
        SectionCard(title: "Logs", subtitle: "Recent events") {
            ScrollView { LazyVStack(alignment: .leading) {
                ForEach(lines.suffix(100), id: \.self) { Text($0).font(.caption.monospaced()).frame(maxWidth: .infinity, alignment: .leading) }
            }}.frame(height: 160)
            HStack {
                Button("Refresh") { lines = loadLogs() }
                Spacer()
                Button("Copy") { UIPasteboard.general.string = lines.joined(separator: "\n") }
            }
        }
        .onAppear { lines = loadLogs() }
    }
}
