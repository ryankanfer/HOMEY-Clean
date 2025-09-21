//
//  PaigeDashboardView.swift
//  HOMEY Clean
//

import SwiftUI

public struct PaigeDashboardView: View {
    @State private var readiness: Double = 0.62

    public init() {}

    public var body: some View {
        ZStack {
            RoomVibeBackground(kind: .paige)

            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                        // Immersive Hero Banner - Edge to Edge
                        HeroVideoView(
                            character: .paige,
                            title: "Paige says Hi",
                            subtitle: "Your HOMEY Teammate",
                            onContinue: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo("paige.contentStart", anchor: .top)
                                }
                            }
                        )

                        // Anchor for hero continue action
                        Color.clear
                            .frame(height: 1)
                            .id("paige.contentStart")

                        // Charlie's Update Box
                        CharlieUpdateBox()

                        // Main Content with proper spacing
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Paige")
                                        .font(.largeTitle.bold())
                                        .foregroundStyle(HomeyKind.paige.gradients.accent)
                                    Text("Paperwork Stylist")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(.white.opacity(0.10), lineWidth: 0.8)
                                    )
                                    .overlay(
                                        Image(systemName: "person.crop.square")
                                            .symbolRenderingMode(.hierarchical)
                                            .font(.system(size: 44))
                                            .foregroundStyle(.secondary.opacity(0.6))
                                    )
                                    .frame(width: 96, height: 96)
                            }

                            DashboardReadinessBar(progress: readiness)

                            SmartUploadCard {
                                // upload action
                            }

                            ChecklistCards(items: [
                                ("ID & Employment", .done),
                                ("Income Docs", .pending),
                                ("Board Package", .missing)
                            ])

                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                                spacing: 12
                            ) {
                                FolderTile(title: "Board Packet", subtitle: "Docs uploaded")
                                FolderTile(title: "Appraisal")
                                FolderTile(title: "Contract")
                                FolderTile(title: "ID Report")
                            }

                            Button("✨ Open Paperwork") {}
                                .buttonStyle(.borderedProminent)
                                .tint(HomeyKind.paige.gradients.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)

                            TipsBanner(
                                title: "Tidy Tips",
                                subtitle: "Board Interview Checklist",
                                buttonTitle: "View"
                            ) {}
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .coordinateSpace(name: "scroll")
        }
    }
}

private struct DashboardReadinessBar: View {
    let progress: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Document Readiness")
                    .font(.headline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline.weight(.semibold))
            }
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.18)).frame(height: 12)
                Capsule().fill(
                    LinearGradient(
                        colors: [.yellow.opacity(0.9), .white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(8, progress.clampedDashboard(to: 0 ... 1) * 1000), height: 12)
                .mask(GeometryReader { geo in
                    Rectangle().frame(width: geo.size.width * progress)
                })
                .shadow(color: .yellow.opacity(0.4), radius: 8)
            }
        }
    }
}

private enum DocState { case done, pending, missing }

private struct ChecklistCards: View {
    let items: [(String, DocState)]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Required Documents").font(.headline)
            ForEach(Array(items.enumerated()), id: \.offset) { _, row in
                GlassCardContent(cornerRadius: 14, padding: 12) {
                    HStack {
                        Image(systemName: icon(for: row.1))
                            .foregroundStyle(color(for: row.1))
                        Text(row.0)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
        }
    }

    private func icon(for s: DocState) -> String {
        switch s {
        case .done: return "checkmark.circle.fill"
        case .pending: return "clock.fill"
        case .missing: return "exclamationmark.circle.fill"
        }
    }

    private func color(for s: DocState) -> Color {
        switch s {
        case .done: return .green
        case .pending: return .orange
        case .missing: return .red
        }
    }
}

private struct SmartUploadCard: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: "tray.and.arrow.up.fill").font(.largeTitle)
                Text("Smart Upload").font(.headline)
                Text("Drop or tap to add documents").font(.subheadline).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)
    }
}

// MARK: - Local components

private struct FolderTile: View {
    let title: String
    var subtitle: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 0.8)
                        .blendMode(.plusLighter)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )

            VStack(alignment: .leading, spacing: 10) {
                // Decorative folder
                Image(systemName: "folder")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.55))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: 2, y: -2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .frame(height: 150)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .hoverEffect(.lift)
    }
}

private struct TipsBanner: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Button(buttonTitle, action: action)
                .buttonStyle(.bordered)
                .controlSize(.regular)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 0.8)
                .blendMode(.plusLighter)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
    }
}

// MARK: - Utilities

fileprivate extension Double {
    func clampedDashboard(to r: ClosedRange<Double>) -> Double {
        min(max(self, r.lowerBound), r.upperBound)
    }
}

