import {
  createHash,
  createHmac,
  randomBytes,
  timingSafeEqual
} from 'crypto';
import { Injectable } from '@nestjs/common';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import {
  buildOpaqueAccessCarrier,
  CurrentSessionVerificationFailureReason,
  decodeOpaqueAccessCarrierPayload,
  encodeOpaqueAccessCarrierPayload,
  OpaqueAccessCarrierPayload,
  parseOpaqueAccessCarrier
} from '../../shared/current-session-verification';
import { authUnavailable } from './auth.errors';

type AccessCarrierVerificationResult =
  | {
      outcome: 'verified';
      payload: OpaqueAccessCarrierPayload;
    }
  | {
      outcome: 'failed';
      reason:
        | 'authorization_carrier_malformed'
        | 'authorization_carrier_signature_invalid'
        | 'authorization_carrier_expired';
    };

@Injectable()
export class AccessCarrierService {
  constructor(private readonly config: RuntimeConfigService) {}

  issue(input: { sessionId: string; organizationId: string | null; expiresAt: Date }) {
    const payloadEncoded = encodeOpaqueAccessCarrierPayload({
      sessionId: input.sessionId,
      organizationId: input.organizationId,
      expiresAt: input.expiresAt.toISOString(),
      nonce: randomBytes(18).toString('base64url')
    });
    return buildOpaqueAccessCarrier(payloadEncoded, this.sign(payloadEncoded));
  }

  verify(token: string): AccessCarrierVerificationResult {
    const parsed = parseOpaqueAccessCarrier(token);
    if (!parsed) {
      return {
        outcome: 'failed',
        reason: 'authorization_carrier_malformed'
      };
    }

    const payload = decodeOpaqueAccessCarrierPayload(parsed.payloadEncoded);
    if (!payload) {
      return {
        outcome: 'failed',
        reason: 'authorization_carrier_malformed'
      };
    }
    if (!this.signaturesMatch(parsed.signatureEncoded, this.sign(parsed.payloadEncoded))) {
      return {
        outcome: 'failed',
        reason: 'authorization_carrier_signature_invalid'
      };
    }

    const expiresAt = new Date(payload.expiresAt);
    if (Number.isNaN(expiresAt.getTime()) || expiresAt.getTime() <= Date.now()) {
      return {
        outcome: 'failed',
        reason: 'authorization_carrier_expired'
      };
    }

    return {
      outcome: 'verified',
      payload
    };
  }

  mapFailureReason(reason: Extract<AccessCarrierVerificationResult, { outcome: 'failed' }>) {
    return reason.reason as CurrentSessionVerificationFailureReason;
  }

  private sign(payloadEncoded: string) {
    return createHmac('sha256', this.readSigningKey())
      .update(payloadEncoded)
      .digest('base64url');
  }

  private signaturesMatch(left: string, right: string) {
    const leftBuffer = Buffer.from(left, 'utf8');
    const rightBuffer = Buffer.from(right, 'utf8');
    if (leftBuffer.length !== rightBuffer.length) {
      return false;
    }
    return timingSafeEqual(leftBuffer, rightBuffer);
  }

  private readSigningKey() {
    const material = [
      this.config.authAccessTokenSecret,
      this.config.sessionSigningSecret,
      this.config.sessionOpaqueVerifierSecret
    ];
    if (material.some((item) => !item.trim())) {
      throw authUnavailable('Current auth runtime is missing access carrier verification material.');
    }
    return createHash('sha256')
      .update(material.join(':'))
      .digest();
  }
}
