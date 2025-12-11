import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import searchRealEstateData from '@/lib/api/realEstateAPI';
import { rateLimit, getRateLimitHeaders } from '@/lib/rateLimiter';
// Force dynamic rendering to avoid build-time errors
export const dynamic = 'force-dynamic';


// Helper function to get authenticated user from request
async function getAuthenticatedUser(request: NextRequest) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

  const supabase = createClient(supabaseUrl, supabaseAnonKey);

  const authHeader = request.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.substring(7);
  const { data: { user }, error } = await supabase.auth.getUser(token);

  if (error || !user) {
    return null;
  }

  return user;
}

// Initialize Supabase with service role key for server-side operations
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

/**
 * Sync Listings API Route
 *
 * This endpoint fetches fresh real estate data from external APIs
 * and syncs it to the Supabase database.
 *
 * PROTECTED: Requires authentication
 * RATE LIMITED: Max 5 requests per hour per user
 *
 * Usage:
 * - Manual: POST /api/sync-listings
 * - Scheduled: Set up a cron job (Vercel Cron, GitHub Actions, etc.)
 * - Body params: { location?, minPrice?, maxPrice?, beds_min? }
 */
export async function POST(request: NextRequest) {
  try {
    // Check authentication
    const user = await getAuthenticatedUser(request);
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    // Apply rate limiting (5 requests per hour)
    const rateLimitConfig = { maxRequests: 5, windowMs: 60 * 60 * 1000 }; // 1 hour
    const rateLimitResult = rateLimit(user.id, rateLimitConfig);

    if (!rateLimitResult.success) {
      const resetDate = new Date(rateLimitResult.resetTime);
      return NextResponse.json(
        {
          error: 'Rate limit exceeded',
          message: `Too many sync requests. Please try again after ${resetDate.toLocaleTimeString()}`,
          resetTime: rateLimitResult.resetTime,
        },
        {
          status: 429,
          headers: getRateLimitHeaders(rateLimitResult, rateLimitConfig),
        }
      );
    }

    // Parse request body for custom search params
    const body = await request.json().catch(() => ({}));
    const {
      location = 'New York, NY',
      minPrice,
      maxPrice,
      beds_min,
      status_type = 'ForRent',
    } = body;

    console.log('🔄 Starting listing sync...', { location, status_type, userId: user.id });

    // Fetch from external APIs
    const apiListings = await searchRealEstateData({
      location,
      status_type,
      minPrice,
      maxPrice,
      beds_min,
      page: 1,
    });

    if (!apiListings || apiListings.length === 0) {
      return NextResponse.json({
        success: false,
        message: 'No listings returned from API',
        synced: 0,
      }, {
        status: 200,
        headers: getRateLimitHeaders(rateLimitResult, rateLimitConfig),
      });
    }

    console.log(`✅ Fetched ${apiListings.length} listings from API`);

    // Sync to database
    let newListings = 0;
    let updatedListings = 0;
    let errors = 0;

    for (const listing of apiListings) {
      try {
        if (!listing.external_id) {
          console.warn('⚠️ Skipping listing without external_id');
          continue;
        }

        // Check if listing already exists
        const { data: existing } = await supabase
          .from('listings')
          .select('id, price, is_active')
          .eq('external_id', listing.external_id)
          .single();

        if (existing) {
          // Update existing listing (price may have changed)
          const { error: updateError } = await supabase
            .from('listings')
            .update({
              price: listing.price,
              is_active: listing.is_active,
              updated_at: new Date().toISOString(),
            })
            .eq('id', existing.id);

          if (updateError) {
            console.error('Failed to update listing:', updateError);
            errors++;
          } else {
            updatedListings++;
          }
        } else {
          // Insert new listing
          const { error: insertError } = await supabase
            .from('listings')
            .insert(listing);

          if (insertError) {
            console.error('Failed to insert listing:', insertError);
            errors++;
          } else {
            newListings++;
          }
        }
      } catch (err) {
        console.error('Error processing listing:', err);
        errors++;
      }
    }

    // Mark old listings as inactive (not seen in latest sync)
    const externalIds = apiListings
      .map((l: any) => l.external_id)
      .filter(Boolean);

    if (externalIds.length > 0) {
      await supabase
        .from('listings')
        .update({ is_active: false })
        .eq('source', apiListings[0]?.source || 'zillow')
        .not('external_id', 'in', `(${externalIds.join(',')})`);
    }

    console.log('✅ Sync complete', { newListings, updatedListings, errors });

    return NextResponse.json({
      success: true,
      message: 'Listings synced successfully',
      stats: {
        fetched: apiListings.length,
        new: newListings,
        updated: updatedListings,
        errors,
      },
    }, {
      headers: getRateLimitHeaders(rateLimitResult, rateLimitConfig),
    });
  } catch (error: any) {
    console.error('❌ Sync failed:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to sync listings',
      },
      { status: 500 }
    );
  }
}

// Support GET for health checks
export async function GET() {
  return NextResponse.json({
    status: 'ok',
    message: 'Sync API is ready. Use POST to trigger sync. Authentication required.',
  });
}
