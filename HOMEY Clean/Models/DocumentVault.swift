import Foundation
import SwiftUI

// MARK: - Document Vault Model

struct DocumentVault: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let documents: [VaultDocument]
    let color: Color
    let icon: String
    let completionPercentage: Double
    let isLocked: Bool

    static let sampleVaults: [DocumentVault] = [
        DocumentVault(
            name: "Identity",
            description: "ID, passport, birth certificate, and legal documents",
            documents: VaultDocument.identityDocuments,
            color: Color(red: 0.45, green: 0.52, blue: 0.65), // Slate blue
            icon: "person.text.rectangle.fill",
            completionPercentage: 0.6,
            isLocked: false
        ),
        DocumentVault(
            name: "Employment",
            description: "Pay stubs, employment letters, and work history",
            documents: VaultDocument.employmentDocuments,
            color: Color(red: 0.75, green: 0.62, blue: 0.45), // Warm amber
            icon: "briefcase.fill",
            completionPercentage: 0.9,
            isLocked: false
        ),
        DocumentVault(
            name: "Financial Records",
            description: "Bank statements, tax returns, and financial documents",
            documents: VaultDocument.financialDocuments,
            color: Color(red: 0.55, green: 0.65, blue: 0.50), // Sage green
            icon: "dollarsign.circle.fill",
            completionPercentage: 0.8,
            isLocked: false
        ),
        DocumentVault(
            name: "References",
            description: "Personal and professional references",
            documents: VaultDocument.referenceDocuments,
            color: Color(red: 0.55, green: 0.55, blue: 0.58), // Neutral gray
            icon: "person.2.fill",
            completionPercentage: 0.7,
            isLocked: false
        ),
        DocumentVault(
            name: "Everything Else",
            description: "Insurance, property history, and other documents",
            documents: VaultDocument.everythingElseDocuments,
            color: Color(red: 0.58, green: 0.50, blue: 0.62), // Dusty purple
            icon: "folder.fill",
            completionPercentage: 0.35,
            isLocked: false
        )
    ]
}

// MARK: - Vault Document Model

struct VaultDocument: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let type: DocumentType
    let status: DocumentStatus
    let uploadDate: Date?
    let fileSize: String?
    let thumbnailName: String?
    
    init(name: String, type: DocumentType, status: DocumentStatus, uploadDate: Date?, fileSize: String?, thumbnailName: String?) {
        self.name = name
        self.type = type
        self.status = status
        self.uploadDate = uploadDate
        self.fileSize = fileSize
        self.thumbnailName = thumbnailName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: VaultDocument, rhs: VaultDocument) -> Bool {
        return lhs.id == rhs.id
    }

    static let financialDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Bank Statement - Chase",
            type: DocumentType.bankStatement,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 5),
            fileSize: "2.3 MB",
            thumbnailName: "doc_bank_statement"
        ),
        VaultDocument(
            name: "Tax Return 2023",
            type: DocumentType.taxReturn,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 10),
            fileSize: "1.8 MB",
            thumbnailName: "doc_tax_return"
        ),
        VaultDocument(
            name: "Pay Stub - Current",
            type: DocumentType.payStub,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 2),
            fileSize: "0.5 MB",
            thumbnailName: "doc_pay_stub"
        ),
        VaultDocument(
            name: "Credit Report",
            type: DocumentType.creditReport,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        )
    ]

    static let identityDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Driver's License",
            type: DocumentType.driversLicense,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 7),
            fileSize: "1.2 MB",
            thumbnailName: "doc_drivers_license"
        ),
        VaultDocument(
            name: "Social Security Card",
            type: DocumentType.socialSecurity,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 7),
            fileSize: "0.8 MB",
            thumbnailName: "doc_ssn"
        ),
        VaultDocument(
            name: "Passport",
            type: DocumentType.passport,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        )
    ]

    static let propertyDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Current Lease Agreement",
            type: DocumentType.lease,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 15),
            fileSize: "3.1 MB",
            thumbnailName: "doc_lease"
        ),
        VaultDocument(
            name: "Rental History",
            type: DocumentType.rentalHistory,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        )
    ]

    static let employmentDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Employment Letter",
            type: DocumentType.employmentLetter,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 3),
            fileSize: "1.1 MB",
            thumbnailName: "doc_employment"
        ),
        VaultDocument(
            name: "Recent Pay Stubs",
            type: DocumentType.payStub,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 1),
            fileSize: "2.4 MB",
            thumbnailName: "doc_pay_stub"
        ),
        VaultDocument(
            name: "W-2 Form",
            type: DocumentType.w2Form,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        )
    ]

    static let insuranceDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Health Insurance Card",
            type: DocumentType.insurance,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        ),
        VaultDocument(
            name: "Auto Insurance",
            type: DocumentType.insurance,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        )
    ]

    static let referenceDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Personal Reference - John",
            type: DocumentType.reference,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 6),
            fileSize: "0.3 MB",
            thumbnailName: "doc_reference"
        ),
        VaultDocument(
            name: "Professional Reference - Manager",
            type: DocumentType.reference,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 4),
            fileSize: "0.4 MB",
            thumbnailName: "doc_reference"
        ),
        VaultDocument(
            name: "Landlord Reference",
            type: DocumentType.reference,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        )
    ]

    static let everythingElseDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Health Insurance Card",
            type: DocumentType.insurance,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        ),
        VaultDocument(
            name: "Auto Insurance",
            type: DocumentType.insurance,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        ),
        VaultDocument(
            name: "Current Lease Agreement",
            type: DocumentType.lease,
            status: DocumentStatus.uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 15),
            fileSize: "3.1 MB",
            thumbnailName: "doc_lease"
        ),
        VaultDocument(
            name: "Rental History",
            type: DocumentType.rentalHistory,
            status: DocumentStatus.pending,
            uploadDate: nil as Date?,
            fileSize: nil as String?,
            thumbnailName: nil as String?
        )
    ]
}

