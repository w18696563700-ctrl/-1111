import { NextRequest, NextResponse } from 'next/server';
import {
  ADMIN_SESSION_COOKIE,
  resolveProtectedPathAccess,
} from '@/core/auth/route-guard';

export function middleware(request: NextRequest) {
  const access = resolveProtectedPathAccess({
    pathname: request.nextUrl.pathname,
    requestUrl: request.url,
    sessionCarrier: request.cookies.get(ADMIN_SESSION_COOKIE)?.value,
  });
  if (access.outcome === 'allow') {
    return NextResponse.next();
  }
  return NextResponse.redirect(access.location);
}

export const config = {
  matcher: ['/review/:path*', '/governance/:path*', '/project_review/:path*', '/template_config/:path*', '/audit/:path*', '/ticketing/:path*'],
};
