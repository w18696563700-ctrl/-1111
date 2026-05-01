export const ADMIN_SESSION_COOKIE = 'admin_session';
export const ACTIVE_ADMIN_LOGIN_MODE = 'server_session_carrier_only';
export const DEFAULT_ADMIN_NEXT_PATH = '/review';

export const PROTECTED_PREFIXES = [
  '/review',
  '/governance',
  '/project_review',
  '/template_config',
  '/audit',
  '/membership',
  '/ticketing',
] as const;

export function isProtectedPath(pathname: string): boolean {
  return PROTECTED_PREFIXES.some((prefix) =>
    pathname === prefix || pathname.startsWith(`${prefix}/`),
  );
}

export function hasAdminSessionCarrier(value: string | null | undefined) {
  return Boolean(value?.trim());
}

export function normalizeAdminSessionCarrier(value: FormDataEntryValue | string | null | undefined) {
  if (typeof value !== 'string') {
    throw new Error('sessionCarrier 为必填项。');
  }

  const normalized = value.trim();
  if (!normalized) {
    throw new Error('sessionCarrier 为必填项。');
  }

  if (normalized.toLowerCase().startsWith('bearer ')) {
    const token = normalized.slice(7).trim();
    if (!token) {
      throw new Error('sessionCarrier 不能为空载体。');
    }
    return token;
  }

  return normalized;
}

export function toAdminAuthorizationCarrier(value: string | null | undefined) {
  if (!hasAdminSessionCarrier(value)) {
    return null;
  }

  const normalized = normalizeAdminSessionCarrier(value);
  return `Bearer ${normalized}`;
}

export function sanitizeAdminNextPath(value: string | null | undefined) {
  const normalized = value?.trim() ?? '';
  if (!normalized.startsWith('/')) {
    return DEFAULT_ADMIN_NEXT_PATH;
  }

  try {
    const url = new URL(normalized, 'http://admin.local');
    if (!isProtectedPath(url.pathname)) {
      return DEFAULT_ADMIN_NEXT_PATH;
    }
    return `${url.pathname}${url.search}`;
  } catch {
    return DEFAULT_ADMIN_NEXT_PATH;
  }
}

export function buildAdminLoginRedirectUrl(requestUrl: string, pathname: string) {
  const loginUrl = new URL('/login', requestUrl);
  loginUrl.searchParams.set('next', sanitizeAdminNextPath(pathname));
  return loginUrl.toString();
}

export function resolveProtectedPathAccess(input: {
  pathname: string;
  requestUrl: string;
  sessionCarrier: string | null | undefined;
}) {
  if (!isProtectedPath(input.pathname)) {
    return { outcome: 'allow' as const };
  }

  if (hasAdminSessionCarrier(input.sessionCarrier)) {
    return { outcome: 'allow' as const };
  }

  return {
    outcome: 'redirect' as const,
    location: buildAdminLoginRedirectUrl(input.requestUrl, input.pathname),
  };
}

export function buildAdminSessionCookieOptions() {
  return {
    httpOnly: true,
    sameSite: 'lax' as const,
    secure: process.env.NODE_ENV === 'production',
    path: '/',
  };
}

export function resolveActiveAdminLoginMode() {
  return ACTIVE_ADMIN_LOGIN_MODE;
}
