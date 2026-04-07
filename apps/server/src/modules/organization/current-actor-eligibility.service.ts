import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { VerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { UserEntity } from '../identity/entities/user.entity';
import {
  authPermissionInsufficient,
  authResourceUnavailable,
  authSessionInvalid
} from './organization-auth.errors';
import { OrganizationCertificationEntity } from './entities/organization-certification.entity';
import { OrganizationMemberEntity } from './entities/organization-member.entity';
import { OrganizationEntity } from './entities/organization.entity';

const ADMIN_ROLE_KEYS = new Set(['buyer_admin', 'supplier_admin']);
const REVIEWER_ROLE_KEYS = new Set(['platform_reviewer', 'platform_super_admin']);
const ACCESSIBLE_MEMBER_STATUSES = ['invited', 'pending_accept', 'active', 'disabled'];

export type CurrentOrganizationScope = {
  organization: OrganizationEntity;
  membership: OrganizationMemberEntity;
  certification: OrganizationCertificationProjection;
  roleKeys: string[];
};

export type AccessibleOrganizationScope = {
  organization: OrganizationEntity;
  roleKeys: string[];
  membershipStatus: string;
  certificationStatus: string;
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
  submittedAt: Date | null;
  reviewedAt: Date | null;
  reviewedBy: string | null;
  rejectReason: string | null;
  expiresAt: Date | null;
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
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>
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
      throw authPermissionInsufficient('Current actor does not hold an active membership in this organization.');
    }

    const certification = await this.organizationCertificationRepository.findOne({
      where: { organizationId },
      order: { updatedAt: 'DESC' }
    });
    return {
      organization,
      membership,
      certification: this.toCertificationProjection(certification),
      roleKeys: [membership.roleKey]
    } satisfies CurrentOrganizationScope;
  }

  async requireOrganizationAdmin(
    currentSession: VerifiedCurrentSessionContext,
    organizationId: string
  ) {
    await this.requireAuthenticatedActor(currentSession);
    const scope = await this.getCurrentOrganizationScope(currentSession);
    if (!scope || scope.organization.id !== organizationId) {
      throw authPermissionInsufficient('Current actor lacks the required organization scope.');
    }
    if (!scope.roleKeys.some((roleKey) => ADMIN_ROLE_KEYS.has(roleKey))) {
      throw authPermissionInsufficient('Current actor lacks the required organization admin role.');
    }
    return scope;
  }

  async requireReviewer(currentSession: VerifiedCurrentSessionContext) {
    const user = await this.requireAuthenticatedActor(currentSession);
    const reviewerMemberships = await this.organizationMemberRepository.find({
      where: {
        userId: user.id,
        memberStatus: 'active',
        roleKey: In([...REVIEWER_ROLE_KEYS])
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
        memberStatus: In(ACCESSIBLE_MEMBER_STATUSES)
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
        if (!organization) {
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
      submittedAt: certification.submittedAt,
      reviewedAt: certification.reviewedAt,
      reviewedBy: certification.reviewedBy,
      rejectReason: certification.rejectReason,
      expiresAt: certification.expiresAt
    };
  }

  private readOptionalId(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}
