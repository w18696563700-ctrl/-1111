import { randomUUID } from 'crypto';

export type HeaderBag = Record<string, string | string[] | undefined>;

export type RequestContext = {
  authorization: string;
  actorId: string;
  userId: string;
  organizationId: string;
  actorRole: string;
  requestId: string;
  traceId: string;
  userAgent: string;
  remoteIp: string;
};

function readHeader(headers: HeaderBag, key: string) {
  const direct = headers[key] ?? headers[key.toLowerCase()];
  if (typeof direct === 'string') {
    return direct.trim();
  }
  if (Array.isArray(direct)) {
    return (direct[0] ?? '').trim();
  }
  return '';
}

export function resolveRequestContext(
  headers: HeaderBag,
  extras?: {
    userAgent?: string;
    remoteIp?: string;
  }
): RequestContext {
  return {
    authorization: readHeader(headers, 'authorization'),
    actorId: readHeader(headers, 'x-actor-id'),
    userId: readHeader(headers, 'x-user-id'),
    organizationId: readHeader(headers, 'x-organization-id'),
    actorRole: readHeader(headers, 'x-actor-role'),
    requestId: readHeader(headers, 'x-request-id') || randomUUID(),
    traceId: readHeader(headers, 'x-trace-id') || randomUUID(),
    userAgent: extras?.userAgent?.trim() ?? '',
    remoteIp: extras?.remoteIp?.trim() ?? ''
  };
}
