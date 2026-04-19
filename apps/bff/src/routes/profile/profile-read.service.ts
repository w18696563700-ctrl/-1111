import { HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type ProfileIndexMyBuildingProjectionViewModel,
  PrivateOperatingSystemReferenceError,
  readProfileIndexMyBuildingProjection,
} from './profile-private-operating-system.read-model';
import type { CertificationStatus, MembershipStatus } from './profile-status.read-model';
import {
  assertScopedStatusConsistency,
  readCertificationStatus,
  readMembershipStatus,
  readNullableCertificationStatus,
  readNullableMembershipStatus,
} from './profile-status.read-model';

type ProfileIndexViewModel = {
  displayName: string;
  avatarUrl: string | null;
  organization: {
    organizationId: string | null;
    roleKeys: string[];
    visibleBuildings: string[];
  };
  certification: {
    status: CertificationStatus | null;
    personalStatus?: CertificationStatus | null;
    personalQualified?: boolean | null;
    personalLockedToOtherActor?: boolean | null;
  };
  membership: {
    status: MembershipStatus | null;
  };
  settingsEntry: {
    state: string;
  };
  myBuildingProjection: ProfileIndexMyBuildingProjectionViewModel;
};

type MyOrganizationsViewModel = {
  items: Array<{
    organizationId: string;
    name: string;
    organizationType: string;
    provinceCode?: string | null;
    cityCode?: string | null;
    contactName?: string | null;
    contactMobile?: string | null;
    intro?: string | null;
    roleKeys: string[];
    membershipStatus: MembershipStatus;
    certificationStatus: CertificationStatus;
    current: boolean;
  }>;
};

type CertificationCurrentViewModel = {
  organizationId: string;
  certificationStatus: CertificationStatus;
  legalName?: string | null;
  uscc?: string | null;
  licenseFileId?: string | null;
  address?: string | null;
  establishedAt?: string | null;
  legalPerson?: string | null;
  businessType?: string | null;
  registeredCapital?: string | null;
  businessTerm?: string | null;
  businessScope?: string | null;
  rejectReason?: string | null;
  expiresAt?: string | null;
  submittedAt?: string | null;
  personalCertification?: {
    organizationId: string;
    userId: string | null;
    certificationStatus: CertificationStatus;
    realName?: string | null;
    idNumberMasked?: string | null;
    idCardFrontFileId?: string | null;
    rejectReason?: string | null;
    submittedAt?: string | null;
    lockedAt?: string | null;
    qualifiedForCurrentActor: boolean;
    lockedToOtherActor: boolean;
  } | null;
};

