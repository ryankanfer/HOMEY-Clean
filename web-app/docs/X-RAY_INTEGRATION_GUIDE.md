# X-Ray Integration Guide

## ✅ What's Been Built

All X-Ray components are ready:

1. ✅ **ExecutiveView** - Line-item layout for leases, paystubs, bank statements
2. ✅ **CardView** - Visual grid for inspections, ID documents
3. ✅ **DigestView** - Narrative summary for pre-approvals, insurance
4. ✅ **XRayDocument** - Master component that auto-routes to correct view
5. ✅ **Database Schema** - `/schema/documents_schema.sql`

## 🎯 Integration Steps

### Step 1: Apply Database Schema

Run `/schema/documents_schema.sql` in Supabase SQL Editor:

```bash
# Open Supabase Dashboard
https://app.supabase.com → Your Project → SQL Editor

# Paste and run documents_schema.sql
```

This creates:
- `user_documents` table
- Extraction status tracking
- Search functions
- RLS policies

### Step 2: Add Database Helpers to lib/supabase.ts

Add these functions to your `db` object in `/lib/supabase.ts`:

```typescript
// In lib/supabase.ts, add to the db object:

// Documents
getDocuments: async (userId: string) => {
  const { data, error } = await supabase
    .from('user_documents')
    .select('*')
    .eq('user_id', userId)
    .eq('is_archived', false)
    .order('created_at', { ascending: false });
  return { data, error };
},

uploadDocument: async (params: {
  userId: string;
  fileName: string;
  fileUrl: string;
  fileSize: number;
  mimeType: string;
}) => {
  const { data, error } = await supabase
    .from('user_documents')
    .insert({
      user_id: params.userId,
      file_name: params.fileName,
      file_url: params.fileUrl,
      file_size: params.fileSize,
      mime_type: params.mimeType,
      extraction_status: 'pending',
    })
    .select()
    .single();
  return { data, error };
},

updateDocumentExtraction: async (params: {
  documentId: string;
  documentType: string;
  extractedData: any;
  viewMode: string;
  confidence: number;
}) => {
  const { data, error } = await supabase
    .from('user_documents')
    .update({
      document_type: params.documentType,
      extracted_data: params.extractedData,
      view_mode: params.viewMode,
      extraction_confidence: params.confidence,
      extraction_status: 'completed',
      extracted_at: new Date().toISOString(),
    })
    .eq('id', params.documentId)
    .select()
    .single();
  return { data, error };
},

searchDocuments: async (userId: string, query: string) => {
  const { data, error } = await supabase
    .rpc('search_documents', {
      p_user_id: userId,
      p_search_query: query,
    });
  return { data, error };
},
```

### Step 3: Wire Up to Vault Page

Here's the complete flow:

```typescript
// In your Vault page component
'use client';

import { useState } from 'react';
import { useDocumentExtraction } from '@/hooks/useDocumentExtraction';
import XRayDocument from '@/components/vault/XRayDocument';
import { db, auth } from '@/lib/supabase';

export default function VaultPage() {
  const [documents, setDocuments] = useState([]);
  const [selectedDoc, setSelectedDoc] = useState(null);
  const [xrayMode, setXrayMode] = useState(false);
  const { extractDocument, isProcessing } = useDocumentExtraction();

  // 1. Handle file upload
  const handleFileUpload = async (file: File) => {
    const { data: { user } } = await auth.getUser();
    if (!user) return;

    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('documents')
      .upload(`${user.id}/${file.name}`, file);

    if (uploadError) {
      console.error('Upload failed:', uploadError);
      return;
    }

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('documents')
      .getPublicUrl(uploadData.path);

    // Save to database
    const { data: docData } = await db.uploadDocument({
      userId: user.id,
      fileName: file.name,
      fileUrl: publicUrl,
      fileSize: file.size,
      mimeType: file.type,
    });

    // Extract document data in background
    if (docData) {
      extractDocumentAsync(docData.id, publicUrl, file.name);
    }
  };

  // 2. Extract document data
  const extractDocumentAsync = async (
    documentId: string,
    fileUrl: string,
    fileName: string
  ) => {
    try {
      const extraction = await extractDocument(fileUrl, fileName);

      // Save extracted data to database
      await db.updateDocumentExtraction({
        documentId,
        documentType: extraction.documentType,
        extractedData: extraction.extractedData,
        viewMode: extraction.viewMode,
        confidence: extraction.confidence,
      });

      // Refresh documents list
      loadDocuments();
    } catch (error) {
      console.error('Extraction failed:', error);
    }
  };

  // 3. Load documents
  const loadDocuments = async () => {
    const { data: { user } } = await auth.getUser();
    if (!user) return;

    const { data } = await db.getDocuments(user.id);
    setDocuments(data || []);
  };

  // 4. Render X-Ray view
  return (
    <div>
      {/* Upload Button */}
      <input type="file" onChange={(e) => e.target.files && handleFileUpload(e.target.files[0])} />

      {/* X-Ray Toggle */}
      <button onClick={() => setXrayMode(!xrayMode)}>
        {xrayMode ? '📄 PDF View' : '🔍 X-Ray View'}
      </button>

      {/* Documents List */}
      {documents.map((doc) => (
        <div key={doc.id} onClick={() => setSelectedDoc(doc)}>
          <h3>{doc.file_name}</h3>
          <p>Type: {doc.document_type}</p>
          {doc.extraction_status === 'processing' && <p>Extracting...</p>}
        </div>
      ))}

      {/* X-Ray Display */}
      {selectedDoc && xrayMode && selectedDoc.extracted_data && (
        <XRayDocument
          data={selectedDoc.extracted_data}
          viewMode={selectedDoc.view_mode}
          onViewOriginal={() => window.open(selectedDoc.file_url, '_blank')}
        />
      )}
    </div>
  );
}
```

