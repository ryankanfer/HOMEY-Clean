/* ShareViewController scaffold from previous step */
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        handleItems()
    }

    private func handleItems() {
        guard let items = (extensionContext?.inputItems as? [NSExtensionItem]), !items.isEmpty else {
            complete()
            return
        }

        var capturedURL: String?
        var capturedText: String?
        var imageURL: String?

        let group = DispatchGroup()

        for item in items {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                        if let u = item as? URL { capturedURL = u.absoluteString }
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, _ in
                        if let s = item as? String { capturedText = s }
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, _ in
                        if let u = item as? URL { imageURL = u.absoluteString }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            // Route either via App Group (A) or URL scheme (B)
            #if USE_APP_GROUPS
                let payload: [String: Any] = [
                    "createdAt": ISO8601DateFormatter().string(from: Date()),
                    "source": "share",
                    "url": capturedURL as Any,
                    "text": capturedText as Any,
                    "imageURL": imageURL as Any,
                ]
                PayloadBridge().writeBookmarkPayload(payload)
                self.complete()
            #else
                // No App Group: bounce to the app with a custom URL
                // No App Group: bounce to the app with a custom URL
                var comps = URLComponents()
                comps.scheme = "homey"
                comps.host = "ingest"

                var items: [URLQueryItem] = []
                if let u = capturedURL { items.append(.init(name: "url", value: u)) } // URL of the listing
                if let t = capturedText { items.append(.init(name: "text", value: t)) } // any selected text
                if let i = imageURL { items.append(.init(name: "imageURL", value: i)) } // optional image URL
                comps.queryItems = items.isEmpty ? nil : items // URLComponents will percent-encode

                if let url = comps.url {
                    self.extensionContext?.open(url) { _ in
                        self.complete()
                    }
                } else {
                    self.complete()
                }
            #endif
        }
    }

    private func complete() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
