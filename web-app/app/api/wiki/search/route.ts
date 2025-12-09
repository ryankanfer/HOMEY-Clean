import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

// CORS headers for C-Suite app
const corsHeaders = {
  'Access-Control-Allow-Origin': process.env.NODE_ENV === 'development'
    ? 'http://localhost:5175'
    : 'https://csuite.homeypocket.ai',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, x-csuite-api-key',
};

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

/**
 * GET /api/wiki/search?q=query
 * Full-text search across wiki pages
 */
export async function GET(request: NextRequest) {
  try {
    const supabase = await createClient();
    const searchParams = request.nextUrl.searchParams;
    const query = searchParams.get('q');

    if (!query) {
      return NextResponse.json(
        { error: 'Missing search query parameter' },
        { status: 400, headers: corsHeaders }
      );
    }

    // Use PostgreSQL full-text search
    const { data, error } = await supabase
      .from('csuite_wiki')
      .select('*')
      .textSearch('search_vector', query, {
        type: 'websearch',
        config: 'english',
      })
      .order('importance', { ascending: false })
      .order('updated_at', { ascending: false })
      .limit(20);

    if (error) {
      console.error('Error searching wiki:', error);
      return NextResponse.json(
        { error: error.message },
        { status: 500, headers: corsHeaders }
      );
    }

    return NextResponse.json(
      { pages: data || [] },
      { headers: corsHeaders }
    );
  } catch (error) {
    console.error('Error in GET /api/wiki/search:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500, headers: corsHeaders }
    );
  }
}
