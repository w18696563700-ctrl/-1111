import { createHash, randomBytes, randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { RequestContext } from '../../shared/request-context';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { SessionEntity } from '../identity/entities/session.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { AUTH_ACCESS_TOKEN_TTL_SECONDS } from './auth.constants';
import { AuthCommandParser } from './auth-command.parser';
import { AuthEventMaterializationService } from './auth-event-materialization.service';
import { authRequestInvalid, authUnavailable } from './auth.errors';
import { AuthPresenter } from './auth.presenter';
import { AccessCarrierService } from './access-carrier.service';

@Injectable()
export class AuthWhitelistTestSessionService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepository: Repository<SessionEntity>,
    @InjectRepository(OrganizationMemberEntity)
    private readonly organizationMemberRepository: Repository<OrganizationMemberEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly dataSource: DataSource,
    private readonly parser: AuthCommandParser,
    private readonly accessCarrierService: AccessCarrierService,
    private readonly presenter: AuthPresenter,
    private readonly config: RuntimeConfigService,
    private readonly events: AuthEventMaterializationService
  ) {}

  async issue(payload: Record<string, unknown>, context: RequestContext) {
    this.ensureEnabled();
    const command = this.parser.parseWhitelistTestSession(payload);

    return this.dataSource.transaction(async (manager) => {
      const userRepository = manager.getRepository(UserEntity);
      const sessionRepository = manager.getRepository(SessionEntity);
      const membershipRepository = manager.getRepository(OrganizationMemberEntity);
      const certificationRepository = manager.getRepository(OrganizationCertificationEntity);

      const user = await this.findTargetUser(command.userId, command.mobile, userRepository);
      this.ensureWhitelisted(user.mobile);

      const membership = await membershipRepository.findOneBy({
        userId: user.id,
        organizationId: command.organizationId,
        memberStatus: 'active'
      });
      if (!membership || membership.roleKey !== command.roleKey) {
        throw authPermissionInsufficient(
          'Current whitelist test session target does not hold the required organization scope role.'
        );
      }

      const certification = await certificationRepository.findOne({
        where: { organizationId: command.organizationId },
        order: { updatedAt: 'DESC', createdAt: 'DESC' }
      });
      const certificationStatus = certification?.certificationStatus ?? 'not_submitted';
      if (command.certificationStatus && command.certificationStatus !== certificationStatus) {
        throw authPermissionInsufficient(
          'Current whitelist test session target does not match the required certification status.'
        );
      }

      const refreshToken = this.generateRefreshToken();
      const session = sessionRepository.create({
        id: randomUUID(),
        userId: user.id,
        refreshTokenHash: this.hashRefreshToken(refreshToken),
        organizationId: command.organizationId,
        deviceId: command.deviceId ?? `whitelist-test-${randomUUID()}`,
        deviceName: command.deviceName ?? 'whitelist-test-session',
        authMode: 'whitelist_test',
        issueReason: command.reason,
        ip: this.nullable(context.remoteIp),
        userAgent: this.nullable(context.userAgent),
        status: 'valid',
        expiresAt: command.expiresAt,
        revokedAt: null
      });
      await sessionRepository.save(session);

      const accessExpiresAt = this.buildAccessExpiresAt(command.expiresAt);
      await this.events.recordWhitelistTestSessionIssued(
        {
          userId: user.id,
          sessionId: session.id,
          mobile: user.mobile,
          organizationId: command.organizationId,
          roleKey: membership.roleKey,
          certificationStatus,
          expiresAt: command.expiresAt,
          reason: command.reason
        },
        context,
        manager
      );

      return this.presenter.toWhitelistTestSessionEstablished({
        sessionId: session.id,
        accessToken: this.accessCarrierService.issue({
          sessionId: session.id,
          organizationId: command.organizationId,
          expiresAt: accessExpiresAt
        }),
        refreshToken,
        expiresInSeconds: Math.max(1, Math.floor((accessExpiresAt.getTime() - Date.now()) / 1000)),
        organizationId: command.organizationId,
        roleKey: membership.roleKey,
        certificationStatus,
        authMode: 'whitelist_test'
      });
    });
  }

  private async findTargetUser(
    userId: string | null,
    mobile: string | null,
    repository: Repository<UserEntity>
  ) {
    if (userId) {
      const user = await repository.findOneBy({ id: userId });
      if (!user) {
        throw authRequestInvalid('Current whitelist test session target user is unavailable.');
      }
      if (mobile && user.mobile !== mobile) {
        throw authRequestInvalid('Current whitelist test session target userId/mobile pair does not match.');
      }
      return user;
    }

    const user = await repository.findOneBy({ mobile: mobile ?? '' });
    if (!user) {
      throw authRequestInvalid('Current whitelist test session target mobile is unavailable.');
    }
    return user;
  }

  private ensureEnabled() {
    if (!this.config.authWhitelistTestSessionEnabled) {
      throw authUnavailable('Current whitelist test session issuance is disabled.');
    }
  }

  private ensureWhitelisted(mobile: string) {
    if (!this.config.authWhitelistTestSessionMobiles.includes(mobile.trim())) {
      throw authPermissionInsufficient('Current mobile is not admitted by the whitelist test session gate.');
    }
  }

  private generateRefreshToken() {
    return randomBytes(48).toString('base64url');
  }

  private hashRefreshToken(token: string) {
    const pepper = this.config.sessionRefreshTokenPepper.trim();
    if (!pepper) {
      throw authUnavailable('Current auth runtime is missing refresh-token hashing material.');
    }
    return createHash('sha256').update(`${pepper}:${token}`).digest('hex');
  }

  private buildAccessExpiresAt(sessionExpiresAt: Date) {
    const candidate = new Date(Date.now() + AUTH_ACCESS_TOKEN_TTL_SECONDS * 1000);
    return candidate.getTime() <= sessionExpiresAt.getTime() ? candidate : sessionExpiresAt;
  }

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}
