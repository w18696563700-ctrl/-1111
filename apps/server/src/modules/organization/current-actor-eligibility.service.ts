import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import {
  CurrentSessionResolver,
  VerifiedCurrentSessionContext,
  requireVerifiedCurrentSessionContext,
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { UserEntity } from '../identity/entities/user.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import {
  authPermissionInsufficient,
  authResourceUnavailable,
  authSessionInvalid
} from './organization-auth.errors';
import { PersonalCertificationEntity } from '../profile/entities/personal-certification.entity';
import {
  APP_ORGANIZATION_ROLE_KEYS,
  isAppFacingOrganizationType
} from './organization-scope.constants';
import { OrganizationCertificationEntity } from './entities/organization-certification.entity';
import { OrganizationMemberEntity } from './entities/organization-member.entity';
import { OrganizationEntity } from './entities/organization.entity';

const ADMIN_ROLE_KEYS = new Set(['buyer_admin', 'supplier_admin']);
const PROJECT_PUBLISH_ROLE_KEYS = new Set(['buyer_admin', 'buyer_member(scoped)']);
const BID_PARTICIPATION_ORGANIZATION_TYPES = new Set(['supplier', 'both']);
const REVIEWER_ROLE_KEYS = new Set(['platform_reviewer', 'platform_super_admin']);
const MANUAL_REVIEWER_ROLE_KEYS = new Set([
  'safety_reviewer',
  'platform_reviewer',
  'platform_super_admin'
]);
type BidEligibilityAction = 'bid submit' | 'bid result';
export type ProjectPublishEligibilityDenyReason =
  | 'organization_scope_missing'
  | 'buyer_role_not_allowed'
  | 'certification_not_approved';

export type CurrentOrganizationScope = {
  organization: OrganizationEntity;
  membership: OrganizationMemberEntity;
  certification: OrganizationCertificationProjection;
  personalCertification: PersonalCertificationProjection;
  roleKeys: string[];
};

export type AccessibleOrganizationScope = {
  organization: OrganizationEntity;
  roleKeys: string[];
  membershipStatus: string;
  certificationStatus: string;
};

export type ProjectPublishEligibility = {
  currentSession: VerifiedCurrentSessionContext;
  scope: CurrentOrganizationScope;
};

export type BidSubmitEligibility = {
  currentSession: VerifiedCurrentSessionContext;
  scope: CurrentOrganizationScope;
  project: ProjectEntity;
};

type ReviewerScope = {
  actorRole: string;
  organizationId: string;
  user: UserEntity;
};

type OrganizationCertificationProjection = {
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
  submittedAt: Date | null;
  reviewedAt: Date | null;
  reviewedBy: string | null;
  rejectReason: string | null;
  expiresAt: Date | null;
};

type PersonalCertificationProjection = {
  certificationStatus: string;
  userId: string | null;
  realName: string | null;
  idNumberMasked: string | null;
  idCardFrontFileId: string | null;
  providerRequestId: string | null;
  submittedAt: Date | null;
  reviewedAt: Date | null;
  rejectReason: string | null;
  lockedAt: Date | null;
  qualifiedForCurrentActor: boolean;
  lockedToOtherActor: boolean;
};

