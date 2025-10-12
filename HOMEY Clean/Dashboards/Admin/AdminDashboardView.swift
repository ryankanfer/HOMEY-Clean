import Supabase
import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject private var flags: FeatureFlags
    private let logger: JourneyLogging?
    let client: SupabaseClient
    let projectURL: URL
    
    @State private var isCreatingInvite = false
    @State private var inviteAlert: String?
    @State private var showInviteAlert = false

    init(client: SupabaseClient, projectURL: URL, logger: JourneyLogging? = nil) {
        self.client = client
        self.projectURL = projectURL
        self.logger = logger
    }

    private enum Role {
        case admin
        case agent
        case client
    }

    @State private var selectedRole: Role = .admin

    // Dummy metrics
    private let cards: [MetricCard] = [
        .init(title: "Active Users", value: "1,284", footnote: "+6% WoW", trend: .up(6.0)),
        .init(title: "New Invites", value: "93", footnote: "Agents: 61 / Admins: 32", trend: .neutral),
        .init(title: "Journey Events", value: "42,713", footnote: "24h ingestion", trend: .up(12.5)),
        .init(title: "Errors", value: "0.12%", footnote: "p95 24h", trend: .down(0.03))
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.background, Theme.surface], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 16) {
                Picker("Mode", selection: $selectedRole) {
                    Text("Admin").tag(Role.admin)
                    Text("Agent").tag(Role.agent)
                    Text("Client").tag(Role.client)
                }
                .pickerStyle(.segmented)

                switch selectedRole {
                case .admin:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Admin").font(.largeTitle).bold()

                            // Metric grid
                            LazyVGrid(
                                columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2),
                                spacing: 12
                            ) {
                                ForEach(cards) { card in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(card.title).font(.subheadline).foregroundStyle(Theme.secondaryText)
                                        Text(card.value).font(.title).bold()
                                        Text(card.footnote).font(.footnote).foregroundStyle(Theme.secondaryText)
                                    }
                                    .padCard()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        .ultraThinMaterial,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    )
                                }
                            }

                            // Management panel
                            SectionCard(title: "Management", subtitle: "Controls & tools") {
                                // Invite Code Generation
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Invite Codes")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("Generate new user invitations")
                                            .font(.caption)
                                            .foregroundStyle(Theme.secondaryText)
                                    }
                                    Spacer()
                                    Button {
                                        Task { await createInviteCode(maxUses: 5) }
                                    } label: {
                                        if isCreatingInvite {
                                            ProgressView()
                                                .controlSize(.small)
                                        } else {
                                            Text("Generate")
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(isCreatingInvite)
                                }
                                .padding(.vertical, 8)
                                
                                Divider()
                                
                                FlagsPanel()
                                PlaceholderRow(label: "Moderation queue")
                                PlaceholderRow(label: "System health")
                            }
                        }
                    }
                case .agent:
                    AgentDashboardView(client: client, projectURL: projectURL)
                case .client:
                    SignatureSceneIntegration()
                }
            }
            .padScreen()
        }
        .onAppear {
            logger?.log("Viewed Dashboard: Admin", metadata: ["screen": "admin"])
        }
        .alert("Invite Code", isPresented: $showInviteAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(inviteAlert ?? "Done")
        }
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

// MARK: - Preview