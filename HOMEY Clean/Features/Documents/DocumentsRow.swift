import Foundation

struct DocumentListItem: Identifiable {
    let id: UUID
    var name: String
    var displayStatus: String
    var extractedData: [String: Any]?
    var agentNotes: String?
    var uploadedAt: Date
    var docType: DocumentType?
    var canDelete: Bool

    init(
        id: UUID,
        name: String,
        displayStatus: String,
        extractedData: [String: Any]? = nil,
        agentNotes: String? = nil,
        uploadedAt: Date,
        docType: DocumentType? = nil,
        canDelete: Bool = true
    ) {
        self.id = id
        self.name = name
        self.displayStatus = displayStatus
        self.extractedData = extractedData
        self.agentNotes = agentNotes
        self.uploadedAt = uploadedAt
        self.docType = docType
        self.canDelete = canDelete
    }
}