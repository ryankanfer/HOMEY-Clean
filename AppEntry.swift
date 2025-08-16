//
//  AppEntry.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/14/25.
//


import SwiftUI

/// Use this only if you don’t want to touch your existing RootView at all.
/// It wraps your current RootView inside the launch gate.
public struct AppEntry: View {
    public init() {}
    public var body: some View {
        LaunchGate {
            // IMPORTANT: replace `RootView()` with your actual app root view.
            RootView()
        }
    }
}