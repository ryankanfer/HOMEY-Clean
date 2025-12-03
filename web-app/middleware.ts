import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { createClient } from '@supabase/supabase-js';

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
const AUTH_ROUTES = ['/login', '/signup'];

export async function middleware(req: NextRequest) {
  const path = req.nextUrl.pathname;

  // Check if the path is protected
  const isProtectedRoute = PROTECTED_ROUTES.some((route) =>
    path.startsWith(route)
  );
  const isAuthRoute = AUTH_ROUTES.some((route) => path.startsWith(route));

  // Get the session token from cookies
  const token = req.cookies.get('sb-access-token')?.value ||
                req.cookies.get('sb-mzqswvyfnblghgvcgxpw-auth-token')?.value;

  // If route is protected and no token exists, redirect to login
  if (isProtectedRoute && !token) {
    const redirectUrl = new URL('/login', req.url);
    redirectUrl.searchParams.set('redirectTo', path);
    return NextResponse.redirect(redirectUrl);
  }

  // If user has token and trying to access auth pages, redirect to home
  if (token && isAuthRoute) {
    return NextResponse.redirect(new URL('/home', req.url));
  }

  // For API routes, verify the token if present
  if (path.startsWith('/api/') && isProtectedRoute) {
    if (!token) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }
  }

  return NextResponse.next();
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
