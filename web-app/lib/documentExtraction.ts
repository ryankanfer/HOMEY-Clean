import OpenAI from 'openai';
import {
  DocumentType,
  ExtractedData,
  LeaseData,
  InspectionData,
  PreApprovalData,
  InsuranceData,
  IdentificationData,
  PaystubData,
  BankStatementData,
  GenericData,
  DOCUMENT_VIEW_MODES,
  ViewMode,
} from '@/types/documents';

// Lazy-initialize OpenAI client to avoid build-time errors
let openaiClient: OpenAI | null = null;
function getOpenAI() {
  if (!openaiClient) {
    openaiClient = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }
  return openaiClient;
}

/**
 * Helper: Check if URL is a PDF file
 */
function isPdfFile(url: string): boolean {
  return url.toLowerCase().endsWith('.pdf') || url.includes('.pdf?');
}

/**
 * Helper: Convert PDF to images using PDF.co API
 */
async function convertPdfToImages(fileUrl: string): Promise<string[]> {
  try {
    const apiKey = process.env.PDF_CO_API_KEY;
    if (!apiKey) {
      throw new Error('PDF_CO_API_KEY not configured');
    }

    console.log('Converting PDF to images using PDF.co...');
    console.log('File URL:', fileUrl.substring(0, 100) + '...');

    // Step 1: Convert PDF to PNG images using PDF.co
    const conversionResponse = await fetch('https://api.pdf.co/v1/pdf/convert/to/png', {
      method: 'POST',
      headers: {
        'x-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        url: fileUrl,
        pages: '0-4', // First 5 pages (0-indexed) - enough for most documents
      }),
    });

    const conversionData = await conversionResponse.json();

    console.log('PDF.co Response Status:', conversionResponse.status);
    console.log('PDF.co Response:', JSON.stringify(conversionData, null, 2));

    if (!conversionResponse.ok || conversionData.error) {
      const errorMessage = conversionData.message || conversionData.error || conversionResponse.statusText;
      console.error('PDF.co API error:', errorMessage);
      throw new Error(`PDF.co conversion failed: ${errorMessage}`);
    }

    if (!conversionData.urls || conversionData.urls.length === 0) {
      throw new Error('No images returned from PDF.co');
    }

    console.log(`PDF converted to ${conversionData.urls.length} images`);
    return conversionData.urls;
  } catch (error) {
    console.error('PDF.co conversion failed:', error);
    throw error; // Propagate the actual error instead of generic message
  }
}

// Document type detection keywords
const DOCUMENT_TYPE_KEYWORDS = {
  lease: ['tenant', 'landlord', 'rent', 'lease term', 'premises', 'rental agreement'],
  inspection: ['inspection report', 'property condition', 'deficiencies', 'inspector'],
  'pre-approval': ['pre-approved', 'pre-qualification', 'mortgage', 'loan amount', 'lender'],
  insurance: ['policy', 'premium', 'coverage', 'insured', 'liability'],
  identification: ['driver license', 'passport', 'identification', 'date of birth', 'expires'],
  paystub: ['pay period', 'gross pay', 'net pay', 'earnings', 'deductions', 'employer'],
  'bank-statement': ['account number', 'statement period', 'beginning balance', 'ending balance', 'bank statement', 'wells fargo', 'chase', 'bank of america', 'bofa', 'citibank', 'checking', 'savings'],
};

/**
 * Detect document type from file name and optional preview text
 */
