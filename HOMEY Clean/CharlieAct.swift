import Foundation

enum CharlieAct {
    /// Fetch the checklist from the `charlie_act` Edge Function.
    /// Returns an array of dictionaries so you can plug straight into existing code without model types.
    static func checklist(role: String, projectRef: String = "fafbjfajmmsjftiivhil") async throws -> [[String: Any]] {
        // Build URL
        let url = URL(string: "https://\(projectRef).functions.supabase.co/charlie_act")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // JSON body
        let body: [String: Any] = [
            "action": "generate_doc_checklist",
            "payload": ["role": role]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        // Execute
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "charlie_act", code: status, userInfo: [NSLocalizedDescriptionKey: "HTTP \(status)"])
        }

        // Parse
        let obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return obj?["checklist"] as? [[String: Any]] ?? []
    }
}
