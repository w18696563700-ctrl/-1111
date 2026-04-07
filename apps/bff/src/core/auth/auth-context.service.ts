import { Injectable, UnauthorizedException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import type { IncomingHttpHeaders } from 'http';

@Injectable()
export class AuthContextService {
  buildAuthTransportHeaders(headers: IncomingHttpHeaders): Record<string, string> {
    const result: Record<string, string> = {
      'x-request-id': this.readHeader(headers, 'x-request-id') ?? randomUUID(),
      'x-trace-id': this.readHeader(headers, 'x-trace-id') ?? randomUUID(),
    };

    this.assignIfPresent(
      result,
      'authorization',
      this.readHeader(headers, 'authorization'),
    );
    this.assignIfPresent(
      result,
      'x-actor-id',
      this.readHeader(headers, 'x-actor-id'),
    );
    this.assignIfPresent(
      result,
      'x-user-id',
      this.readHeader(headers, 'x-user-id'),
    );
    this.assignIfPresent(
      result,
      'x-device-id',
      this.readHeader(headers, 'x-device-id'),
    );
    this.assignIfPresent(
      result,
      'user-agent',
      this.readHeader(headers, 'user-agent'),
    );
    this.assignIfPresent(
      result,
      'x-forwarded-for',
      this.readHeader(headers, 'x-forwarded-for'),
    );
    this.assignIfPresent(
      result,
      'x-real-ip',
      this.readHeader(headers, 'x-real-ip'),
    );

    return result;
  }

  buildReadOnlyForwardHeaders(headers: IncomingHttpHeaders): Record<string, string> {
    const authorization = this.readHeader(headers, 'authorization');
    const actorId = this.readHeader(headers, 'x-actor-id');
    const userId = this.readHeader(headers, 'x-user-id');

    if (!authorization && !actorId && !userId) {
      throw new UnauthorizedException({
        statusCode: 401,
        code: 'AUTH_SESSION_INVALID',
        message:
          'Request must include a forwardable auth transport carrier or actor hint (authorization, x-actor-id, or x-user-id header).',
        source: 'bff',
      });
    }

    const result = this.buildPublicHeaders(headers);
    this.assignIfPresent(result, 'x-actor-id', actorId);
    this.assignIfPresent(result, 'x-user-id', userId);
    return result;
  }

  buildPublicHeaders(headers: IncomingHttpHeaders): Record<string, string> {
    const result: Record<string, string> = {
      'x-request-id': this.readHeader(headers, 'x-request-id') ?? randomUUID(),
      'x-trace-id': this.readHeader(headers, 'x-trace-id') ?? randomUUID(),
    };

    this.assignIfPresent(
      result,
      'authorization',
      this.readHeader(headers, 'authorization'),
    );
    this.assignIfPresent(
      result,
      'x-device-id',
      this.readHeader(headers, 'x-device-id'),
    );
    this.assignIfPresent(
      result,
      'x-organization-id',
      this.readHeader(headers, 'x-organization-id', 'x-org-id'),
    );
    this.assignIfPresent(
      result,
      'x-actor-role',
      this.readHeader(headers, 'x-actor-role', 'x-role'),
    );
    this.assignIfPresent(
      result,
      'user-agent',
      this.readHeader(headers, 'user-agent'),
    );

    return result;
  }

  buildPublicHeadersWithOptionalActorHints(
    headers: IncomingHttpHeaders,
  ): Record<string, string> {
    const result = this.buildPublicHeaders(headers);
    this.assignIfPresent(
      result,
      'x-actor-id',
      this.readHeader(headers, 'x-actor-id'),
    );
    this.assignIfPresent(
      result,
      'x-user-id',
      this.readHeader(headers, 'x-user-id'),
    );
    return result;
  }

  buildForwardHeaders(headers: IncomingHttpHeaders): Record<string, string> {
    const result = this.buildReadOnlyForwardHeaders(headers);
    if (!result['x-actor-id'] && result['x-user-id']) {
      result['x-actor-id'] = result['x-user-id'];
    }
    return result;
  }

  private assignIfPresent(
    target: Record<string, string>,
    key: string,
    value: string | undefined,
  ) {
    if (value) {
      target[key] = value;
    }
  }

  private readHeader(
    headers: IncomingHttpHeaders,
    ...keys: string[]
  ): string | undefined {
    for (const key of keys) {
      const value = headers[key];
      if (Array.isArray(value)) {
        if (value[0]) {
          return value[0];
        }
        continue;
      }
      if (typeof value === 'string' && value.length > 0) {
        return value;
      }
    }
    return undefined;
  }
}
