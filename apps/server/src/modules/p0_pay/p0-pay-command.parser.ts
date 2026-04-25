import { Injectable } from '@nestjs/common';
import { normalizeFeeRate, normalizePositiveMoney } from './p0-pay-calculator';
import {
  AuthorizeInitCommand,
  ContractConfirmationCommand,
  CreateAuthorizationCommand,
  CreateInquiryDepositOrderCommand,
  InquiryDepositPayInitCommand
} from './p0-pay.commands';
import { p0PayInvalid } from './p0-pay.errors';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import { P0PayPaymentChannel } from './p0-pay.types';

@Injectable()
export class P0PayCommandParser {
  constructor(private readonly idempotencyService: P0PayIdempotencyService) {}

  toCreateCommand(taskId: string, bidId: string, payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      taskId: this.readPathId(taskId, 'taskId'),
      bidId: this.readPathId(bidId, 'bidId'),
      expectedQuotedAmount: normalizePositiveMoney(
        this.readRequired(source.expectedQuotedAmount),
        'expectedQuotedAmount'
      ),
      expectedFeeRate: normalizeFeeRate(this.readRequired(source.expectedFeeRate)),
      expectedAuthorizationAmount: normalizePositiveMoney(
        this.readRequired(source.expectedAuthorizationAmount),
        'expectedAuthorizationAmount'
      ),
      currency: this.readCurrency(source.currency),
      idempotencyKey: this.idempotencyService.normalizeKey(source.idempotencyKey)
    } satisfies CreateAuthorizationCommand;
  }

  toAuthorizeInitCommand(
    taskId: string,
    bidId: string,
    authorizationId: string,
    payload: Record<string, unknown>
  ) {
    const source = this.asRecord(payload);
    return {
      taskId: this.readPathId(taskId, 'taskId'),
      bidId: this.readPathId(bidId, 'bidId'),
      authorizationId: this.readPathId(authorizationId, 'authorizationId'),
      payChannel: this.readPayChannel(source.payChannel),
      clientPlatform: this.readClientPlatform(source.clientPlatform),
      idempotencyKey: this.idempotencyService.normalizeKey(source.idempotencyKey)
    } satisfies AuthorizeInitCommand;
  }

  toCreateInquiryDepositOrderCommand(taskId: string, payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      taskId: this.readPathId(taskId, 'taskId'),
      expectedAmount: normalizePositiveMoney(this.readRequired(source.expectedAmount), 'expectedAmount'),
      expectedCurrency: this.readCurrency(source.expectedCurrency),
      ruleVersion: this.readRequiredString(source.ruleVersion, 'ruleVersion'),
      ruleSnapshotHash: this.readRequiredString(source.ruleSnapshotHash, 'ruleSnapshotHash'),
      idempotencyKey: this.idempotencyService.normalizeKey(source.idempotencyKey)
    } satisfies CreateInquiryDepositOrderCommand;
  }

  toInquiryDepositPayInitCommand(taskId: string, depositOrderId: string, payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      taskId: this.readPathId(taskId, 'taskId'),
      depositOrderId: this.readPathId(depositOrderId, 'depositOrderId'),
      payChannel: this.readPayChannel(source.payChannel),
      clientPlatform: this.readClientPlatform(source.clientPlatform),
      idempotencyKey: this.idempotencyService.normalizeKey(source.idempotencyKey)
    } satisfies InquiryDepositPayInitCommand;
  }

  toContractConfirmationCommand(taskId: string, payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      taskId: this.readPathId(taskId, 'taskId'),
      selectedBidId: this.readOptionalId(source.selectedBidId),
      selectedQuotationId: this.readOptionalId(source.selectedQuotationId),
      finalConfirmedAmount: normalizePositiveMoney(
        this.readRequired(source.finalConfirmedAmount),
        'finalConfirmedAmount'
      ),
      currency: this.readCurrency(source.currency),
      contractFileAssetIds: this.readStringArray(source.contractFileAssetIds, 'contractFileAssetIds'),
      confirmationRole: this.readConfirmationRole(source.confirmationRole),
      platformServiceFeeRecalculationAwarenessConfirmed: this.readRequiredBoolean(
        source.platformServiceFeeRecalculationAwarenessConfirmed,
        'platformServiceFeeRecalculationAwarenessConfirmed'
      ),
      idempotencyKey: this.idempotencyService.normalizeKey(source.idempotencyKey)
    } satisfies ContractConfirmationCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw p0PayInvalid('P0-Pay request body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequired(value: unknown) {
    if (value === null || value === undefined || value === '') {
      throw p0PayInvalid('Required P0-Pay field is missing.');
    }
    return value as string | number;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw p0PayInvalid(`Field \`${field}\` is required for P0-Pay.`);
    }
    return value.trim();
  }

  private readOptionalId(value: unknown) {
    if (value === null || value === undefined) {
      return null;
    }
    if (typeof value !== 'string') {
      throw p0PayInvalid('Optional id fields must be strings when present.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readStringArray(value: unknown, field: string) {
    if (!Array.isArray(value)) {
      throw p0PayInvalid(`Field \`${field}\` must be an array.`);
    }
    return value.map((item) => this.readRequiredString(item, field));
  }

  private readRequiredBoolean(value: unknown, field: string) {
    if (value !== true) {
      throw p0PayInvalid(`Field \`${field}\` must be confirmed.`);
    }
    return value;
  }

  private readConfirmationRole(value: unknown): ContractConfirmationCommand['confirmationRole'] {
    if (value === 'publisher' || value === 'factory') {
      return value;
    }
    throw p0PayInvalid('Field `confirmationRole` must be publisher or factory.');
  }

  private readPathId(value: string, field: string) {
    const normalized = value.trim();
    if (!normalized) {
      throw p0PayInvalid(`Path parameter \`${field}\` is required.`);
    }
    return normalized;
  }

  private readCurrency(value: unknown) {
    if (typeof value !== 'string' || value.trim() !== 'CNY') {
      throw p0PayInvalid('Field `currency` must be CNY.');
    }
    return value.trim();
  }

  private readPayChannel(value: unknown): P0PayPaymentChannel {
    if (value === 'alipay_candidate') {
      return 'alipay';
    }
    if (value === 'wechat_candidate') {
      return 'wechat';
    }
    if (value === 'other_candidate') {
      return 'other';
    }
    throw p0PayInvalid('Field `payChannel` must be a supported P0-Pay channel candidate.');
  }

  private readClientPlatform(value: unknown) {
    if (typeof value !== 'string' || !value.trim()) {
      throw p0PayInvalid('Field `clientPlatform` is required for authorization init.');
    }
    return value.trim().slice(0, 64);
  }
}
