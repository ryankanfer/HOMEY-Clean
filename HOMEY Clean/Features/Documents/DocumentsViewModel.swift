//
//  DocumentsViewModel.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 9/16/25.
//

import Foundation
import SwiftUI

@MainActor
class DocumentsViewModel: ObservableObject {
    @Published var rows: [DocumentListItem] = []
    @Published var isLoading = false
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var errorMessage: String?
    
    private let documentsRepo: DocumentsRepository
    private let aiService: AIDocumentService
    private let eventsRepo: EventsRepository
    
    init(
        documentsRepo: DocumentsRepository? = nil,
        aiService: AIDocumentService = AIDocumentService(),
        eventsRepo: EventsRepository? = nil
    ) {
        self.documentsRepo = documentsRepo ?? DocumentsRepository(client: AppSessionManager.shared.supabaseClient)
        self.aiService = aiService
        self.eventsRepo = eventsRepo ?? EventsRepository(client: AppSessionManager.shared.supabaseClient)
    }
    
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            rows = try await documentsRepo.fetchDocuments()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func upload(data: Data, filename: String, mime: String) async throws {
        isUploading = true
        uploadProgress = 0.0
        
        defer { 
            isUploading = false
            uploadProgress = 0.0
        }
        
        do {
            // Track upload event
            await eventsRepo.recordEvent(.documentUpload(filename: filename, type: mime))
            
            // Step 1: Upload document (30% progress)
            uploadProgress = 0.3
            let documentId = try await documentsRepo.uploadDocument(
                data: data, 
                filename: filename, 
                mime: mime
            )
            
            // Step 2: AI Categorization (60% progress)
            uploadProgress = 0.6
            let docType = try await aiService.categorizeDocument(data: data, filename: filename)
            
            // Step 3: AI Extraction (90% progress)
            uploadProgress = 0.9
            let extractedData = try await aiService.extractDocumentData(
                data: data, 
                filename: filename, 
                docType: docType
            )
            
            // Step 4: Update document with AI results (100% progress)
            uploadProgress = 1.0
            try await documentsRepo.updateDocumentAIResults(
                id: documentId,
                docType: docType,
                extractedData: extractedData
            )
            
            // Update preferences/financials if applicable
            await updatePreferencesFromExtraction(extractedData, docType: docType)
            
            // Track completion event
            await eventsRepo.recordEvent(.documentProcessed(
                id: documentId,
                type: docType.rawValue,
                extractedFields: extractedData.keys.count
            ))
            
            await refresh()
            
        } catch {
            // Track error event
            await eventsRepo.recordEvent(.documentUploadError(
                filename: filename,
                error: error.localizedDescription
            ))
            throw error
        }
    }
    
    func deleteDocument(_ id: UUID) {
        Task {
            do {
                try await documentsRepo.deleteDocument(id: id)
                await eventsRepo.recordEvent(.documentDeleted(id: id))
                rows.removeAll { $0.id == id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateDocumentStatus(_ id: UUID, status: DocumentStatus, notes: String? = nil) async {
        do {
            try await documentsRepo.updateDocumentStatus(id: id, status: status, notes: notes)
            await eventsRepo.recordEvent(.documentStatusChanged(id: id, status: status.rawValue))
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func updatePreferencesFromExtraction(_ data: [String: Any], docType: DocumentType) async {
        // Update preferences/financials based on extracted data
        switch docType {
        case .payStub:
            if let income = data["monthly_income"] as? Double {
                await updateFinancialInfo(monthlyIncome: income)
            }
            if let employer = data["employer"] as? String {
                await updateEmploymentInfo(employer: employer)
            }
            
        case .bankStatement:
            if let bankName = data["bank_name"] as? String,
               let accountHolder = data["account_holder"] as? String {
                await updateBankingInfo(bankName: bankName, accountHolder: accountHolder)
            }
            
        case .lease:
            if let currentRent = data["monthly_rent"] as? Double {
                await updateHousingInfo(currentRent: currentRent)
            }
            if let address = data["property_address"] as? String {
                await updateAddressInfo(currentAddress: address)
            }
            
        default:
            break
        }
    }
    
    private func updateFinancialInfo(monthlyIncome: Double) async {
        // TODO: Update preferences/financials table
        print("Updating financial info: monthly income = \(monthlyIncome)")
    }
    
    private func updateEmploymentInfo(employer: String) async {
        // TODO: Update preferences table
        print("Updating employment info: employer = \(employer)")
    }
    
    private func updateBankingInfo(bankName: String, accountHolder: String) async {
        // TODO: Update preferences table
        print("Updating banking info: \(bankName), \(accountHolder)")
    }
    
    private func updateHousingInfo(currentRent: Double) async {
        // TODO: Update preferences table
        print("Updating housing info: current rent = \(currentRent)")
    }
    
    private func updateAddressInfo(currentAddress: String) async {
        // TODO: Update preferences table
        print("Updating address info: \(currentAddress)")
    }
}

// MARK: - AI Document Service
class AIDocumentService {
    func categorizeDocument(data: Data, filename: String) async throws -> DocumentType {
        // TODO: Implement actual AI categorization
        // For now, return based on filename patterns
        let lowercased = filename.lowercased()
        
        if lowercased.contains("pay") || lowercased.contains("stub") || lowercased.contains("salary") {
            return .payStub
        } else if lowercased.contains("tax") || lowercased.contains("1040") || lowercased.contains("w2") {
            return .taxReturn
        } else if lowercased.contains("bank") || lowercased.contains("statement") {
            return .bankStatement
        } else if lowercased.contains("offer") || lowercased.contains("employment") {
            return .offerLetter
        } else if lowercased.contains("lease") || lowercased.contains("rental") {
            return .lease
        } else if lowercased.contains("id") || lowercased.contains("license") || lowercased.contains("passport") {
            return .id
        } else if lowercased.contains("reference") || lowercased.contains("recommendation") {
            return .referenceLetter
        } else if lowercased.contains("board") || lowercased.contains("application") {
            return .boardForm
        }
        
        return .id // Default fallback
    }
    
    func extractDocumentData(data: Data, filename: String, docType: DocumentType) async throws -> [String: Any] {
        // TODO: Implement actual AI extraction using OCR/ML
        // For now, return mock data based on document type
        
        switch docType {
        case .payStub:
            return [
                "employer": "Tech Corp Inc.",
                "employee_name": "John Doe",
                "monthly_income": 5000.0,
                "pay_period": "Monthly",
                "gross_pay": 5000.0,
                "net_pay": 3800.0
            ]
            
        case .bankStatement:
            return [
                "bank_name": "Chase Bank",
                "account_holder": "John Doe",
                "account_number": "****1234",
                "statement_period": "Jan 2024",
                "average_balance": 15000.0
            ]
            
        case .lease:
            return [
                "property_address": "123 Main St, NYC",
                "monthly_rent": 2500.0,
                "lease_start": "2024-01-01",
                "lease_end": "2024-12-31",
                "landlord": "Property Management Co."
            ]
            
        case .offerLetter:
            return [
                "employer": "Tech Corp Inc.",
                "position": "Software Engineer",
                "annual_salary": 120000.0,
                "start_date": "2024-02-01"
            ]
            
        default:
            return [:]
        }
    }
}