import Foundation
import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

final class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    @Published private(set) var lastURL: URL?

    enum Route: Equatable {
        case documents
        case settings
        case profile
        case authCallback(params: [String: String])
        case unknown
    }

    // Use this for redirectTo when generating magic-link / reset emails
    static var defaultRedirectURL: URL { URL(string: "homey://auth-callback")! }

    func handle(_ url: URL) {
        lastURL = url
        let route = parse(url: url)
        #if DEBUG
        print("[DeepLinkManager] Handling URL: \(url.absoluteString) -> route: \(route)")
        #endif

        switch route {
        case .documents:
            notify(route)
        case .settings:
            notify(route)
        case .profile:
            notify(route)
        case .authCallback(let params):
            handleAuthCallback(url: url, params: params)
        case .unknown:
            notify(route)
        }
    }

    private func handleAuthCallback(url: URL, params: [String: String]) {
        // Attempt to complete Supabase auth flows (magic link / OAuth) if available
        #if canImport(Supabase)
        Task {
            let client = await MainActor.run { AppSessionManager.shared.supabaseClient }
            do {
                // Newer Supabase Swift supports exchanging the code from the callback URL
                try await client.auth.exchangeCodeForSession(from: url)
                await AppSessionManager.shared.restoreIfPossible()
                #if DEBUG
                print("[DeepLinkManager] Supabase auth callback processed successfully")
                #endif
            } catch {
                #if DEBUG
                print("[DeepLinkManager] Supabase auth callback failed: \(error.localizedDescription)")
                #endif
            }
            // Notify listeners regardless so UI can react
            self.notify(.authCallback(params: params))
        }
        #else
        // If Supabase isn't available in this target, just forward the route
        notify(.authCallback(params: params))
        #endif
    }

    private func notify(_ route: Route) {
        NotificationCenter.default.post(name: .deepLinkRouted, object: self, userInfo: [Notification.RouteKey: route])
    }

    // MARK: - Parsing

    private func parse(url: URL) -> Route {
        let scheme = (url.scheme ?? "").lowercased()
        let host = (url.host ?? "").lowercased()
        let path = url.path.lowercased()
        let params = parseQuery(url)

        // Custom scheme: homey://<host>
        if scheme == "homey" {
            switch host {
            case "documents": return .documents
            case "settings": return .settings
            case "profile": return .profile
            case "auth-callback": return .authCallback(params: params)
            default: return .unknown
            }
        }

        // Universal link variants (https). Adapt paths to your domain if needed.
        if scheme == "https" || scheme == "http" {
            if path.contains("/auth/callback") { return .authCallback(params: params) }
            if path.contains("/open/documents") { return .documents }
            if path.contains("/open/settings") { return .settings }
            if path.contains("/open/profile") { return .profile }
        }

        return .unknown
    }

    private func parseQuery(_ url: URL) -> [String: String] {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false), let items = comps.queryItems else {
            return [:]
        }
        var dict: [String: String] = [:]
        for item in items { dict[item.name] = item.value ?? "" }
        return dict
    }
}

extension Notification.Name {
    static let deepLinkRouted = Notification.Name("DeepLinkRouted")
}

extension Notification {
    static let RouteKey = "route"
}
