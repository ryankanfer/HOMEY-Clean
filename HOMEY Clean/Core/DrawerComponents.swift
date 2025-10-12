//
//  DrawerComponents.swift
//  HOMEY Clean
//
//  Extracted drawer components from ClientTabView
//

import SwiftUI

// MARK: - Drawer Router

final class DrawerRouter: ObservableObject {
    @Published var route: DrawerRoute?
}

// MARK: - Drawer Route Enum

enum DrawerRoute: Identifiable, Equatable {
    case arFeatures
    case insights
    case directory
    case vision
    case settings
    case matchmaker
    case profile
    case documents

    var id: String {
        switch self {
        case .arFeatures: return "arFeatures"
        case .insights: return "insights"
        case .directory: return "directory"
        case .vision: return "vision"
        case .settings: return "settings"
        case .matchmaker: return "matchmaker"
        case .profile: return "profile"
        case .documents: return "documents"
        }
    }
}

// MARK: - Left Navigation Drawer

// LeftNavigationDrawer moved to Components/LeftNavigationDrawer.swift to avoid duplication

// MARK: - Drawer Menu Item

struct DrawerMenuItem: View {
    let title: String
    let subtitle: String?
    let icon: String
    let destination: String
    @Binding var isDrawerPresented: Bool
    
    @EnvironmentObject private var router: DrawerRouter
    
    init(title: String, subtitle: String? = nil, icon: String, destination: String, isDrawerPresented: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.destination = destination
        self._isDrawerPresented = isDrawerPresented
    }
    
    var body: some View {
        Button {
            // Close drawer first
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isDrawerPresented = false
            }
            
            // Navigate based on destination
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                navigateToDestination()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.primaryAction)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func navigateToDestination() {
        switch destination {
        case "insights":
            router.route = .insights
        case "directory":
            router.route = .directory
        case "vision":
            router.route = .vision
        case "documents":
            router.route = .documents
        case "ar-features":
            router.route = .arFeatures
        case "settings":
            router.route = .settings
        case "matchmaker":
            router.route = .matchmaker
        case "profile":
            router.route = .profile
        default:
            break
        }
    }
}