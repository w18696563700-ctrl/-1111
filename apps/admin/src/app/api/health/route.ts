import { NextResponse } from 'next/server';
import { getServerConfig } from '@/core/config/env';

export async function GET() {
  const config = getServerConfig();
  return NextResponse.json({
    ok: true,
    mode: 'phase1b-admin-skeleton',
    serverAdminApiBaseUrl: config.serverAdminApiBaseUrl,
    serverAdminApiEntryMode: config.serverAdminApiEntryMode,
    serverAdminApiConnectionLabel: config.serverAdminApiConnectionLabel,
  });
}
