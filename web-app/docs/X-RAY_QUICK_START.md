# X-Ray Document Extraction - Quick Start

## ✅ What's Been Built

The complete MVP X-Ray extraction system is ready to use:

1. **Type Definitions** (`/types/documents.ts`)
   - 8 document types supported (lease, inspection, pre-approval, insurance, ID, paystub, bank statement, other)
   - Complete TypeScript interfaces for each type
   - View mode mappings (executive, card, digest)

2. **Extraction Service** (`/lib/documentExtraction.ts`)
   - Auto document type detection
   - OpenAI Vision (GPT-4o) extraction
   - Structured data extraction with JSON schemas
   - Confidence scoring

3. **API Endpoint** (`/app/api/documents/extract/route.ts`)
   - POST `/api/documents/extract`
   - GET `/api/documents/extract?test=true` (test endpoint)
   - 60-second timeout for large documents

4. **React Hooks** (`/hooks/useDocumentExtraction.ts`)
   - `useDocumentExtraction()` - Single document
   - `useBatchDocumentExtraction()` - Multiple documents
   - Progress tracking, error handling

5. **Documentation** (`/docs/DOCUMENT_EXTRACTION.md`)
   - Complete usage guide
   - Example components
   - Cost estimation
   - Troubleshooting

## 🚀 Quick Setup (3 minutes)

### Step 1: Add OpenAI API Key

Add to `.env.local`:
```bash
OPENAI_API_KEY=sk-proj-...your-key-here
```

Get key: https://platform.openai.com/api-keys

### Step 2: Test the API

```bash
curl http://localhost:3000/api/documents/extract?test=true
```

Expected response:
```json
{
  "status": "OK",
  "message": "Document extraction API is running",
  "supportedDocumentTypes": ["lease", "inspection", "pre-approval", ...]
}
```

### Step 3: Extract Your First Document

```typescript
import { useDocumentExtraction } from '@/hooks/useDocumentExtraction';

function MyComponent() {
  const { extractDocument, isProcessing, result } = useDocumentExtraction();

  const handleExtract = async () => {
    const extraction = await extractDocument(
      'https://example.com/lease.pdf',
      'lease.pdf'
    );

    console.log('Type:', extraction.documentType);
    console.log('Data:', extraction.extractedData);
    console.log('View Mode:', extraction.viewMode); // 'executive' | 'card' | 'digest'
  };

  return (
    <button onClick={handleExtract} disabled={isProcessing}>
      {isProcessing ? 'Extracting...' : 'Extract Document'}
    </button>
  );
}
```

## 📊 What Gets Extracted

### Lease Documents → Executive Mode
```json
{
  "rentAmount": 2400,
  "moveInDate": "2024-06-01",
  "securityDeposit": 2400,
  "petPolicy": "Cats allowed with $300 deposit",
  "utilities": {
    "included": ["Water", "Trash"],
    "tenantResponsible": ["Electric", "Gas", "Internet"]
  }
}
```

### Inspection Documents → Card Mode
```json
{
  "overallCondition": "good",
  "majorIssues": 2,
  "estimatedTotalRepairs": 5400,
  "categories": [
    {
      "name": "Roof",
      "status": "needs_repair",
      "estimatedRepairCost": 3500
    }
  ]
}
```

### Pre-Approval Documents → Digest Mode
```json
{
  "approval": {
    "amount": 450000,
    "loanType": "Conventional",
    "interestRate": 6.75,
    "expirationDate": "2025-03-15"
  },
  "summary": "Pre-approved for $450K conventional loan at 6.75% APR..."
}
```

## 💰 Cost

- **Per document**: ~$0.005 - $0.01 (half a cent)
- **1000 documents**: ~$5-10 total
- **Processing time**: 3-5 seconds average

## 🔧 Integration with Vault

Add to your document upload flow:

```typescript
// 1. User uploads document
const file = await uploadToSupabase(selectedFile);

// 2. Extract data immediately
const extraction = await extractDocument(file.publicUrl, file.name);

// 3. Save extracted data to database
await supabase.from('documents').update({
  extracted_data: extraction.extractedData,
  document_type: extraction.documentType,
  view_mode: extraction.viewMode,
  extraction_confidence: extraction.confidence,
}).eq('id', documentId);

// 4. Show X-Ray view in UI
if (extraction.viewMode === 'executive') {
  return <ExecutiveView data={extraction.extractedData} />;
} else if (extraction.viewMode === 'card') {
  return <CardView data={extraction.extractedData} />;
} else {
  return <DigestView data={extraction.extractedData} />;
}
```

## 📝 Next Steps

1. **Create X-Ray display components**:
   - `/components/vault/ExecutiveView.tsx` - Line-item layout
   - `/components/vault/CardView.tsx` - Visual grid
   - `/components/vault/DigestView.tsx` - Narrative summary

2. **Add database schema** for storing extracted documents

3. **Build "Quick Actions"**:
   - "Add to Calendar" button next to move-in dates
   - "Set up Auto-Pay" for rent amounts
   - "Schedule Tour" for properties

4. **Implement semantic search** for "Ask your vault..."

## 🎯 Files Reference

- **Types**: `/types/documents.ts`
- **Service**: `/lib/documentExtraction.ts`
- **API**: `/app/api/documents/extract/route.ts`
- **Hooks**: `/hooks/useDocumentExtraction.ts`
- **Docs**: `/docs/DOCUMENT_EXTRACTION.md` (full guide)

Ready to extract documents! 🎉
