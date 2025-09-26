//
//  EpisodeDetailView.swift
//  HOMEY Clean
//
//  Detailed view for individual journey episodes
//

import SwiftUI

struct EpisodeDetailView: View {
    let episode: JourneyEpisode
    @Environment(\.dismiss) private var dismiss
    @State private var showingActionSheet = false
    @State private var isPlaying = false
    @State private var playbackProgress: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero section with poster and play button
                        heroSection
                        
                        // Content section
                        contentSection
                            .padding(.top, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingActionSheet = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .confirmationDialog("Episode Options", isPresented: $showingActionSheet) {
            Button("Add to My List") {
                // Add to watchlist
            }
            
            Button("Share Episode") {
                // Share functionality
            }
            
            Button("Download for Offline") {
                // Download functionality
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Background poster
                AsyncImage(url: URL(string: episode.posterImageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(Rectangle())
                        )
                }
                .frame(width: geometry.size.width, height: 400)
                .clipped()
                
                // Gradient overlay
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, .black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                
                // Play button overlay
                VStack {
                    Spacer()
                    
                    Button {
                        withAnimation(.spring()) {
                            isPlaying.toggle()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .background(.ultraThinMaterial)
                            
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(isPlaying ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isPlaying)
                    
                    Spacer()
                }
            }
        }
        .frame(height: 400)
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Episode info
            episodeInfoSection
            
            // Progress section
            if episode.status == .current {
                progressSection
            }
            
            // Description
            descriptionSection
            
            // Action buttons
            actionButtonsSection
            
            // Related episodes
            relatedEpisodesSection
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Episode Info Section
    
    private var episodeInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                StatusBadge(status: episode.status)
                Spacer()
                Text(episode.estimatedTime)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(episode.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(episode.subtitle)
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 16) {
                Label("Episode \(episode.episodeNumber ?? 1)", systemImage: "number")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                if let difficulty = episode.difficulty {
                    Label(difficulty, systemImage: "chart.bar")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(episode.progress * 100))% Complete")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            ProgressView(value: episode.progress)
                .progressViewStyle(NetflixProgressStyle())
            
            if episode.progress > 0 {
                Text("Continue from where you left off")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
                .background(.ultraThinMaterial)
        )
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Episode")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(episode.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
            
            if let learningObjectives = episode.learningObjectives {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What You'll Learn")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    ForEach(learningObjectives, id: \.self) { objective in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(objective)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Primary action button
            Button {
                // Handle primary action
                withAnimation {
                    isPlaying = true
                }
            } label: {
                HStack {
                    Image(systemName: episode.status == .completed ? "arrow.clockwise" : "play.fill")
                    Text(episode.actionTitle)
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .cornerRadius(12)
            }
            
            // Secondary actions
            HStack(spacing: 12) {
                Button {
                    // Add to list
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("My List")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Button {
                    // Download
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle")
                        Text("Download")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Button {
                    // Share
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Related Episodes Section
    
    private var relatedEpisodesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("More Like This")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(JourneyEpisode.sampleEpisodes.filter { $0.id != episode.id }.prefix(5)) { relatedEpisode in
                        RelatedEpisodeCard(episode: relatedEpisode)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Related Episode Card

struct RelatedEpisodeCard: View {
    let episode: JourneyEpisode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster thumbnail
            AsyncImage(url: URL(string: episode.posterImageName)) { image in
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
            .frame(width: 120, height: 68)
            .clipped()
            .cornerRadius(8)
            
            // Episode info
            VStack(alignment: .leading, spacing: 2) {
                Text(episode.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(episode.estimatedTime)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 120)
    }
}

// MARK: - Extensions

extension JourneyEpisode {
    var episodeNumber: Int? {
        // Extract episode number from title or ID
        return Int(id.uuidString.suffix(1)) ?? 1
    }
    
    var difficulty: String? {
        switch actionType {
        case .start: return "Beginner"
        case .continue: return "Intermediate"
        case .review: return "Easy"
        case .complete: return "Advanced"
        case .documentUpload: return "Intermediate"
        case .lenderConnection: return "Advanced"
        case .neighborhoodExploration: return "Beginner"
        case .propertySearch: return "Intermediate"
        case .offerPreparation: return "Advanced"
        case .inspectionScheduling: return "Intermediate"
        case .custom(_): return "Intermediate"
        }
    }
    
    var learningObjectives: [String]? {
        // Sample learning objectives based on episode type
        switch actionType {
        case .start:
            return [
                "Understand the basics of home buying process",
                "Learn about different property types",
                "Discover financing options"
            ]
        case .continue:
            return [
                "Explore neighborhood amenities",
                "Compare market prices",
                "Schedule property viewings"
            ]
        case .review:
            return [
                "Review your saved properties",
                "Update your preferences",
                "Track market changes"
            ]
        case .complete:
            return [
                "Finalize your property choice",
                "Complete the purchase process",
                "Plan your move"
            ]
        case .documentUpload:
            return [
                "Prepare required documents",
                "Upload financial statements",
                "Verify document accuracy"
            ]
        case .lenderConnection:
            return [
                "Connect with mortgage lenders",
                "Compare loan options",
                "Get pre-approved for financing"
            ]
        case .neighborhoodExploration:
            return [
                "Research local amenities",
                "Explore transportation options",
                "Understand community features"
            ]
        case .propertySearch:
            return [
                "Define search criteria",
                "Browse available properties",
                "Save favorite listings"
            ]
        case .offerPreparation:
            return [
                "Prepare competitive offers",
                "Understand negotiation strategies",
                "Review contract terms"
            ]
        case .inspectionScheduling:
            return [
                "Schedule property inspections",
                "Understand inspection process",
                "Review inspection reports"
            ]
        case .custom(_):
            return [
                "Complete custom task",
                "Follow specific instructions",
                "Track progress"
            ]
        }
    }
}

// MARK: - Preview

#Preview {
    EpisodeDetailView(episode: JourneyEpisode.sampleEpisodes.first!)
        .preferredColorScheme(.dark)
}