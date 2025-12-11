import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
// Force dynamic rendering to avoid build-time errors
export const dynamic = 'force-dynamic';


// Helper function to get authenticated user from request
async function getAuthenticatedUser(request: NextRequest) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

  // Create client with anon key for auth verification
  const supabase = createClient(supabaseUrl, supabaseAnonKey);

  // Get the authorization header
  const authHeader = request.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.substring(7);

  // Verify the token and get user
  const { data: { user }, error } = await supabase.auth.getUser(token);

  if (error || !user) {
    return null;
  }

  return user;
}

// Create service role client for database operations
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function GET(request: NextRequest) {
  try {
    // Verify authentication
    const user = await getAuthenticatedUser(request);
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    // Use authenticated user's ID (not client-provided userId)
    const { data, error } = await supabase
      .from('user_locations')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return NextResponse.json({ locations: data || [] });
  } catch (error) {
    console.error('Error fetching user locations:', error);
    return NextResponse.json(
      { error: 'Failed to fetch locations' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    // Verify authentication
    const user = await getAuthenticatedUser(request);
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const body = await request.json();
    const { location } = body;

    if (!location) {
      return NextResponse.json(
        { error: 'location is required' },
        { status: 400 }
      );
    }

    // Validate location structure
    if (!location.name || !location.type) {
      return NextResponse.json(
        { error: 'location must have name and type' },
        { status: 400 }
      );
    }

    // Use authenticated user's ID (not client-provided userId)
    const { data, error } = await supabase
      .from('user_locations')
      .insert([
        {
          user_id: user.id, // Force authenticated user's ID
          name: location.name,
          type: location.type,
          address: location.address || null,
          latitude: location.latitude || null,
          longitude: location.longitude || null,
          icon: location.icon || null,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ location: data });
  } catch (error) {
    console.error('Error saving location:', error);
    return NextResponse.json({ error: 'Failed to save location' }, { status: 500 });
  }
}

export async function DELETE(request: NextRequest) {
  try {
    // Verify authentication
    const user = await getAuthenticatedUser(request);
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const { searchParams } = new URL(request.url);
    const locationId = searchParams.get('locationId');

    if (!locationId) {
      return NextResponse.json(
        { error: 'locationId is required' },
        { status: 400 }
      );
    }

    // Delete only if belongs to authenticated user
    const { error } = await supabase
      .from('user_locations')
      .delete()
      .eq('id', locationId)
      .eq('user_id', user.id); // Verify ownership

    if (error) throw error;

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error deleting location:', error);
    return NextResponse.json({ error: 'Failed to delete location' }, { status: 500 });
  }
}
