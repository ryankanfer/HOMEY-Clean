import UIKit
import Social
import UniformTypeIdentifiers
import Supabase

final class ShareViewController: SLComposeServiceViewController {
    private let supabase = SupabaseManager.shared.client
    
    override func isContentValid() -> Bool { true }

    override func didSelectPost() {
        extractURL { [weak self] url in
            guard let self else { return }
            if let url {
                self.save(url: url) { _ in
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
            } else {
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    override func configurationItems() -> [Any]! { [] }

    private func extractURL(completion: @escaping (URL?) -> Void) {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { completion(nil); return }
        for item in items {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (data, _) in
                        let url = data as? URL
                        completion(url)
                    }
                    return
                }
            }
        }
        completion(nil)
    }

    private func save(url: URL, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let user = try await supabase.auth.user()
                guard user != nil else {
                    console("User is not logged in.")
                    // Here you could show an alert to the user
                    completion(false)
                    return
                }

                let response = try await supabase.functions.invoke("saveListing", options: .init(body: [
                    "source": "streeteasy",
                    "listing_url": url.absoluteString
                ]))
                console("Successfully saved listing. Response: \(String(describing: response))")
                completion(true)
            } catch {
                console("Error saving listing: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    private func console(_ message: String) {
        NSLog("HOMEY Share Extension: \(message)")
    }
}