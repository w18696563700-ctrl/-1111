import { UnauthorizedException } from '@nestjs/common';
import { RequestContext } from './request-context';

export type VerifiedCurrentSessionContext = {
  sessionId: string;
  actorId: string;
  userId: string;
  organizationId: string | null;
  requestId: string;
  traceId: string;
};

export type CurrentSessionVerificationFailureReason =
  | 'missing_current_session_carrier'
  | 'authorization_carrier_malformed'
  | 'authorization_carrier_signature_invalid'
  | 'authorization_carrier_expired'
  | 'current_session_not_found'
  | 'current_session_revoked'
  | 'current_actor_inactive';

export type CurrentSessionVerificationResult =
  | {
      outcome: 'verified';
      currentSession: VerifiedCurrentSessionContext;
    }
  | {
      outcome: 'failed';
      reason: CurrentSessionVerificationFailureReason;
      requestId: string;
      traceId: string;
    };

export type CurrentSessionResolver = {
  verifyCurrentSessionContext(context: RequestContext): Promise<CurrentSessionVerificationResult>;
};

export type OpaqueAccessCarrierPayload = {
  sessionId: string;
  organizationId: string | null;
  expiresAt: string;
  nonce: string;
};

export function readBearerTransportCarrier(authorization: string) {
  const normalized = authorization.trim();
  if (!normalized) {
    return null;
  }

  const [scheme, token, ...rest] = normalized.split(/\s+/);
  if (scheme?.toLowerCase() !== 'bearer' || !token || rest.length > 0) {
    return null;
  }
  return token;
}

export function encodeOpaqueAccessCarrierPayload(payload: OpaqueAccessCarrierPayload) {
  return Buffer.from(JSON.stringify(payload)).toString('base64url');
}

export function decodeOpaqueAccessCarrierPayload(encoded: string) {
  try {
    const raw = Buffer.from(encoded, 'base64url').toString('utf8');
    const value = JSON.parse(raw) as Partial<OpaqueAccessCarrierPayload>;
    if (
      typeof value.sessionId !== 'string' ||
      typeof value.expiresAt !== 'string' ||
      typeof value.nonce !== 'string'
    ) {
      return null;
    }
    if (value.organizationId !== null && value.organizationId !== undefined && typeof value.organizationId !== 'string') {
      return null;
    }

    return {
      sessionId: value.sessionId.trim(),
      organizationId: normalizeNullableString(value.organizationId),
      expiresAt: value.expiresAt,
      nonce: value.nonce.trim()
    } satisfies OpaqueAccessCarrierPayload;
  } catch {
    return null;
  }
}

export function parseOpaqueAccessCarrier(token: string) {
  const normalized = token.trim();
  const segments = normalized.split('.');
  if (segments.length !== 3) {
    return null;
  }
  const [prefix, payloadEncoded, signatureEncoded] = segments;
  if (prefix !== 'p1a' || !payloadEncoded || !signatureEncoded) {
    return null;
  }
  return { payloadEncoded, signatureEncoded };
}

export function buildOpaqueAccessCarrier(payloadEncoded: string, signatureEncoded: string) {
  return `p1a.${payloadEncoded}.${signatureEncoded}`;
}

export function requireVerifiedCurrentSessionContext(context: RequestContext): never;
export function requireVerifiedCurrentSessionContext(
  context: RequestContext,
  resolver: CurrentSessionResolver
): Promise<VerifiedCurrentSessionContext>;
export function requireVerifiedCurrentSessionContext(
  context: RequestContext,
  resolver?: CurrentSessionResolver
) {
  if (!resolver) {
    throw new UnauthorizedException({
      code: 'AUTH_SESSION_INVALID',
      message: describeFailure('authorization_carrier_malformed')
    });
  }
  return requireVerifiedCurrentSessionContextInternal(context, resolver);
}

async function requireVerifiedCurrentSessionContextInternal(
  context: RequestContext,
  resolver: CurrentSessionResolver
) {
  const result = await resolver.verifyCurrentSessionContext(context);
  if (result.outcome === 'verified') {
    return result.currentSession;
  }

  throw new UnauthorizedException({
    code: 'AUTH_SESSION_INVALID',
    message: describeFailure(result.reason)
  });
}

function describeFailure(reason: CurrentSessionVerificationFailureReason) {
  switch (reason) {
    case 'missing_current_session_carrier':
      return 'Current session is invalid or missing a verifiable current-session carrier.';
    case 'authorization_carrier_malformed':
      return 'Current session is invalid because the authorization carrier format is malformed.';
    case 'authorization_carrier_signature_invalid':
      return 'Current session is invalid because the authorization carrier signature is not verifiable.';
    case 'authorization_carrier_expired':
      return 'Current session is invalid because the authorization carrier has expired.';
    case 'current_session_not_found':
      return 'Current session is invalid because no matching session truth is available.';
    case 'current_session_revoked':
      return 'Current session is invalid because the session truth is revoked or expired.';
    case 'current_actor_inactive':
      return 'Current session is invalid because the current actor is unavailable or inactive.';
  }
}

function normalizeNullableString(value: string | null | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized ? normalized : null;
}
