//
//  AppState.swift
//  HOMEY Clean
//
//  Minimal, boring, and intentionally safe.
//

import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    // Keep only what we actually need at this stage.
    @Published var selectedHomeyDisplayTitle: String = "Charlie"
    @Published var askHomey: String?
}
