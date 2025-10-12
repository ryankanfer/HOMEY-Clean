//
//  RoundedCard.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

import SwiftUI

public struct RoundedCard<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        ZStack { content }
            .background(
                LinearGradient(
                    colors: [Theme.primaryAction.opacity(0.18), Theme.primaryAction.opacity(0.18)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.primaryAction.opacity(0.25))
            )
            .shadow(radius: 8, y: 2)
    }
}