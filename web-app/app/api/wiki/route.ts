import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

// CORS headers for C-Suite app
const corsHeaders = {
  'Access-Control-Allow-Origin': process.env.NODE_ENV === 'development'
    ? 'http://localhost:5175'
    : 'https://csuite.homeypocket.ai',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, x-csuite-api-key',
};

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

/**
 * GET /api/wiki
 * List wiki pages with optional filtering
 */
export async function GET(request: NextRequest) {
  try {
    const supabase = await createClient();
    const searchParams = request.nextUrl.searchParams;

    const category = searchParams.get('category');
    const search = searchParams.get('search');
    const tags = searchParams.get('tags')?.split(',').filter(Boolean);
    const limit = parseInt(searchParams.get('limit') || '50');
    const offset = parseInt(searchParams.get('offset') || '0');

    let query = supabase
      .from('csuite_wiki')
      .select('*', { count: 'exact' });

    // Filter by category
    if (category && category !== 'all') {
      query = query.eq('category', category);
    }

    // Filter by tags
    if (tags && tags.length > 0) {
      query = query.overlaps('tags', tags);
    }

    // Full-text search
    if (search) {
      query = query.textSearch('search_vector', search, {
        type: 'websearch',
        config: 'english',
      });
    }

    // Pagination
    query = query
      .order('importance', { ascending: false })
      .order('updated_at', { ascending: false })
      .range(offset, offset + limit - 1);

    const { data, error, count } = await query;

    if (error) {
      console.error('Error fetching wiki pages:', error);
      return NextResponse.json(
        { error: error.message },
        { status: 500, headers: corsHeaders }
      );
    }

    return NextResponse.json(
      { pages: data || [], total: count || 0 },
      { headers: corsHeaders }
    );
  } catch (error) {
    console.error('Error in GET /api/wiki:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500, headers: corsHeaders }
    );
  }
}

/**
 * POST /api/wiki
 * Create a new wiki page
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const body = await request.json();

    const {
      category,
      title,
      slug,
      content,
      tags = [],
      importance = 'normal',
      is_public = true,
      related_pages = [],
    } = body;

    // Validate required fields
    if (!category || !title || !slug || !content) {
      return NextResponse.json(
        { error: 'Missing required fields: category, title, slug, content' },
        { status: 400, headers: corsHeaders }
      );
    }

    // Get current user (or use C-Suite agent identity)
    const { data: { session } } = await supabase.auth.getSession();
    const createdBy = session?.user?.email || 'c-suite-agent';

    const { data, error } = await supabase
      .from('csuite_wiki')
      .insert({
        category,
        title,
        slug,
        content,
        tags,
        importance,
        is_public,
        related_pages,
        created_by: createdBy,
        updated_by: createdBy,
      })
      .select()
      .single();

    if (error) {
      console.error('Error creating wiki page:', error);
      return NextResponse.json(
        { error: error.message },
        { status: 500, headers: corsHeaders }
      );
    }

    return NextResponse.json(data, { headers: corsHeaders });
  } catch (error) {
    console.error('Error in POST /api/wiki:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500, headers: corsHeaders }
    );
  }
}
