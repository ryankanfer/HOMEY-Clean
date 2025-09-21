//
//  HeroVideoView.swift
//  HOMEY Clean
//
//  Hero video component with fullscreen support, internal parallax,
//  local Data-asset video playback, and CDN fallback,
//  with persona-specific layout behavior.
//

import SwiftUI
import AVKit
import UIKit

private enum ImageLoadingState { case loading, loaded, failed }

private struct HeroConfig {
    let imageContentMode: ContentMode
    let videoGravity: AVLayerVideoGravity
    let parallaxFactor: CGFloat
    let contentYOffset: CGFloat
    let bottomSafeInset: CGFloat

    static func forCharacter(_ c: HomeyKind) -> HeroConfig {
        switch c {
        case .viza, .drew:
            // Gentle parallax, lift content a bit and add more bottom inset so footer won't overlap
            return .init(
                imageContentMode: .fit,
                videoGravity: .resizeAspect,
                parallaxFactor: 0.08,
                contentYOffset: -16,
                bottomSafeInset: 120
            )
        default:
            return .init(
                imageContentMode: .fill,
                videoGravity: .resizeAspectFill,
                parallaxFactor: 0.30,
                contentYOffset: 0,
                bottomSafeInset: 80
            )
        }
    }
}

struct HeroVideoView: View {
    let character: HomeyKind
    let title: String
    let subtitle: String
    let onContinue: (() -> Void)?

    @State private var isVisible = false
    @State private var animationOffset: CGFloat = 50
    @State private var imageLoadingState: ImageLoadingState = .loading
    @StateObject private var navigationController = TRAENavigationController()

    // Internal parallax (no external preference)
    @State private var localOffset: CGFloat = 0

    // Local video playback (Data asset)
    @State private var queuePlayer: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var tempVideoURL: URL?

    private var config: HeroConfig { .forCharacter(character) }

    // Optional CDN fallback for image
    private var remoteHeroURL: URL? {
        if let base = Bundle.main.infoDictionary?["HERO_CDN_BASE_URL"] as? String,
           let baseURL = URL(string: base) {
            return baseURL.appendingPathComponent("\(character.rawValue)_page_hero.png")
        }
        return nil
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                heroContent(geometry: geometry)

                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.3), .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.custom("JosefinSans-Bold", size: 32))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                        Text(subtitle)
                            .font(.custom("PlayfairDisplay-Regular", size: 18))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .offset(y: animationOffset + config.contentYOffset)

                    Spacer().frame(height: 24)

                    // Bottom scroll indicator only (no "Start")
                    scrollIndicator

                    Spacer().frame(height: config.bottomSafeInset)
                }
            }
            .background(
                GeometryReader { g in
                    Color.clear
                        .onAppear { updateLocalOffset(g) }
                        .onChange(of: g.frame(in: .global).minY) { _ in updateLocalOffset(g) }
                }
            )
        }
        .frame(minHeight: UIScreen.main.bounds.height)
        .clipped()
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            navigationController.setHeroDisplaying(true)
            prepareVideoIfAvailable()
            startAnimations()
            validateAndLoadImage()
        }
        .onDisappear {
            navigationController.setHeroDisplaying(false)
            queuePlayer?.pause()
        }
    }

    @ViewBuilder
    private func heroContent(geometry: GeometryProxy) -> some View {
        ZStack {
            if let queuePlayer {
                HeroAVPlayerView(player: queuePlayer, gravity: config.videoGravity)
                    .allowsHitTesting(false)
                    .frame(width: geometry.size.width,
                           height: geometry.size.height + max(0, -localOffset * 0.5))
                    .offset(y: getScrollOffset())
                    .clipped()
            } else {
                Group {
                    switch imageLoadingState {
                    case .loading:
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                    case .loaded:
                        Image("\(character.rawValue)_page_hero")
                            .resizable()
                            .aspectRatio(contentMode: config.imageContentMode)
                    case .failed:
                        if let url = remoteHeroURL {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: config.imageContentMode)
                            } placeholder: {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.1)],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                            }
                        } else {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.1)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("Hero Image")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                )
                        }
                    }
                }
                .frame(width: geometry.size.width,
                       height: geometry.size.height + max(0, -localOffset * 0.5))
                .offset(y: getScrollOffset())
                .clipped()
            }

            characterSpecificOverlay()
        }
        .clipped()
    }

    @ViewBuilder
    private func characterSpecificOverlay() -> some View {
        switch character {
        case .viza:
            LinearGradient(
                colors: [Color.pink.opacity(0.15), Color.purple.opacity(0.1), Color.clear],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .blendMode(.overlay)
        case .drew:
            LinearGradient(
                colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.1), Color.clear],
                startPoint: .topTrailing, endPoint: .bottomLeading
            )
            .blendMode(.overlay)
        default:
            EmptyView()
        }
    }

    private var scrollIndicator: some View {
        VStack(spacing: 12) {
            Text("Scroll to explore")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            VStack(spacing: 4) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .offset(y: -8)
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .offset(y: -12)
            }
            .onTapGesture { onContinue?() }
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isVisible)
        }
        .padding(.bottom, 20)
        .contentShape(Rectangle())
    }

    private func startAnimations() {
        withAnimation(.easeOut(duration: navigationController.isTransitioning ? 0.2 : 0.8)) {
            isVisible = true
            animationOffset = 0
        }
    }

    private func updateLocalOffset(_ g: GeometryProxy) {
        localOffset = g.frame(in: .global).minY
    }

    private func getScrollOffset() -> CGFloat {
        if navigationController.isTransitioning { return 0 }
        return localOffset * config.parallaxFactor
    }

    private func validateAndLoadImage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if UIImage(named: "\(character.rawValue)_page_hero") != nil {
                imageLoadingState = .loaded
            } else {
                imageLoadingState = .failed
            }
        }
    }

    private func prepareVideoIfAvailable() {
        let baseName = "\(character.rawValue)_hero_video"

        // 1) Try a bundled mp4 resource (e.g., viza_hero_video)
        if let url = Bundle.main.url(forResource: baseName, withExtension: "mp4") {
            setupPlayer(with: url)
            return
        }

        // 2) Try a Data asset in Assets.xcassets (with or without the .mp4 suffix)
        if let dataAsset = NSDataAsset(name: baseName) ?? NSDataAsset(name: "\(baseName).mp4") {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("homey_hero_\(character.rawValue).mp4")
            try? dataAsset.data.write(to: url, options: .atomic)
            setupPlayer(with: url)
            return
        }

        // 3) No video available → let image path render
        queuePlayer = nil
        looper = nil
    }

    private func setupPlayer(with url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        let looper = AVPlayerLooper(player: player, templateItem: item)
        player.isMuted = true
        player.play()
        self.queuePlayer = player
        self.looper = looper
    }
}