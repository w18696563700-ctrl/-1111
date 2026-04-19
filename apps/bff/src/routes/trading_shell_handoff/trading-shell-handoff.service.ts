import { BadRequestException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { TradingShellHandoffErrorService } from './trading-shell-handoff.error.service';

@Injectable()
export class TradingShellHandoffService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: TradingShellHandoffErrorService,
  ) {}

  async submitMilestone(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/milestone/submit',
        payload,
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return this.toMilestoneAccepted(
        this.requireRecord(result, 'Milestone submit accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeMilestoneSubmitError(error);
    }
  }

  async submitInspection(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/inspection/submit',
        payload,
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return this.toInspectionAccepted(
        this.requireRecord(result, 'Inspection submit accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeInspectionSubmitError(error);
    }
  }

  async recheckInspection(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/inspection/recheck',
        this.normalizeInspectionRecheckPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return this.toInspectionRecheckAccepted(
        this.requireRecord(result, 'Inspection recheck accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeInspectionRecheckError(error);
    }
  }

  async confirmContract(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/contract/confirm',
        this.normalizeContractConfirmPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return this.toContractConfirmAccepted(
        this.requireRecord(result, 'Contract confirm accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeContractConfirmError(error);
    }
  }

  async amendContract(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/contract/amend',
        this.normalizeContractAmendPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return this.toContractAmendAccepted(
        this.requireRecord(result, 'Contract amend accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeContractAmendError(error);
    }
  }

  async openDispute(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/dispute/open',
        payload,
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return this.toDisputeAccepted(
        this.requireRecord(result, 'Dispute open accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeDisputeOpenError(error);
    }
  }

  async withdrawDispute(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/dispute/withdraw',
        this.normalizeDisputeWithdrawPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return this.toDisputeWithdrawAccepted(
        this.requireRecord(result, 'Dispute withdraw accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeDisputeWithdrawError(error);
    }
  }

  private toMilestoneAccepted(result: Record<string, unknown>) {
    const milestoneId = this.asString(result.milestoneId);
    if (!milestoneId) {
      throw new Error('Milestone submit accepted response is missing milestoneId.');
    }
    return { milestoneId };
  }

  private toInspectionAccepted(result: Record<string, unknown>) {
    const inspectionId = this.asString(result.inspectionId);
    const milestoneId = this.asString(result.milestoneId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!inspectionId || !milestoneId || !state || !summary) {
      throw new Error('Inspection submit accepted response is missing required fields.');
    }
    return {
      inspectionId,
      milestoneId,
      state,
      summary,
    };
  }

  private toInspectionRecheckAccepted(result: Record<string, unknown>) {
    const inspectionId = this.asString(result.inspectionId);
    const milestoneId = this.asString(result.milestoneId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!inspectionId || !milestoneId || !state || !summary) {
      throw new Error('Inspection recheck accepted response is missing required fields.');
    }
    return {
      inspectionId,
      milestoneId,
      state,
      summary,
    };
  }

  private toContractConfirmAccepted(result: Record<string, unknown>) {
    const contractId = this.asString(result.contractId);
    const orderId = this.asString(result.orderId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!contractId || !orderId || !state || !summary) {
      throw new Error('Contract confirm accepted response is missing required fields.');
    }
    return {
      contractId,
      orderId,
      state,
      summary,
    };
  }

  private toContractAmendAccepted(result: Record<string, unknown>) {
    const contractId = this.asString(result.contractId);
    const orderId = this.asString(result.orderId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!contractId || !orderId || !state || !summary) {
      throw new Error('Contract amend accepted response is missing required fields.');
    }
    return {
      contractId,
      orderId,
      state,
      summary,
    };
  }

  private toDisputeAccepted(result: Record<string, unknown>) {
    const orderId = this.asString(result.orderId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!orderId || !state || !summary) {
      throw new Error('Dispute open accepted response is missing required fields.');
    }
    return {
      orderId,
      state,
      summary,
    };
  }

  private toDisputeWithdrawAccepted(result: Record<string, unknown>) {
    const disputeId = this.asString(result.disputeId);
    const orderId = this.asString(result.orderId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!disputeId || !orderId || !state || !summary) {
      throw new Error('Dispute withdraw accepted response is missing required fields.');
    }
    return {
      disputeId,
      orderId,
      state,
      summary,
    };
  }

  private requireRecord(value: unknown, message: string) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asRecordOrNull(value: unknown) {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private asString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }

  private normalizeContractConfirmPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'CONTRACT_CONFIRM_INVALID',
        message: '当前合同确认参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    const orderId = this.asString(payload.orderId);
    if (!orderId) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'CONTRACT_CONFIRM_INVALID',
        message: '当前合同确认参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    return { orderId };
  }

  private normalizeInspectionRecheckPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'INSPECTION_RECHECK_INVALID',
        message: '当前验收复检参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    const inspectionId = this.asString(payload.inspectionId);
    if (!inspectionId) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'INSPECTION_RECHECK_INVALID',
        message: '当前验收复检参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    return { inspectionId };
  }

  private normalizeDisputeWithdrawPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'DISPUTE_WITHDRAW_INVALID',
        message: '当前争议撤回参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    const orderId = this.asString(payload.orderId);
    if (!orderId) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'DISPUTE_WITHDRAW_INVALID',
        message: '当前争议撤回参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    return { orderId };
  }

  private normalizeContractAmendPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'CONTRACT_AMEND_INVALID',
        message: '当前合同改单参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    const orderId = this.asString(payload.orderId);
    if (!orderId) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'CONTRACT_AMEND_INVALID',
        message: '当前合同改单参数无效，请检查后再试。',
        source: 'bff',
      });
    }

    return { orderId };
  }
}
