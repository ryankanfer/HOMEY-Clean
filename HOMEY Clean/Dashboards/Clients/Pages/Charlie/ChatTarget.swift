import SwiftUI

public enum ChatTarget: Equatable, Identifiable {
    case agent
    case homey(HomeyKind)

    public var id: String {
        switch self {
        case .agent:               return "agent"
        case .homey(let kind):     return "homey-\(kind.id)"
        }
    }

    public var title: String {
        switch self {
        case .agent:
            return "Chat · Agent"
        case .homey(let h):
            return "Chat · \(h.displayName)"
        }
    }

    public var avatarName: String? {
        switch self {
        case .agent:               return nil
        case .homey(let h):        return h.assetName
        }
    }
}