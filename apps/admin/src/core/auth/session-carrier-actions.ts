'use server';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import {
  AdminApiError,
  verifyAdminSessionCarrier,
} from '../server/admin-api-client';
import {
  ADMIN_SESSION_COOKIE,
  buildAdminSessionCookieOptions,
  normalizeAdminSessionCarrier,
  sanitizeAdminNextPath,
} from './route-guard';

export async function connectAdminSessionCarrierAction(formData: FormData) {
  const nextPath = sanitizeAdminNextPath(readOptionalString(formData, 'next'));

  try {
    const sessionCarrier = normalizeAdminSessionCarrier(formData.get('sessionCarrier'));
    await verifyAdminSessionCarrier(sessionCarrier);
    const cookieStore = await cookies();
    cookieStore.set(
      ADMIN_SESSION_COOKIE,
      sessionCarrier,
      buildAdminSessionCookieOptions(),
    );
    redirect(nextPath);
  } catch (error) {
    redirect(buildLoginUrl(nextPath, 'error', toErrorMessage(error)));
  }
}

export async function clearAdminSessionCarrierAction(formData: FormData) {
  const nextPath = sanitizeAdminNextPath(readOptionalString(formData, 'next'));
  const cookieStore = await cookies();
  cookieStore.set(ADMIN_SESSION_COOKIE, '', {
    ...buildAdminSessionCookieOptions(),
    expires: new Date(0),
  });
  redirect(buildLoginUrl(nextPath, 'notice', 'carrier_cleared'));
}

function buildLoginUrl(nextPath: string, key: 'error' | 'notice', value: string) {
  const params = new URLSearchParams({ next: nextPath });
  params.set(key, value);
  return `/login?${params.toString()}`;
}

function readOptionalString(formData: FormData, key: string) {
  const value = formData.get(key);
  return typeof value === 'string' ? value : null;
}

function toErrorMessage(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '管理员会话载体验证失败。';
}
