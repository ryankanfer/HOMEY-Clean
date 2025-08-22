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
            name: "Financial Records",
            description: "Bank statements, tax returns, and financial documents",
            documents: VaultDocument.financialDocuments,
            color: .green,
            icon: "dollarsign.circle.fill",
            completionPercentage: 0.8,
            isLocked: false
        ),
        DocumentVault(
            name: "Identity & Legal",
            description: "ID, passport, birth certificate, and legal documents",
            documents: VaultDocument.identityDocuments,
            color: .blue,
            icon: "person.text.rectangle.fill",
            completionPercentage: 0.6,
            isLocked: false
        ),
        DocumentVault(
            name: "Property History",
            description: "Previous rental agreements and property records",
            documents: VaultDocument.propertyDocuments,
            color: .purple,
            icon: "house.fill",
            completionPercentage: 0.4,
            isLocked: false
        ),
        DocumentVault(
            name: "Employment",
            description: "Pay stubs, employment letters, and work history",
            documents: VaultDocument.employmentDocuments,
            color: .orange,
            icon: "briefcase.fill",
            completionPercentage: 0.9,
            isLocked: false
        ),
        DocumentVault(
            name: "Insurance",
            description: "Health, auto, and other insurance documents",
            documents: VaultDocument.insuranceDocuments,
            color: .red,
            icon: "shield.fill",
            completionPercentage: 0.3,
            isLocked: true
        ),
        DocumentVault(
            name: "References",
            description: "Personal and professional references",
            documents: VaultDocument.referenceDocuments,
            color: .cyan,
            icon: "person.2.fill",
            completionPercentage: 0.7,
            isLocked: false
        )
    ]
}

// MARK: - Vault Document Model

struct VaultDocument: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let type: DocumentType
    let status: DocumentStatus
    let uploadDate: Date?
    let fileSize: String?
    let thumbnailName: String?

    static let financialDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Bank Statement - Chase",
            type: .bankStatement,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 5),
            fileSize: "2.3 MB",
            thumbnailName: "doc_bank_statement"
        ),
        VaultDocument(
            name: "Tax Return 2023",
            type: .taxReturn,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 10),
            fileSize: "1.8 MB",
            thumbnailName: "doc_tax_return"
        ),
        VaultDocument(
            name: "Pay Stub - Current",
            type: .payStub,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 2),
            fileSize: "0.5 MB",
            thumbnailName: "doc_pay_stub"
        ),
        VaultDocument(
            name: "Credit Report",
            type: .creditReport,
            status: .pending,
            uploadDate: nil,
            fileSize: nil,
            thumbnailName: nil
        )
    ]

    static let identityDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Driver's License",
            type: .driversLicense,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 7),
            fileSize: "1.2 MB",
            thumbnailName: "doc_drivers_license"
        ),
        VaultDocument(
            name: "Social Security Card",
            type: .socialSecurity,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 7),
            fileSize: "0.8 MB",
            thumbnailName: "doc_ssn"
        ),
        VaultDocument(
            name: "Passport",
            type: .passport,
            status: .pending,
            uploadDate: nil,
            fileSize: nil,
            thumbnailName: nil
        )
    ]

    static let propertyDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Current Lease Agreement",
            type: .lease,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 15),
            fileSize: "3.1 MB",
            thumbnailName: "doc_lease"
        ),
        VaultDocument(
            name: "Rental History",
            type: .rentalHistory,
            status: .pending,
            uploadDate: nil,
            fileSize: nil,
            thumbnailName: nil
        )
    ]

    static let employmentDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Employment Letter",
            type: .employmentLetter,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 3),
            fileSize: "0.7 MB",
            thumbnailName: "doc_employment"
        ),
        VaultDocument(
            name: "Recent Pay Stubs",
            type: .payStub,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 1),
            fileSize: "1.4 MB",
            thumbnailName: "doc_pay_stubs"
        ),
        VaultDocument(
            name: "W-2 Form",
            type: .w2Form,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 8),
            fileSize: "0.9 MB",
            thumbnailName: "doc_w2"
        )
    ]

    static let insuranceDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Health Insurance Card",
            type: .insurance,
            status: .pending,
            uploadDate: nil,
            fileSize: nil,
            thumbnailName: nil
        ),
        VaultDocument(
            name: "Auto Insurance",
            type: .insurance,
            status: .pending,
            uploadDate: nil,
            fileSize: nil,
            thumbnailName: nil
        )
    ]

    static let referenceDocuments: [VaultDocument] = [
        VaultDocument(
            name: "Personal Reference - John",
            type: .reference,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 6),
            fileSize: "0.3 MB",
            thumbnailName: "doc_reference"
        ),
        VaultDocument(
            name: "Professional Reference - Manager",
            type: .reference,
            status: .uploaded,
            uploadDate: Date().addingTimeInterval(-86400 * 4),
            fileSize: "0.4 MB",
            thumbnailName: "doc_reference"
        ),
        VaultDocument(
            name: "Landlord Reference",
            type: .reference,
            status: .pending,
            uploadDate: nil,
            fileSize: nil,
            thumbnailName: nil
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
