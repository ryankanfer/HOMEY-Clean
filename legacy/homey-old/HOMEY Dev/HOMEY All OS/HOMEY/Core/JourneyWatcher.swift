import Foundation
import Supabase

/// Minimal, version-agnostic watcher to keep the app compiling on public Xcode.
/// It preserves your public surface (start/stop with SupabaseClient) without
/// relying on any Realtime API that keeps changing between package versions.
final class JourneyWatcher {

    private(set) var isRunning = false
    private weak var client: SupabaseClient?

    deinit { stop() }

    /// Call from your app once (e.g., after login).
    /// Safe to call repeatedly; it won't double-start.
    func start(client: SupabaseClient) {
        guard !isRunning else { return }
        self.client = client
        isRunning = true

        // TODO: When you’re ready, plug Realtime back in here.
        // Keep it behind a tiny helper so you don’t bind this file to a volatile API.
        // Example shape (fill in once you pin a supabase-swift version):
        // subscribeToJourneyChanges()
    }

    /// Stop any observers (noop for now).
    func stop() {
        guard isRunning else { return }
        // If you add a realtime channel later, unsubscribe it here.
        isRunning = false
        client = nil
    }

    // MARK: - Future Realtime (leave commented until you pin the package)
    /*
    private func subscribeToJourneyChanges() {
        // Pin a specific supabase-swift version first, then implement.
        // Keep all Realtime-specific types contained in here so the rest of
        // the file stays stable across SDK changes.
    }
    */
}
