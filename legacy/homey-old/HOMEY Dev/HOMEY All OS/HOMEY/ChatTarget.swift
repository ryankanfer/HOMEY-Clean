//
//  ChatTarget.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/8/25.
//


import SwiftUI

/// Who we’re chatting with.
enum ChatTarget: Equatable, Identifiable {
    case agent
    case homey(HomeyKind)

    // For `.sheet(item:)`
    var id: String {
        switch self {
        case .agent:               return "agent"
        case .homey(let kind):     return "homey-\(kind.id)"
        }
    }

    /// Title shown in the chat header.
    var title: String {
        switch self {
        case .agent:
            return "Chat · Agent"
        case .homey(let h):
            return "Chat · \(h.displayName)"
        }
    }

    /// Optional avatar image name if you want to show a circle image in the header.
    var avatarName: String? {
        switch self {
        case .agent:               return nil        // use SF Symbol, or "agentAvatar" if you have one
        case .homey(let h):        return h.assetName
        }
    }
}