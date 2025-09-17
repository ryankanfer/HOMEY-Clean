import Foundation
import Supabase

@MainActor
final class DocumentsViewModel: ObservableObject {
    @Published var rows: [[String: Any]] = []
    @Published var isUploading = false
    let repo: DocumentsRepository

    init(repo: DocumentsRepository) { self.repo = repo }

    func refresh() async {
        do { rows = try await repo.listMine() } catch { print("list error:", error) }
    }

    func upload(data: Data, filename: String, mime: String) async {
        isUploading = true
        defer { isUploading = false }
        do {
            try await repo.upload(data: data, filename: filename, mime: mime)
            await refresh()
        } catch { print("upload error:", error) }
    }
}