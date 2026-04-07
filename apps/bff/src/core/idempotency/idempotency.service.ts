import { Injectable } from '@nestjs/common';

type CacheEntry = {
  expiresAt: number;
  value: unknown;
};

const DEFAULT_TTL_MS = 120_000;

@Injectable()
export class IdempotencyService {
  private readonly cache = new Map<string, CacheEntry>();

  async getCached<T>(scope: string, key?: string): Promise<T | undefined> {
    const cacheKey = this.toCacheKey(scope, key);
    if (!cacheKey) {
      return undefined;
    }

    const cached = this.cache.get(cacheKey);
    if (!cached) {
      return undefined;
    }

    if (cached.expiresAt <= Date.now()) {
      this.cache.delete(cacheKey);
      return undefined;
    }

    return cached.value as T;
  }

  async remember(scope: string, key: string | undefined, value: unknown, ttlMs = DEFAULT_TTL_MS): Promise<void> {
    const cacheKey = this.toCacheKey(scope, key);
    if (!cacheKey) {
      return;
    }

    this.cache.set(cacheKey, {
      expiresAt: Date.now() + ttlMs,
      value,
    });
  }

  private toCacheKey(scope: string, key?: string) {
    const normalizedScope = scope.trim();
    const normalizedKey = typeof key === 'string' ? key.trim() : '';
    if (!normalizedScope || !normalizedKey) {
      return null;
    }
    return `${normalizedScope}:${normalizedKey}`;
  }
}