## 📋 Quick Example - Minimal Implementation

The simplest possible implementation:

```typescript
import { useDocumentExtraction } from '@/hooks/useDocumentExtraction';
import XRayDocument from '@/components/vault/XRayDocument';

function MyVault() {
  const { extractDocument, result } = useDocumentExtraction();

  return (
    <div>
      <button onClick={async () => {
        const extraction = await extractDocument(
          'https://your-url.com/lease.pdf',
          'lease.pdf'
        );
        console.log('Extracted:', extraction);
      }}>
        Extract Document
      </button>

      {result && (
        <XRayDocument
          data={result.extractedData}
          viewMode={result.viewMode}
        />
      )}
    </div>
  );
}
```

## 🎨 UI Patterns

### Ghost Slots (Missing Required Docs)

```typescript
const REQUIRED_DOCS = ['lease', 'insurance', 'identification'];

function GhostSlots({ userDocs }) {
  const missing = REQUIRED_DOCS.filter(
    type => !userDocs.some(d => d.document_type === type)
  );

  return (
    <div>
      <h3>Required Documents</h3>
      {missing.map(type => (
        <div key={type} className="border-dashed border-2 opacity-50">
          <span>Missing: {type}</span>
          <button>Upload Now</button>
        </div>
      ))}
    </div>
  );
}
```

### Agent Comments

```typescript
// Add agent comment to document
await supabase
  .from('user_documents')
  .update({
    agent_comments: [
      {
        author: 'Sarah',
        text: 'Please verify the late fee clause',
        timestamp: new Date().toISOString()
      }
    ]
  })
  .eq('id', documentId);
```

### Natural Language Search

```typescript
async function searchVault(query: string) {
  const { data: { user } } = await auth.getUser();
  const { data } = await db.searchDocuments(user.id, query);

  // data includes relevance ranking
  return data;
}

// Usage
const results = await searchVault('Can I have a dog?');
```

## 🚀 Advanced Features

### Auto-Categorization

```typescript
function categorizeDocument(docType: string): string {
  const categories = {
    'lease': 'Leases & Contracts',
    'inspection': 'Inspections',
    'pre-approval': 'Financial',
    'insurance': 'Insurance & Protection',
    'identification': 'ID & Verification',
    'paystub': 'Income Verification',
    'bank-statement': 'Financial Records',
  };
  return categories[docType] || 'Other';
}
```

### Quick Actions in X-Ray View

Already built into ExecutiveView:
- "Add to Calendar" for dates
- "Set up Auto-Pay" for rent amounts
- "View Original" button

### Confidence Indicators

```typescript
{doc.extraction_confidence < 0.7 && (
  <div className="warning">
    ⚠️ Low confidence extraction. Please verify data.
  </div>
)}
```

## 📊 Analytics & Tracking

Track extraction performance:

```typescript
// After extraction
if (result.confidence < 0.7) {
  console.warn('Low confidence extraction:', {
    documentType: result.documentType,
    confidence: result.confidence,
    fileName: fileName,
  });
}
```

## 🎯 Next Steps

1. ✅ Apply database schema
2. ✅ Add database helpers to lib/supabase.ts
3. ✅ Wire up to Vault upload flow
4. 🔄 Test with real documents
5. 🔄 Add agent comment UI
6. 🔄 Implement semantic search

## 📁 Files Reference

**Components:**
- `/components/vault/XRayDocument.tsx` - Master router
- `/components/vault/ExecutiveView.tsx` - Line-item layout
- `/components/vault/CardView.tsx` - Visual grid
- `/components/vault/DigestView.tsx` - Narrative summary

**Schema:**
- `/schema/documents_schema.sql` - Database schema

**Hooks:**
- `/hooks/useDocumentExtraction.ts` - Extraction hook

**API:**
- `/app/api/documents/extract/route.ts` - Extraction endpoint

Ready to integrate! 🎉