@Injectable()
export class ProfileReadService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getProfileIndex(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/profile/index', {
        headers: this.authContext.buildReadOnlyForwardHeaders(headers),
      });
      return this.toProfileIndexViewModel(result);
    } catch (error) {
      throw this.normalizeProfileIndexError(error);
    }
  }

  async getOrganizations(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/profile/organization/mine', {
        headers: this.authContext.buildReadOnlyForwardHeaders(headers),
      });
      return this.toOrganizationsViewModel(result);
    } catch (error) {
      throw this.normalizeReadError(error, '当前组织列表暂时不可用，请稍后再试。');
    }
  }

  async getCurrentCertification(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/profile/certification/current', {
        headers: this.authContext.buildReadOnlyForwardHeaders(headers),
      });
      return this.toCertificationCurrentViewModel(result);
    } catch (error) {
      throw this.normalizeReadError(error, '当前认证信息暂时不可用，请稍后再试。');
    }
  }

  private normalizeReadError(error: unknown, fallbackMessage: string) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      fallbackMessage,
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const payload = this.asOptionalRecord(normalized.getResponse());
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

  private normalizeProfileIndexError(error: unknown) {
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
      '当前资料页摘要暂时不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const originalMessage = this.asString(payload.message);
    const code = this.normalizeProfileIndexCode(this.asString(payload.code), originalMessage);

    if (code === 'AUTH_SESSION_INVALID' && normalized.getStatus() === 401) {
      return new HttpException(
        {
          ...payload,
          statusCode: normalized.getStatus(),
          code,
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前登录态不可用，请重新登录或刷新后再试。',
        },
        normalized.getStatus(),
      );
    }

    if (
      code === 'PROFILE_INDEX_ROUTE_UNAVAILABLE' ||
      code === 'REGROUPING_REFERENCE_UNAVAILABLE' ||
      code === 'ENTRY_ORDER_REFERENCE_UNAVAILABLE' ||
      code === 'CORRIDOR_REFERENCE_UNAVAILABLE'
    ) {
      return new HttpException(
        {
          statusCode: normalized.getStatus(),
          code,
          message: this.translatePrivateOperatingSystemMessage(code),
          details: this.buildNormalizedDetails(payload.details, originalMessage),
          source: payload.source === 'server' ? 'server' : 'bff',
        },
        normalized.getStatus(),
      );
    }

    return normalized;
  }

  private toProfileIndexViewModel(result: Record<string, unknown>): ProfileIndexViewModel {
    this.requireKeys(result, [
      'displayName',
      'avatarUrl',
      'organization',
      'certification',
      'membership',
      'settingsEntry',
    ]);
    const organization = this.requireRecord(result.organization, 'Profile index response is missing organization.');
    const certification = this.requireRecord(result.certification, 'Profile index response is missing certification.');
    const membership = this.requireRecord(result.membership, 'Profile index response is missing membership.');
    const settingsEntry = this.requireRecord(result.settingsEntry, 'Profile index response is missing settingsEntry.');
    const displayName = this.asString(result.displayName);

    this.requireKeys(organization, ['organizationId', 'roleKeys', 'visibleBuildings']);
    this.requireKeys(certification, ['status']);
    this.requireKeys(membership, ['status']);
    this.requireKeys(settingsEntry, ['state']);

    const state = this.asString(settingsEntry.state);
    if (!state || !displayName) {
      throw new Error('Profile index response is missing settingsEntry.state.');
    }

    const organizationId = this.asNullableString(organization.organizationId);
    const certificationStatus = readNullableCertificationStatus(
      certification.status,
      'Profile index response is missing a valid certification.status.',
    );
    const membershipStatus = readNullableMembershipStatus(
      membership.status,
      'Profile index response is missing a valid membership.status.',
    );

    assertScopedStatusConsistency({
      context: 'Profile index response',
      organizationId,
      certificationStatus,
      membershipStatus,
    });

    return {
      displayName,
      avatarUrl: this.asNullableString(result.avatarUrl),
      organization: {
        organizationId,
        roleKeys: this.asStringArray(organization.roleKeys),
        visibleBuildings: this.asStringArray(organization.visibleBuildings),
      },
      certification: {
        status: certificationStatus,
        personalStatus: readNullableCertificationStatus(
          certification.personalStatus ?? null,
          'Profile index response is missing a valid certification.personalStatus.',
        ),
        personalQualified:
          typeof certification.personalQualified === 'boolean'
            ? certification.personalQualified
            : null,
        personalLockedToOtherActor:
          typeof certification.personalLockedToOtherActor === 'boolean'
            ? certification.personalLockedToOtherActor
            : null,
      },
      membership: {
        status: membershipStatus,
      },
      settingsEntry: {
        state,
      },
      myBuildingProjection: readProfileIndexMyBuildingProjection(result.myBuildingProjection),
    };
  }

  private toOrganizationsViewModel(result: Record<string, unknown>): MyOrganizationsViewModel {
    this.requireKeys(result, ['items']);
    if (!Array.isArray(result.items)) {
      throw new Error('My organizations response is missing items.');
    }

    return {
      items: result.items.map((item) => {
        const record = this.requireRecord(item, 'My organizations response contains an invalid item.');
        this.requireKeys(record, [
          'organizationId',
          'name',
          'organizationType',
          'roleKeys',
          'membershipStatus',
          'certificationStatus',
          'current',
        ]);

        const organizationId = this.asString(record.organizationId);
        const name = this.asString(record.name);
        const organizationType = this.asString(record.organizationType);
        const membershipStatus = readMembershipStatus(
          record.membershipStatus,
          'My organizations response contains an invalid membershipStatus.',
        );
        const certificationStatus = readCertificationStatus(
          record.certificationStatus,
          'My organizations response contains an invalid certificationStatus.',
        );
        if (!organizationId || !name || !organizationType) {
          throw new Error('My organizations response contains an incomplete item.');
        }

        return {
          organizationId,
          name,
          organizationType,
          ...(Object.prototype.hasOwnProperty.call(record, 'provinceCode')
            ? { provinceCode: this.asNullableString(record.provinceCode) }
            : {}),
          ...(Object.prototype.hasOwnProperty.call(record, 'cityCode')
            ? { cityCode: this.asNullableString(record.cityCode) }
            : {}),
          ...(Object.prototype.hasOwnProperty.call(record, 'contactName')
            ? { contactName: this.asNullableString(record.contactName) }
            : {}),
          ...(Object.prototype.hasOwnProperty.call(record, 'contactMobile')
            ? { contactMobile: this.asNullableString(record.contactMobile) }
            : {}),
          ...(Object.prototype.hasOwnProperty.call(record, 'intro')
            ? { intro: this.asNullableString(record.intro) }
            : {}),
          roleKeys: this.asStringArray(record.roleKeys),
          membershipStatus,
          certificationStatus,
          current: record.current === true,
        };
      }),
    };
  }

  private toCertificationCurrentViewModel(result: Record<string, unknown>): CertificationCurrentViewModel {
    this.requireKeys(result, ['organizationId', 'certificationStatus']);

    const organizationId = this.asString(result.organizationId);
    const certificationStatus = readCertificationStatus(
      result.certificationStatus,
      'Certification current response is missing a valid certificationStatus.',
    );
    if (!organizationId) {
      throw new Error('Certification current response is missing organizationId.');
    }

    return {
      organizationId,
      certificationStatus,
      ...(Object.prototype.hasOwnProperty.call(result, 'legalName')
        ? { legalName: this.asNullableString(result.legalName) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'uscc')
        ? { uscc: this.asNullableString(result.uscc) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'licenseFileId')
        ? { licenseFileId: this.asNullableString(result.licenseFileId) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'address')
        ? { address: this.asNullableString(result.address) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'establishedAt')
        ? { establishedAt: this.asNullableString(result.establishedAt) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'legalPerson')
        ? { legalPerson: this.asNullableString(result.legalPerson) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'businessType')
        ? { businessType: this.asNullableString(result.businessType) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'registeredCapital')
        ? { registeredCapital: this.asNullableString(result.registeredCapital) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'businessTerm')
        ? { businessTerm: this.asNullableString(result.businessTerm) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'businessScope')
        ? { businessScope: this.asNullableString(result.businessScope) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'rejectReason')
        ? { rejectReason: this.asNullableString(result.rejectReason) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'expiresAt')
        ? { expiresAt: this.asNullableString(result.expiresAt) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'submittedAt')
        ? { submittedAt: this.asNullableString(result.submittedAt) }
        : {}),
      ...(Object.prototype.hasOwnProperty.call(result, 'personalCertification')
        ? {
            personalCertification: this.readPersonalCertificationViewModel(
              result.personalCertification
            ),
          }
        : {}),
    };
  }

  private readPersonalCertificationViewModel(value: unknown) {
    if (value == null) {
      return null;
    }
    const record = this.requireRecord(
      value,
      'Certification current response is missing a valid personalCertification object.'
    );
    this.requireKeys(record, [
      'organizationId',
      'certificationStatus',
      'qualifiedForCurrentActor',
      'lockedToOtherActor',
    ]);
    const organizationId = this.asString(record.organizationId);
    const certificationStatus = readCertificationStatus(
      record.certificationStatus,
      'Certification current response is missing a valid personalCertification.certificationStatus.'
    );
    if (!organizationId) {
      throw new Error('Certification current response is missing personalCertification.organizationId.');
    }
    return {
      organizationId,
      userId: this.asNullableString(record.userId),
      certificationStatus,
      realName: this.asNullableString(record.realName),
      idNumberMasked: this.asNullableString(record.idNumberMasked),
      idCardFrontFileId: this.asNullableString(record.idCardFrontFileId),
      rejectReason: this.asNullableString(record.rejectReason),
      submittedAt: this.asNullableString(record.submittedAt),
      lockedAt: this.asNullableString(record.lockedAt),
      qualifiedForCurrentActor: record.qualifiedForCurrentActor === true,
      lockedToOtherActor: record.lockedToOtherActor === true,
    };
  }

  private requireKeys(source: Record<string, unknown>, keys: string[]) {
    if (keys.every((key) => Object.prototype.hasOwnProperty.call(source, key))) {
      return;
    }
    throw new Error('Profile read response is missing required fields.');
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asOptionalRecord(value: unknown) {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private asStringArray(value: unknown) {
    if (!Array.isArray(value)) {
      throw new Error('Expected a string array in profile read response.');
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

  private normalizeProfileIndexCode(code: string, originalMessage: string) {
    if (originalMessage.startsWith('Cannot GET /server/profile/index')) {
      return 'PROFILE_INDEX_ROUTE_UNAVAILABLE';
    }
    if (
      code === 'PROFILE_INDEX_ROUTE_UNAVAILABLE' ||
      code === 'REGROUPING_REFERENCE_UNAVAILABLE' ||
      code === 'ENTRY_ORDER_REFERENCE_UNAVAILABLE' ||
      code === 'CORRIDOR_REFERENCE_UNAVAILABLE'
    ) {
      return code;
    }
    return code;
  }

  private translatePrivateOperatingSystemMessage(code: string) {
    if (code === 'PROFILE_INDEX_ROUTE_UNAVAILABLE') {
      return '当前资料页入口暂不可用，请稍后再试。';
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
    return '当前资料页摘要暂时不可用，请稍后再试。';
  }

  private buildNormalizedDetails(rawDetails: unknown, originalMessage: string) {
    const details = this.asOptionalRecord(rawDetails) ?? {};
    if (originalMessage) {
      details.originalMessage = originalMessage;
    }
    return Object.keys(details).length > 0 ? details : undefined;
  }
}
