import Foundation
import SwiftUI

struct AlertState: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var message: String?
    var primaryActionTitle: String = "OK"
    var primaryAction: (() -> Void)? = nil

    static func == (lhs: AlertState, rhs: AlertState) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.primaryActionTitle == rhs.primaryActionTitle
    }
}

enum SheetRoute: Identifiable, Equatable {
    case vaultDetail(DocumentVault)
    case arScanner
    case educationCenter
    case helpSupport

    var id: String {
        switch self {
        case .vaultDetail(let v): return "vault-\(v.id)"
        case .arScanner: return "arScanner"
        case .educationCenter: return "educationCenter"
        case .helpSupport: return "helpSupport"
        }
    }

    static func == (lhs: SheetRoute, rhs: SheetRoute) -> Bool {
        lhs.id == rhs.id
    }
}

final class PresentationController: ObservableObject {
    @Published var activeSheet: SheetRoute?
    @Published var alert: AlertState?

    func present(sheet: SheetRoute) {
        activeSheet = sheet
    }

    func presentAlert(title: String, message: String? = nil, primary: String = "OK", action: (() -> Void)? = nil) {
        alert = AlertState(title: title, message: message, primaryActionTitle: primary, primaryAction: action)
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func dismissAlert() {
        alert = nil
    }
}