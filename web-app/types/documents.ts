// Document Types
export type DocumentType =
  | 'lease'
  | 'inspection'
  | 'pre-approval'
  | 'insurance'
  | 'identification' 
  | 'paystub'
  | 'bank-statement'
  | 'other';

// View Modes for X-Ray
export type ViewMode = 'executive' | 'card' | 'digest';

// Base Document Interface
export interface Document {
  id: string;
  userId: string;
  type: DocumentType;
  fileName: string;
  fileUrl: string;
  fileSize: number;
  uploadedAt: string;
  extractedData?: ExtractedData;
  extractionStatus: 'pending' | 'processing' | 'completed' | 'failed';
  extractionError?: string;
  viewMode?: ViewMode;
}

// Extracted Data Union Type
export type ExtractedData =
  | LeaseData
  | InspectionData
  | PreApprovalData
  | InsuranceData
  | IdentificationData
  | PaystubData
  | BankStatementData
  | GenericData;

// Lease Extraction Schema
export interface LeaseData {
  type: 'lease';
  property: {
    address: string;
    unit?: string;
    city: string;
    state: string;
    zipCode: string;
  };
  parties: {
    tenant: string[];
    landlord: string[];
    propertyManager?: string;
  };
  terms: {
    rentAmount: number;
    securityDeposit: number;
    moveInDate: string; // ISO date
    leaseStartDate: string;
    leaseEndDate: string;
    leaseDuration: string; // e.g., "12 months"
  };
  fees: {
    lateFee?: string;
    parkingFee?: number;
    petFee?: number;
    applicationFee?: number;
    otherFees?: Array<{
      name: string;
      amount: number | string;
    }>;
  };
  policies: {
    petPolicy: string;
    smokingPolicy: string;
    guestPolicy?: string;
    sublettingPolicy?: string;
  };
  utilities: {
    included: string[];
    tenantResponsible: string[];
  };
  maintenance: {
    landlordResponsibilities: string[];
    tenantResponsibilities: string[];
    emergencyContact?: string;
  };
  specialClauses?: string[];
  summary?: string;
}

// Inspection Extraction Schema
export interface InspectionData {
  type: 'inspection';
  property: {
    address: string;
    propertyType: string;
  };
  inspection: {
    date: string;
    inspector: string;
    inspectorLicense?: string;
  };
  summary: {
    overallCondition: 'excellent' | 'good' | 'fair' | 'poor';
    majorIssues: number;
    minorIssues: number;
    passFailStatus: 'pass' | 'fail' | 'conditional';
  };
  categories: Array<{
    name: string;
    status: 'pass' | 'fail' | 'needs_repair' | 'monitor';
    issues?: string[];
    estimatedRepairCost?: number;
  }>;
  estimatedTotalRepairs: number;
  recommendations: string[];
  summary?: string;
}

// Pre-Approval Extraction Schema
export interface PreApprovalData {
  type: 'pre-approval';
  borrower: {
    name: string;
    email?: string;
  };
  lender: {
    name: string;
    loanOfficer?: string;
    phone?: string;
    email?: string;
  };
  approval: {
    amount: number;
    loanType: string; // e.g., "Conventional", "FHA", "VA"
    interestRate?: number;
    term?: number; // in months
    expirationDate: string;
    issuedDate: string;
  };
  conditions?: string[];
  summary?: string;
}

// Insurance Extraction Schema
export interface InsuranceData {
  type: 'insurance';
  policy: {
    policyNumber: string;
    type: string; // "Renters", "Homeowners", etc.
    provider: string;
    effectiveDate: string;
    expirationDate: string;
  };
  coverage: {
    personalProperty: number;
    liability: number;
    medicalPayments?: number;
    lossOfUse?: number;
    deductible: number;
  };
  premium: {
    amount: number;
    frequency: 'monthly' | 'quarterly' | 'annually';
  };
  insured: {
    name: string;
    address: string;
  };
  summary?: string;
}

// Identification Extraction Schema
export interface IdentificationData {
  type: 'identification';
  document: {
    type: 'drivers-license' | 'passport' | 'state-id';
    number: string;
    issuingState?: string;
    issuingCountry?: string;
    issueDate: string;
    expirationDate: string;
  };
  person: {
    fullName: string;
    dateOfBirth: string;
    address?: string;
  };
  summary?: string;
}

// Paystub Extraction Schema
export interface PaystubData {
  type: 'paystub';
  employee: {
    name: string;
    employeeId?: string;
    address?: string;
  };
  employer: {
    name: string;
    address?: string;
  };
  payPeriod: {
    startDate: string;
    endDate: string;
    payDate: string;
  };
  earnings: {
    grossPay: number;
    netPay: number;
    yearToDateGross?: number;
    yearToDateNet?: number;
  };
  deductions?: Array<{
    type: string;
    amount: number;
  }>;
  summary?: string;
}

// Bank Statement Extraction Schema
export interface BankStatementData {
  type: 'bank-statement';
  account: {
    accountNumber: string; // Partially masked
    accountType: 'checking' | 'savings' | 'unknown';
    bankName: string;
  };
  period: {
    startDate: string;
    endDate: string;
  };
  balances: {
    openingBalance: number;
    closingBalance: number;
    averageBalance?: number;
  };
  activity: {
    totalDeposits: number;
    totalWithdrawals: number;
    numberOfTransactions: number;
  };
  summary?: string;
}

// Generic fallback for unstructured documents
export interface GenericData {
  type: 'other';
  summary: string;
  keyPoints?: string[];
  extractedText?: string;
}

// API Response Types
export interface DocumentExtractionRequest {
  documentId: string;
  fileUrl: string;
  fileName: string;
}

export interface DocumentExtractionResponse {
  success: boolean;
  documentType: DocumentType;
  extractedData: ExtractedData;
  viewMode: ViewMode;
  confidence: number; // 0-1
  processingTime: number; // in ms
  securityWarnings?: string[]; // Security warnings (e.g., unredacted account numbers)
  error?: string;
}

// Document type to view mode mapping
export const DOCUMENT_VIEW_MODES: Record<DocumentType, ViewMode> = {
  'lease': 'executive',
  'inspection': 'card',
  'pre-approval': 'digest',
  'insurance': 'digest',
  'identification': 'card',
  'paystub': 'executive',
  'bank-statement': 'executive',
  'other': 'digest',
};
