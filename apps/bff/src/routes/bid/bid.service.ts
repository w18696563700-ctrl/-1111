import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { IdempotencyService } from '../../core/idempotency/idempotency.service';
import { normalizeBidAwardError, normalizeBidResultError } from './bid.error';
import {
  normalizeBidPackageCompletenessError,
  normalizeBidSeatError,
} from './bid-seat-completeness.error';
import {
  readBidPackageCompletenessReadModel,
  readBidSeatReadModel,
  readBidSeatStatusReadModel,
} from './bid-seat-completeness.read-model';
import {
  readBidAwardAcceptedResponse,
  readBidSubmitAcceptedResponse,
  readBidResultReadModel,
} from './bid.read-model';
import { readBidSubmissionSnapshotReadModel } from '../my_bid/my-bid.read-model';

@Injectable()
export class BidService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly idempotencyService: IdempotencyService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async lockSeat(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const normalizedIdempotencyKey = this.normalizeIdempotencyKey(idempotencyKey);
    const cached = await this.idempotencyService.getCached(
      'bid-seat-lock',
      normalizedIdempotencyKey,
    );
    if (cached) {
      return cached;
    }

    try {
      const result = await this.serverClient.post<unknown>(
        '/server/bid/seat/lock',
        this.toSeatPayload(payload),
        {
          headers: this.buildScopedForwardHeaders(headers, normalizedIdempotencyKey),
        },
      );
      const readModel = readBidSeatReadModel(result);
      await this.idempotencyService.remember(
        'bid-seat-lock',
        normalizedIdempotencyKey,
        readModel,
      );
      return readModel;
    } catch (error) {
      throw normalizeBidSeatError(error, this.errors, 'lock');
    }
  }

  async releaseSeat(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const normalizedIdempotencyKey = this.normalizeIdempotencyKey(idempotencyKey);
    const cached = await this.idempotencyService.getCached(
      'bid-seat-release',
      normalizedIdempotencyKey,
    );
    if (cached) {
      return cached;
    }

    try {
      const result = await this.serverClient.post<unknown>(
        '/server/bid/seat/release',
        this.toSeatPayload(payload),
        {
          headers: this.buildScopedForwardHeaders(headers, normalizedIdempotencyKey),
        },
      );
      const readModel = readBidSeatReadModel(result);
      await this.idempotencyService.remember(
        'bid-seat-release',
        normalizedIdempotencyKey,
        readModel,
      );
      return readModel;
    } catch (error) {
      throw normalizeBidSeatError(error, this.errors, 'release');
    }
  }

  async getSeatStatus(
    projectId: string | undefined,
    bidId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.get<unknown>('/server/bid/seat/status', {
        headers: this.buildScopedForwardHeaders(headers),
        params: {
          projectId: this.readSeatProjectId(projectId),
          bidId: this.readSeatBidId(bidId),
        },
      });
      return readBidSeatStatusReadModel(result);
    } catch (error) {
      throw normalizeBidSeatError(error, this.errors, 'status');
    }
  }

  async getPackageCompleteness(
    projectId: string | undefined,
    bidId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.get<unknown>(
        '/server/bid/package-completeness',
        {
          headers: this.buildScopedForwardHeaders(headers),
          params: {
            projectId: this.readPackageCompletenessProjectId(projectId),
            bidId: this.readPackageCompletenessBidId(bidId),
          },
        },
      );
      return readBidPackageCompletenessReadModel(result);
    } catch (error) {
      throw normalizeBidPackageCompletenessError(error, this.errors);
    }
  }

  async submitBid(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/bids',
        payload,
        {
          headers: {
            ...this.authContext.buildForwardHeaders(headers),
            ...this.readOrganizationScopeHeaders(headers),
          },
        },
      );
      return this.toAcceptedResponse(result);
    } catch (error) {
      throw this.normalizeSubmitError(error);
    }
  }

  async getBidSubmissionSnapshot(
    projectId: string | undefined,
    bidId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/bid/submission/snapshot',
        {
          headers: this.buildScopedForwardHeaders(headers),
          params: {
            projectId: this.readBidSubmissionSnapshotProjectId(projectId),
            bidId: this.readBidSubmissionSnapshotBidId(bidId),
          },
        },
      );
      return readBidSubmissionSnapshotReadModel(result);
    } catch (error) {
      throw this.normalizeSnapshotError(error);
    }
  }

  async awardBid(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/bid/award',
        this.toAwardPayload(payload),
        {
          headers: this.buildScopedForwardHeaders(headers),
        },
      );
      return readBidAwardAcceptedResponse(result);
    } catch (error) {
      throw normalizeBidAwardError(error, this.errors);
    }
  }

  async getBidResult(projectId: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/bid/result',
        {
          headers: this.buildScopedForwardHeaders(headers),
          params: {
            projectId: this.readBidResultProjectId(projectId),
          },
        },
      );
      return readBidResultReadModel(result);
    } catch (error) {
      throw normalizeBidResultError(error, this.errors);
    }
  }

  private normalizeSubmitError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前投标提交入口暂不可用，请稍后再试。',
      {
        400: 'BID_SUBMIT_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'BID_DUPLICATE_SUBMISSION',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const code = this.asString(payload.code);
    const message = this.asString(payload.message);
    const rewrittenMessage = this.rewriteSubmitErrorMessage(
      statusCode,
      code,
      message,
    );

    if (!rewrittenMessage || rewrittenMessage === message) {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode,
        code,
        source: payload.source === 'server' ? 'server' : 'bff',
        message: rewrittenMessage,
      },
      statusCode,
    );
  }

  private rewriteSubmitErrorMessage(
    statusCode: number,
    code: string | undefined,
    message: string | undefined,
  ) {
    if (statusCode === 401 && code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录后再试。';
    }

    if (statusCode === 403 && code === 'AUTH_PERMISSION_INSUFFICIENT') {
      if (message === 'Current actor lacks the required organization scope for bid submit.') {
        return '当前组织身份不可用，请先进入可投标的组织后再试。';
      }

      if (message === 'Current organization type is not allowed for bid submit.') {
        return '当前组织类型未开放竞标资格，请切换到供应商或需求方/供应商主体后再试。';
      }

      if (message === 'Current actor lacks the required supplier role for bid submit.') {
        return '当前组织类型未开放竞标资格，请切换到供应商或需求方/供应商主体后再试。';
      }

      if (message === 'Current organization certification is not approved for bid submit.') {
        return '当前组织认证尚未通过，暂不具备竞标资格。';
      }

      if (message === 'Current personal certification is not approved for bid submit.') {
        return '当前我的认证尚未通过，暂不具备竞标资格。请先完成身份证正面认证。';
      }

      if (message === 'Current personal certification is locked to another actor for bid submit.') {
        return '当前公司的我的认证已锁定到其他账号，不支持换人，当前账号暂不具备竞标资格。';
      }

      if (
        message ===
        'Current actor lacks the required supplier role, approved certification, or non-owner relation for bid submit.'
      ) {
        return '当前组织类型、认证状态或项目关系不满足竞标资格，请确认当前主体属于供应商或需求方/供应商，且双重认证已经通过后再试。';
      }

      if (message === 'Current project is not published for bid submit.') {
        return '当前项目未处于可投标状态，暂时无法提交投标。';
      }

      if (message === 'Current organization cannot submit bid to its own project.') {
        return '当前组织不能对自己发布的项目提交投标。';
      }

      return '当前组织不具备竞标资格，请确认当前主体类型与认证状态后再试。';
    }

    if (statusCode === 404 && code === 'AUTH_RESOURCE_UNAVAILABLE') {
      if (message === 'Current project is unavailable for bid submit.') {
        return '当前项目不可用，暂时无法提交投标。';
      }

      return '当前投标资源不可用，请稍后再试。';
    }

    if (statusCode === 409 && code === 'BID_DUPLICATE_SUBMISSION') {
      return '当前项目已提交过投标，请勿重复提交。';
    }

    if (statusCode === 409 && code === 'BID_SERVICE_FEE_AUTHORIZATION_REQUIRED') {
      return '资料确认通过后需先完成 4000 元竞标服务费预授权额度，完成后才能开启项目级自由发送。';
    }

    if (statusCode === 409 && code === 'BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE') {
      return '当前竞标服务费预授权额度状态暂不允许开启项目级自由发送，请先完成预授权或刷新后重试。';
    }

    if (statusCode === 400 && code === 'BID_SUBMIT_INVALID') {
      return this.rewriteInvalidMessage(message);
    }

    return message;
  }

  private rewriteInvalidMessage(message: string | undefined) {
    if (message === 'Bid submit body must be an object.') {
      return '当前投标提交数据格式无效，请刷新后重试。';
    }

    if (message === 'Field `projectId` is required for bid submit.') {
      return '当前项目标识缺失，无法提交投标。';
    }

    if (message === 'Field `proposalSummary` is required for bid submit.') {
      return '请先填写投标方案摘要后再提交。';
    }

    if (message === 'Field `quoteAmount` must be a positive number for bid submit.') {
      return '请先填写有效报价金额后再提交。';
    }

    return message;
  }

  private toAcceptedResponse(result: Record<string, unknown>) {
    return readBidSubmitAcceptedResponse(result);
  }

  private normalizeSnapshotError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'BID_SUBMISSION_SNAPSHOT_UNAVAILABLE',
      '当前竞标摘要暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'BID_SUBMISSION_SNAPSHOT_FORBIDDEN',
        404: 'BID_SUBMISSION_SNAPSHOT_UNAVAILABLE',
      },
    );

    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const statusCode = normalized.getStatus();
    const message = this.asString(payload.message);
    if (statusCode === 404 && message?.includes('/server/bid/submission/snapshot')) {
      return new HttpException(
        {
          ...payload,
          statusCode,
          code: 'BID_SUBMISSION_SNAPSHOT_UNAVAILABLE',
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前竞标摘要暂不可用，请稍后再试。',
        },
        statusCode,
      );
    }

    return normalized;
  }

  private asOptionalRecord(value: unknown) {
    return value && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : undefined;
  }

  private asString(value: unknown) {
    return typeof value === 'string' && value.length > 0 ? value : undefined;
  }

  private toAwardPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'BID_AWARD_INVALID',
        message: '当前定标数据格式无效，请刷新后重试。',
        source: 'bff',
      });
    }

    return {
      projectId: this.readRequiredPayloadString(
        payload.projectId,
        '当前项目标识缺失，无法提交定标。',
      ),
      winningBidId: this.readRequiredPayloadString(
        payload.winningBidId,
        '当前中标投标标识缺失，无法提交定标。',
      ),
      reasonCode: this.readRequiredPayloadString(
        payload.reasonCode,
        '当前定标原因编码缺失，无法提交定标。',
      ),
      reasonText: this.readRequiredPayloadString(
        payload.reasonText,
        '当前定标原因说明缺失，无法提交定标。',
      ),
    };
  }

  private readBidResultProjectId(projectId: string | undefined) {
    const normalized = projectId?.trim() ?? '';
    if (normalized.length > 0) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'BID_RESULT_INVALID',
      message: '当前项目标识缺失，无法查看投标结果。',
      source: 'bff',
    });
  }

  private readBidSubmissionSnapshotProjectId(projectId: string | undefined) {
    const normalized = projectId?.trim() ?? '';
    if (normalized.length > 0) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'BID_SUBMISSION_SNAPSHOT_INVALID',
      message: '当前竞标摘要查询参数无效，请检查后重试。',
      source: 'bff',
    });
  }

  private readBidSubmissionSnapshotBidId(bidId: string | undefined) {
    const normalized = bidId?.trim() ?? '';
    if (normalized.length > 0) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'BID_SUBMISSION_SNAPSHOT_INVALID',
      message: '当前竞标摘要查询参数无效，请检查后重试。',
      source: 'bff',
    });
  }

  private toSeatPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'BID_SEAT_INVALID',
        message: '当前席位请求参数无效，请检查后重试。',
        source: 'bff',
      });
    }

    return {
      projectId: this.readRequiredPayloadString(
        payload.projectId,
        '当前席位请求参数无效，请检查后重试。',
        'BID_SEAT_INVALID',
      ),
      bidId: this.readRequiredPayloadString(
        payload.bidId,
        '当前席位请求参数无效，请检查后重试。',
        'BID_SEAT_INVALID',
      ),
    };
  }

  private readSeatProjectId(projectId: string | undefined) {
    const normalized = projectId?.trim() ?? '';
    if (normalized.length > 0) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'BID_SEAT_INVALID',
      message: '当前席位请求参数无效，请检查后重试。',
      source: 'bff',
    });
  }

  private readSeatBidId(bidId: string | undefined) {
    const normalized = bidId?.trim() ?? '';
    if (normalized.length > 0) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'BID_SEAT_INVALID',
      message: '当前席位请求参数无效，请检查后重试。',
      source: 'bff',
    });
  }

  private readPackageCompletenessProjectId(projectId: string | undefined) {
    const normalized = projectId?.trim() ?? '';
    if (normalized.length > 0) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'BID_PACKAGE_COMPLETENESS_INVALID',
      message: '当前投标资料完整性查询参数无效，请检查后重试。',
      source: 'bff',
    });
  }

  private readPackageCompletenessBidId(bidId: string | undefined) {
    const normalized = bidId?.trim() ?? '';
    if (normalized.length > 0) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'BID_PACKAGE_COMPLETENESS_INVALID',
      message: '当前投标资料完整性查询参数无效，请检查后重试。',
      source: 'bff',
    });
  }

  private readRequiredPayloadString(
    value: unknown,
    message: string,
    code = 'BID_AWARD_INVALID',
  ) {
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

  private buildScopedForwardHeaders(
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const result = {
      ...this.authContext.buildForwardHeaders(headers),
      ...this.readOrganizationScopeHeaders(headers),
    };
    if (idempotencyKey) {
      result['x-idempotency-key'] = idempotencyKey;
    }
    return result;
  }

  private readOrganizationScopeHeaders(headers: IncomingHttpHeaders) {
    const organizationId =
      this.readHeader(headers, 'x-organization-id') ??
      this.readHeader(headers, 'x-org-id');
    const actorRole =
      this.readHeader(headers, 'x-actor-role') ??
      this.readHeader(headers, 'x-role');
    const result: Record<string, string> = {};

    if (organizationId) {
      result['x-organization-id'] = organizationId;
    }
    if (actorRole) {
      result['x-actor-role'] = actorRole;
    }

    return result;
  }

  private readHeader(headers: IncomingHttpHeaders, key: string) {
    const value = headers[key];
    if (Array.isArray(value)) {
      return typeof value[0] === 'string' && value[0].length > 0 ? value[0] : undefined;
    }
    return typeof value === 'string' && value.length > 0 ? value : undefined;
  }

  private normalizeIdempotencyKey(idempotencyKey?: string) {
    if (typeof idempotencyKey !== 'string') {
      return undefined;
    }
    const normalized = idempotencyKey.trim();
    return normalized.length > 0 ? normalized : undefined;
  }
}
