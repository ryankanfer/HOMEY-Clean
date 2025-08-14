//
//  MatchesView.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//


import SwiftUI

struct MatchesView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Matches").font(.largeTitle.bold())
                Text("Wire this up to your real matches screen.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ListingDetailView: View {
    let listingId: UUID

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Listing Detail").font(.title.bold())
                Text("ID: \(listingId.uuidString)")
                    .font(.footnote).foregroundStyle(.secondary)
                // TODO: fetch listing by id and render detail UI
            }
            .padding()
            .navigationTitle("Listing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}