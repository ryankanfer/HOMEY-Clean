import { NextRequest, NextResponse } from 'next/server';
import { processDocument } from '@/lib/documentExtraction';
import { auth } from '@/lib/supabase';
import { createClient } from '@supabase/supabase-js';
import { updateProfileFromDocument } from '@/lib/profileLearning';

export const runtime = 'nodejs';
export const maxDuration = 60; // Allow up to 60 seconds for processing

/**
 * POST /api/documents/extract
 * Extract structured data from a document using AI
 */
export async function POST(request: NextRequest) {
  try {
    // Verify authentication
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { error: 'Missing authorization header' },
        { status: 401 }
      );
    }

    // Extract JWT token from Authorization header
    const token = authHeader.replace('Bearer ', '');

    // Create Supabase client with user's token to get userId
    const supabaseUser = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        global: {
          headers: {
            Authorization: authHeader,
          },
        },
      }
    );

    // Get user from token
    const { data: { user }, error: userError } = await supabaseUser.auth.getUser(token);

    if (userError || !user) {
      return NextResponse.json(
        { error: 'Invalid authorization token' },
        { status: 401 }
      );
    }

    const userId = user.id;

    // Parse request body
    const body = await request.json();
    const { fileUrl, fileName, documentId } = body;

    if (!fileUrl || !fileName) {
      return NextResponse.json(
        { error: 'Missing required fields: fileUrl and fileName' },
        { status: 400 }
      );
    }

    console.log(`Processing document: ${fileName}`);
    console.log(`Storage path: ${fileUrl}`);
    console.log(`Document ID: ${documentId || 'N/A'}`);

    // Create admin client to access private files
    const supabaseAdmin = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    );

    // Generate a signed URL for OpenAI to access the document
    const { data, error } = await supabaseAdmin.storage
      .from('documents')
      .createSignedUrl(fileUrl, 600); // 10 minutes

    if (error || !data) {
      console.error('Failed to generate signed URL:', error);
      return NextResponse.json(
        { error: 'Failed to access document from storage' },
        { status: 500 }
      );
    }

    const signedUrl = data.signedUrl;
    console.log(`Generated signed URL for extraction`);

    // Process the document with the signed URL
    const result = await processDocument(signedUrl, fileName);

    if (!result.success) {
      return NextResponse.json(
        {
          error: result.error || 'Failed to process document',
          documentType: result.documentType,
        },
        { status: 500 }
      );
    }

    // Step 6: Update user profile from extracted data (non-blocking)
    // This runs in the background and doesn't block the response
    updateProfileFromDocument(userId, result.documentType, result.extractedData)
      .catch((error) => {
        console.error('[Profile Learning] Background update failed:', error);
        // Don't throw - profile learning is non-critical
      });

    // Return extraction results
    return NextResponse.json({
      success: true,
      documentId,
      documentType: result.documentType,
      extractedData: result.extractedData,
      viewMode: result.viewMode,
      confidence: result.confidence,
      processingTime: result.processingTime,
    });
  } catch (error) {
    console.error('Document extraction API error:', error);

    return NextResponse.json(
      {
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

/**
 * GET /api/documents/extract?test=true
 * Test endpoint to verify API is working
 */
export async function GET(request: NextRequest) {
  const isTest = request.nextUrl.searchParams.get('test') === 'true';

  if (!isTest) {
    return NextResponse.json(
      { error: 'Method not allowed. Use POST to extract documents.' },
      { status: 405 }
    );
  }

  return NextResponse.json({
    status: 'OK',
    message: 'Document extraction API is running',
    supportedDocumentTypes: [
      'lease',
      'inspection',
      'pre-approval',
      'insurance',
      'identification',
      'paystub',
      'bank-statement',
      'other',
    ],
    viewModes: {
      executive: ['lease', 'paystub', 'bank-statement'],
      card: ['inspection', 'identification'],
      digest: ['pre-approval', 'insurance', 'other'],
    },
  });
}
