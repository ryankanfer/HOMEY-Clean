//
//  LogTailView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


struct LogTailView: View {
    @State private var lines: [String] = []
    var body: some View {
        SectionCard(title: "Logs", subtitle: "Recent events") {
            ScrollView { LazyVStack(alignment: .leading) {
                ForEach(lines.suffix(100), id: \.self) { Text($0).font(.caption.monospaced()).frame(maxWidth: .infinity, alignment: .leading) }
            }}.frame(height: 160)
            HStack {
                Button("Refresh") { lines = HomeyLog.shared.recent() }
                Spacer()
                Button("Copy") { UIPasteboard.general.string = lines.joined(separator: "\n") }
            }
        }
        .onAppear { lines = HomeyLog.shared.recent() }
    }
}