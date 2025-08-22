//
//  TeamTile.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/19/25.
//
import SwiftUI
import UIKit

public struct TeamTile: View {
    let kind: HomeyKind
    public init(kind: HomeyKind) { self.kind = kind }
    public var body: some View {
        GlassCardContent(cornerRadius: 22, padding: 12) {
            VStack(spacing: 6) {
                Self.avatarImage(for: kind)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 78, height: 78)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.secondary)
                Text(kind.displayName).font(.footnote).foregroundStyle(.white.opacity(0.9))
                Text(kind.role).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.98)))
    }

    private static func avatarImage(for kind: HomeyKind) -> Image {
        if let ui = UIImage(named: kind.assetName) {
            return Image(uiImage: ui)
        } else {
            return Image(systemName: "person.crop.square")
        }
    }
}
