//
//  Theme.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/16/25.
//

import SwiftUI

public enum Theme {
    // asset names must match exactly
    public static let primary    = Color("Primary")
    public static let background = Color("Background")
    public static let text       = Color("Text")
    public static let textMuted  = Color("TextMuted")
}

public extension View {
    func themedCardBackground() -> some View {
        self.background(Theme.background)
    }
    func themedText() -> some View {
        self.foregroundStyle(Theme.text)
    }
    func themedMuted() -> some View {
        self.foregroundStyle(Theme.textMuted)
    }
}
