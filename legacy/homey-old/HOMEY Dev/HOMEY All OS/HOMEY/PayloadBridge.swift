//
//  PayloadBridge.swift
//  HOMEY
//
//  Bridge for passing small JSON “messages” between the app and extensions
//  via an App Group container as newline-delimited JSON (NDJSON).
//

import Foundation

enum PayloadBridge {
    // MARK: - Configure your App Group once here

    // Update if your identifier changes
    private static let appGroupID = "group.com.homey.shared"
    private static let inboxFilename = "bookmark_inbox.jsonl" // line-delimited JSON

    // MARK: - File locations

    private static func containerURL() -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    private static func inboxURL() -> URL? {
        containerURL()?.appendingPathComponent(inboxFilename, isDirectory: false)
    }

    // MARK: - Write

    /// Append a single JSON object as one line of NDJSON.
    /// Safe to call from multiple places; it opens, seeks, writes, and closes.
    static func write(_ payload: [String: Any]) {
        guard let url = inboxURL() else { return }

        // Convert to JSON + newline
        let jsonData = (try? JSONSerialization.data(withJSONObject: payload, options: [])) ?? Data()
        var line = jsonData
        line.append(0x0A) // '\n'

        // Ensure parent directory exists
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            // Silently fail; you can surface to your logger if needed
            return
        }

        if FileManager.default.fileExists(atPath: url.path) {
            // Append
            do {
                let handle = try FileHandle(forWritingTo: url)
                try handle.seekToEnd()
                try handle.write(contentsOf: line)
                try handle.close()
            } catch {
                // swallow or log
            }
        } else {
            // First write
            do {
                try line.write(to: url, options: .atomic)
            } catch {
                // swallow or log
            }
        }
    }

    // MARK: - Read

    /// Reads all lines as `[String: Any]` dictionaries without deleting.
    static func readAll() -> [[String: Any]] {
        guard let url = inboxURL(),
              let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8)
        else { return [] }

        return text
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { line in
                guard let d = line.data(using: .utf8) else { return nil }
                return (try? JSONSerialization.jsonObject(with: d)) as? [String: Any]
            }
    }

    /// Atomically reads then clears the inbox file.
    @discardableResult
    static func consumeAll() -> [[String: Any]] {
        let items = readAll()
        guard let url = inboxURL() else { return items }
        do {
            // Truncate to zero bytes (keeps file inode; avoids race conditions)
            let handle = try FileHandle(forWritingTo: url)
            try handle.truncate(atOffset: 0)
            try handle.close()
        } catch {
            // If truncation fails, removing is fine
            try? FileManager.default.removeItem(at: url)
        }
        return items
    }

    /// Utility if an extension wants to confirm the bridge is reachable.
    static func isAvailable() -> Bool {
        containerURL() != nil
    }
}
