import { HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type ShellMyBuildingProjectionViewModel,
  PrivateOperatingSystemReferenceError,
  readShellMyBuildingProjection,
} from '../profile/profile-private-operating-system.read-model';
import {
  type PaidMembershipShellSummaryViewModel,
  hasPaidMembershipShellSummary,
  readPaidMembershipShellSummary,
} from '../profile/profile-membership.read-model';
import type { CertificationStatus, MembershipStatus } from '../profile/profile-status.read-model';
import {
  assertScopedStatusConsistency,
  readNullableCertificationStatus,
  readNullableMembershipStatus,
} from '../profile/profile-status.read-model';

type ShellContextViewModel = {
  userId: string;
  displayName: string;
  avatarUrl: string | null;
  organizationId: string | null;
  roleKeys: string[];
  certificationStatus: CertificationStatus | null;
  membershipStatus: MembershipStatus | null;
  visibleBuildings: string[];
  featureFlagsVersion: string;
  unreadSummary: Record<string, unknown>;
  myBuildingProjection: ShellMyBuildingProjectionViewModel;
} & Partial<PaidMembershipShellSummaryViewModel>;

@Injectable()
export class ShellService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getContext(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/shell/context', {
        headers: this.authContext.buildReadOnlyForwardHeaders(headers),
      });
      return this.toContextViewModel(result);
    } catch (error) {
      throw this.normalizeError(error);
    }
  }

  private normalizeError(error: unknown) {
    if (error instanceof PrivateOperatingSystemReferenceError) {
      return new HttpException(
        {
          statusCode: 404,
          code: error.code,
          message: this.translatePrivateOperatingSystemMessage(error.code),
          details: { originalMessage: error.message },
          source: 'bff',
        },
        404,
      );
    }

    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前壳上下文暂时不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const payload = this.asOptionalRecord(normalized.getResponse());
    if (payload) {
      const originalMessage = this.asString(payload.message);
      const code = this.normalizeShellCode(this.asString(payload.code), originalMessage);
      if (
        code === 'SHELL_CONTEXT_ROUTE_UNAVAILABLE' ||
        code === 'REGROUPING_REFERENCE_UNAVAILABLE' ||
        code === 'ENTRY_ORDER_REFERENCE_UNAVAILABLE' ||
        code === 'CORRIDOR_REFERENCE_UNAVAILABLE'
      ) {
        return new HttpException(
          {
            ...payload,
            statusCode: normalized.getStatus(),
            code,
            message: this.translatePrivateOperatingSystemMessage(code),
            details: this.buildNormalizedDetails(payload.details, originalMessage),
            source: payload.source === 'server' ? 'server' : 'bff',
          },
          normalized.getStatus(),
        );
      }
    }

    if (!payload || normalized.getStatus() !== 401 || this.asString(payload.code) !== 'AUTH_SESSION_INVALID') {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        source: payload.source === 'server' ? 'server' : 'bff',
        message: '当前登录态不可用，请重新登录或刷新后再试。',
      },
      normalized.getStatus(),
    );
  }

  private toContextViewModel(result: Record<string, unknown>): ShellContextViewModel {
    this.requireKeys(result, [
      'userId',
      'displayName',
      'avatarUrl',
      'organizationId',
      'roleKeys',
      'certificationStatus',
      'membershipStatus',
      'visibleBuildings',
      'featureFlagsVersion',
      'unreadSummary',
    ]);

    const userId = this.asString(result.userId);
    const displayName = this.asString(result.displayName);
    const featureFlagsVersion = this.asString(result.featureFlagsVersion);
    const unreadSummary = this.asOptionalRecord(result.unreadSummary);

    if (!userId || !displayName || !featureFlagsVersion || !unreadSummary) {
      throw new Error('Shell context response is missing required fields.');
    }

    const organizationId = this.asNullableString(result.organizationId);
    const certificationStatus = readNullableCertificationStatus(
      result.certificationStatus,
      'Shell context response is missing a valid certificationStatus.',
    );
    const membershipStatus = readNullableMembershipStatus(
      result.membershipStatus,
      'Shell context response is missing a valid membershipStatus.',
    );

    assertScopedStatusConsistency({
      context: 'Shell context response',
      organizationId,
      certificationStatus,
      membershipStatus,
    });

    const baseViewModel: ShellContextViewModel = {
      userId,
      displayName,
      avatarUrl: this.asNullableString(result.avatarUrl),
      organizationId,
      roleKeys: this.asStringArray(result.roleKeys),
      certificationStatus,
      membershipStatus,
      visibleBuildings: this.asStringArray(result.visibleBuildings),
      featureFlagsVersion,
      unreadSummary,
      myBuildingProjection: readShellMyBuildingProjection(result.myBuildingProjection),
    };

    if (!hasPaidMembershipShellSummary(result)) {
      return baseViewModel;
    }

    return {
      ...baseViewModel,
      ...readPaidMembershipShellSummary(result, 'Shell context response'),
    };
  }

  private requireKeys(source: Record<string, unknown>, keys: string[]) {
    if (keys.every((key) => Object.prototype.hasOwnProperty.call(source, key))) {
      return;
    }
    throw new Error('Shell context response is missing required fields.');
  }

  private asOptionalRecord(value: unknown) {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private asStringArray(value: unknown) {
    if (!Array.isArray(value)) {
      throw new Error('Expected a string array in shell context response.');
    }

    return [...new Set(value.filter((item): item is string => typeof item === 'string' && item.trim().length > 0))];
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNullableString(value: unknown) {
    if (value === null) {
      return null;
    }
    return this.asString(value) || null;
  }

  private normalizeShellCode(code: string, originalMessage: string) {
    if (originalMessage.startsWith('Cannot GET /server/shell/context')) {
      return 'SHELL_CONTEXT_ROUTE_UNAVAILABLE';
    }
    if (
      code === 'SHELL_CONTEXT_ROUTE_UNAVAILABLE' ||
      code === 'REGROUPING_REFERENCE_UNAVAILABLE' ||
      code === 'ENTRY_ORDER_REFERENCE_UNAVAILABLE' ||
      code === 'CORRIDOR_REFERENCE_UNAVAILABLE'
    ) {
      return code;
    }
    return code;
  }

  private translatePrivateOperatingSystemMessage(code: string) {
    if (code === 'SHELL_CONTEXT_ROUTE_UNAVAILABLE') {
      return '当前壳上下文入口暂不可用，请稍后再试。';
    }
    if (code === 'REGROUPING_REFERENCE_UNAVAILABLE') {
      return '当前重组参考暂不可用，请稍后再试。';
    }
    if (code === 'ENTRY_ORDER_REFERENCE_UNAVAILABLE') {
      return '当前排序参考暂不可用，请稍后再试。';
    }
    if (code === 'CORRIDOR_REFERENCE_UNAVAILABLE') {
      return '当前走廊参考暂不可用，请稍后再试。';
    }
    return '当前壳上下文暂时不可用，请稍后再试。';
  }

  private buildNormalizedDetails(rawDetails: unknown, originalMessage: string) {
    const details = this.asOptionalRecord(rawDetails) ?? {};
    if (originalMessage) {
      details.originalMessage = originalMessage;
    }
    return Object.keys(details).length > 0 ? details : undefined;
  }
}
