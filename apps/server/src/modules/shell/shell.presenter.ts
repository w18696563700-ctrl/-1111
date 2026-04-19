import { Injectable } from '@nestjs/common';
import {
  SHELL_FEATURE_FLAGS_VERSION,
  SHELL_VISIBLE_BUILDINGS
} from './shell.constants';

@Injectable()
export class ShellPresenter {
  toContext(input: {
    userId: string;
    displayName: string;
    avatarUrl: string | null;
    profileIntro: string | null;
    organizationId: string | null;
    organizationType: string | null;
    roleKeys: string[];
    certificationStatus: string | null;
    personalCertificationStatus?: string | null;
    personalCertificationQualified?: boolean | null;
    personalCertificationLockedToOtherActor?: boolean | null;
    membershipStatus: string | null;
    projectCreateEligibility: {
      canCreateProject: boolean;
    } | null;
    paidMembershipTier: string | null;
    paidMembershipEntitlementsSummary: string[];
    paidMembershipQuotaSummary: string[];
    paidMembershipNextRefreshAt: Date | null;
    myBuildingProjection: {
      profileCorridorKey: string;
      profileEntryOrderBucket: string;
      visibleFamilyKeys: string[];
      orderingReferenceVersion: string;
      updatedAt: Date;
      regrouping: {
        regroupingKey: string;
        regroupingVisibilityStatus: string;
        regroupingExplanationKey: string;
        updatedAt: Date;
      };
      entryOrder: {
        entryOrderKey: string;
        entryVisibilityStatus: string;
        entryPriorityBucket: string;
        orderingExplanationKey: string;
        updatedAt: Date;
      };
      corridor: {
        corridorKey: string;
        corridorVisibilityStatus: string;
        corridorExplanationKey: string;
        corridorTargetFamily: string;
        updatedAt: Date;
      };
      familyPresence: Array<{
        familyKey: string;
        familyPresenceStatus: string;
        familyOrderReference: number;
        familyVisibilityReasonKey: string;
        updatedAt: Date;
      }>;
      navigationExplanation: {
        navigationExplanationKey: string;
        regroupingExplanationKey: string;
        orderingExplanationKey: string;
        corridorExplanationKey: string;
        dependencyExplanationKey: string;
      };
      dependencyReference: {
        dependencyRequired: boolean;
        dependencyFamilyKey: string;
        dependencyExplanationKey: string;
        dependencyHandoffKey: string;
      };
    };
  }) {
    return {
      userId: input.userId,
      displayName: input.displayName,
      avatarUrl: input.avatarUrl,
      profileIntro: input.profileIntro,
      organizationId: input.organizationId,
      organizationType: input.organizationType,
      roleKeys: input.roleKeys,
      certificationStatus: input.certificationStatus,
      personalCertificationStatus: input.personalCertificationStatus ?? null,
      personalCertificationQualified:
        input.personalCertificationQualified == null
          ? null
          : input.personalCertificationQualified,
      personalCertificationLockedToOtherActor:
        input.personalCertificationLockedToOtherActor == null
          ? null
          : input.personalCertificationLockedToOtherActor,
      membershipStatus: input.membershipStatus,
      projectCreateEligibility: input.projectCreateEligibility,
      paidMembershipTier: input.paidMembershipTier,
      paidMembershipEntitlementsSummary: input.paidMembershipEntitlementsSummary,
      paidMembershipQuotaSummary: input.paidMembershipQuotaSummary,
      paidMembershipNextRefreshAt: input.paidMembershipNextRefreshAt?.toISOString() ?? null,
      visibleBuildings: SHELL_VISIBLE_BUILDINGS,
      featureFlagsVersion: SHELL_FEATURE_FLAGS_VERSION,
      unreadSummary: {},
      myBuildingProjection: {
        profileCorridorKey: input.myBuildingProjection.profileCorridorKey,
        profileEntryOrderBucket: input.myBuildingProjection.profileEntryOrderBucket,
        visibleFamilyKeys: input.myBuildingProjection.visibleFamilyKeys,
        orderingReferenceVersion: input.myBuildingProjection.orderingReferenceVersion,
        updatedAt: input.myBuildingProjection.updatedAt.toISOString(),
        regrouping: {
          ...input.myBuildingProjection.regrouping,
          updatedAt: input.myBuildingProjection.regrouping.updatedAt.toISOString()
        },
        entryOrder: {
          ...input.myBuildingProjection.entryOrder,
          updatedAt: input.myBuildingProjection.entryOrder.updatedAt.toISOString()
        },
        corridor: {
          ...input.myBuildingProjection.corridor,
          updatedAt: input.myBuildingProjection.corridor.updatedAt.toISOString()
        },
        familyPresence: input.myBuildingProjection.familyPresence.map((item) => ({
          ...item,
          updatedAt: item.updatedAt.toISOString()
        })),
        navigationExplanation: input.myBuildingProjection.navigationExplanation,
        dependencyReference: input.myBuildingProjection.dependencyReference
      }
    };
  }
}
