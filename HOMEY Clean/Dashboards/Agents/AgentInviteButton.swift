//
//  AgentInviteButton.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

// AgentInviteButton.swift
// Drop-in UI to create an invite code via Edge Function `charlie_act`.
// Requirements: import Supabase, have a configured SupabaseClient you can pass in.

import Supabase
import SwiftUI

struct AgentInviteButton: View {
    let client: SupabaseClient // inject your configured client
    let projectURL: URL // e.g. URL(string:"https://fafbjfajmmsjftiivhil.supabase.co")!

    @State private var isLoading = false
    @State private var alertMsg: String?
    @State private var showAlert = false

    var body: some View {
        Button {
            Task { await createInviteCode(maxUses: 3) }
        } label: {
            if isLoading {
                ProgressView()
            } else {
                Text("Create Invite Code")
            }
        }
        .disabled(isLoading)
        .alert("Invite", isPresented: $showAlert, actions: { Button("OK", role: .cancel) {} }, message: {
            Text(alertMsg ?? "Done")
        })
    }

    private func createInviteCode(maxUses: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1) get fresh user JWT
            let session = try await client.auth.session
            let accessToken = session.accessToken
            guard !accessToken.isEmpty else { throw InviteError.noSession }

            // 2) build request
            let fnURL = projectURL.appendingPathComponent("functions/v1/charlie_act")
            var req = URLRequest(url: fnURL)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let body: [String: Any] = [
                "action": "create_invite_code",
                "payload": ["max_uses": maxUses]
            ]
            req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

            // 3) call edge function
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw InviteError.badResponse }

            // 4) parse
            if http.statusCode == 200 {
                let obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let ok = obj?["ok"] as? Bool, ok, let code = obj?["code"] as? String {
                    alertMsg = "Code: \(code)"
                } else if let msg = obj?["error"] as? String {
                    throw InviteError.edgeError(msg)
                } else {
                    throw InviteError.edgeError("unknown_response")
                }
            } else {
                let text = String(data: data, encoding: .utf8) ?? ""
                throw InviteError.http(http.statusCode, text)
            }
        } catch {
            alertMsg = "Failed: \(error.localizedDescription)"
        }
        showAlert = true
    }

    enum InviteError: LocalizedError {
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
