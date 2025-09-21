//
//  AppTabRoot.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/17/25.
//

// Apply globally in your root/tab container

import Foundation
import Supabase
import SwiftUI

struct AppTabRootStyle: View {
    private let supabaseURL: URL
    private let supabaseAnonKey: String
    private let client: SupabaseClient
    private let projectURL: URL
    @StateObject private var appState = AppState()
    @State private var selectedTab = 0

    init() {
        let rawURL = (Bundle.main.infoDictionary?["SUPABASE_URL"
        ] as? String) ?? "https://mzqswvyfnblghgvcgxpw.supabase.co/"
        let url = URL(string: rawURL)!
        let key = (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? "<YOUR_ANON_KEY>"
        supabaseURL = url
        supabaseAnonKey = key
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        projectURL = url
    }
    
    private var currentPersona: HomeyKind {
        HomeyKind(fromFooterTitle: appState.selectedHomeyDisplayTitle) ?? .charlie
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SignatureSceneIntegration()
                .environmentObject(appState)
                .tabItem {
                    Label("Client", systemImage: "person")
                }
                .tag(0)

            AgentDashboardView(client: client, projectURL: projectURL)
                .tabItem {
                    Label("Agent", systemImage: "person.2")
                }
                .tag(1)

            DocumentsView(vm: DocumentsViewModel(
                repo: DocumentsRepository(client: client)
            ))
            .tabItem { Label("Documents", systemImage: "doc.richtext") }
            .tag(2)
        }
        .background(.ultraThinMaterial.opacity(0.9))
        .tint(currentPersona.accentColor)
    }
}

private struct PlaceholderDocumentsTab: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Documents module not available in this target")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
