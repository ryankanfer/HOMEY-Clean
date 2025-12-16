import Foundation
#if canImport(Supabase)
import Supabase
#endif

@MainActor
final class RealtimeSubscriptions: ObservableObject {
    #if canImport(Supabase)
    private let client: SupabaseClient
    private var channels: [String: RealtimeChannelV2] = [:]
    #endif

    #if canImport(Supabase)
    init(client: SupabaseClient) {
        self.client = client
    }
    #else
    init() {}
    #endif

    deinit {
        Task { @MainActor in
            self.unsubscribeAll()
        }
    }

    // MARK: - Generic subscribe helper
    func subscribe(
        toTable table: String,
        schema: String = "public",
        onChange: @escaping (Any) -> Void
    ) {
        #if canImport(Supabase)
        let name = "\(schema):\(table)"
        guard channels[name] == nil else { return }

        let channel: RealtimeChannelV2 = client.channel(name)
        channel.onPostgresChange(AnyAction.self, schema: schema, table: table) { action in
            // Always dispatch to main for UI/state changes
            Task { @MainActor in
                onChange(action)
            }
        }
        Task {
            do {
                try await channel.subscribe()
                print("✅ Subscribed to \(name)")
            } catch {
                print("❌ Failed to subscribe to \(name): \(error)")
            }
        }
        channels[name] = channel
        #endif
    }

    func unsubscribe(table: String, schema: String = "public") {
        #if canImport(Supabase)
        let name = "\(schema):\(table)"
        guard let ch = channels.removeValue(forKey: name) else { return }
        Task {
            await client.removeChannel(ch)
        }
        #endif
    }

    func unsubscribeAll() {
        #if canImport(Supabase)
        let values = Array(channels.values)
        channels.removeAll()
        for ch in values {
            Task {
                await client.removeChannel(ch)
            }
        }
        #endif
    }

    // MARK: - Convenience per-table helpers
    func subscribeOnboardingProfiles(_ onChange: @escaping (Any) -> Void) {
        // Subscribe to profiles table for user profile updates
        subscribe(toTable: "profiles", onChange: onChange)
    }

    func subscribeDocuments(_ onChange: @escaping (Any) -> Void) {
        subscribe(toTable: "documents", onChange: onChange)
    }

    func subscribeShowingRequests(_ onChange: @escaping (Any) -> Void) {
        subscribe(toTable: "showing_requests", onChange: onChange)
    }

    func subscribeMessages(_ onChange: @escaping (Any) -> Void) {
        subscribe(toTable: "messages", onChange: onChange)
    }
}

