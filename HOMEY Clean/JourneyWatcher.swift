//
//  JourneyWatcher.swift
//  HOMEY Clean
//
//  You can make this fancy later. For now it compiles and doesn't bite.
//

import Foundation

@MainActor
final class JourneyWatcher: ObservableObject {
    static let shared = JourneyWatcher()
    @Published var lastEvent: String = "boot"

    private init() {}

    func log(_ event: String) {
        lastEvent = event
        #if DEBUG
        print("[Journey]", event)
        #endif
    }
}
