//
//  AuthFieldStyle.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


import SwiftUI

public struct AuthFieldStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

public struct PrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.black.opacity(0.7) : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

public extension View {
    func authFieldStyle() -> some View { modifier(AuthFieldStyle()) }
}