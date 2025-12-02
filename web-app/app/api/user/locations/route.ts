import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');

    if (!userId) {
      return NextResponse.json({ error: 'userId is required' }, { status: 400 });
    }

    const { data, error } = await supabase
      .from('user_locations')
      .select('*')
      .eq('user_id', userId)
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
    const body = await request.json();
    const { userId, location } = body;

    if (!userId || !location) {
      return NextResponse.json(
        { error: 'userId and location are required' },
        { status: 400 }
      );
    }

    const { data, error } = await supabase
      .from('user_locations')
      .insert([
        {
          user_id: userId,
          name: location.name,
          type: location.type,
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          icon: location.icon,
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
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    const locationId = searchParams.get('locationId');

    if (!userId || !locationId) {
      return NextResponse.json(
        { error: 'userId and locationId are required' },
        { status: 400 }
      );
    }

    const { error } = await supabase
      .from('user_locations')
      .delete()
      .eq('id', locationId)
      .eq('user_id', userId);

    if (error) throw error;

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error deleting location:', error);
    return NextResponse.json({ error: 'Failed to delete location' }, { status: 500 });
  }
}
