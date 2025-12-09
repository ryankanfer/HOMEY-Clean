import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { createClient } from '@/lib/supabase-server';

// Routes that require authentication
const PROTECTED_ROUTES = [
  '/settings',
  '/profile',
  '/vault',
  '/agent',
  '/calendar',
  '/saved',
  '/learn',
  '/education',
];

// Routes that should redirect authenticated users away
const AUTH_ROUTES = ['/signup'];

export async function middleware(req: NextRequest) {
  const path = req.nextUrl.pathname;
  const hostname = req.nextUrl.hostname;

  // PREVIEW SITE PROTECTION: Only allow Ryan + C-Suite API on preview.homeypocket.ai
  if (hostname === 'preview.homeypocket.ai') {
    // Allow C-Suite API calls with API key
    const csuiteApiKey = req.headers.get('x-csuite-api-key');
    const validApiKey = process.env.CSUITE_API_KEY;

    if (csuiteApiKey && validApiKey && csuiteApiKey === validApiKey) {
      // C-Suite agents have full access
      return NextResponse.next();
    }

    // For human users, require authentication as Ryan
    // Continue to session check below...
  }

  // Create supabase server client
  const { supabase, response } = createClient(req);

  // Check if the path is protected
  const isProtectedRoute = PROTECTED_ROUTES.some((route) =>
    path.startsWith(route)
  );
  const isAuthRoute = AUTH_ROUTES.some((route) => path.startsWith(route));

  // Get the session using Supabase SSR
  const { data: { session } } = await supabase.auth.getSession();

  // Check if user is admin (ryan@homeypocket.ai)
  let isAdmin = false;
  if (session?.user?.id) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('is_admin, email')
      .eq('id', session.user.id)
      .single();

    isAdmin = profile?.is_admin === true || profile?.email === 'ryan@homeypocket.ai';
  }

  // PREVIEW SITE: Only Ryan (admin) can access
  if (hostname === 'preview.homeypocket.ai' && !isAdmin) {
    // Not Ryan - block access
    return NextResponse.json(
      { error: 'Preview site is restricted to admin access only' },
      { status: 403 }
    );
  }

  // Admins can access everything - skip all route restrictions
  if (isAdmin) {
    return response;
  }

  // If route is protected and no session exists, redirect to root (login page)
  if (isProtectedRoute && !session) {
    const redirectUrl = new URL('/', req.url);
    redirectUrl.searchParams.set('redirectTo', path);
    return NextResponse.redirect(redirectUrl);
  }

  // If user has session and trying to access auth pages, redirect to home
  if (session && isAuthRoute) {
    return NextResponse.redirect(new URL('/home', req.url));
  }

  // For API routes, verify the session if protected
  if (path.startsWith('/api/') && isProtectedRoute) {
    if (!session) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }
  }

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
