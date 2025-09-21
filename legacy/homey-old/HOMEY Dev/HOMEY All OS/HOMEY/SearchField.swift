//
//  SearchField.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//

import SwiftUI

// MARK: - Lightweight UI helpers used by Scout

// Drop-in shims so your screen compiles. Replace with real components anytime.

// Search text field
public struct SearchField: View {
    public var placeholder: String
    @Binding public var text: String
    public var onSubmit: () -> Void = {}

    public init(placeholder: String, text: Binding<String>, onSubmit: @escaping () -> Void = {}) {
        self.placeholder = placeholder
        _text = text
        self.onSubmit = onSubmit
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.search)
            .onSubmit(onSubmit)
    }
}

// Simple listing card
public struct MatchCard: View {
    public let listing: HomeyListing
    public var onTap: () -> Void = {}

    public init(listing: HomeyListing, onTap: @escaping () -> Void = {}) {
        self.listing = listing
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.address).font(.headline)
                Text("\(listing.neighborhood ?? "") • $\(listing.price)")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

// Empty state
public struct EmptyState: View {
    public var title: String
    public var subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: 6) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding()
    }
}

// Top-right icon row (bell/gear/ellipsis)
