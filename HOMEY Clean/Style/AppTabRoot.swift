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

struct AppTabRoot: View {
    private let supabaseURL: URL
    private let supabaseAnonKey: String
    private let client: SupabaseClient
    private let projectURL: URL

    init() {
        let rawURL = (Bundle.main.infoDictionary?["SUPABASE_URL"
        ] as? String) ?? "https://fafbjfajmmsjftiivhil.supabase.co"
        let url = URL(string: rawURL)!
        let key = (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? "<YOUR_ANON_KEY>"
        supabaseURL = url
        supabaseAnonKey = key
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        projectURL = url
    }

    var body: some View {
        TabView {
            ClientDashboardView().tabItem { Label("Client", systemImage: "person") }
            AgentDashboardView(client: client, projectURL: projectURL)
                .tabItem { Label("Agent", systemImage: "person.2") }
            IslaDashboardView().tabItem { Label("Isla", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .tint(Theme.accent) // TabBar uses token
    }
}
