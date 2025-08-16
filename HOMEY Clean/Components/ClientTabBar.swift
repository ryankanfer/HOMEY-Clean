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

    public init(items: [HomeyKind],
                selection: Binding<HomeyKind>,
                onPrimaryAction: (() -> Void)? = nil) {
        self.items = items
        self._selection = selection
        self.onPrimaryAction = onPrimaryAction
    }

    public var body: some View {
        VStack(spacing: 12) {
            tabsRow
            primaryAction
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private var primaryAction: some View {
        if let onPrimaryAction {
            Button(action: onPrimaryAction) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(primaryTitle(for: selection))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.primary.opacity(0.12))
            .foregroundStyle(.primary)
        }
    }

    private var tabsRow: some View {
        HStack(spacing: 14) {
            ForEach(items, id: \.self) { item in
                TabItemView(
                    item: item,
                    isSelected: item == selection,
                    onTap: { withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { selection = item } },
                    avatar: { avatar(for: item) },
                    title: item.displayName
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Helpers

    private struct TabItemView<Avatar: View>: View {
        let item: HomeyKind
        let isSelected: Bool
        let onTap: () -> Void
        let avatar: () -> Avatar
        let title: String

        var body: some View {
            Button(action: onTap) {
                VStack(spacing: 6) {
                    avatar()
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSelected ? Color.primary.opacity(0.6) : Color.clear, lineWidth: 1)
                        )
                        .shadow(radius: isSelected ? 2 : 0, x: 0, y: isSelected ? 1 : 0)

                    Text(title)
                        .font(.footnote)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                }
                .padding(8)
                .background(
                    (isSelected ? Color.primary.opacity(0.06) : Color.clear),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(title))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }

    private func avatar(for item: HomeyKind) -> some View {
        // Prefer your asset; fall back to a decent SF Symbol if missing
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
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func symbol(for item: HomeyKind) -> String {
        switch item {
        case .charlie: return "person.crop.circle.fill"
        case .paige:   return "doc.fill"
        case .scout:   return "magnifyingglass"
        case .isla:    return "map.fill"
        case .viza:    return "camera.aperture"
        case .drew:    return "list.bullet.rectangle.portrait.fill"
        }
    }

    private func primaryTitle(for item: HomeyKind) -> String {
        switch item {
        case .charlie: return "Ask Charlie"
        case .paige:   return "Open Paperwork"
        case .scout:   return "Refine Searches"
        case .isla:    return "Neighborhood Intel"
        case .viza:    return "Open Visuals"
        case .drew:    return "View Directory"
        }
    }
}
