// AgentDashboardView.swift
import Supabase
import SwiftUI

enum TaskFilter: String, CaseIterable { case to_do = "To-do", doing = "Doing", done = "Done" }
enum ScopeFilter: String, CaseIterable { case all = "All", mine = "Clients" }

enum AgentFilter: String, CaseIterable, Identifiable { case all, clientsOnly, hasEmail
    var id: String { rawValue }
    var label: String {
        switch self { case .all: "All"; case .clientsOnly: "Clients"; case .hasEmail: "Has Email" }
    }
}

// Use ProfileRecord from ProfilesRepository instead of custom AgentClientProfile
typealias AgentClientProfile = ProfileRecord

protocol ProfileServiceType {
    func fetchClients() async throws -> [ProfileRecord]
}

#if canImport(Foundation)
    final class SupabaseProfileService: ProfileServiceType {
        private let profilesRepository: ProfilesRepository
        
        @MainActor
        init() {
            self.profilesRepository = ProfilesRepository()
        }

        func fetchClients() async throws -> [ProfileRecord] {
            // Fetch clients assigned to the current agent using agent_client_links
            return try await profilesRepository.fetchClientProfiles()
        }
    }
#endif

final class MockProfileService: ProfileServiceType {
    func fetchClients() async throws -> [ProfileRecord] {
        // Return mock ProfileRecord data for testing
        return [
            ProfileRecord(
                id: UUID(),
                email: "client1@example.com",
                fullName: "Alex Rivera",
                role: "client",
                clientSegment: "buyer",
                createdAt: Date(),
                updatedAt: Date(),
                avatarUrl: nil,
                phoneNumber: "+1234567890",
                preferredComms: "email",
                workingWithAgent: true,
                firstName: "Alex",
                lastName: "Rivera",
                agentId: nil
            ),
            ProfileRecord(
                id: UUID(),
                email: "client2@example.com",
                fullName: "Jamie Cole",
                role: "client",
                clientSegment: "renter",
                createdAt: Date(),
                updatedAt: Date(),
                avatarUrl: nil,
                phoneNumber: "+1234567891",
                preferredComms: "sms",
                workingWithAgent: true,
                firstName: "Jamie",
                lastName: "Cole",
                agentId: nil
            )
        ]
    }
}

public struct AgentDashboardView: View {
    let client: SupabaseClient
    let projectURL: URL

    @State private var clients: [ProfileRecord] = []
    @State private var loading = true
    @State private var errorText: String?
    @State private var filter: AgentFilter = .all
    @State private var isCreatingInvite = false
    @State private var inviteAlert: String?
    @State private var showInviteAlert = false
    @State private var userJWT: String = ""

    @State private var statusFilter: TaskFilter = .to_do
    @State private var scopeFilter: ScopeFilter = .all
    @State private var searchText: String = ""

    // Use SupabaseProfileService for real data
    private let service: ProfileServiceType = SupabaseProfileService()

    public init(client: SupabaseClient, projectURL: URL) {
        self.client = client
        self.projectURL = projectURL
    }

    public var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.background, Theme.surface], startPoint: .top, endPoint: .bottom)
            List {
                Section {
                    // Scope chips (All | Clients)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ScopeFilter.allCases, id: \.self) { s in
                                Chip(selected: scopeFilter == s, title: s.rawValue) { scopeFilter = s }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    // Status segmented control
                    Picker("Status", selection: $statusFilter) {
                        ForEach(TaskFilter.allCases, id: \.self) { t in Text(t.rawValue).tag(t) }
                    }
                    .pickerStyle(.segmented)

                    // Search
                    TextField("Search name or email", text: $searchText)
                }
                if loading { ProgressView().listRowSeparator(.hidden) }
                if let e = errorText { Text(e).foregroundStyle(.red) }
                ForEach(filteredProfiles(clients)) { p in
                    AgentClientRow(
                        clientId: p.id.uuidString,
                        name: p.fullName ?? "(No name)",
                        projectURL: projectURL.absoluteString,
                        userJWT: userJWT
                    )
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.clear)
            .navigationTitle("Agent — Clients")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink("Events") { AgentEventsView(userJWT: userJWT) }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await createInviteCode(maxUses: 3) }
                    } label: {
                        if isCreatingInvite { ProgressView() } else { Text("Invite") }
                    }
                    .disabled(isCreatingInvite)
                }
            }
            .alert("Invite", isPresented: $showInviteAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(inviteAlert ?? "Done")
            }
            .task { await load() }
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            clients = try await service.fetchClients()
            if let session = try? await client.auth.session {
                userJWT = session.accessToken
            }
        } catch {
            errorText = "Failed to load clients."
        }
    }

    private func filteredProfiles(_ items: [ProfileRecord]) -> [ProfileRecord] {
        items
            // scope
            .filter { scopeFilter == .all ? true : $0.role == "client" }
            // search
            .filter { p in
                guard !searchText.isEmpty else { return true }
                let q = searchText.lowercased()
                return (p.fullName ?? "").lowercased().contains(q) || (p.email ?? "").lowercased().contains(q)
            }
        // NOTE: status filter (to_do/doing/done) requires task aggregation; wire later.
    }

    private func createInviteCode(maxUses: Int) async {
        isCreatingInvite = true
        defer { isCreatingInvite = false }
        do {
            let session = try await client.auth.session
            let accessToken = session.accessToken
            guard !accessToken.isEmpty else { throw InviteError.noSession }
            let fnURL = projectURL.appendingPathComponent("functions/v1/charlie_act")
            var req = URLRequest(url: fnURL)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let body: [String: Any] = ["action": "create_invite_code", "payload": ["max_uses": maxUses]]
            req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw InviteError.badResponse }
            if http.statusCode == 200 {
                if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let ok = obj["ok"] as? Bool, ok,
                   let code = obj["code"] as? String {
                    inviteAlert = "Code: \(code)"
                } else if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let err = obj["error"] as? String {
                    throw InviteError.edgeError(err)
                } else {
                    throw InviteError.edgeError("unknown_response")
                }
            } else {
                let text = String(data: data, encoding: .utf8) ?? ""
                throw InviteError.http(http.statusCode, text)
            }
        } catch {
            inviteAlert = "Failed: \(error.localizedDescription)"
        }
        showInviteAlert = true
    }

    private enum InviteError: LocalizedError {
        case noSession
        case badResponse
        case http(Int, String)
        case edgeError(String)
        var errorDescription: String? {
            switch self {
            case .noSession: return "No signed-in session."
            case .badResponse: return "Invalid response."
            case let .http(code, body): return "HTTP \(code): \(body)"
            case let .edgeError(msg): return msg
            }
        }
    }
}

