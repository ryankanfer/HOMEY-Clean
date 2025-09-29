import SwiftUI
import UIKit

/// Presents SwiftUI content modally above the top-most view controller.
/// Useful for cross-screen events (e.g., when a map expands) where the origin
/// view may not be in the current hierarchy.
enum GlobalModalPresenter {
    private static var overlayWindow: UIWindow?

    /// Presents the given SwiftUI content using a page sheet with the provided detents.
    static func present<Content: View>(
        _ content: Content,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        animated: Bool = true
    ) {
        guard let top = topMostViewController() else { return }
        let host = UIHostingController(rootView: AnyView(content))
        host.modalPresentationStyle = .pageSheet
        if let sheet = host.sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        top.present(host, animated: animated)
    }
    
    /// Presents the given SwiftUI content over full screen with a dimmed backdrop.
    static func presentFullScreen<Content: View>(
        _ content: Content,
        animated: Bool = true,
        dimming: UIColor = UIColor.black.withAlphaComponent(0.35)
    ) {
        guard let top = topMostViewController() else { return }
        DispatchQueue.main.async {
            let wrapped = AnyView(
                ZStack {
                    Color(uiColor: dimming).ignoresSafeArea()
                    AnyView(content)
                }
            )
            let host = UIHostingController(rootView: wrapped)
            host.modalPresentationStyle = .overFullScreen
            host.view.backgroundColor = .clear
            top.present(host, animated: animated)
        }
    }

    /// Presents above all UI by creating a temporary UIWindow at alert level.
    /// Useful when the current presenter is itself a sheet and you need to escape its bounds.
    static func presentOverlayWindow<Content: View>(
        _ content: Content,
        animated: Bool = true,
        dimming: UIColor = UIColor.black.withAlphaComponent(0.35)
    ) {
        DispatchQueue.main.async {
            // If an overlay is already showing, dismiss it first.
            dismissOverlay()

            let scene: UIWindowScene? = topMostViewController()?.view.window?.windowScene
                ?? UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first { $0.activationState == .foregroundActive }
                ?? UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first
            guard let windowScene = scene else { return }

            let window = UIWindow(windowScene: windowScene)
            window.windowLevel = .alert + 2
            window.backgroundColor = .clear

            let host = UIHostingController(rootView: AnyView(
                ZStack {
                    Color(uiColor: dimming).ignoresSafeArea()
                    AnyView(content)
                }
            ))
            host.view.backgroundColor = .clear

            window.rootViewController = host
            window.makeKeyAndVisible()
            overlayWindow = window

            if animated {
                host.view.alpha = 0
                UIView.animate(withDuration: 0.22) {
                    host.view.alpha = 1
                }
            }
        }
    }

    /// Dismisses the overlay window if present.
    static func dismissOverlay(animated: Bool = true) {
        guard let window = overlayWindow else { return }
        let complete = {
            window.isHidden = true
            window.rootViewController = nil
            overlayWindow = nil
        }
        if animated, let view = window.rootViewController?.view {
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0
            }, completion: { _ in complete() })
        } else {
            complete()
        }
    }

    // MARK: - Private helpers

    private static func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC: UIViewController? = {
            if let base = base { return base }
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first
            let window = windowScene?.windows.first { $0.isKeyWindow }
            return window?.rootViewController
        }()

        guard let baseVC else { return nil }

        if let nav = baseVC as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = baseVC as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = baseVC.presentedViewController {
            return topMostViewController(base: presented)
        }
        return baseVC
    }
}
