import { Injectable } from '@nestjs/common';
import { createHash, randomUUID } from 'crypto';
import { p0PayInvalid } from './p0-pay.errors';

@Injectable()
export class P0PayIdempotencyService {
  normalizeKey(value: unknown) {
    if (typeof value !== 'string') {
      throw p0PayInvalid('Field `idempotencyKey` is required for P0-Pay mutations.');
    }
    const normalized = value.trim();
    if (normalized.length < 8 || normalized.length > 128) {
      throw p0PayInvalid('Field `idempotencyKey` must be 8 to 128 characters.');
    }
    return normalized;
  }

  hashKey(idempotencyKey: string) {
    return createHash('sha256').update(idempotencyKey, 'utf8').digest('hex');
  }

  hashRequest(value: unknown) {
    return createHash('sha256').update(JSON.stringify(this.sortValue(value)), 'utf8').digest('hex');
  }

  buildMerchantOrderNo(prefix: string) {
    const normalizedPrefix = prefix.trim().replace(/[^A-Za-z0-9_]/g, '').slice(0, 24) || 'P0PAY';
    const suffix = randomUUID().replace(/-/g, '').toUpperCase();
    return `${normalizedPrefix}_${suffix}`;
  }

  private sortValue(value: unknown): unknown {
    if (Array.isArray(value)) {
      return value.map((item) => this.sortValue(item));
    }
    if (!value || typeof value !== 'object') {
      return value;
    }
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, item]) => [key, this.sortValue(item)])
    );
  }
}
