// HOMEY All OS/HOMEY/HOMEYApp.swift
import Combine
import SwiftUI

#if !os(iOS)
    @main
    struct HOMEYApp: App {
        @StateObject private var session = SessionManager()
        @StateObject private var appState = AppState()
        @StateObject private var edu = EducationCenterStore()
        @StateObject private var taste = TasteStore()

        var body: some Scene {
            WindowGroup {
                RootProviders {
                    RootView()
                }
            }
        }
    }
#endif
