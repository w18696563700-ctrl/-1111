'use server';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import {
  AdminApiError,
  issueAdminSessionCarrier,
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
  let sessionCarrier = '';

  try {
    sessionCarrier = normalizeAdminSessionCarrier(formData.get('sessionCarrier'));
    await verifyAdminSessionCarrier(sessionCarrier);
  } catch (error) {
    redirect(buildLoginUrl(nextPath, 'error', toErrorMessage(error)));
  }

  const cookieStore = await cookies();
  cookieStore.set(
    ADMIN_SESSION_COOKIE,
    sessionCarrier,
    buildAdminSessionCookieOptions(),
  );
  redirect(nextPath);
}

export async function issueAdminSessionCarrierAction(formData: FormData) {
  const nextPath = sanitizeAdminNextPath(readOptionalString(formData, 'next'));
  let sessionCarrier = '';

  try {
    if (formData.get('consentAccepted') !== 'on') {
      throw new Error('请先确认由 Server Auth 验证并签发管理员会话载体。');
    }
    const response = await issueAdminSessionCarrier({
      mobile: readRequiredString(formData, 'mobile'),
      password: readRequiredString(formData, 'password'),
      deviceId: readOptionalString(formData, 'deviceId') ?? 'admin-carrier-browser',
      deviceName: 'Admin Governance Console',
      osType: 'web',
      consentAccepted: true,
    });
    sessionCarrier = normalizeAdminSessionCarrier(response.adminSessionCarrier);
    await verifyAdminSessionCarrier(sessionCarrier);
  } catch (error) {
    redirect(buildLoginUrl(nextPath, 'error', toErrorMessage(error)));
  }

  const cookieStore = await cookies();
  cookieStore.set(
    ADMIN_SESSION_COOKIE,
    sessionCarrier,
    buildAdminSessionCookieOptions(),
  );
  redirect(nextPath);
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

function readRequiredString(formData: FormData, key: string) {
  const value = readOptionalString(formData, key)?.trim() ?? '';
  if (!value) {
    throw new Error(`字段 ${key} 不能为空。`);
  }
  return value;
}

function toErrorMessage(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '管理员会话载体验证失败。';
}
