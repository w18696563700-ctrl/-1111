import { Injectable } from '@nestjs/common';
import {
  SHELL_FEATURE_FLAGS_VERSION,
  SHELL_VISIBLE_BUILDINGS
} from '../shell/shell.constants';

@Injectable()
export class OrganizationWritePresenter {
  toOrganizationCreated(input: {
    organizationId: string;
    roleKeys: string[];
    membershipStatus: string;
    certificationStatus: string;
  }) {
    return {
      organizationId: input.organizationId,
      roleKeys: input.roleKeys,
      membershipStatus: input.membershipStatus,
      certificationStatus: input.certificationStatus
    };
  }

  toOrganizationJoined(input: {
    organizationId: string;
    membershipStatus: string;
    traceId: string;
  }) {
    return {
      organizationId: input.organizationId,
      membershipStatus: input.membershipStatus,
      traceId: input.traceId
    };
  }

  toSwitchedShellContext(input: {
    userId: string;
    organizationId: string;
    roleKeys: string[];
    certificationStatus: string;
    membershipStatus: string;
  }) {
    return {
      userId: input.userId,
      organizationId: input.organizationId,
      roleKeys: input.roleKeys,
      certificationStatus: input.certificationStatus,
      membershipStatus: input.membershipStatus,
      visibleBuildings: SHELL_VISIBLE_BUILDINGS,
      featureFlagsVersion: SHELL_FEATURE_FLAGS_VERSION,
      unreadSummary: {}
    };
  }

  toActionAck(traceId: string) {
    return {
      ok: true,
      traceId
    };
  }
}
