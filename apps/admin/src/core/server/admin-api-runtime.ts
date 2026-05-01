import { cookies, headers } from 'next/headers.js';
import { getServerConfig } from '../config/env';
import {
  ADMIN_SESSION_COOKIE,
  toAdminAuthorizationCarrier
} from '../auth/route-guard';

export type AdminApiRuntimeSnapshot = {
  fetchImpl: typeof fetch;
  serverAdminApiBaseUrl: string;
  incomingHeaders: Headers;
  sessionCarrier: string | null;
};

type AdminApiRuntimeOverrides = Partial<AdminApiRuntimeSnapshot>;

let adminApiRuntimeFactoryForTest:
  | (() => Promise<AdminApiRuntimeSnapshot>)
  | null = null;

export class AdminApiError extends Error {
  readonly status: number;
  readonly code: string;
  readonly details: unknown;

  constructor(status: number, code: string, message: string, details: unknown) {
    super(message);
    this.name = 'AdminApiError';
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export function setAdminApiRuntimeForTest(
  factory: (() => Promise<AdminApiRuntimeSnapshot>) | null
) {
  adminApiRuntimeFactoryForTest = factory;
}

export async function adminJsonRequest<T>(
  path: string,
  options: { method?: 'GET' | 'POST'; body?: Record<string, unknown> } = {},
  runtimeOverrides: AdminApiRuntimeOverrides = {}
): Promise<T> {
  const runtime = await resolveAdminApiRuntime(runtimeOverrides);
  const response = await runtime.fetchImpl(
    buildAdminApiUrl(runtime.serverAdminApiBaseUrl, path),
    {
      method: options.method ?? 'GET',
      cache: 'no-store',
      headers: buildServerAdminHeaders({
        incomingHeaders: runtime.incomingHeaders,
        sessionCarrier: runtime.sessionCarrier,
        hasBody: Boolean(options.body)
      }),
      body: options.body ? JSON.stringify(options.body) : undefined
    }
  );
  const payload = await readJson(response);
  if (!response.ok) {
    throw toAdminApiError(response.status, payload);
  }
  return payload as T;
}

export function toQueryString(query: Record<string, string | number | undefined>) {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined && value !== '') {
      params.set(key, String(value));
    }
  }
  const serialized = params.toString();
  return serialized ? `?${serialized}` : '';
}

async function resolveAdminApiRuntime(
  overrides: AdminApiRuntimeOverrides
): Promise<AdminApiRuntimeSnapshot> {
  const baseRuntime = adminApiRuntimeFactoryForTest
    ? await adminApiRuntimeFactoryForTest()
    : await readAdminApiRuntimeFromNext();
  return {
    fetchImpl: overrides.fetchImpl ?? baseRuntime.fetchImpl,
    serverAdminApiBaseUrl:
      overrides.serverAdminApiBaseUrl ?? baseRuntime.serverAdminApiBaseUrl,
    incomingHeaders: overrides.incomingHeaders ?? baseRuntime.incomingHeaders,
    sessionCarrier:
      overrides.sessionCarrier === undefined
        ? baseRuntime.sessionCarrier
        : overrides.sessionCarrier
  };
}

async function readAdminApiRuntimeFromNext(): Promise<AdminApiRuntimeSnapshot> {
  const incomingHeaders = await headers();
  const incomingCookies = await cookies();
  return {
    fetchImpl: fetch,
    serverAdminApiBaseUrl: getServerConfig().serverAdminApiBaseUrl,
    incomingHeaders,
    sessionCarrier: incomingCookies.get(ADMIN_SESSION_COOKIE)?.value ?? null
  };
}

function buildServerAdminHeaders(input: {
  incomingHeaders: Headers;
  sessionCarrier: string | null;
  hasBody: boolean;
}) {
  const outgoing: Record<string, string> = {
    'x-admin-client': 'admin-governance-console'
  };
  // Admin runtime carrier truth comes from the verified admin_session cookie.
  // Incoming Authorization is not a production carrier source for Admin.
  const authorization = toAdminAuthorizationCarrier(input.sessionCarrier);
  if (authorization) {
    outgoing.authorization = authorization;
  }
  for (const headerName of [
    'x-actor-id',
    'x-user-id',
    'x-organization-id',
    'x-actor-role',
    'x-role',
    'x-request-id',
    'x-trace-id'
  ]) {
    const value = readForwardHeader(input.incomingHeaders, headerName);
    if (value) {
      outgoing[headerName] = value;
    }
  }
  if (input.hasBody) {
    outgoing['content-type'] = 'application/json';
  }
  return outgoing;
}

function buildAdminApiUrl(baseUrl: string, path: string) {
  return `${baseUrl.replace(/\/$/, '')}/${path.replace(/^\//, '')}`;
}

function readForwardHeader(source: Headers, name: string) {
  const value = source.get(name)?.trim() ?? '';
  return value ? value : null;
}

async function readJson(response: Response) {
  const text = await response.text();
  if (!text) {
    return null;
  }
  try {
    return JSON.parse(text) as unknown;
  } catch {
    return { message: text };
  }
}

function toAdminApiError(status: number, payload: unknown) {
  const body = isRecord(payload) ? payload : {};
  const code = typeof body.code === 'string' ? body.code : `HTTP_${status}`;
  const message =
    typeof body.message === 'string'
      ? body.message
      : `Server Admin API request failed with ${status}`;
  return new AdminApiError(status, code, message, payload);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}
