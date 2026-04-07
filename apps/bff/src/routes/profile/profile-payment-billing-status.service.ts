import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type PaymentAndBillingExplanationViewModel,
  type PaymentAndBillingHandoffViewModel,
  type PaymentAndBillingStatusViewModel,
  readPaymentAndBillingExplanationViewModel,
  readPaymentAndBillingHandoffViewModel,
  readPaymentAndBillingStatusViewModel,
} from './profile-payment-billing-status.read-model';
import { ProfilePaymentBillingStatusErrorService } from './profile-payment-billing-status-error.service';

@Injectable()
export class ProfilePaymentBillingStatusService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly paymentBillingErrors: ProfilePaymentBillingStatusErrorService,
  ) {}

  async getStatus(headers: IncomingHttpHeaders): Promise<PaymentAndBillingStatusViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/payment-and-billing-status/status',
        { headers: this.authContext.buildReadOnlyForwardHeaders(headers) },
      );
      return readPaymentAndBillingStatusViewModel(
        this.requireRecord(result, 'Payment-and-billing-status status response must be an object.'),
      );
    } catch (error) {
      throw this.paymentBillingErrors.normalizeStatusError(error);
    }
  }

  async getExplanation(
    headers: IncomingHttpHeaders,
  ): Promise<PaymentAndBillingExplanationViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/payment-and-billing-status/explanation',
        { headers: this.authContext.buildReadOnlyForwardHeaders(headers) },
      );
      return readPaymentAndBillingExplanationViewModel(
        this.requireRecord(
          result,
          'Payment-and-billing-status explanation response must be an object.',
        ),
      );
    } catch (error) {
      throw this.paymentBillingErrors.normalizeExplanationError(error);
    }
  }

  async getHandoff(headers: IncomingHttpHeaders): Promise<PaymentAndBillingHandoffViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/payment-and-billing-status/handoff',
        { headers: this.authContext.buildReadOnlyForwardHeaders(headers) },
      );
      return readPaymentAndBillingHandoffViewModel(
        this.requireRecord(
          result,
          'Payment-and-billing-status handoff response must be an object.',
        ),
      );
    } catch (error) {
      throw this.paymentBillingErrors.normalizeHandoffError(error);
    }
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }
}
