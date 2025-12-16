//
//  JourneyEpisodeInterface.swift
//  HOMEY Clean
//
//  Netflix-style episode interface for user journeys
//

import SwiftUI

// MARK: - Journey Episode Interface

struct JourneyEpisodeInterface: View {
    @State private var episodes: [JourneyEpisode] = JourneyEpisode.sampleEpisodes
    @State private var selectedEpisode: JourneyEpisode?
    @State private var showingEpisodeDetail = false
    @State private var scrollOffset: CGFloat = 0
    @State private var currentSection: EpisodeSectionType = .current
    
    private let heroHeight: CGFloat = 300
    private let cardHeight: CGFloat = 180
    private let cardWidth: CGFloat = 320
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            HeroVideoView(
                                character: .charlie,
                                title: "Charlie says Hi",
                                subtitle: "Your HOMEY Teammate",
                                onContinue: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo("journey.contentStart", anchor: .top)
                                    }
                                }
                            )

                            Color.clear
                                .frame(height: 1)
                                .id("journey.contentStart")

                            heroEpisodeSection
                                .offset(y: scrollOffset * 0.3)

                            episodeSectionsView
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEpisodeDetail) {
            if let episode = selectedEpisode {
                EpisodeDetailView(episode: episode)
            }
        }
    }
    
    // MARK: - Hero Episode Section
    
    private var heroEpisodeSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Hero background with current episode poster
                if let currentEpisode = episodes.first(where: { $0.status == .current }) {
                    AsyncImage(url: URL(string: currentEpisode.posterImageName)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .clipShape(Rectangle())
                            )
                    }
                    .frame(width: geometry.size.width, height: heroHeight)
                    .clipped()
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    
                    // Hero content overlay
                    VStack(alignment: .leading, spacing: 16) {
                        Spacer()

                        VStack(alignment: .leading, spacing: 8) {
                            Text(currentEpisode.title)
                                .font(.custom("JosefinSans-Bold", size: 32))
                                .foregroundColor(.white)

                            Text(currentEpisode.subtitle)
                                .font(.custom("PlayfairDisplay-Regular", size: 20))
                                .foregroundColor(.white.opacity(0.9))

                            Text(currentEpisode.description)
                                .font(.custom("PlayfairDisplay-Regular", size: 16))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(3)
                        }

                        // Progress bar
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progress")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(Int(currentEpisode.progress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            ProgressView(value: currentEpisode.progress)
                                .progressViewStyle(NetflixProgressStyle())
                        }
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            Button {
                                selectedEpisode = currentEpisode
                                showingEpisodeDetail = true
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text(currentEpisode.actionTitle)
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(.white)
                                .cornerRadius(8)
                            }
                            
                            Button {
                                // Add to watchlist action
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("My List")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        
                        Spacer().frame(height: 32)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .frame(height: heroHeight)
    }
    
    // MARK: - Episode Sections View
    
    private var episodeSectionsView: some View {
        VStack(spacing: 32) {
            // Current Episode Section
            if !currentEpisodes.isEmpty {
                EpisodeSection(
                    title: "Continue Watching",
                    episodes: currentEpisodes,
                    onEpisodeSelected: { episode in
                        selectedEpisode = episode
                        showingEpisodeDetail = true
                    }
                )
            }
            
            // Upcoming Episodes Section
            if !upcomingEpisodes.isEmpty {
                EpisodeSection(
                    title: "Up Next",
                    episodes: upcomingEpisodes,
                    onEpisodeSelected: { episode in
                        selectedEpisode = episode
                        showingEpisodeDetail = true
                    }
                )
            }
            
            // Completed Episodes Section
            if !completedEpisodes.isEmpty {
                EpisodeSection(
                    title: "Completed",
                    episodes: completedEpisodes,
                    onEpisodeSelected: { episode in
                        selectedEpisode = episode
                        showingEpisodeDetail = true
                    }
                )
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Computed Properties
    
    private var currentEpisodes: [JourneyEpisode] {
        episodes.filter { $0.status == .current }
    }
    
    private var upcomingEpisodes: [JourneyEpisode] {
        episodes.filter { $0.status == .upcoming }
    }
    
    private var completedEpisodes: [JourneyEpisode] {
        episodes.filter { $0.status == .completed }
    }
}

// MARK: - Episode Section

struct EpisodeSection: View {
    let title: String
    let episodes: [JourneyEpisode]
    let onEpisodeSelected: (JourneyEpisode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.custom("JosefinSans-SemiBold", size: 20))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Horizontal scrolling episode cards
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(episodes) { episode in
                        EpisodeCard(episode: episode) {
                            onEpisodeSelected(episode)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Episode Card

struct EpisodeCard: View {
    let episode: JourneyEpisode
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 180
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Card background with poster
                AsyncImage(url: URL(string: episode.posterImageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(Rectangle())
                        )
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipped()
                .cornerRadius(12)
                
                // Overlay gradient
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, .black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                .cornerRadius(12)
                
                // Content overlay
                VStack(alignment: .leading) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(episode.title)
                            .font(.custom("JosefinSans-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(episode.subtitle)
                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)

                        HStack {
                            Text(episode.estimatedTime)
                                .font(.custom("PlayfairDisplay-Regular", size: 12))
                                .foregroundColor(.white.opacity(0.7))

                            Spacer()

                            StatusBadge(status: episode.status)
                        }

                        if episode.status == .current && episode.progress > 0 {
                            ProgressView(value: episode.progress)
                                .progressViewStyle(NetflixProgressStyle())
                                .padding(.top, 4)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: EpisodeStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.8))
            .cornerRadius(6)
    }
}

// MARK: - Netflix Progress Style

struct NetflixProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(.red)
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: 4
                    )
            }
            .cornerRadius(2)
        }
        .frame(height: 4)
    }
}

// MARK: - Episode Section Enum

enum EpisodeSectionType: CaseIterable {
    case current
    case upcoming
    case completed
    
    var title: String {
        switch self {
        case .current: return "Continue Watching"
        case .upcoming: return "Up Next"
        case .completed: return "Completed"
        }
    }
}

// ScrollOffsetPreferenceKey is defined in GlassScaffold.swift

// MARK: - Preview

#Preview {
    JourneyEpisodeInterface()
        .preferredColorScheme(.dark)
}
