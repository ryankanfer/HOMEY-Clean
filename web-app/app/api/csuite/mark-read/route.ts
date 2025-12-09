import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

// CORS headers for C-Suite app
const corsHeaders = {
  'Access-Control-Allow-Origin': 'http://localhost:5175',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

// Handle OPTIONS request for CORS preflight
export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

// Mark notifications as read
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { notificationIds } = await request.json();

    if (!Array.isArray(notificationIds) || notificationIds.length === 0) {
      return NextResponse.json(
        { error: 'Invalid notification IDs' },
        { status: 400, headers: corsHeaders }
      );
    }

    // Update notifications to mark as read
    const { data, error } = await supabase
      .from('homey_notifications')
      .update({ is_read: true })
      .in('id', notificationIds)
      .select();

    if (error) {
      console.error('Error marking notifications as read:', error);
      return NextResponse.json(
        { error: error.message },
        { status: 500, headers: corsHeaders }
      );
    }

    return NextResponse.json(
      { success: true, updated: data?.length || 0 },
      { headers: corsHeaders }
    );
  } catch (error) {
    console.error('Error in mark-read endpoint:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500, headers: corsHeaders }
    );
  }
}
