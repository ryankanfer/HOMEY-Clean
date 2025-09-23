import Foundation
#if canImport(Supabase)
import Supabase
#endif

public actor InteractionLogger {
    public static let shared = InteractionLogger()

    private var events: [InteractionEvent] = []
    private var unsent: Set<UUID> = []
    private let maxEvents = 1000

    private let storageURL: URL = {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("homey.intelligence", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("interaction_events.json")
    }()

    private init() {
        load()
    }

    // MARK: - Public API

    public func log(_ event: InteractionEvent) async {
        if events.count >= maxEvents {
            events.removeFirst(events.count - maxEvents + 1)
        }
        events.append(event)
        unsent.insert(event.id)
        save()

        await MainActor.run {
            CrossScreenContext.shared.apply(event)
        }

        Task {
            await LearningLoop.shared.observe(event)
        }

        await tryToSync()
    }

    public func history(limit: Int = 200, since: Date? = nil) -> [InteractionEvent] {
        var slice = events
        if let since {
            slice = slice.filter { $0.occurredAt >= since }
        }
        return Array(slice.suffix(limit))
    }

    public func tryToSync() async {
        #if canImport(Supabase)
        let isAuthed = await MainActor.run { AppSessionManager.shared.isAuthenticated }
        guard isAuthed else { return }
        let client = await MainActor.run { AppSessionManager.shared.supabaseClient }
        let batch = events.filter { unsent.contains($0.id) }
        guard !batch.isEmpty else { return }

        struct OutgoingEvent: Encodable {
            let id: UUID
            let user_id: UUID?
            let event_type: String
            let event_data: [String: InteractionAnyCodable]
            let timestamp: Date
            let session_id: String
        }

        let payload: [OutgoingEvent] = batch.map { e in
            OutgoingEvent(
                id: e.id,
                user_id: e.userId,
                event_type: e.type.rawValue,
                event_data: e.metadata,
                timestamp: e.occurredAt,
                session_id: e.sessionId
            )
        }

        do {
            _ = try await client
                .from("events")
                .insert(payload)
                .execute()
            for ev in batch { unsent.remove(ev.id) }
            save()
        } catch {
            // Keep unsent; will retry later
            #if DEBUG
            print("InteractionLogger sync failed: \(error.localizedDescription)")
            #endif
        }
        #endif
    }

    // MARK: - Convenience helpers

    public func makeSessionId() -> String {
        if let sid = UserDefaults.standard.string(forKey: "homey.session.id"), !sid.isEmpty {
            return sid
        }
        let sid = UUID().uuidString
        UserDefaults.standard.set(sid, forKey: "homey.session.id")
        return sid
    }

    public func captureSearch(query: String, filters: [String: InteractionAnyCodable] = [:], page: AppPage? = nil) async {
        let uid = await currentUserId()
        let sid = makeSessionId()
        let ev = InteractionEvent.search(query: query, filters: filters, page: page, userId: uid, sessionId: sid)
        await log(ev)
    }

    public func capturePropertyView(id: String, source: String, page: AppPage? = nil) async {
        let uid = await currentUserId()
        let sid = makeSessionId()
        let ev = InteractionEvent.propertyView(listingId: id, source: source, page: page, userId: uid, sessionId: sid)
        await log(ev)
    }

    public func capturePropertySave(id: String, saved: Bool, page: AppPage? = nil) async {
        let uid = await currentUserId()
        let sid = makeSessionId()
        let ev = InteractionEvent.propertySave(listingId: id, saved: saved, page: page, userId: uid, sessionId: sid)
        await log(ev)
    }

    public func captureDocUpload(name: String, type: DocumentType, page: AppPage? = nil) async {
        let uid = await currentUserId()
        let sid = makeSessionId()
        let ev = InteractionEvent.docUpload(name: name, type: type.rawValue, page: page, userId: uid, sessionId: sid)
        await log(ev)
    }

    public func captureDocUploadUnknown(name: String, typeString: String, page: AppPage? = nil) async {
        let uid = await currentUserId()
        let sid = makeSessionId()
        let ev = InteractionEvent(
            type: .documentUploaded,
            page: page,
            userId: uid,
            sessionId: sid,
            metadata: ["name": .init(name), "type": .init(typeString)]
        )
        await log(ev)
    }

    public func captureJourneyStageChange(from: JourneyStage, to: JourneyStage, page: AppPage? = nil) async {
        let uid = await currentUserId()
        let sid = makeSessionId()
        let ev = InteractionEvent.journeyStageChange(from: from, to: to, page: page, userId: uid, sessionId: sid)
        await log(ev)
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: storageURL) else { return }
        struct Snapshot: Codable { let events: [InteractionEvent]; let unsent: [UUID] }
        if let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            self.events = decoded.events
            self.unsent = Set(decoded.unsent)
        }
    }

    private func save() {
        struct Snapshot: Codable { let events: [InteractionEvent]; let unsent: [UUID] }
        let snap = Snapshot(events: events, unsent: Array(unsent))
        if let data = try? JSONEncoder().encode(snap) {
            try? data.write(to: storageURL)
        }
    }

    // MARK: - Utilities

    public func currentUserId() async -> UUID? {
        await MainActor.run {
            AppSessionManager.shared.userProfile?.id
        }
    }
}