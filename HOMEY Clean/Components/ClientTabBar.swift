//
//  ClientTabBar.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI
import UIKit

public struct ClientTabBar: View {
    public var items: [HomeyKind]
    @Binding public var selection: HomeyKind
    public var onPrimaryAction: (() -> Void)?

    @State private var appear = false
    @State private var shimmerPhase: CGFloat = 0

    public init(
        items: [HomeyKind],
        selection: Binding<HomeyKind>,
        onPrimaryAction: (() -> Void)? = nil
    ) {
        self.items = items
        _selection = selection
        self.onPrimaryAction = onPrimaryAction
    }

    public var body: some View {
        VStack(spacing: 12) {
            if let onPrimaryAction {
                GlassCTAPill(
                    title: primaryTitle(for: selection),
                    accentStyle: accentStyle(for: selection),
                    glow: glow(for: selection),
                    action: onPrimaryAction
                )
            }

            tabsRow
                .padding(.horizontal, 6)
        }
        .padding(.top, 10)
        .padding(.bottom, 14)
        .padding(.horizontal, 14)
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial)

                LinearGradient(
                    colors: [Color.black.opacity(0.10), Color.clear],
                    startPoint: .top, endPoint: .bottom
                )
                .blendMode(.plusLighter)
            }
        )
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 28, bottomLeading: 0, bottomTrailing: 0, topTrailing: 28)
            )
        )
        .overlay(
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 28, bottomLeading: 0, bottomTrailing: 0, topTrailing: 28)
            )
            .strokeBorder(
                LinearGradient(
                    colors: [Color.white.opacity(0.20), Color.white.opacity(0.06)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -4)
        .offset(y: appear ? 0 : 28)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: appear)
        .onAppear { appear = true }
        .accessibilityElement(children: .contain)
    }

    private var tabsRow: some View {
        HStack(spacing: 12) {
            ForEach(items, id: \.self) { item in
                TabItemView(
                    item: item,
                    isSelected: item == selection,
                    onTap: { withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) { selection = item } },
                    avatar: { avatar(for: item) },
                    title: item.displayName
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Helpers

    private struct GlassCTAPill: View {
        let title: String
        let accentStyle: AnyShapeStyle
        let glow: Color
        let action: () -> Void
        @State private var pressed = false
        @State private var shimmer = false

        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { pressed = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { pressed = false }
                action()
                // brief shimmer burst on tap
                withAnimation(.easeInOut(duration: 0.8)) { shimmer.toggle() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { shimmer = false }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(title).fontWeight(.semibold)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(
                ZStack {
                    Capsule().fill(.ultraThinMaterial)

                    Capsule()
                        .strokeBorder(LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.10)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1)
                        .blendMode(.plusLighter)

                    Capsule()
                        .fill(accentStyle).opacity(0.18)
                        .blur(radius: 16)
                        .scaleEffect(pressed ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: pressed)

                    if shimmer {
                        CTASheen()
                            .clipShape(Capsule())
                            .allowsHitTesting(false)
                    }
                }
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.8)
            )
            .shadow(color: glow.opacity(0.35), radius: pressed ? 18 : 12, x: 0, y: 6)
            .scaleEffect(pressed ? 0.98 : 1.0)
        }
    }

    private struct CTASheen: View {
        @State private var t: CGFloat = -1.0
        var body: some View {
            LinearGradient(
                colors: [.white.opacity(0.00), .white.opacity(0.35), .white.opacity(0.00)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(10))
            .offset(x: t * 240, y: -t * 120)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) { t = 1.0 }
            }
        }
    }

    private struct TabItemView<Avatar: View>: View {
        let item: HomeyKind
        let isSelected: Bool
        let onTap: () -> Void
        let avatar: () -> Avatar
        let title: String
        @State private var tilt = false

        var body: some View {
            Button(action: onTap) {
                VStack(spacing: 6) {
                    avatar()
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    isSelected ? Color.white.opacity(0.35) : Color.white.opacity(0.12),
                                    lineWidth: isSelected ? 1.5 : 1
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(0.20),
                            radius: isSelected ? 6 : 4,
                            x: 0,
                            y: isSelected ? 3 : 2
                        )
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .rotation3DEffect(.degrees(tilt ? 4 : -4), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: tilt)

                    Text(title)
                        .font(.footnote.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .primary : .secondary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.06) : Color.clear)
                )
            }
            .buttonStyle(.plain)
            .onAppear { tilt = true }
            .accessibilityLabel(Text(title))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }

    private func avatar(for item: HomeyKind) -> some View {
        Group {
            if UIImage(named: item.assetName) != nil {
                Image(item.assetName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Image(systemName: symbol(for: item))
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
        }
    }

    private func symbol(for item: HomeyKind) -> String {
        switch item {
        case .charlie: return "person.crop.circle.fill"
        case .paige: return "doc.fill"
        case .scout: return "magnifyingglass"
        case .isla: return "map.fill"
        case .viza: return "camera.aperture"
        case .drew: return "list.bullet.rectangle.portrait.fill"
        }
    }

    private func primaryTitle(for item: HomeyKind) -> String {
        switch item {
        case .charlie: return "Ask Charlie"
        case .paige: return "Open Paperwork"
        case .scout: return "Refine Searches"
        case .isla: return "Neighborhood Intel"
        case .viza: return "Open Visuals"
        case .drew: return "View Directory"
        }
    }

    private func accentStyle(for item: HomeyKind) -> AnyShapeStyle {
        switch item {
        case .charlie: return HomeyKind.charlie.gradients.accent
        case .paige: return HomeyKind.paige.gradients.accent
        case .scout: return HomeyKind.scout.gradients.accent
        case .isla: return HomeyKind.isla.gradients.accent
        case .viza: return HomeyKind.viza.gradients.accent
        case .drew: return HomeyKind.drew.gradients.accent
        }
    }

    private func glow(for _: HomeyKind) -> Color {
        // Fallback glow color used for shadows; replace with brand tokens if available
        return Color.accentColor
    }
}