export async function detectDocumentType(
  fileName: string,
  previewText?: string
): Promise<DocumentType> {
  const lowerFileName = fileName.toLowerCase().replace(/[^a-z0-9]/g, ''); // Remove special chars
  const lowerText = previewText?.toLowerCase() || '';

  // Simple keyword matching first (fast)
  for (const [type, keywords] of Object.entries(DOCUMENT_TYPE_KEYWORDS)) {
    const matchCount = keywords.filter(
      (keyword) => {
        const normalizedKeyword = keyword.replace(/[^a-z0-9]/g, '');
        return lowerFileName.includes(normalizedKeyword) || lowerText.includes(keyword);
      }
    ).length;

    // Bank statements: require only 1 match (more flexible)
    // Other types: require 2 matches for accuracy
    const threshold = type === 'bank-statement' ? 1 : 2;

    if (matchCount >= threshold) {
      return type as DocumentType;
    }
  }

  // If no clear match and we have preview text, use LLM classification
  if (previewText && previewText.length > 100) {
    try {
      const response = await getOpenAI().chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: 'You are a document classifier for real estate documents. Respond with ONLY the document type, no explanation.',
          },
          {
            role: 'user',
            content: `Classify this document as one of: lease, inspection, pre-approval, insurance, identification, paystub, bank-statement, or other.\n\nDocument preview:\n${previewText.slice(0, 2000)}`,
          },
        ],
        temperature: 0.1,
        max_tokens: 20,
      });

      const classification = response.choices[0].message.content?.toLowerCase().trim();
      if (classification && classification in DOCUMENT_TYPE_KEYWORDS) {
        return classification as DocumentType;
      }
    } catch (error) {
      console.error('LLM classification failed:', error);
    }
  }

  // Default to 'other' if we can't determine
  return 'other';
}

/**
 * Get extraction schema/prompt for a specific document type
 */
function getExtractionSchema(docType: DocumentType): string {
  const schemas = {
    lease: `{
  "type": "lease",
  "property": {
    "address": "string",
    "unit": "string | null",
    "city": "string",
    "state": "string",
    "zipCode": "string"
  },
  "parties": {
    "tenant": ["string"],
    "landlord": ["string"],
    "propertyManager": "string | null"
  },
  "terms": {
    "rentAmount": number,
    "securityDeposit": number,
    "moveInDate": "YYYY-MM-DD",
    "leaseStartDate": "YYYY-MM-DD",
    "leaseEndDate": "YYYY-MM-DD",
    "leaseDuration": "string (e.g., '12 months')"
  },
  "fees": {
    "lateFee": "string | null",
    "parkingFee": number | null,
    "petFee": number | null,
    "applicationFee": number | null,
    "otherFees": [{"name": "string", "amount": number | string}] | null
  },
  "policies": {
    "petPolicy": "string",
    "smokingPolicy": "string",
    "guestPolicy": "string | null",
    "sublettingPolicy": "string | null"
  },
  "utilities": {
    "included": ["string"],
    "tenantResponsible": ["string"]
  },
  "maintenance": {
    "landlordResponsibilities": ["string"],
    "tenantResponsibilities": ["string"],
    "emergencyContact": "string | null"
  },
  "specialClauses": ["string"] | null,
  "summary": "string (2-3 sentence summary of key lease terms)"
}`,

    inspection: `{
  "type": "inspection",
  "property": {
    "address": "string",
    "propertyType": "string"
  },
  "inspection": {
    "date": "YYYY-MM-DD",
    "inspector": "string",
    "inspectorLicense": "string | null"
  },
  "summary": {
    "overallCondition": "excellent | good | fair | poor",
    "majorIssues": number,
    "minorIssues": number,
    "passFailStatus": "pass | fail | conditional"
  },
  "categories": [{
    "name": "string (e.g., 'Roof', 'Foundation', 'Electrical')",
    "status": "pass | fail | needs_repair | monitor",
    "issues": ["string"] | null,
    "estimatedRepairCost": number | null
  }],
  "estimatedTotalRepairs": number,
  "recommendations": ["string"],
  "summary": "string (2-3 sentence summary)"
}`,

    'pre-approval': `{
  "type": "pre-approval",
  "borrower": {
    "name": "string",
    "email": "string | null"
  },
  "lender": {
    "name": "string",
    "loanOfficer": "string | null",
    "phone": "string | null",
    "email": "string | null"
  },
  "approval": {
    "amount": number,
    "loanType": "string (e.g., 'Conventional', 'FHA', 'VA')",
    "interestRate": number | null,
    "term": number | null,
    "expirationDate": "YYYY-MM-DD",
    "issuedDate": "YYYY-MM-DD"
  },
  "conditions": ["string"] | null,
  "summary": "string (2-3 sentence summary)"
}`,

    insurance: `{
  "type": "insurance",
  "policy": {
    "policyNumber": "string",
    "type": "string (e.g., 'Renters', 'Homeowners')",
    "provider": "string",
    "effectiveDate": "YYYY-MM-DD",
    "expirationDate": "YYYY-MM-DD"
  },
  "coverage": {
    "personalProperty": number,
    "liability": number,
    "medicalPayments": number | null,
    "lossOfUse": number | null,
    "deductible": number
  },
  "premium": {
    "amount": number,
    "frequency": "monthly | quarterly | annually"
  },
  "insured": {
    "name": "string",
    "address": "string"
  },
  "summary": "string (2-3 sentence summary)"
}`,

    identification: `{
  "type": "identification",
  "document": {
    "type": "drivers-license | passport | state-id",
    "number": "string (partially masked for privacy)",
    "issuingState": "string | null",
    "issuingCountry": "string | null",
    "issueDate": "YYYY-MM-DD",
    "expirationDate": "YYYY-MM-DD"
  },
  "person": {
    "fullName": "string",
    "dateOfBirth": "YYYY-MM-DD",
    "address": "string | null"
  },
  "summary": "string (1-2 sentence summary)"
}`,

    paystub: `{
  "type": "paystub",
  "employee": {
    "name": "string",
    "employeeId": "string | null",
    "address": "string | null"
  },
  "employer": {
    "name": "string",
    "address": "string | null"
  },
  "payPeriod": {
    "startDate": "YYYY-MM-DD",
    "endDate": "YYYY-MM-DD",
    "payDate": "YYYY-MM-DD"
  },
  "earnings": {
    "grossPay": number,
    "netPay": number,
    "yearToDateGross": number | null,
    "yearToDateNet": number | null
  },
  "deductions": [{"type": "string", "amount": number}] | null,
  "summary": "string (1-2 sentence summary)"
}`,

    'bank-statement': `{
  "type": "bank-statement",
  "account": {
    "accountNumber": "string (last 4 digits only)",
    "accountType": "checking | savings | unknown",
    "bankName": "string"
  },
  "period": {
    "startDate": "YYYY-MM-DD",
    "endDate": "YYYY-MM-DD"
  },
  "balances": {
    "openingBalance": number,
    "closingBalance": number,
    "averageBalance": number | null
  },
  "activity": {
    "totalDeposits": number,
    "totalWithdrawals": number,
    "numberOfTransactions": number
  },
  "summary": "string (2-3 sentence summary)"
}`,

    other: `{
  "type": "other",
  "summary": "string (detailed summary of document content)",
  "keyPoints": ["string (important points from the document)"],
  "extractedText": "string (first 500 characters of document text) | null"
}`,
  };

  return schemas[docType] || schemas.other;
}

