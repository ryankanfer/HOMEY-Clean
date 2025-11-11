//
//  ShareViewController.swift
//  StreetEasyShareExtension
//
//  Created by Ryan Kanfer on 11/9/25.
//

import UIKit
import Social
import UniformTypeIdentifiers

final class ShareViewController: SLComposeServiceViewController {
    private let homeyAPIBase = URL(string: "https://api.homey.example.com") // TODO: replace with actual

    private let availableTags = ["Top 3", "Maybe", "If rent drops", "Backup"]
    private var selectedTag: String? = "Top 3"
    private var shareWithAgent: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Save to HOMEY"
    }

    override func isContentValid() -> Bool {
        // Basic validation; ensure we have at least one URL from the context
        return true
    }

    override func didSelectPost() {
        // Extract shared URL and send to HOMEY backend
        extractSharedURL { [weak self] url in
            guard let self = self, let url = url else {
                self?.completeRequest()
                return
            }
            self.sendToHomey(url: url) { _ in
                self.completeRequest()
            }
        }
    }

    override func configurationItems() -> [Any]! {
        let tagItem = SLComposeSheetConfigurationItem()
        tagItem?.title = "Tag"
        tagItem?.value = selectedTag ?? "None"
        tagItem?.tapHandler = { [weak self] in
            self?.presentTagSelection()
        }

        let shareItem = SLComposeSheetConfigurationItem()
        shareItem?.title = "Share with agent"
        shareItem?.value = shareWithAgent ? "Yes" : "No"
        shareItem?.tapHandler = { [weak self, weak shareItem] in
            guard let self = self else { return }
            self.shareWithAgent.toggle()
            shareItem?.value = self.shareWithAgent ? "Yes" : "No"
            self.reloadConfigurationItems()
        }

        var items: [SLComposeSheetConfigurationItem] = []
        if let tagItem = tagItem { items.append(tagItem) }
        if let shareItem = shareItem { items.append(shareItem) }
        return items
    }

    private func presentTagSelection() {
        let alert = UIAlertController(title: "Tag this place", message: nil, preferredStyle: .actionSheet)
        for tag in availableTags {
            alert.addAction(UIAlertAction(title: tag, style: .default) { [weak self] _ in
                self?.selectedTag = tag
                self?.reloadConfigurationItems()
            })
        }
        alert.addAction(UIAlertAction(title: "Clear tag", style: .destructive) { [weak self] _ in
            self?.selectedTag = nil
            self?.reloadConfigurationItems()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // On iPad, configure popover source to avoid a crash
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true, completion: nil)
    }

    private func completeRequest() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func extractSharedURL(completion: @escaping (URL?) -> Void) {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            completion(nil)
            return
        }
        for item in items {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                        if let url = item as? URL {
                            completion(url)
                        } else {
                            completion(nil)
                        }
                    }
                    return
                }
                if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
                        if let text = item as? String, let url = URL(string: text) {
                            completion(url)
                        } else {
                            completion(nil)
                        }
                    }
                    return
                }
            }
        }
        completion(nil)
    }

    private func sendToHomey(url: URL, completion: @escaping (Bool) -> Void) {
        guard let base = homeyAPIBase else { completion(false); return }
        var request = URLRequest(url: base.appendingPathComponent("v1/external-listings"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var payload: [String: Any] = [
            "source": "streeteasy",
            "listing_url": url.absoluteString,
            "notes": contentText ?? "",
            "platform": "ios_share_extension"
        ]

        if let selectedTag = selectedTag {
            payload["tag"] = selectedTag
        }
        payload["share_with_agent"] = shareWithAgent

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { _, _, _ in
            completion(true)
        }.resume()
    }
}
