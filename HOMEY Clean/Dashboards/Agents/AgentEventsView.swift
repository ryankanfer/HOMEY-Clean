//
//  AgentEventsView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

// AgentEventsView.swift
import SwiftUI

public struct AgentEventsView: View {
    @State private var events: [JourneyEvent] = []
    @State private var loading = true
    @State private var errorText: String?

    private let userJWT: String
    private let service: SupabaseEventsService

    public init(userJWT: String) {
        self.userJWT = userJWT
        service = SupabaseEventsService()
    }

    public var body: some View {
        ZStack {
            GradientBackground(theme: heroTheme(for: .drew))
            List {
                if loading { ProgressView().listRowSeparator(.hidden) }
                if let e = errorText { Text(e).foregroundStyle(.red) }
                ForEach(events) { ev in
                    HStack(spacing: 12) {
                        Circle().frame(width: 10, height: 10)
                        VStack(alignment: .leading, spacing: 2) {
                            Text((ev.kind ?? "event").capitalized).bold()
                            Text(ev.created_at).font(.caption).foregroundStyle(.secondary)
                            if let n = ev.note, !n.isEmpty { Text(n).font(.footnote) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Journey Events")
            .task { await load() }
        }
    }

    private func load() async {
        loading = true; defer { loading = false }
        do { events = try await service.fetchRecent(userJWT: userJWT) } catch { errorText = "Couldn’t load events." }
    }
}
