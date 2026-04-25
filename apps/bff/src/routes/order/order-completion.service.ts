import { BadRequestException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { OrderCompletionErrorService } from './order-completion.error.service';
import { readOrderCompletionAcceptedResponse } from './order-completion.read-model';

@Injectable()
export class OrderCompletionService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: OrderCompletionErrorService,
  ) {}

  async requestCompletion(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<unknown>(
        '/server/order/complete/request',
        this.toRequestPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return readOrderCompletionAcceptedResponse(
        result,
        'order_completion_request.submit',
      );
    } catch (error) {
      throw this.errors.normalizeRequestError(error);
    }
  }

  async confirmCompletion(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<unknown>(
        '/server/order/complete/confirm',
        this.toOrderOnlyPayload(payload, '当前完工确认参数无效，请检查后再试。'),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return readOrderCompletionAcceptedResponse(
        result,
        'order_completion_confirm.submit',
      );
    } catch (error) {
      throw this.errors.normalizeConfirmError(error);
    }
  }

  async rejectCompletion(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<unknown>(
        '/server/order/complete/reject',
        this.toRejectPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return readOrderCompletionAcceptedResponse(
        result,
        'order_completion_reject.submit',
      );
    } catch (error) {
      throw this.errors.normalizeRejectError(error);
    }
  }

  private toRequestPayload(payload: Record<string, unknown>) {
    const source = this.requirePayload(payload, '当前完工申请参数无效，请检查后再试。');
    return this.compactRecord({
      orderId: this.readRequiredString(
        source.orderId,
        '当前完工申请参数无效，请检查后再试。',
      ),
      note: this.readOptionalString(source.note),
    });
  }

  private toRejectPayload(payload: Record<string, unknown>) {
    const source = this.requirePayload(payload, '当前完工拒绝参数无效，请检查后再试。');
    return this.compactRecord({
      orderId: this.readRequiredString(
        source.orderId,
        '当前完工拒绝参数无效，请检查后再试。',
      ),
      reason: this.readOptionalString(source.reason),
      reserveDispute: source.reserveDispute === true,
    });
  }

  private toOrderOnlyPayload(payload: Record<string, unknown>, message: string) {
    const source = this.requirePayload(payload, message);
    return {
      orderId: this.readRequiredString(source.orderId, message),
    };
  }

  private requirePayload(value: unknown, message: string) {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw this.invalid(message);
  }

  private readRequiredString(value: unknown, message: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw this.invalid(message);
  }

  private readOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return undefined;
    }
    const normalized = value.trim();
    return normalized || undefined;
  }

  private compactRecord<T extends Record<string, unknown>>(value: T) {
    const result: Record<string, unknown> = {};
    for (const [key, rawValue] of Object.entries(value)) {
      if (rawValue !== undefined) {
        result[key] = rawValue;
      }
    }
    return result;
  }

  private invalid(message: string) {
    return new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_ORDER_COMPLETE_INVALID',
      message,
      source: 'bff',
    });
  }
}
