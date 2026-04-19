import { NextResponse } from 'next/server';
import { getServerConfig } from '@/core/config/env';

export async function GET() {
  return NextResponse.json({
    ok: true,
    mode: 'phase1b-admin-skeleton',
    serverAdminApiBaseUrl: getServerConfig().serverAdminApiBaseUrl,
  });
}
