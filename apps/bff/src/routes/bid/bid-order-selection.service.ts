import { BadRequestException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { normalizeBidSelectAndCreateOrderError } from './bid-order-selection.error';
import { readBidSelectAndCreateOrderAcceptedResponse } from './bid-order-selection.read-model';

@Injectable()
export class BidOrderSelectionService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async selectBidAndCreateOrder(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<unknown>(
        '/server/bid/select-bid-and-create-order',
        this.toSelectionPayload(payload),
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return readBidSelectAndCreateOrderAcceptedResponse(result);
    } catch (error) {
      throw normalizeBidSelectAndCreateOrderError(error, this.errors);
    }
  }

  private toSelectionPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw this.invalidSelection('当前选择合作方数据格式无效，请刷新后重试。');
    }

    return {
      projectId: this.readRequiredString(payload.projectId, '当前项目标识缺失，无法选择合作方。'),
      winningBidId: this.readRequiredString(payload.winningBidId, '当前投标标识缺失，无法选择合作方。'),
      reasonCode: this.readRequiredString(payload.reasonCode, '当前选择合作方原因编码缺失，无法提交。'),
      reasonText: this.readRequiredString(payload.reasonText, '当前选择合作方原因说明缺失，无法提交。'),
    };
  }

  private readRequiredString(value: unknown, message: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw this.invalidSelection(message);
  }

  private invalidSelection(message: string) {
    return new BadRequestException({
      statusCode: 400,
      code: 'BID_AWARD_INVALID',
      message,
      source: 'bff',
    });
  }
}
