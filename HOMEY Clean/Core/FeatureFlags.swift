import SwiftUI

final class FeatureFlags: ObservableObject {
    // Shared singleton for easy injection: .environmentObject(FeatureFlags.shared)
    @MainActor
    static let shared = FeatureFlags()

    init() {}

    // Per-tab switches (use later; safe to keep now)
    @AppStorage("FF_Client_Tab_Charlie") var ffClientCharlie = true
    @AppStorage("FF_Client_Tab_Paige") var ffClientPaige = false
    @AppStorage("FF_Client_Tab_Scout") var ffClientScout = false
    @AppStorage("FF_Client_Tab_Isla") var ffClientIsla = false
    @AppStorage("FF_Client_Tab_Viza") var ffClientViza = false
    @AppStorage("FF_Client_Tab_Drew") var ffClientDrew = false
}
