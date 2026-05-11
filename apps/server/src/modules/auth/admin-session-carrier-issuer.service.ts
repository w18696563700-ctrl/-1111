import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { AuthPasswordService } from './auth-password.service';
import { CurrentSessionVerificationService } from './current-session-verification.service';

const ADMIN_ISSUER_ACCEPTED_ROLE_KEYS = ['platform_reviewer', 'platform_super_admin'] as const;
const ADMIN_DEFAULT_NEXT_PATH = '/audit';

type AdminIssuerRoleKey = (typeof ADMIN_ISSUER_ACCEPTED_ROLE_KEYS)[number];

@Injectable()
export class AdminSessionCarrierIssuerService {
  constructor(
    private readonly passwordService: AuthPasswordService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    @InjectRepository(OrganizationMemberEntity)
    private readonly organizationMemberRepository: Repository<OrganizationMemberEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>
  ) {}

  async issueWithPassword(payload: Record<string, unknown>, context: RequestContext) {
    const session = await this.passwordService.login(payload, context);
    const currentSession = await requireVerifiedCurrentSessionContext(
      {
        ...context,
        authorization: `Bearer ${session.accessToken}`
      },
      this.currentSessionVerificationService
    );
    const reviewer = await this.requirePlatformReviewer(currentSession.userId);

    return {
      adminSessionCarrier: session.accessToken,
      expiresInSeconds: session.expiresInSeconds,
      roleKey: reviewer.roleKey,
      platformOrganizationId: reviewer.organizationId,
      nextPath: ADMIN_DEFAULT_NEXT_PATH,
      issuer: 'server_auth' as const
    };
  }

  private async requirePlatformReviewer(userId: string) {
    const memberships = await this.organizationMemberRepository.find({
      where: {
        userId,
        memberStatus: 'active',
        roleKey: In([...ADMIN_ISSUER_ACCEPTED_ROLE_KEYS])
      },
      order: { joinedAt: 'DESC' }
    });
    if (!memberships.length) {
      throw authPermissionInsufficient('Current actor lacks Admin carrier issuer permission.');
    }

    const organizations = await this.organizationRepository.findBy({
      id: In(memberships.map((item) => item.organizationId)),
      organizationType: 'platform'
    });
    const platformOrganizationIds = new Set(organizations.map((item) => item.id));
    const membership = memberships.find((item) => platformOrganizationIds.has(item.organizationId));
    if (!membership) {
      throw authPermissionInsufficient('Current actor lacks Admin carrier issuer permission.');
    }

    return {
      roleKey: membership.roleKey as AdminIssuerRoleKey,
      organizationId: membership.organizationId
    };
  }
}
