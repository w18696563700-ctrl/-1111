import { Injectable } from '@nestjs/common';
import { SHELL_VISIBLE_BUILDINGS } from '../shell/shell.constants';

@Injectable()
export class ProfilePresenter {
  toIndex(input: {
    displayName: string;
    avatarUrl: string | null;
    profileIntro: string | null;
    organizationId: string | null;
    roleKeys: string[];
    certificationStatus: string | null;
    membershipStatus: string | null;
    myBuildingProjection: {
      regroupingKey: string;
      entryOrderKey: string;
      corridorVisibilityStatus: string;
      groupingExplanationKey: string;
      updatedAt: Date;
    };
  }) {
    return {
      displayName: input.displayName,
      avatarUrl: input.avatarUrl,
      profileIntro: input.profileIntro,
      organization: {
        organizationId: input.organizationId,
        roleKeys: input.roleKeys,
        visibleBuildings: SHELL_VISIBLE_BUILDINGS
      },
      certification: {
        status: input.certificationStatus
      },
      membership: {
        status: input.membershipStatus
      },
      myBuildingProjection: {
        regroupingKey: input.myBuildingProjection.regroupingKey,
        entryOrderKey: input.myBuildingProjection.entryOrderKey,
        corridorVisibilityStatus: input.myBuildingProjection.corridorVisibilityStatus,
        groupingExplanationKey: input.myBuildingProjection.groupingExplanationKey,
        updatedAt: input.myBuildingProjection.updatedAt.toISOString()
      },
      settingsEntry: {
        state: 'visible'
      }
    };
  }

  toOrganizations(
    items: Array<{
      organizationId: string;
      name: string;
      organizationType: string;
      roleKeys: string[];
      membershipStatus: string;
      certificationStatus: string;
      current: boolean;
    }>
  ) {
    return { items };
  }

  toOrganizationMembers(
    items: Array<{
      memberId: string;
      userId: string;
      displayName: string | null;
      mobileMasked: string | null;
      roleKey: string;
      memberStatus: string;
      joinedAt: Date | null;
      disabledAt: Date | null;
    }>
  ) {
    return {
      items: items.map((item) => ({
        memberId: item.memberId,
        userId: item.userId,
        displayName: item.displayName,
        mobileMasked: item.mobileMasked,
        roleKey: item.roleKey,
        memberStatus: item.memberStatus,
        joinedAt: item.joinedAt?.toISOString() ?? null,
        disabledAt: item.disabledAt?.toISOString() ?? null
      }))
    };
  }

  toCurrentCertification(input: {
    organizationId: string;
    certificationStatus: string;
    legalName: string | null;
    uscc: string | null;
    licenseFileId: string | null;
    rejectReason: string | null;
    expiresAt: Date | null;
    submittedAt: Date | null;
  }) {
    return {
      organizationId: input.organizationId,
      certificationStatus: input.certificationStatus,
      legalName: input.legalName,
      uscc: input.uscc,
      licenseFileId: input.licenseFileId,
      rejectReason: input.rejectReason,
      expiresAt: input.expiresAt?.toISOString() ?? null,
      submittedAt: input.submittedAt?.toISOString() ?? null
    };
  }

  toCertificationAccepted(input: {
    organizationId: string;
    certificationStatus: string;
    submittedAt: Date | null;
    traceId: string;
  }) {
    return {
      organizationId: input.organizationId,
      certificationStatus: input.certificationStatus,
      submittedAt: input.submittedAt?.toISOString() ?? null,
      traceId: input.traceId
    };
  }

  toSecurityDevices(
    items: Array<{
      deviceId: string;
      deviceName: string | null;
      osType: string | null;
      appVersion: string | null;
      currentDevice: boolean;
      trustStatus: string;
      lastSeenAt: Date | null;
      revokedAt: Date | null;
    }>
  ) {
    return {
      items: items.map((item) => ({
        deviceId: item.deviceId,
        deviceName: item.deviceName,
        osType: item.osType,
        appVersion: item.appVersion,
        currentDevice: item.currentDevice,
        trustStatus: item.trustStatus,
        lastSeenAt: item.lastSeenAt?.toISOString() ?? null,
        revokedAt: item.revokedAt?.toISOString() ?? null
      }))
    };
  }

  toActionAck(traceId: string) {
    return {
      ok: true,
      traceId
    };
  }

  toPersonalUpdated(input: {
    displayName: string;
    avatarUrl: string | null;
    traceId: string;
  }) {
    return {
      ok: true,
      traceId: input.traceId,
      displayName: input.displayName,
      avatarUrl: input.avatarUrl
    };
  }
}
