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
        case .agent:               return "agent"
        case .homey(let kind):     return "homey-\(kind.id)"
        }
    }

    var title: String {
        switch self {
        case .agent:
            return "Chat · Agent"
        case .homey(let h):
            return "Chat · \(h.displayName)"
        }
    }

    var avatarName: String? {
        switch self {
        case .agent:               return nil
        case .homey(let h):        return h.assetName
        }
    }
}
