import Foundation

actor AgentService {
    static let shared = AgentService()

    private let baseURL = URL(string: "https://fafbjqjammsjfitiivihil.supabase.co/rest/v1")!
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhZmJqZmFqbW1zamZ0aWl2aGlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxODg4MjEsImV4cCI6MjA2Nzc2NDgyMX0.S9P5wgPZGBop-0E55VMD1mhfIe2PnJfq28nt8UMLjCM"

    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    enum APIError: LocalizedError {
        case badStatus(Int), decodeFailed
        var errorDescription: String? {
            switch self {
            case .badStatus(let c): return "HTTP \(c)"
            case .decodeFailed: return "Failed to decode response"
            }
        }
    }

    func fetchAgents() async throws -> [Agent] {
        let url = baseURL.appendingPathComponent("agents")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, resp) = try await session.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.badStatus(http.statusCode)
        }
        return try JSONDecoder().decode([Agent].self, from: data)
    }
}
