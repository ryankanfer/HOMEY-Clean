/**
 * HOMEY C-Suite Wiki API
 * Allows c-suite agents to access and update the internal wiki
 */

import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

// Use service role key for server-side access
const supabase = createClient(supabaseUrl, supabaseServiceKey);

// CORS headers for C-Suite app
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

/**
 * Handle OPTIONS request for CORS preflight
 */
export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

/**
 * GET /api/csuite/wiki
 * GET /api/csuite/wiki?slug=tech-stack
 * GET /api/csuite/wiki?category=operations
 * GET /api/csuite/wiki?search=budget
 */
export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const slug = searchParams.get('slug');
  const category = searchParams.get('category');
  const search = searchParams.get('search');

  try {
    // If slug provided, get specific page
    if (slug) {
      const { data, error } = await supabase
        .from('csuite_wiki')
        .select('*')
        .eq('slug', slug)
        .single();

      if (error) throw error;

      return NextResponse.json({ page: data }, { headers: corsHeaders });
    }

    // Build query
    let query = supabase
      .from('csuite_wiki')
      .select('*')
      .order('importance', { ascending: false })
      .order('updated_at', { ascending: false });

    // Filter by category
    if (category) {
      query = query.eq('category', category);
    }

    // Filter by search term
    if (search) {
      query = query.or(`title.ilike.%${search}%,content.ilike.%${search}%,tags.cs.{${search}}`);
    }

    const { data, error } = await query;

    if (error) throw error;

    return NextResponse.json({ pages: data || [] }, { headers: corsHeaders });
  } catch (error) {
    console.error('Wiki API error:', error);
    return NextResponse.json(
      { error: 'Internal server error', details: String(error) },
      { status: 500, headers: corsHeaders }
    );
  }
}

/**
 * POST /api/csuite/wiki
 * Create a new wiki page
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { category, title, slug, content, tags, importance, is_public, created_by } = body;

    if (!category || !title || !slug || !content) {
      return NextResponse.json(
        { error: 'category, title, slug, and content are required' },
        { status: 400, headers: corsHeaders }
      );
    }

    const { data, error } = await supabase
      .from('csuite_wiki')
      .insert({
        category,
        title,
        slug,
        content,
        tags: tags || [],
        importance: importance || 'medium',
        is_public: is_public || false,
        created_by: created_by || 'system',
        updated_by: created_by || 'system',
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ page: data }, { headers: corsHeaders, status: 201 });
  } catch (error) {
    console.error('Error creating wiki page:', error);
    return NextResponse.json(
      { error: 'Failed to create wiki page', details: String(error) },
      { status: 500, headers: corsHeaders }
    );
  }
}

/**
 * PUT /api/csuite/wiki?slug=tech-stack
 * Update an existing wiki page
 */
export async function PUT(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const slug = searchParams.get('slug');

    if (!slug) {
      return NextResponse.json(
        { error: 'slug parameter required' },
        { status: 400, headers: corsHeaders }
      );
    }

    const body = await request.json();
    const { title, content, tags, importance, is_public, updated_by } = body;

    const updates: any = {
      updated_at: new Date().toISOString(),
      updated_by: updated_by || 'system',
    };

    if (title !== undefined) updates.title = title;
    if (content !== undefined) updates.content = content;
    if (tags !== undefined) updates.tags = tags;
    if (importance !== undefined) updates.importance = importance;
    if (is_public !== undefined) updates.is_public = is_public;

    const { data, error } = await supabase
      .from('csuite_wiki')
      .update(updates)
      .eq('slug', slug)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ page: data }, { headers: corsHeaders });
  } catch (error) {
    console.error('Error updating wiki page:', error);
    return NextResponse.json(
      { error: 'Failed to update wiki page', details: String(error) },
      { status: 500, headers: corsHeaders }
    );
  }
}

/**
 * DELETE /api/csuite/wiki?slug=tech-stack
 * Delete a wiki page
 */
export async function DELETE(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const slug = searchParams.get('slug');

    if (!slug) {
      return NextResponse.json(
        { error: 'slug parameter required' },
        { status: 400, headers: corsHeaders }
      );
    }

    const { error } = await supabase
      .from('csuite_wiki')
      .delete()
      .eq('slug', slug);

    if (error) throw error;

    return NextResponse.json({ success: true }, { headers: corsHeaders });
  } catch (error) {
    console.error('Error deleting wiki page:', error);
    return NextResponse.json(
      { error: 'Failed to delete wiki page', details: String(error) },
      { status: 500, headers: corsHeaders }
    );
  }
}