/**
 * Get system prompt for document extraction
 */
function getSystemPrompt(docType: DocumentType): string {
  return `You are an expert real estate document parser. Extract structured data from the provided document image.

IMPORTANT RULES:
1. Return ONLY valid JSON matching the schema - no markdown, no explanation
2. Use null for missing/unavailable fields
3. For dates, use YYYY-MM-DD format
4. For monetary amounts, use numbers without currency symbols
5. Be precise - extract exact values from the document
6. If text is unclear or ambiguous, use your best judgment
7. For sensitive data (SSN, full account numbers), partially mask them
8. Create a helpful summary in natural language

Expected JSON Schema:
${getExtractionSchema(docType)}`;
}

/**
 * Extract structured data from a document using OpenAI Vision
 */
export async function extractDocumentData(
  fileUrl: string,
  docType: DocumentType
): Promise<ExtractedData> {
  const startTime = Date.now();

  try {
    const isPdf = isPdfFile(fileUrl);
    let response;

    if (isPdf) {
      // Convert PDF to images using PDF.co
      console.log('Converting PDF to images...');
      const imageUrls = await convertPdfToImages(fileUrl);
      console.log(`Got ${imageUrls.length} image(s) from PDF`);

      // Use first page image for extraction (most important info)
      const firstPageUrl = imageUrls[0];

      response = await getOpenAI().chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: getSystemPrompt(docType),
          },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Extract all data from this ${docType} document according to the schema.`,
              },
              {
                type: 'image_url',
                image_url: {
                  url: firstPageUrl,
                  detail: 'high',
                },
              },
            ],
          },
        ],
        temperature: 0.1,
        max_tokens: 2000,
        response_format: { type: 'json_object' },
      });
    } else {
      // Image files: Use Vision API
      console.log('Using Vision API for image document...');
      response = await getOpenAI().chat.completions.create({
        model: 'gpt-4o', // Vision-capable model
        messages: [
          {
            role: 'system',
            content: getSystemPrompt(docType),
          },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Extract all data from this ${docType} document according to the schema.`,
              },
              {
                type: 'image_url',
                image_url: {
                  url: fileUrl,
                  detail: 'high', // High detail for better extraction
                },
              },
            ],
          },
        ],
        temperature: 0.1, // Low temperature for consistency
        max_tokens: 2000,
        response_format: { type: 'json_object' },
      });
    }

    const extractedText = response.choices[0].message.content;
    if (!extractedText) {
      throw new Error('No content returned from OpenAI');
    }

    const extractedData = JSON.parse(extractedText) as ExtractedData;
    const processingTime = Date.now() - startTime;

    console.log(`Document extraction completed in ${processingTime}ms`);

    return extractedData;
  } catch (error) {
    console.error('Document extraction failed:', error);
    throw error;
  }
}

