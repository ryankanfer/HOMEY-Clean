//
//  Theme.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/8/25.
//


// SharedUI.swift
import SwiftUI

struct Theme {
    let top: Color
    let bottom: Color
    let accent: Color
}

func theme(for h: HomeyKind) -> Theme {
    switch h {
    case .charlie: return .init(top: Color(#colorLiteral(red:0.94, green:0.96, blue:1.00, alpha:1)),
                                bottom: Color(#colorLiteral(red:0.86, green:0.91, blue:1.00, alpha:1)),
                                accent: .blue)
    case .paige:   return .init(top: Color.purple.opacity(0.18),
                                bottom: Color.indigo.opacity(0.14),
                                accent: .purple)
    case .scout:   return .init(top: Color.green.opacity(0.16),
                                bottom: Color.teal.opacity(0.14),
                                accent: .green)
    case .isla:    return .init(top: Color.orange.opacity(0.14),
                                bottom: Color.yellow.opacity(0.14),
                                accent: .orange)
    case .viza:    return .init(top: Color.pink.opacity(0.16),
                                bottom: Color.gray.opacity(0.10),
                                accent: .pink)
    case .drew:    return .init(top: Color.gray.opacity(0.14),
                                bottom: Color.gray.opacity(0.10),
                                accent: .mint)
    }
}

struct GradientBackground: View {
    let theme: Theme
    @State private var animate = false
    var body: some View {
        LinearGradient(colors: [theme.top, theme.bottom],
                       startPoint: animate ? .topLeading : .top,
                       endPoint: animate ? .bottomTrailing : .bottom)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

// Simple hero
struct HeroHeader: View {
    let name: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name).font(.largeTitle.bold()).foregroundStyle(.primary)
            Text(subtitle).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Glassy card




struct BulletRow: View {
    let text: String
    let icon: String
    init(_ text: String, _ icon: String) { self.text = text; self.icon = icon }
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(.primary)
            Text(text)
            Spacer()
        }
        .font(.subheadline)
    }
}

struct ShortcutGrid: View {
    struct Item: Identifiable { let id = UUID(); let title: String; let icon: String; let action: () -> Void }
    let items: [Item]
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items) { item in
                Button(action: item.action) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: item.icon).font(.title2)
                        Text(item.title).font(.headline)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.06), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// Footer dock with avatars + primary action
struct FooterDock: View {
    let homeys: [HomeyKind]
    @Binding var selected: HomeyKind
    var avatarNS: Namespace.ID
    var onAvatarLongPress: (HomeyKind) -> Void
    let primaryTitle: String
    let primaryIcon: String
    let primaryTap: () -> Void
    var currentStation: String? = nil

    @State private var adviceHomey: HomeyKind? = nil
    @State private var adviceText: String? = nil

    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(homeys, id: \.self) { h in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                selected = h
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            VStack(spacing: 4) {
                                Image(String(describing: h.rawValue))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                                Text(displayName(h))
                                    .font(.caption2)
                                    .foregroundStyle(selected == h ? .primary : .secondary)
                            }
                        }
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                            adviceText = adviceFor(homey: h, station: currentStation)
                            adviceHomey = h
                        })
                    }
                }
                .padding(.horizontal, 16)
            }
            Button(action: primaryTap) {
                Label(primaryTitle, systemImage: primaryIcon)
                    .font(.headline.weight(.semibold))
                    .padding(.vertical, 14)
            }
            .frame(width: 180)
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 10)
        .sheet(item: $adviceHomey) { homey in
            AdviceSheet(homey: homey, advice: adviceText ?? "No advice available.")
        }
    }

    private func displayName(_ h: HomeyKind) -> String {
        switch h {
        case .charlie: return "Charlie"
        case .paige:   return "Paige"
        case .scout:   return "Scout"
        case .isla:    return "Isla"
        case .viza:    return "Viza"
        case .drew:    return "Drew"
        }
    }
    
    private func adviceFor(homey: HomeyKind, station: String?) -> String {
        return "\(displayName(homey))'s advice for \(station ?? "your journey"): [Personalized tip here]"
    }
}

struct AdviceSheet: View, Identifiable {
    let id = UUID()
    let homey: HomeyKind
    let advice: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(String(describing: homey.rawValue))
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
            Text(displayName(homey))
                .font(.title)
                .bold()
            Text(advice)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Dismiss") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .padding(.top, 20)
        }
        .padding()
    }

    private func displayName(_ h: HomeyKind) -> String {
        switch h {
        case .charlie: return "Charlie"
        case .paige:   return "Paige"
        case .scout:   return "Scout"
        case .isla:    return "Isla"
        case .viza:    return "Viza"
        case .drew:    return "Drew"
        }
    }
}
