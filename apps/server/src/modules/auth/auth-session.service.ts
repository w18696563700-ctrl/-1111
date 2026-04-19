import { createHash, randomBytes, randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Not, Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { authSessionInvalid } from '../organization/organization-auth.errors';
import { DeviceEntity } from '../identity/entities/device.entity';
import { SessionEntity } from '../identity/entities/session.entity';
import { UserEntity } from '../identity/entities/user.entity';
import {
  AUTH_ACCESS_TOKEN_TTL_SECONDS,
  AUTH_REFRESH_TOKEN_TTL_DAYS
} from './auth.constants';
import {
  AuthCommandParser,
  LogoutCommand,
  OtpLoginCommand,
  RefreshSessionCommand
} from './auth-command.parser';
import { AuthAntiAbuseService } from './auth-anti-abuse.service';
import { AuthEventMaterializationService } from './auth-event-materialization.service';
import { authLoginInvalid, authUnavailable } from './auth.errors';
import { AuthPresenter } from './auth.presenter';
import { AuthOtpService } from './auth-otp.service';
import { AccessCarrierService } from './access-carrier.service';
import { CurrentSessionVerificationService } from './current-session-verification.service';

type BootstrapState = {
  shellBootstrapState: 'authenticated' | 'no_organization';
  organizationId: string | null;
};

@Injectable()
export class AuthSessionService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepository: Repository<SessionEntity>,
    @InjectRepository(OrganizationMemberEntity)
    private readonly organizationMemberRepository: Repository<OrganizationMemberEntity>,
    private readonly dataSource: DataSource,
    private readonly parser: AuthCommandParser,
    private readonly otpService: AuthOtpService,
    private readonly accessCarrierService: AccessCarrierService,
    private readonly verifier: CurrentSessionVerificationService,
    private readonly presenter: AuthPresenter,
    private readonly config: RuntimeConfigService,
    private readonly antiAbuse: AuthAntiAbuseService,
    private readonly events: AuthEventMaterializationService
  ) {}

  async login(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.parser.parseOtpLogin(payload);
    await this.antiAbuse.assertLoginAllowed(command, context);

    try {
      await this.otpService.consumeLoginOtp(command.mobile, command.otpCode);

      return await this.dataSource.transaction(async (manager) => {
        const userRepository = manager.getRepository(UserEntity);
        const sessionRepository = manager.getRepository(SessionEntity);
        const deviceRepository = manager.getRepository(DeviceEntity);
        const membershipRepository = manager.getRepository(OrganizationMemberEntity);
        const user = await this.findOrCreateUser(command, context, userRepository);
        await this.upsertDevice(command, user.id, deviceRepository);

        const refreshToken = this.generateRefreshToken();
        const refreshTokenHash = this.hashRefreshToken(refreshToken);
        const sessionExpiresAt = this.buildSessionExpiresAt();
        const agreedAt = new Date();
        const agreementVersion = this.config.authUserAgreementVersion;
        const privacyVersion = this.config.authPrivacyPolicyVersion;
        const bootstrap = await this.resolveBootstrapState(user.id, membershipRepository);
        const accessExpiresAt = this.buildAccessExpiresAt(sessionExpiresAt);
        const organizationId = bootstrap.organizationId;
        const session = sessionRepository.create({
          id: randomUUID(),
          userId: user.id,
          refreshTokenHash,
          organizationId,
          deviceId: command.deviceId,
          deviceName: command.deviceName,
          agreementVersion,
          privacyVersion,
          agreedAt,
          ip: this.nullable(context.remoteIp),
          userAgent: this.nullable(context.userAgent),
          status: 'valid',
          expiresAt: sessionExpiresAt,
          revokedAt: null
        });
        await sessionRepository.save(session);
        await this.events.recordLoginSuccess(
          {
            userId: user.id,
            sessionId: session.id,
            mobile: command.mobile,
            deviceId: command.deviceId,
            ip: this.nullable(context.remoteIp),
            agreementVersion,
            privacyVersion,
            agreedAt,
            shellBootstrapState: bootstrap.shellBootstrapState,
            organizationId: bootstrap.organizationId
          },
          context,
          manager
        );

        return this.presenter.toSessionEstablished({
          accessToken: this.accessCarrierService.issue({
            sessionId: session.id,
            organizationId,
            expiresAt: accessExpiresAt
          }),
          refreshToken,
          expiresInSeconds: Math.max(1, Math.floor((accessExpiresAt.getTime() - Date.now()) / 1000)),
          shellBootstrapState: bootstrap.shellBootstrapState
        });
      });
    } catch (error) {
      await this.recordLoginFailureIfNeeded(command, context, error);
      throw error;
    }
  }

  async refresh(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.parser.parseRefresh(payload);
    return this.dataSource.transaction(async (manager) => {
      const sessionRepository = manager.getRepository(SessionEntity);
      const userRepository = manager.getRepository(UserEntity);
      const membershipRepository = manager.getRepository(OrganizationMemberEntity);
      const session = await this.loadRefreshSession(command, sessionRepository);
      const user = await userRepository.findOneBy({ id: session.userId });
      if (!user || user.status !== 'active') {
        throw authSessionInvalid('Current session is invalid or actor is not active.');
      }

      const refreshToken = this.generateRefreshToken();
      const sessionExpiresAt = this.buildSessionExpiresAt();
      const accessExpiresAt = this.buildAccessExpiresAt(sessionExpiresAt);
      const bootstrap = await this.resolveBootstrapState(user.id, membershipRepository);
      const organizationId = session.organizationId ?? bootstrap.organizationId;

      session.refreshTokenHash = this.hashRefreshToken(refreshToken);
      session.expiresAt = sessionExpiresAt;
      session.organizationId = organizationId;
      await sessionRepository.save(session);
      await this.events.recordSessionRefresh(
        {
          sessionId: session.id,
          userId: user.id,
          deviceId: session.deviceId,
          organizationId
        },
        context,
        manager
      );

      return this.presenter.toSessionRefreshed({
        accessToken: this.accessCarrierService.issue({
          sessionId: session.id,
          organizationId,
          expiresAt: accessExpiresAt
        }),
        refreshToken,
        expiresInSeconds: Math.max(1, Math.floor((accessExpiresAt.getTime() - Date.now()) / 1000))
      });
    });
  }

  async logout(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.parser.parseLogout(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.verifier);

    return this.dataSource.transaction(async (manager) => {
      const sessionRepository = manager.getRepository(SessionEntity);
      await this.revokeSessions(command, currentSession, sessionRepository);
      await this.events.recordLogout(
        {
          sessionId: currentSession.sessionId,
          userId: currentSession.userId,
          targetDeviceId: command.deviceId,
          revokeAllOtherDevices: command.revokeAllOtherDevices
        },
        context,
        manager
      );
      return this.presenter.toActionAck(context.traceId);
    });
  }

  private async findOrCreateUser(
    command: OtpLoginCommand,
    context: RequestContext,
    repository: Repository<UserEntity>
  ) {
    const now = new Date();
    const existing = await repository.findOneBy({ mobile: command.mobile });
    if (!existing) {
      const user = repository.create({
        id: randomUUID(),
        mobile: command.mobile,
        mobileVerifiedAt: now,
        nickname: null,
        avatarUrl: null,
        status: 'active',
        lastLoginAt: now,
        lastLoginIp: this.nullable(context.remoteIp)
      });
      return repository.save(user);
    }

    if (['disabled', 'frozen'].includes(existing.status)) {
      throw authLoginInvalid('The current actor is unavailable for login.');
    }
    existing.status = 'active';
    existing.mobileVerifiedAt = now;
    existing.lastLoginAt = now;
    existing.lastLoginIp = this.nullable(context.remoteIp);
    return repository.save(existing);
  }

  private async upsertDevice(
    command: OtpLoginCommand,
    userId: string,
    repository: Repository<DeviceEntity>
  ) {
    // Prefer the current user's existing device fingerprint record.
    // This keeps repeated login attempts idempotent even when older clients
    // reused a shared deviceId across multiple accounts.
    const existingByFingerprint = await repository.findOneBy({
      userId,
      deviceFingerprint: command.deviceId
    });
    const existing =
      existingByFingerprint ??
      (await repository.findOneBy({ id: command.deviceId }));
    const now = new Date();
    const device =
      existing ??
      repository.create({
        id: command.deviceId,
        firstSeenAt: now
      });

    device.userId = userId;
    device.deviceFingerprint = command.deviceId;
    device.deviceName = command.deviceName;
    device.osType = command.osType;
    device.appVersion = command.appVersion;
    device.lastSeenAt = now;
    device.trustStatus = 'trusted';

    await repository.save(device);
  }

  private async resolveBootstrapState(
    userId: string,
    repository: Repository<OrganizationMemberEntity>
  ): Promise<BootstrapState> {
    const membership = await repository.findOne({
      where: {
        userId,
        memberStatus: 'active'
      },
      order: { joinedAt: 'DESC' }
    });
    if (!membership) {
      return {
        shellBootstrapState: 'no_organization',
        organizationId: null
      };
    }
    return {
      shellBootstrapState: 'authenticated',
      organizationId: membership.organizationId
    };
  }

  private async loadRefreshSession(
    command: RefreshSessionCommand,
    repository: Repository<SessionEntity>
  ) {
    const refreshTokenHash = this.hashRefreshToken(command.refreshToken);
    const session = await repository.findOneBy({
      refreshTokenHash,
      status: 'valid'
    });
    if (!session) {
      throw authSessionInvalid('Current session is invalid because the refresh token is unavailable.');
    }
    if (session.revokedAt || session.expiresAt.getTime() <= Date.now()) {
      throw authSessionInvalid('Current session is invalid because the refresh token is revoked or expired.');
    }
    if (command.deviceId && session.deviceId && command.deviceId !== session.deviceId) {
      throw authSessionInvalid('Current session is invalid because the refresh token device scope does not match.');
    }
    return session;
  }

  private async revokeSessions(
    command: LogoutCommand,
    currentSession: VerifiedCurrentSessionContext,
    repository: Repository<SessionEntity>
  ) {
    const now = new Date();
    if (command.deviceId) {
      await repository.update(
        {
          userId: currentSession.userId,
          deviceId: command.deviceId,
          status: 'valid'
        },
        {
          status: 'revoked',
          revokedAt: now
        }
      );
      return;
    }
    if (command.revokeAllOtherDevices) {
      await repository.update(
        {
          userId: currentSession.userId,
          status: 'valid',
          id: Not(currentSession.sessionId)
        },
        {
          status: 'revoked',
          revokedAt: now
        }
      );
      return;
    }
    await repository.update(
      {
        id: currentSession.sessionId,
        status: 'valid'
      },
      {
        status: 'revoked',
        revokedAt: now
      }
    );
  }

  private async recordLoginFailureIfNeeded(
    command: OtpLoginCommand,
    context: RequestContext,
    error: unknown
  ) {
    if (!this.isLoginFailure(error)) {
      return;
    }
    await this.events.recordLoginFailure(
      {
        mobile: command.mobile,
        deviceId: command.deviceId,
        ip: this.nullable(context.remoteIp),
        reason: this.readErrorCode(error) ?? 'AUTH_LOGIN_INVALID'
      },
      context
    );
  }

  private isLoginFailure(error: unknown) {
    return this.readErrorCode(error) === 'AUTH_LOGIN_INVALID';
  }

  private readErrorCode(error: unknown) {
    if (
      !error ||
      typeof error !== 'object' ||
      typeof (error as { getResponse?: unknown }).getResponse !== 'function'
    ) {
      return null;
    }
    const response = (error as { getResponse: () => unknown }).getResponse();
    if (!response || typeof response !== 'object' || Array.isArray(response)) {
      return null;
    }
    const value = (response as Record<string, unknown>).code;
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
  }

  private buildAccessExpiresAt(sessionExpiresAt: Date) {
    return new Date(
      Math.min(
        sessionExpiresAt.getTime(),
        Date.now() + AUTH_ACCESS_TOKEN_TTL_SECONDS * 1000
      )
    );
  }

  private buildSessionExpiresAt() {
    return new Date(Date.now() + AUTH_REFRESH_TOKEN_TTL_DAYS * 24 * 60 * 60 * 1000);
  }

  private generateRefreshToken() {
    return `srt1_${randomBytes(32).toString('base64url')}`;
  }

  private hashRefreshToken(refreshToken: string) {
    const pepper = this.config.sessionRefreshTokenPepper.trim();
    if (!pepper) {
      throw authUnavailable('Current auth runtime is missing refresh-token hashing material.');
    }
    return createHash('sha256')
      .update(`${pepper}:${refreshToken}`)
      .digest('hex');
  }

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}
