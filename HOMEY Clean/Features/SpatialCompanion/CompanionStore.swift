import SwiftUI

private let activeKey = "Companion.active.module"

public enum CompanionSheet: Equatable, Identifiable {
    case modulePicker
    case help

    public var id: String {
        switch self {
        case .modulePicker: return "modulePicker"
        case .help: return "help"
        }
    }
}

public final class CompanionStore: ObservableObject {
    @Published public var active: CompanionModule = .charlie {
        didSet { saveActive() }
    }

    @Published public var depthStack: [CompanionModule]
    @Published public var sheet: CompanionSheet?

    public init(
        active: CompanionModule = .charlie,
        depthStack: [CompanionModule] = [],
        sheet: CompanionSheet? = nil
    ) {
        if let restored = Self.loadActive() {
            self.active = restored
        } else {
            self.active = active
        }
        self.depthStack = depthStack
        self.sheet = sheet
        saveActive()
    }

    public func push(_ module: CompanionModule) {
        depthStack.append(active)
        active = module
    }

    public func pop() {
        guard let last = depthStack.popLast() else { return }
        active = last
    }

    private func saveActive() {
        UserDefaults.standard.set(active.rawValue, forKey: activeKey)
    }

    private static func loadActive() -> CompanionModule? {
        guard let raw = UserDefaults.standard.string(forKey: activeKey) else { return nil }
        return CompanionModule(rawValue: raw)
    }
}
