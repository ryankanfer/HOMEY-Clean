//  ClientDashboardPlaceholder.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/16/25.
//

import SwiftUI

public struct ClientDashboardPlaceholder: View {
    public init() {}
    public var body: some View {
        ComingSoonView(
            featureTitle: "Client Dashboard",
            subtitle: "The brains are wiring up behind the scenes."
        )
    }
}

public struct AgentDashboardPlaceholder: View {
    public init() {}
    public var body: some View {
        ComingSoonView(
            featureTitle: "Agent Dashboard",
            subtitle: "Metrics, docs, and chat will land here."
        )
    }
}

public struct AdminDashboardPlaceholder: View {
    public init() {}
    public var body: some View {
        ComingSoonView(
            featureTitle: "Admin Dashboard",
            subtitle: "Controls, flags, and roles are in progress."
        )
    }
}
