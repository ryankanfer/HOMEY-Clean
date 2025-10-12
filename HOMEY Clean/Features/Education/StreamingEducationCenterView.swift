//
//  StreamingEducationCenterView.swift
//  HOMEY Clean
//
//  Created by Alex on 9/30/25.
//  Refactored to a Netflix-style, immersive learning experience.
//

import SwiftUI

// MARK: - Main View

struct StreamingEducationCenterView: View {
    @StateObject private var viewModel = EducationViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                // Full-bleed hero carousel at the top.
                HeroCarouselView(videos: viewModel.featuredVideos)
                    .frame(height: 400)
                
                // Horizontally scrolling carousels for each category.
                ForEach(viewModel.categories) { category in
                    VideoCarousel(
                        category: category,
                        videos: viewModel.videos(for: category)
                    )
                }
            }
        }
        .background(Theme.black)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}


// MARK: - View Model

@MainActor
class EducationViewModel: ObservableObject {
    @Published var allVideos: [VideoContent] = []
    @Published var categories: [VideoCategory] = []
    
    init() {
        loadContent()
    }
    
    func loadContent() {
        // In a real app, this would fetch from an API.
        self.allVideos = VideoContent.mockData()
        self.categories = VideoCategory.allCases
    }
    
    var featuredVideos: [VideoContent] {
        allVideos.filter { $0.isFeatured }
    }
    
    func videos(for category: VideoCategory) -> [VideoContent] {
        allVideos.filter { $0.category == category }
    }
}


// MARK: - UI Components

private struct HeroCarouselView: View {
    let videos: [VideoContent]
    @State private var currentIndex = 0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(videos.indices, id: \.self) { index in
                HeroSlide(video: videos[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

private struct HeroSlide: View {
    let video: VideoContent
    
    var body: some View {
        ZStack {
            // Background Image
            Image(video.thumbnailImage)
                .resizable()
                .scaledToFill()
            
            // Gradient Overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading) {
                Spacer()
                Text(video.title)
                    .homeyFont(.title)
                Text(video.subtitle)
                    .homeyFont(.body)
                    .foregroundColor(Theme.secondaryText)
            }
            .padding()
        }
        .foregroundColor(Theme.primaryText)
    }
}

private struct VideoCarousel: View {
    let category: VideoCategory
    let videos: [VideoContent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.title)
                .homeyFont(.heading)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(videos) { video in
                        VideoCard(video: video)
                    }
                }
                .padding(.horizontal)
            }
        }
        .foregroundColor(Theme.primaryText)
    }
}

private struct VideoCard: View {
    let video: VideoContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Image(video.thumbnailImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Subtle glass overlay for premium feel
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(0.1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .homeyFont(.body)
                    .lineLimit(2)
                
                Text(video.instructor)
                    .homeyFont(.caption)
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .frame(width: 200)
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}


// MARK: - Data Models

struct VideoContent: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let instructor: String
    let thumbnailImage: String
    let category: VideoCategory
    let isFeatured: Bool
}

enum VideoCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case firstTimeBuyers = "First-Time Buyers"
    case nycBasics = "NYC Basics"
    case financing = "Financing"
    case legal = "Legal"
    
    var id: String { self.rawValue }
    var title: String { self.rawValue }
}


// MARK: - Mock Data & Preview

extension VideoContent {
    static func mockData() -> [VideoContent] {
        [
            .init(
                title: "Master NYC Real Estate",
                subtitle: "Learn the ins and outs of the market.",
                instructor: "Charlie Rodriguez",
                thumbnailImage: "charlie",
                category: .firstTimeBuyers,
                isFeatured: true
            ),
            .init(
                title: "Navigate With Confidence",
                subtitle: "Legal frameworks for stress-free transactions.",
                instructor: "Viza Martinez",
                thumbnailImage: "viza",
                category: .legal,
                isFeatured: true
            ),
            .init(
                title: "Expert Financial Guidance",
                subtitle: "Mortgage strategies and financial planning.",
                instructor: "Isla Thompson",
                thumbnailImage: "isla",
                category: .financing,
                isFeatured: true
            ),
            .init(
                title: "First-Time Buyer Essentials",
                subtitle: "A step-by-step guide.",
                instructor: "Charlie Rodriguez",
                thumbnailImage: "drew",
                category: .firstTimeBuyers,
                isFeatured: false
            ),
            .init(
                title: "NYC Market Insights",
                subtitle: "Understanding trends and opportunities.",
                instructor: "David Chen",
                thumbnailImage: "paige",
                category: .nycBasics,
                isFeatured: false
            ),
        ]
    }
}

#if DEBUG
struct StreamingEducationCenterView_Previews: PreviewProvider {
    static var previews: some View {
        StreamingEducationCenterView()
    }
}
#endif