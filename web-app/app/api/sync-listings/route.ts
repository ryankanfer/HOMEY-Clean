import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import searchRealEstateData from '@/lib/api/realEstateAPI';

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
 * Usage:
 * - Manual: POST /api/sync-listings
 * - Scheduled: Set up a cron job (Vercel Cron, GitHub Actions, etc.)
 * - Body params: { location?, minPrice?, maxPrice?, beds_min? }
 */
export async function POST(request: NextRequest) {
  try {
    // Parse request body for custom search params
    const body = await request.json().catch(() => ({}));
    const {
      location = 'New York, NY',
      minPrice,
      maxPrice,
      beds_min,
      status_type = 'ForRent',
    } = body;

    console.log('🔄 Starting listing sync...', { location, status_type });

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
      }, { status: 200 });
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
      .map(l => l.external_id)
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
    message: 'Sync API is ready. Use POST to trigger sync.',
  });
}
