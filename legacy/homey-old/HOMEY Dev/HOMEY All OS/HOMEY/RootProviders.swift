//
//  RootProviders.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/11/25.
//
import SwiftUI
import Combine

struct RootProviders<Content: View>: View {
    @StateObject private var session = SessionManager()
    @StateObject private var appState = AppState()
    @StateObject private var edu = EducationCenterStore()
    @StateObject private var taste = TasteStore()

    let content: () -> Content

    var body: some View {
        content()
            .environmentObject(session)
            .environmentObject(appState)
            .environmentObject(edu)
            .environmentObject(taste)
    }
}
