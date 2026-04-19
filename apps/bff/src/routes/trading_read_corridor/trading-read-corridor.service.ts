import { BadRequestException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type ContractDetailViewModel,
  type InspectionDetailViewModel,
  type MilestoneListViewModel,
  type OrderDetailViewModel,
  readContractDetailViewModel,
  readInspectionDetailViewModel,
  readMilestoneListViewModel,
  readOrderDetailViewModel,
} from './trading-read-corridor.read-model';
import { TradingReadCorridorErrorService } from './trading-read-corridor.error.service';

@Injectable()
export class TradingReadCorridorService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly tradingReadErrors: TradingReadCorridorErrorService,
  ) {}

  async getOrderDetail(
    orderId: string | undefined,
    headers: IncomingHttpHeaders,
  ): Promise<OrderDetailViewModel> {
    const normalizedOrderId = this.requireQueryId(
      orderId,
      'ORDER_DETAIL_INVALID',
      '当前订单标识缺失，请重新进入订单详情后再试。',
    );
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/order/detail',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
          params: { orderId: normalizedOrderId },
        },
      );
      return readOrderDetailViewModel(
        this.requireRecord(result, 'Order detail response must be an object.'),
      );
    } catch (error) {
      throw this.tradingReadErrors.normalizeOrderDetailError(error);
    }
  }

  async getContractDetail(
    orderId: string | undefined,
    headers: IncomingHttpHeaders,
  ): Promise<ContractDetailViewModel> {
    const normalizedOrderId = this.requireQueryId(
      orderId,
      'CONTRACT_DETAIL_INVALID',
      '当前合同标识缺失，请重新进入合同详情后再试。',
    );
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/contract/detail',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
          params: { orderId: normalizedOrderId },
        },
      );
      return readContractDetailViewModel(
        this.requireRecord(result, 'Contract detail response must be an object.'),
      );
    } catch (error) {
      throw this.tradingReadErrors.normalizeContractDetailError(error);
    }
  }

  async getMilestoneList(
    orderId: string | undefined,
    headers: IncomingHttpHeaders,
  ): Promise<MilestoneListViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/milestone/list',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
          params: { orderId },
        },
      );
      return readMilestoneListViewModel(
        this.requireRecord(result, 'Milestone list response must be an object.'),
      );
    } catch (error) {
      throw this.tradingReadErrors.normalizeMilestoneListError(error);
    }
  }

  async getInspectionDetail(
    milestoneId: string | undefined,
    headers: IncomingHttpHeaders,
  ): Promise<InspectionDetailViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/inspection/detail',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
          params: { milestoneId },
        },
      );
      return readInspectionDetailViewModel(
        this.requireRecord(
          result,
          'Inspection detail response must be an object.',
        ),
      );
    } catch (error) {
      throw this.tradingReadErrors.normalizeInspectionDetailError(error);
    }
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private requireQueryId(
    value: string | undefined,
    code: string,
    message: string,
  ): string {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: 'bff',
    });
  }
}