@Injectable()
export class CurrentActorEligibilityService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(OrganizationMemberEntity)
    private readonly organizationMemberRepository: Repository<OrganizationMemberEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(PersonalCertificationEntity)
    private readonly personalCertificationRepository: Repository<PersonalCertificationEntity>
  ) {}

  async requireAuthenticatedActor(currentSession: VerifiedCurrentSessionContext) {
    const user = await this.userRepository.findOneBy({ id: currentSession.userId });
    if (!user || user.status !== 'active') {
      throw authSessionInvalid('Current session is invalid or actor is not active.');
    }
    return user;
  }

  async getCurrentOrganizationScope(currentSession: VerifiedCurrentSessionContext) {
    const organizationId = this.readOptionalId(currentSession.organizationId);
    if (!organizationId) {
      return null;
    }

    const organization = await this.organizationRepository.findOneBy({ id: organizationId });
    if (!organization) {
      throw authResourceUnavailable('Current organization scope is unavailable.');
    }

    const membership = await this.organizationMemberRepository.findOneBy({
      organizationId,
      userId: currentSession.userId,
      memberStatus: 'active'
    });
    if (!membership) {
      throw authPermissionInsufficient(
        'Current actor does not hold an active membership in this organization.',
        {
          reason: 'organization_active_membership_missing',
          organizationId,
        }
      );
    }

    const certification = await this.organizationCertificationRepository.findOne({
      where: { organizationId },
      order: { updatedAt: 'DESC' }
    });
    const personalCertification = await this.personalCertificationRepository.findOne({
      where: { organizationId },
      order: { updatedAt: 'DESC', createdAt: 'DESC' }
    });
    return {
      organization,
      membership,
      certification: this.toCertificationProjection(certification),
      personalCertification: this.toPersonalCertificationProjection(
        personalCertification,
        currentSession.userId
      ),
      roleKeys: [membership.roleKey]
    } satisfies CurrentOrganizationScope;
  }

  async requireOrganizationAdmin(
    currentSession: VerifiedCurrentSessionContext,
    organizationId: string
  ) {
    const scope = await this.requireCurrentOrganizationScope(
      currentSession,
      organizationId
    );
    if (!scope.roleKeys.some((roleKey) => ADMIN_ROLE_KEYS.has(roleKey))) {
      throw authPermissionInsufficient(
        'Current actor lacks the required organization admin role.',
        {
          reason: 'organization_admin_role_missing',
          organizationId,
          currentRoleKeys: scope.roleKeys,
        }
      );
    }
    return scope;
  }

  async requireCurrentOrganizationScope(
    currentSession: VerifiedCurrentSessionContext,
    organizationId: string
  ) {
    await this.requireAuthenticatedActor(currentSession);
    const scope = await this.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authPermissionInsufficient(
        'Current actor lacks the required organization scope.',
        {
          reason: 'organization_scope_missing',
          requestedOrganizationId: organizationId,
        }
      );
    }
    if (scope.organization.id !== organizationId) {
      throw authPermissionInsufficient(
        'Current actor lacks the required organization scope.',
        {
          reason: 'organization_scope_mismatch',
          currentOrganizationId: scope.organization.id,
          requestedOrganizationId: organizationId,
        }
      );
    }
    return scope;
  }

  async requireProjectPublishEligibilityFromContext(
    context: RequestContext,
    resolver: CurrentSessionResolver
  ) {
    const currentSession = await requireVerifiedCurrentSessionContext(context, resolver);
    const scope = await this.requireProjectPublishEligibility(currentSession);
    return {
      currentSession,
      scope,
    } satisfies ProjectPublishEligibility;
  }

  async requireProjectPublishEligibility(currentSession: VerifiedCurrentSessionContext) {
    await this.requireAuthenticatedActor(currentSession);
    const scope = await this.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authPermissionInsufficient(
        'Current actor lacks the required organization scope for project create.',
        {
          reason: 'organization_scope_missing' satisfies ProjectPublishEligibilityDenyReason
        }
      );
    }
    if (!scope.roleKeys.some((roleKey) => PROJECT_PUBLISH_ROLE_KEYS.has(roleKey))) {
      throw authPermissionInsufficient(
        'Current actor lacks the required buyer role for project create.',
        {
          reason: 'buyer_role_not_allowed' satisfies ProjectPublishEligibilityDenyReason
        }
      );
    }
    if (scope.certification.certificationStatus !== 'approved') {
      throw authPermissionInsufficient(
        'Current organization certification is not approved for project create.',
        {
          reason: 'certification_not_approved' satisfies ProjectPublishEligibilityDenyReason,
          certificationStatus: scope.certification.certificationStatus
        }
      );
    }
    return scope;
  }

  canPublishProjectInScope(scope: CurrentOrganizationScope | null) {
    if (!scope) {
      return false;
    }
    return (
      scope.roleKeys.some((roleKey) => PROJECT_PUBLISH_ROLE_KEYS.has(roleKey)) &&
      scope.certification.certificationStatus === 'approved'
    );
  }

  async requireBidSubmitEligibilityFromContext(
    context: RequestContext,
    resolver: CurrentSessionResolver,
    project: ProjectEntity | null
  ) {
    const currentSession = await requireVerifiedCurrentSessionContext(context, resolver);
    const scope = await this.requireBidSubmitEligibility(currentSession, project);
    return {
      currentSession,
      scope,
      project: project as ProjectEntity
    } satisfies BidSubmitEligibility;
  }

  async requireBidSubmitEligibility(
    currentSession: VerifiedCurrentSessionContext,
    project: ProjectEntity | null
  ) {
    const scope = await this.requireBidQualifiedScope(currentSession, 'bid submit');
    if (!project || project.state !== 'published' || project.publishedAt === null) {
      throw authPermissionInsufficient(
        'Current project is not published for bid submit.',
        {
          reason: 'project_not_published',
          projectState: project?.state ?? null,
          publishedAt: project?.publishedAt?.toISOString() ?? null,
        }
      );
    }
    if (scope.organization.id === project.organizationId) {
      throw authPermissionInsufficient(
        'Current organization cannot submit bid to its own project.',
        {
          reason: 'owner_relation_not_allowed',
          organizationId: scope.organization.id,
          projectOrganizationId: project.organizationId,
        }
      );
    }
    return scope;
  }

  canSubmitBidInScope(scope: CurrentOrganizationScope | null, project: ProjectEntity | null) {
    if (!scope || !project) {
      return false;
    }
    return (
      this.canParticipateInBidInScope(scope) &&
      project.state === 'published' &&
      project.publishedAt !== null &&
      scope.organization.id !== project.organizationId
    );
  }

  async requireBidQualifiedScope(
    currentSession: VerifiedCurrentSessionContext,
    action: BidEligibilityAction = 'bid submit'
  ) {
    await this.requireAuthenticatedActor(currentSession);
    const scope = await this.getCurrentOrganizationScope(currentSession);
    return this.assertBidQualifiedScope(scope, currentSession, action);
  }

  async requireReviewer(currentSession: VerifiedCurrentSessionContext) {
    return this.requireReviewerByRoleKeys(currentSession, REVIEWER_ROLE_KEYS);
  }

  async requireManualReviewer(currentSession: VerifiedCurrentSessionContext) {
    return this.requireReviewerByRoleKeys(currentSession, MANUAL_REVIEWER_ROLE_KEYS);
  }

  private async requireReviewerByRoleKeys(
    currentSession: VerifiedCurrentSessionContext,
    acceptedRoleKeys: Set<string>
  ) {
    const user = await this.requireAuthenticatedActor(currentSession);
    const reviewerMemberships = await this.organizationMemberRepository.find({
      where: {
        userId: user.id,
        memberStatus: 'active',
        roleKey: In([...acceptedRoleKeys])
      },
      order: { joinedAt: 'DESC' }
    });
    if (!reviewerMemberships.length) {
      throw authPermissionInsufficient('Current actor lacks reviewer permission for organization review.');
    }

    const platformOrganizations = await this.organizationRepository.findBy({
      id: In(reviewerMemberships.map((item) => item.organizationId)),
      organizationType: 'platform'
    });
    if (!platformOrganizations.length) {
      throw authPermissionInsufficient('Current actor lacks reviewer permission for organization review.');
    }

    const platformOrganizationIds = new Set(platformOrganizations.map((item) => item.id));
    const reviewerMembership = reviewerMemberships.find((item) =>
      platformOrganizationIds.has(item.organizationId)
    );
    if (!reviewerMembership) {
      throw authPermissionInsufficient('Current actor lacks reviewer permission for organization review.');
    }

    return {
      actorRole: reviewerMembership.roleKey,
      organizationId: reviewerMembership.organizationId,
      user
    } satisfies ReviewerScope;
  }

  async listAccessibleOrganizations(userId: string) {
    const memberships = await this.organizationMemberRepository.find({
      where: {
        userId,
        memberStatus: 'active'
      },
      order: { joinedAt: 'DESC' }
    });
    if (!memberships.length) {
      return [] satisfies AccessibleOrganizationScope[];
    }

    const organizations = await this.organizationRepository.findBy({
      id: In(memberships.map((item) => item.organizationId))
    });
    const certifications = await this.organizationCertificationRepository.findBy({
      organizationId: In(organizations.map((item) => item.id))
    });
    const organizationMap = new Map(organizations.map((item) => [item.id, item]));
    const certificationMap = this.toLatestCertificationMap(certifications);

    return memberships
      .map((membership) => {
        const organization = organizationMap.get(membership.organizationId);
        if (
          !organization ||
          !APP_ORGANIZATION_ROLE_KEYS.has(membership.roleKey) ||
          !isAppFacingOrganizationType(organization.organizationType)
        ) {
          return null;
        }
        return {
          organization,
          roleKeys: [membership.roleKey],
          membershipStatus: membership.memberStatus,
          certificationStatus: this.toCertificationProjection(
            certificationMap.get(membership.organizationId) ?? null
          ).certificationStatus
        } satisfies AccessibleOrganizationScope;
      })
      .filter((item): item is AccessibleOrganizationScope => Boolean(item));
  }

  private toLatestCertificationMap(certifications: OrganizationCertificationEntity[]) {
    const certificationMap = new Map<string, OrganizationCertificationEntity>();
    for (const certification of certifications) {
      const current = certificationMap.get(certification.organizationId);
      if (!current || current.updatedAt.getTime() < certification.updatedAt.getTime()) {
        certificationMap.set(certification.organizationId, certification);
      }
    }
    return certificationMap;
  }

  private toCertificationProjection(
    certification: OrganizationCertificationEntity | null
  ): OrganizationCertificationProjection {
    if (!certification) {
      return {
        certificationStatus: 'not_submitted',
        legalName: null,
        uscc: null,
        licenseFileId: null,
        address: null,
        establishedAt: null,
        legalPerson: null,
        businessType: null,
        registeredCapital: null,
        businessTerm: null,
        businessScope: null,
        submittedAt: null,
        reviewedAt: null,
        reviewedBy: null,
        rejectReason: null,
        expiresAt: null
      };
    }

    return {
      certificationStatus: certification.certificationStatus,
      legalName: certification.legalName,
      uscc: certification.uscc,
      licenseFileId: certification.licenseFileId,
      address: certification.address,
      establishedAt: certification.establishedAt,
      legalPerson: certification.legalPerson,
      businessType: certification.businessType,
      registeredCapital: certification.registeredCapital,
      businessTerm: certification.businessTerm,
      businessScope: certification.businessScope,
      submittedAt: certification.submittedAt,
      reviewedAt: certification.reviewedAt,
      reviewedBy: certification.reviewedBy,
      rejectReason: certification.rejectReason,
      expiresAt: certification.expiresAt
    };
  }

  private toPersonalCertificationProjection(
    certification: PersonalCertificationEntity | null,
    currentUserId: string
  ): PersonalCertificationProjection {
    if (!certification) {
      return {
        certificationStatus: 'not_submitted',
        userId: null,
        realName: null,
        idNumberMasked: null,
        idCardFrontFileId: null,
        providerRequestId: null,
        submittedAt: null,
        reviewedAt: null,
        rejectReason: null,
        lockedAt: null,
        qualifiedForCurrentActor: false,
        lockedToOtherActor: false,
      };
    }

    const qualifiedForCurrentActor =
      certification.certificationStatus === 'approved' &&
      certification.userId === currentUserId;
    const lockedToOtherActor =
      certification.certificationStatus === 'approved' &&
      certification.userId !== currentUserId;
    return {
      certificationStatus: certification.certificationStatus,
      userId: certification.userId,
      realName: certification.realName,
      idNumberMasked: certification.idNumberMasked,
      idCardFrontFileId: certification.idCardFrontFileId,
      providerRequestId: certification.providerRequestId,
      submittedAt: certification.submittedAt,
      reviewedAt: certification.reviewedAt,
      rejectReason: certification.rejectReason,
      lockedAt: certification.lockedAt,
      qualifiedForCurrentActor,
      lockedToOtherActor,
    };
  }

  private readOptionalId(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private assertBidQualifiedScope(
    scope: CurrentOrganizationScope | null,
    currentSession: VerifiedCurrentSessionContext,
    action: BidEligibilityAction
  ) {
    if (!scope) {
      throw authPermissionInsufficient(
        `Current actor lacks the required organization scope for ${action}.`,
        {
          reason: 'organization_scope_missing',
        }
      );
    }

    const organizationType = this.readOptionalText(scope.organization.organizationType);
    if (!organizationType || !BID_PARTICIPATION_ORGANIZATION_TYPES.has(organizationType)) {
      throw authPermissionInsufficient(
        `Current organization type is not allowed for ${action}.`,
        {
          reason: 'organization_type_not_allowed',
          organizationType: scope.organization.organizationType,
          currentRoleKeys: scope.roleKeys,
        }
      );
    }

    if (scope.certification.certificationStatus !== 'approved') {
      throw authPermissionInsufficient(
        `Current organization certification is not approved for ${action}.`,
        {
          reason: 'certification_not_approved',
          certificationStatus: scope.certification.certificationStatus,
        }
      );
    }

    if (
      scope.personalCertification.certificationStatus !== 'approved' ||
      !scope.personalCertification.qualifiedForCurrentActor
    ) {
      throw authPermissionInsufficient(
        scope.personalCertification.lockedToOtherActor
          ? `Current personal certification is locked to another actor for ${action}.`
          : `Current personal certification is not approved for ${action}.`,
        {
          reason: scope.personalCertification.lockedToOtherActor
            ? 'personal_certification_locked'
            : 'personal_certification_not_approved',
          personalCertificationStatus: scope.personalCertification.certificationStatus,
          personalCertificationQualified:
            scope.personalCertification.qualifiedForCurrentActor,
          certifiedUserId: scope.personalCertification.userId,
          currentUserId: currentSession.userId,
        }
      );
    }

    return scope;
  }

  private canParticipateInBidInScope(scope: CurrentOrganizationScope | null) {
    if (!scope) {
      return false;
    }

    const organizationType = this.readOptionalText(scope.organization.organizationType);
    return (
      organizationType !== null &&
      BID_PARTICIPATION_ORGANIZATION_TYPES.has(organizationType) &&
      scope.certification.certificationStatus === 'approved' &&
      scope.personalCertification.certificationStatus === 'approved' &&
      scope.personalCertification.qualifiedForCurrentActor &&
      scope.personalCertification.lockedToOtherActor !== true
    );
  }

  private readOptionalText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}