/**
 * Get the appropriate view mode for a document type
 */
export function getViewModeForDocument(docType: DocumentType): ViewMode {
  return DOCUMENT_VIEW_MODES[docType];
}

/**
 * Validate bank statement for security issues
 */
function validateBankStatementSecurity(data: any): string[] {
  const warnings: string[] = [];

  if (data.type !== 'bank-statement') {
    return warnings;
  }

  // Check if account number is properly redacted (should only show last 4 digits)
  const accountNumber = data.account?.accountNumber;
  if (accountNumber) {
    // Remove all non-digit characters
    const digitsOnly = accountNumber.replace(/\D/g, '');

    // If more than 4 consecutive digits are visible, warn the user
    if (digitsOnly.length > 4) {
      warnings.push(
        '⚠️ SECURITY WARNING: Your full account number is visible. For your security, please redact all but the last 4 digits before sharing this document.'
      );
    }
  }

  return warnings;
}

/**
 * Calculate confidence score based on extracted data completeness
 */
export function calculateConfidence(extractedData: ExtractedData): number {
  // Count filled vs total fields (simplified version)
  const dataString = JSON.stringify(extractedData);
  const nullCount = (dataString.match(/null/g) || []).length;
  const totalFields = dataString.split(',').length;

  const filledRatio = 1 - nullCount / totalFields;
  return Math.max(0.5, Math.min(1, filledRatio)); // Clamp between 0.5 and 1
}

/**
 * Main extraction pipeline
 */
export async function processDocument(fileUrl: string, fileName: string) {
  const startTime = Date.now();

  try {
    // Step 1: Detect document type
    console.log('Detecting document type...');
    const docType = await detectDocumentType(fileName);
    console.log(`Detected type: ${docType}`);

    // Step 2: Extract structured data
    console.log('Extracting document data...');
    const extractedData = await extractDocumentData(fileUrl, docType);

    // Step 3: Determine view mode
    const viewMode = getViewModeForDocument(docType);

    // Step 4: Calculate confidence
    const confidence = calculateConfidence(extractedData);

    // Step 5: Validate security (for bank statements)
    const securityWarnings = validateBankStatementSecurity(extractedData);

    // Add warnings to extracted data for storage
    const dataWithWarnings = {
      ...extractedData,
      _securityWarnings: securityWarnings.length > 0 ? securityWarnings : undefined,
    };

    const processingTime = Date.now() - startTime;

    return {
      success: true,
      documentType: docType,
      extractedData: dataWithWarnings,
      viewMode,
      confidence,
      processingTime,
      securityWarnings: securityWarnings.length > 0 ? securityWarnings : undefined,
    };
  } catch (error) {
    console.error('Document processing failed:', error);
    return {
      success: false,
      documentType: 'other' as DocumentType,
      extractedData: {
        type: 'other',
        summary: 'Failed to extract document data',
        keyPoints: [],
      } as GenericData,
      viewMode: 'digest' as ViewMode,
      confidence: 0,
      processingTime: Date.now() - startTime,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
