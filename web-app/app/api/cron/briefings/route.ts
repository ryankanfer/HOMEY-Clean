/**
 * Cron endpoint for automated briefings
 * Call this endpoint from your cron service (Vercel Cron, GitHub Actions, etc.)
 */

import { NextRequest, NextResponse } from 'next/server';
import { sendMorningBriefing, sendEveningBriefing, sendWeeklySummary } from '@/lib/csuite-briefings';

// Optional: Protect with authorization header
const CRON_SECRET = process.env.CRON_SECRET || 'your-secret-key-here';

export async function GET(request: NextRequest) {
  // Verify authorization
  const authHeader = request.headers.get('authorization');
  if (authHeader !== `Bearer ${CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { searchParams } = request.nextUrl;
  const type = searchParams.get('type'); // 'morning', 'evening', or 'weekly'

  try {
    switch (type) {
      case 'morning':
        await sendMorningBriefing();
        return NextResponse.json({
          success: true,
          message: 'Morning briefing sent',
          timestamp: new Date().toISOString()
        });

      case 'evening':
        await sendEveningBriefing();
        return NextResponse.json({
          success: true,
          message: 'Evening briefing sent',
          timestamp: new Date().toISOString()
        });

      case 'weekly':
        await sendWeeklySummary();
        return NextResponse.json({
          success: true,
          message: 'Weekly summary sent',
          timestamp: new Date().toISOString()
        });

      default:
        return NextResponse.json(
          { error: 'Invalid type. Use: morning, evening, or weekly' },
          { status: 400 }
        );
    }
  } catch (error) {
    console.error('Briefing cron error:', error);
    return NextResponse.json(
      { error: 'Failed to send briefing', details: String(error) },
      { status: 500 }
    );
  }
}

// For manual testing (no auth required in development)
export async function POST(request: NextRequest) {
  if (process.env.NODE_ENV !== 'development') {
    return NextResponse.json({ error: 'Only available in development' }, { status: 403 });
  }

  const { type } = await request.json();

  try {
    switch (type) {
      case 'morning':
        await sendMorningBriefing();
        break;
      case 'evening':
        await sendEveningBriefing();
        break;
      case 'weekly':
        await sendWeeklySummary();
        break;
      default:
        return NextResponse.json({ error: 'Invalid type' }, { status: 400 });
    }

    return NextResponse.json({ success: true, message: `${type} briefing sent` });
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}
