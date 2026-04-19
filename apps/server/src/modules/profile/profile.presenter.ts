import { Injectable } from "@nestjs/common";
import { GovernanceAppealCaseEntity } from "../governance/entities/governance-appeal-case.entity";
import { GovernancePenaltyEntity } from "../governance/entities/governance-penalty.entity";
import { SHELL_VISIBLE_BUILDINGS } from "../shell/shell.constants";

@Injectable()
export class ProfilePresenter {
  toIndex(input: {
    displayName: string;
    avatarUrl: string | null;
    profileIntro: string | null;
    organizationId: string | null;
    roleKeys: string[];
    certificationStatus: string | null;
    personalCertificationStatus?: string | null;
    personalCertificationQualified?: boolean | null;
    personalCertificationLockedToOtherActor?: boolean | null;
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
        visibleBuildings: SHELL_VISIBLE_BUILDINGS,
      },
      certification: {
        status: input.certificationStatus,
        personalStatus: input.personalCertificationStatus ?? null,
        personalQualified:
          input.personalCertificationQualified == null
            ? null
            : input.personalCertificationQualified,
        personalLockedToOtherActor:
          input.personalCertificationLockedToOtherActor == null
            ? null
            : input.personalCertificationLockedToOtherActor,
      },
      membership: {
        status: input.membershipStatus,
      },
      myBuildingProjection: {
        regroupingKey: input.myBuildingProjection.regroupingKey,
        entryOrderKey: input.myBuildingProjection.entryOrderKey,
        corridorVisibilityStatus:
          input.myBuildingProjection.corridorVisibilityStatus,
        groupingExplanationKey:
          input.myBuildingProjection.groupingExplanationKey,
        updatedAt: input.myBuildingProjection.updatedAt.toISOString(),
      },
      settingsEntry: {
        state: "visible",
      },
    };
  }

  toOrganizations(
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
      membershipStatus: string;
      certificationStatus: string;
      current: boolean;
    }>,
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
    }>,
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
        disabledAt: item.disabledAt?.toISOString() ?? null,
      })),
    };
  }

  toCurrentCertification(input: {
    organizationId: string;
    certificationStatus: string;
    legalName: string | null;
    uscc: string | null;
    licenseFileId: string | null;
    address: string | null;
    establishedAt: string | null;
    legalPerson: string | null;
    businessType: string | null;
    registeredCapital: string | null;
    businessTerm: string | null;
    businessScope: string | null;
    rejectReason: string | null;
    expiresAt: Date | null;
    submittedAt: Date | null;
    personalCertification?: {
      organizationId: string;
      userId: string | null;
      certificationStatus: string;
      realName: string | null;
      idNumberMasked: string | null;
      idCardFrontFileId: string | null;
      rejectReason: string | null;
      submittedAt: Date | null;
      lockedAt: Date | null;
      qualifiedForCurrentActor: boolean;
      lockedToOtherActor: boolean;
    } | null;
  }) {
    return {
      organizationId: input.organizationId,
      certificationStatus: input.certificationStatus,
      legalName: input.legalName,
      uscc: input.uscc,
      licenseFileId: input.licenseFileId,
      address: input.address,
      establishedAt: input.establishedAt,
      legalPerson: input.legalPerson,
      businessType: input.businessType,
      registeredCapital: input.registeredCapital,
      businessTerm: input.businessTerm,
      businessScope: input.businessScope,
      rejectReason: input.rejectReason,
      expiresAt: input.expiresAt?.toISOString() ?? null,
      submittedAt: input.submittedAt?.toISOString() ?? null,
      personalCertification: input.personalCertification
        ? {
            organizationId: input.personalCertification.organizationId,
            userId: input.personalCertification.userId,
            certificationStatus: input.personalCertification.certificationStatus,
            realName: input.personalCertification.realName,
            idNumberMasked: input.personalCertification.idNumberMasked,
            idCardFrontFileId: input.personalCertification.idCardFrontFileId,
            rejectReason: input.personalCertification.rejectReason,
            submittedAt:
              input.personalCertification.submittedAt?.toISOString() ?? null,
            lockedAt: input.personalCertification.lockedAt?.toISOString() ?? null,
            qualifiedForCurrentActor:
              input.personalCertification.qualifiedForCurrentActor,
            lockedToOtherActor:
              input.personalCertification.lockedToOtherActor,
          }
        : null,
    };
  }

  toGovernanceAppealList(input: {
    items: Array<{
      appeal: GovernanceAppealCaseEntity;
      penalty: GovernancePenaltyEntity;
    }>;
    page: number;
    pageSize: number;
    total: number;
  }) {
    return {
      items: input.items.map(({ appeal, penalty }) => ({
        appealCaseId: appeal.id,
        penaltyId: penalty.id,
        penaltyType: penalty.penaltyType,
        penaltyStatus: penalty.status,
        status: appeal.status,
        reasonSummary: penalty.reasonSummary,
        submittedAt: this.toIso(appeal.submittedAt),
        decidedAt: this.toIso(appeal.decidedAt),
        effectiveFrom: this.toIso(penalty.effectiveFrom),
        effectiveUntil: this.toIso(penalty.effectiveUntil),
      })),
      pagination: {
        page: input.page,
        pageSize: input.pageSize,
        total: input.total,
        hasMore: input.page * input.pageSize < input.total,
      },
    };
  }

  toGovernanceAppealDetail(input: {
    appeal: GovernanceAppealCaseEntity;
    penalty: GovernancePenaltyEntity;
  }) {
    return {
      appealCaseId: input.appeal.id,
      penaltyId: input.penalty.id,
      penaltyType: input.penalty.penaltyType,
      penaltyStatus: input.penalty.status,
      status: input.appeal.status,
      reason: input.appeal.reason,
      reasonSummary: input.penalty.reasonSummary,
      submittedAt: this.toIso(input.appeal.submittedAt),
      evidenceFileAssetIds: input.appeal.evidenceFileAssetIds,
      decision: input.appeal.decision,
      decisionNote: input.appeal.decisionNote,
      decidedAt: this.toIso(input.appeal.decidedAt),
      effectiveFrom: this.toIso(input.penalty.effectiveFrom),
      effectiveUntil: this.toIso(input.penalty.effectiveUntil),
      penalty: {
        penaltyId: input.penalty.id,
        penaltyType: input.penalty.penaltyType,
        status: input.penalty.status,
        reasonSummary: input.penalty.reasonSummary,
        effectiveFrom: this.toIso(input.penalty.effectiveFrom),
        effectiveUntil: this.toIso(input.penalty.effectiveUntil),
      },
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
      traceId: input.traceId,
    };
  }

  toCertificationLicenseOcr(input: {
    status: "recognized" | "partial" | "manual_required";
    message: string;
    legalName: string | null;
    uscc: string | null;
    legalPerson: string | null;
    businessType: string | null;
    address: string | null;
    registeredCapital: string | null;
    establishedAt: string | null;
    businessTerm: string | null;
    businessScope: string | null;
    providerRequestId: string | null;
  }) {
    return {
      status: input.status,
      message: input.message,
      legalName: input.legalName,
      uscc: input.uscc,
      legalPerson: input.legalPerson,
      businessType: input.businessType,
      address: input.address,
      registeredCapital: input.registeredCapital,
      establishedAt: input.establishedAt,
      businessTerm: input.businessTerm,
      businessScope: input.businessScope,
      providerRequestId: input.providerRequestId,
    };
  }

  toPersonalCertificationIdCardOcr(input: {
    status: 'recognized' | 'manual_required';
    message: string;
    realName: string | null;
    idNumberMasked: string | null;
    providerRequestId: string | null;
  }) {
    return {
      status: input.status,
      message: input.message,
      realName: input.realName,
      idNumberMasked: input.idNumberMasked,
      providerRequestId: input.providerRequestId,
    };
  }

  toPersonalCertificationAccepted(input: {
    organizationId: string;
    userId: string;
    certificationStatus: string;
    submittedAt: Date | null;
    lockedAt: Date | null;
    traceId: string;
  }) {
    return {
      organizationId: input.organizationId,
      userId: input.userId,
      certificationStatus: input.certificationStatus,
      submittedAt: input.submittedAt?.toISOString() ?? null,
      lockedAt: input.lockedAt?.toISOString() ?? null,
      traceId: input.traceId,
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
    }>,
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
        revokedAt: item.revokedAt?.toISOString() ?? null,
      })),
    };
  }

  toActionAck(traceId: string) {
    return {
      ok: true,
      traceId,
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
      avatarUrl: input.avatarUrl,
    };
  }

  private toIso(value: Date | null | undefined) {
    return value ? value.toISOString() : null;
  }
}
