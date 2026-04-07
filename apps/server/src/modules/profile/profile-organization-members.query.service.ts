import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { ProfilePresenter } from './profile.presenter';

const LISTABLE_MEMBER_STATUSES = ['invited', 'pending_accept', 'active', 'disabled'];

@Injectable()
export class ProfileOrganizationMembersQueryService {
  constructor(
    @InjectRepository(OrganizationMemberEntity)
    private readonly organizationMemberRepository: Repository<OrganizationMemberEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProfilePresenter
  ) {}

  async getMembers(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const organizationId = this.readOrganizationId(currentSession.organizationId);
    const scope = await this.eligibilityService.requireOrganizationAdmin(currentSession, organizationId);

    const members = await this.organizationMemberRepository.find({
      where: {
        organizationId: scope.organization.id,
        memberStatus: In(LISTABLE_MEMBER_STATUSES)
      },
      order: {
        joinedAt: 'ASC',
        id: 'ASC'
      }
    });
    if (!members.length) {
      return this.presenter.toOrganizationMembers([]);
    }

    const users = await this.userRepository.findBy({
      id: In(members.map((member) => member.userId))
    });
    const userMap = new Map(users.map((user) => [user.id, user]));

    return this.presenter.toOrganizationMembers(
      members.map((member) => {
        const user = userMap.get(member.userId) ?? null;
        return {
          memberId: member.id,
          userId: member.userId,
          displayName: this.resolveDisplayName(user),
          mobileMasked: this.maskMobile(user?.mobile ?? null),
          roleKey: member.roleKey,
          memberStatus: member.memberStatus,
          joinedAt: member.joinedAt,
          disabledAt: member.disabledAt
        };
      })
    );
  }

  private readOrganizationId(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw authPermissionInsufficient(
        'Current organization scope is required for organization members list.'
      );
    }
    return normalized;
  }

  private resolveDisplayName(user: UserEntity | null) {
    const nickname = user?.nickname?.trim() ?? '';
    return nickname ? nickname : null;
  }

  private maskMobile(mobile: string | null) {
    const normalized = mobile?.trim() ?? '';
    if (normalized.length < 7) {
      return normalized || null;
    }
    return `${normalized.slice(0, 3)}****${normalized.slice(-4)}`;
  }
}