struct Chip: View {
    let selected: Bool
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.subheadline).bold()
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Capsule().fill(selected ? AnyShapeStyle(Theme.primaryAction) : AnyShapeStyle(.ultraThinMaterial)))
                .foregroundStyle(selected ? Theme.white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AgentClientRow

struct AgentClientRow: View {
    let clientId: String
    let name: String
    @State private var sending = false
    @State private var notice: String?

    // Remove anonKey since we're using ProfilesRepository
    let projectURL: String
    let userJWT: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                if let n = notice { Text(n).font(.footnote).foregroundStyle(.secondary) }
            }
            Spacer()
            NavigationLink("Timeline") {
                ClientTimelineView(clientId: clientId, projectURL: projectURL, userJWT: userJWT)
            }
            .buttonStyle(.bordered)

            Button {
                Task { await sendNudge() }
            } label: {
                if sending { ProgressView().controlSize(.small) } else { Label("Nudge", systemImage: "paperplane.fill") }
            }
            .buttonStyle(.borderedProminent)
            .disabled(sending)
        }
        .padCard()
    }

    private func sendNudge() async {
        sending = true; defer { sending = false }
        do {
            let svc = try NudgeService(projectURL: projectURL)
            try await svc.nudge(clientId: clientId, userJWT: userJWT)
            await MainActor.run { notice = "Nudge sent" }
        } catch {
            await MainActor.run { notice = "Nudge failed" }
        }
    }
}

// MARK: - Timeline

struct ClientTimelineView: View {
    let clientId: String
    let projectURL: String
    let userJWT: String

    @State private var events: [JourneyEvent] = []
    @State private var loading = true
    @State private var errorText: String?

    var body: some View {
        Group {
            if loading { ProgressView("Loading…") } else if let e = errorText { Text(e).foregroundStyle(.red) } else if events.isEmpty { Text("No recent events").foregroundStyle(.secondary) } else {
                List(events) { ev in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ev.kind ?? "—").font(.headline)
                        if let n = ev.note, !n.isEmpty { Text(n).font(.subheadline) }
                        Text(formatDate(ev.created_at))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padCard()
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Timeline")
        .task { await load() }
    }

    private func formatDate(_ iso: String?) -> String {
        guard let iso = iso else { return "—" }
        let isoFmt = ISO8601DateFormatter()
        if let d = isoFmt.date(from: iso) {
            let out = DateFormatter()
            out.dateStyle = .medium
            out.timeStyle = .short
            return out.string(from: d)
        }
        return iso
    }

    private func load() async {
        loading = true; defer { loading = false }
        do {
            // Build REST URL:
            // /rest/v1/journey_events?user_id=eq.<id>&select=kind,note,created_at&order=created_at.desc&limit=50
            var comps = URLComponents(string: projectURL)!
            comps.path = comps.path.appending("/rest/v1/journey_events")
            comps.queryItems = [
                URLQueryItem(name: "user_id", value: "eq.\(clientId)"),
                URLQueryItem(name: "select", value: "kind,note,created_at"),
                URLQueryItem(name: "order", value: "created_at.desc"),
                URLQueryItem(name: "limit", value: "50")
            ]
            guard let url = comps.url else { throw URLError(.badURL) }
            var req = URLRequest(url: url)
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            req.addValue("Bearer \(userJWT)", forHTTPHeaderField: "Authorization")
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }
            let evs = try JSONDecoder().decode([JourneyEvent].self, from: data)
            events = evs
        } catch {
            errorText = "Failed to load timeline."
        }
    }
}