// MARK: - Document Type

enum DocumentType: String, CaseIterable {
    case bankStatement = "Bank Statement"
    case taxReturn = "Tax Return"
    case payStub = "Pay Stub"
    case creditReport = "Credit Report"
    case driversLicense = "Driver's License"
    case socialSecurity = "Social Security Card"
    case passport = "Passport"
    case lease = "Lease Agreement"
    case rentalHistory = "Rental History"
    case employmentLetter = "Employment Letter"
    case w2Form = "W-2 Form"
    case insurance = "Insurance"
    case reference = "Reference"
    case offerLetter = "Offer Letter"
    case id = "ID"
    case referenceLetter = "Reference Letter"
    case boardForm = "Board Form"

    var displayName: String {
        switch self {
        case .bankStatement: return "Bank Statement"
        case .taxReturn: return "Tax Return"
        case .payStub: return "Pay Stub"
        case .creditReport: return "Credit Report"
        case .driversLicense: return "Driver's License"
        case .socialSecurity: return "Social Security Card"
        case .passport: return "Passport"
        case .lease: return "Lease Agreement"
        case .rentalHistory: return "Rental History"
        case .employmentLetter: return "Employment Letter"
        case .w2Form: return "W-2 Form"
        case .insurance: return "Insurance"
        case .reference: return "Reference"
        case .offerLetter: return "Offer Letter"
        case .id: return "ID"
        case .referenceLetter: return "Reference Letter"
        case .boardForm: return "Board Form"
        }
    }

    var systemIcon: String {
        switch self {
        case .bankStatement:
            return "building.columns.fill"
        case .taxReturn:
            return "doc.text.fill"
        case .payStub:
            return "dollarsign.square.fill"
        case .creditReport:
            return "chart.line.uptrend.xyaxis"
        case .driversLicense:
            return "car.fill"
        case .socialSecurity:
            return "person.crop.rectangle.fill"
        case .passport:
            return "book.closed.fill"
        case .lease:
            return "house.fill"
        case .rentalHistory:
            return "clock.arrow.circlepath"
        case .employmentLetter:
            return "briefcase.fill"
        case .w2Form:
            return "doc.plaintext.fill"
        case .insurance:
            return "shield.fill"
        case .reference:
            return "person.2.fill"
        case .offerLetter:
            return "doc.text.fill"
        case .id:
            return "person.crop.rectangle.fill"
        case .referenceLetter:
            return "person.2.fill"
        case .boardForm:
            return "doc.plaintext.fill"
        }
    }
}

// MARK: - Document Status

enum DocumentStatus: String, CaseIterable {
    case pending = "Pending"
    case uploaded = "Uploaded"
    case verified = "Verified"
    case rejected = "Rejected"

    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .uploaded:
            return .blue
        case .verified:
            return .green
        case .rejected:
            return .red
        }
    }

    var systemIcon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .uploaded:
            return "checkmark.circle.fill"
        case .verified:
            return "checkmark.seal.fill"
        case .rejected:
            return "xmark.circle.fill"
        }
    }

    var displayName: String {
        return rawValue
    }
}
