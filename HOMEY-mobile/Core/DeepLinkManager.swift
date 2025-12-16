import Foundation
import SwiftUI

// MARK: - Deep Link Manager
class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    private init() {}
    
    // MARK: - Route Types
    enum Route {
        case authCallback(tokens: [String: String])
        case onboarding
        case dashboard
        case settings
        case custom(String)
    }
    
    // MARK: - Handle URL
    func handle(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        let route = parseRoute(from: components)
        routeToDestination(route)
    }
    
    // MARK: - Parse Route
    private func parseRoute(from components: URLComponents) -> Route {
        let path = components.path.lowercased()
        let host = (components.host ?? "").lowercased()
        
        // Support:
        // - homey://auth/callback
        // - homey://auth-callback
        // - homey://callback
        if host == "auth-callback" || host == "callback" || (host == "auth" && path == "/callback") {
            let tokens = extractTokensFromURL(components)
            return .authCallback(tokens: tokens)
        }
        
        // Supabase verify endpoint (intermediate) that will have token=pkce_* and type=signup|magiclink
        // Example:
        // https://<project>.supabase.co/auth/v1/verify?token=pkce_xxx&type=signup&redirect_to=homey://auth-callback
        if host.hasSuffix(".supabase.co") && path.hasPrefix("/auth/v1/verify") {
            let tokens = extractTokensFromURL(components)
            return .authCallback(tokens: tokens)
        }
        
        switch path {
        case "/auth/callback", "/callback", "/auth-callback":
            let tokens = extractTokensFromURL(components)
            return .authCallback(tokens: tokens)
        case "/onboarding":
            return .onboarding
        case "/dashboard":
            return .dashboard
        case "/settings":
            return .settings
        default:
            return !path.isEmpty ? .custom(path) : (!host.isEmpty ? .custom(host) : .custom(""))
        }
    }
    
    // MARK: - Extract Tokens
    private func extractTokensFromURL(_ components: URLComponents) -> [String: String] {
        var tokens: [String: String] = [:]
        
        #if DEBUG
        print("[DeepLinkManager] Extracting tokens from URL: \(components.url?.absoluteString ?? "nil")")
        print("[DeepLinkManager] Query items: \(components.queryItems?.map { "\($0.name)=\($0.value ?? "nil")" }.joined(separator: ", ") ?? "none")")
        print("[DeepLinkManager] Fragment: \(components.fragment ?? "none")")
        #endif
        
        // Extract query parameters
        if let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value {
                    tokens[item.name] = value
                    #if DEBUG
                    print("[DeepLinkManager] Added query token: \(item.name) = \(value)")
                    #endif
                }
            }
        }
        
        // Extract fragment parameters (common for OAuth flows; Supabase often puts access/refresh here)
        if let fragment = components.fragment {
            let fragmentComponents = fragment.components(separatedBy: "&")
            for component in fragmentComponents {
                let keyValue = component.components(separatedBy: "=")
                if keyValue.count == 2 {
                    let key = keyValue[0]
                    let value = keyValue[1].removingPercentEncoding ?? keyValue[1]
                    tokens[key] = value
                    #if DEBUG
                    print("[DeepLinkManager] Added fragment token: \(key) = \(value)")
                    #endif
                }
            }
        }
        
        #if DEBUG
        print("[DeepLinkManager] Final extracted tokens: \(tokens.keys.joined(separator: ", "))")
        #endif
        
        return tokens
    }
    
    // MARK: - Route to Destination
    private func routeToDestination(_ route: Route) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .deepLinkRouted,
                object: nil,
                userInfo: [Notification.RouteKey: route]
            )
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let deepLinkRouted = Notification.Name("deepLinkRouted")
}

extension Notification {
    static let RouteKey = "route"
}
