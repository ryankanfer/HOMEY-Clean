//
//  ChatTarget.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI

enum ChatTarget: Equatable, Identifiable {
    case agent
    case homey(HomeyKind)

    var id: String {
        switch self {
        case .agent: return "agent"
        case let .homey(kind): return "homey-\(kind.id)"
        }
    }

    var title: String {
        switch self {
        case .agent:
            return "Chat · Agent"
        case let .homey(h):
            return "Chat · \(h.displayName)"
        }
    }

    var avatarName: String? {
        switch self {
        case .agent: return nil
        case let .homey(h): return h.assetName
        }
    }
}
