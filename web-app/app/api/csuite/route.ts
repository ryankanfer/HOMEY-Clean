/**
 * HOMEY C-Suite API
 * Allows c-suite agents to query app status and fetch notifications
 */

import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

// Use service role key for server-side access
const supabase = createClient(supabaseUrl, supabaseServiceKey);

// CORS headers for local development
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

/**
 * Handle OPTIONS request for CORS preflight
 */
export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

/**
 * GET /api/csuite?type=notifications&agent_id=tech-cody
 * GET /api/csuite?type=status
 * GET /api/csuite?type=metrics&timeframe=24h
 */
export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const type = searchParams.get('type');
  const agentId = searchParams.get('agent_id');
  const timeframe = searchParams.get('timeframe') || '24h';

  try {
    switch (type) {
      case 'notifications':
        return await getNotifications(agentId);

      case 'status':
        return await getAppStatus();

      case 'metrics':
        return await getMetrics(timeframe);

      case 'errors':
        return await getRecentErrors(timeframe);

      case 'feedback':
        return await getRecentFeedback(timeframe);

      default:
        return NextResponse.json(
          { error: 'Invalid type parameter. Use: notifications, status, metrics, errors, or feedback' },
          { status: 400, headers: corsHeaders }
        );
    }
  } catch (error) {
    console.error('C-Suite API error:', error);
    return NextResponse.json(
      { error: 'Internal server error', details: String(error) },
      { status: 500, headers: corsHeaders }
    );
  }
}

/**
 * POST /api/csuite/mark-read
 * Mark notifications as read
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { notification_ids } = body;

    if (!notification_ids || !Array.isArray(notification_ids)) {
      return NextResponse.json(
        { error: 'notification_ids array required' },
        { status: 400, headers: corsHeaders }
      );
    }

    const { error } = await supabase
      .from('csuite_notifications')
      .update({ read: true, read_at: new Date().toISOString() })
      .in('id', notification_ids);

    if (error) throw error;

    return NextResponse.json({ success: true }, { headers: corsHeaders });
  } catch (error) {
    console.error('Error marking notifications as read:', error);
    return NextResponse.json(
      { error: 'Failed to mark notifications as read' },
      { status: 500, headers: corsHeaders }
    );
  }
}

// Helper functions

async function getNotifications(agentId: string | null) {
  let query = supabase
    .from('csuite_notifications')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50);

  if (agentId) {
    query = query.eq('agent_id', agentId);
  }

  const { data, error } = await query;

  if (error) throw error;

  return NextResponse.json({
    notifications: data || [],
    unread_count: data?.filter(n => !n.read).length || 0,
  }, { headers: corsHeaders });
}

async function getAppStatus() {
  // Get overall app health metrics
  const { count: totalUsers } = await supabase
    .from('user_profiles')
    .select('*', { count: 'exact', head: true });

  const { count: activeListings } = await supabase
    .from('listings')
    .select('*', { count: 'exact', head: true });

  const { count: savedListings } = await supabase
    .from('saved_listings')
    .select('*', { count: 'exact', head: true });

  // Get recent activity (last 24h)
  const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

  const { count: recentEvents } = await supabase
    .from('user_events')
    .select('*', { count: 'exact', head: true })
    .gte('timestamp', yesterday);

  const { count: recentSaves } = await supabase
    .from('saved_listings')
    .select('*', { count: 'exact', head: true })
    .gte('saved_at', yesterday);

  return NextResponse.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    metrics: {
      total_users: totalUsers || 0,
      active_listings: activeListings || 0,
      total_saves: savedListings || 0,
      recent_activity: {
        events_24h: recentEvents || 0,
        saves_24h: recentSaves || 0,
      },
    },
  }, { headers: corsHeaders });
}

async function getMetrics(timeframe: string) {
  const hours = timeframe === '1h' ? 1 : timeframe === '24h' ? 24 : timeframe === '7d' ? 168 : 720;
  const since = new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();

  // Get event breakdown
  const { data: events } = await supabase
    .from('user_events')
    .select('event_type, event_category, event_action')
    .gte('timestamp', since);

  const eventCounts: Record<string, number> = {};
  const categoryCounts: Record<string, number> = {};

  events?.forEach(event => {
    eventCounts[event.event_type] = (eventCounts[event.event_type] || 0) + 1;
    categoryCounts[event.event_category] = (categoryCounts[event.event_category] || 0) + 1;
  });

  // Get top listings
  const { data: topListings } = await supabase
    .from('saved_listings')
    .select('listing_id')
    .gte('saved_at', since);

  const listingCounts: Record<string, number> = {};
  topListings?.forEach(save => {
    listingCounts[save.listing_id] = (listingCounts[save.listing_id] || 0) + 1;
  });

  const topListingIds = Object.entries(listingCounts)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5)
    .map(([id]) => id);

  return NextResponse.json({
    timeframe,
    period_hours: hours,
    metrics: {
      total_events: events?.length || 0,
      event_types: eventCounts,
      event_categories: categoryCounts,
      top_listings: topListingIds,
    },
  }, { headers: corsHeaders });
}

async function getRecentErrors(timeframe: string) {
  // This would integrate with your error tracking
  // For now, return a placeholder
  return NextResponse.json({
    timeframe,
    errors: [],
    message: 'Integrate with error tracking service (e.g., Sentry)',
  }, { headers: corsHeaders });
}

async function getRecentFeedback(timeframe: string) {
  const hours = timeframe === '1h' ? 1 : timeframe === '24h' ? 24 : timeframe === '7d' ? 168 : 720;
  const since = new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();

  // Get user feedback from events or a feedback table
  const { data: feedbackEvents } = await supabase
    .from('user_events')
    .select('*')
    .eq('event_category', 'communication')
    .gte('timestamp', since)
    .order('timestamp', { ascending: false })
    .limit(20);

  return NextResponse.json({
    timeframe,
    feedback_events: feedbackEvents || [],
    count: feedbackEvents?.length || 0,
  }, { headers: corsHeaders });
}
