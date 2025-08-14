//
//  ScoutView.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//


import SwiftUI
import Supabase

struct ScoutView: View {
    // Environment
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var taste: TasteStore
    @EnvironmentObject var appState: AppState

    // Optional handlers (can be nil; falls back to intents)
    var openMatches: (() -> Void)? = nil
    var openChat: (() -> Void)? = nil

    // UI state
    @State private var expandGame = false
    @State private var query: String = ""
    @State private var results: [HomeyListing] = []
    @State private var isLoading = false
    @State private var page = 0
    @State private var canLoadMore = true

    // Derived
    private var tasteSummary: String {
        taste.summary.isEmpty ? "High-end kitchens • Chelsea" : taste.summary
    }

    // Service
    private var searchService: SearchService { SearchService(client: session.client) }

    var body: some View {
        if #available(iOS 17.0, *) {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Header / Taste
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Scout").font(.largeTitle.bold())
                        Text("Let’s narrow the hunt and surface perfect matches.")
                            .foregroundStyle(.secondary)
                        Text(tasteSummary).font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Search
                    SearchField(
                        placeholder: "Neighborhood, features, price…",
                        text: $query,
                        onSubmit: { Task { await hardSearch() } }
                    )
                    
                    // Game card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Closing Time (Prototype)").font(.headline)
                            Spacer()
                            Button(expandGame ? "Minimize" : "Play") {
                                withAnimation(.spring()) { expandGame.toggle() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        if expandGame {
                            GameHostView(game: .closingTimeNYC)
                                .frame(height: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.12)))
                                .shadow(radius: 10, y: 6)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            Text("Race rival agents across a stylized NYC. Close deals before time runs out.")
                                .font(.footnote)
                                .opacity(0.7)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Results
                    LazyVStack(spacing: 12) {
                        ForEach(results) { listing in
                            MatchCard(listing: listing) {
                                appState.intentOpenListingId = listing.id
                            }
                            .onAppear {
                                if listing.id == results.last?.id {
                                    Task { await loadNextPageIfNeeded() }
                                }
                            }
                        }
                        
                        if isLoading { ProgressView().padding(.vertical, 8) }
                        
                        if !isLoading && results.isEmpty {
                            EmptyState(
                                title: "No matches yet",
                                subtitle: "Try loosening a filter or ask Scout to broaden the search."
                            )
                            .padding(.top, 8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Scout")
            // Fixed CTA above footer
            .safeAreaInset(edge: .bottom) {
                Button {
                    if let openMatches { openMatches() }
                    else { appState.intentGoToMatches = true }
                } label: {
                    Text("View Matches").fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
            .onAppear { Task { await softSearch() } }
            .onChange(of: query) { _, _ in Task { await softSearch() } }
            .onChange(of: taste.summary) { _, _ in Task { await hardSearch() } }
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Search helpers

    private func softSearch() async {
        try? await Task.sleep(nanoseconds: 300_000_000)
        await hardSearch()
    }

    @MainActor
    private func hardSearch() async {
        page = 0
        results = []
        canLoadMore = true
        await loadNextPageIfNeeded(force: true)
    }

    @MainActor
    private func loadNextPageIfNeeded(force: Bool = false) async {
        guard !isLoading, canLoadMore || force else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let pageSize = 20
            let newItems: [HomeyListing] = try await searchService.searchListings(
                query: query,
                taste: tasteSummary,
                page: page,
                pageSize: pageSize
            )
            results.append(contentsOf: newItems)
            if newItems.count < pageSize { canLoadMore = false }
            page += 1
        } catch {
            canLoadMore = false
        }
    }
}
