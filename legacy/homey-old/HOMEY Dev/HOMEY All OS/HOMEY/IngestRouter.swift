/* IngestRouter for URLs */
import Foundation

public struct IngestRequest {
    public let sharedURL: String?
    public let sharedText: String?
    public init(sharedURL: String?, sharedText: String? = nil) {
        self.sharedURL = sharedURL
        self.sharedText = sharedText
    }
}

public enum IngestRouter {
    public static func handle(url: URL) -> IngestRequest? {
        guard url.scheme == "homey", url.host == "ingest" else { return nil }
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let u = comps?.queryItems?.first(where: { $0.name == "url" })?.value?.removingPercentEncoding
        let t = comps?.queryItems?.first(where: { $0.name == "text" })?.value?.removingPercentEncoding
        return IngestRequest(sharedURL: u, sharedText: t)
    }
}
