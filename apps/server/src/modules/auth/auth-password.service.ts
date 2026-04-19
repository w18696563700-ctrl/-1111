import { createHash, randomBytes, randomUUID } from 'crypto';
import { argon2id, hash as argon2Hash, verify as argon2Verify } from 'argon2';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { DeviceEntity } from '../identity/entities/device.entity';
import { PasswordCredentialEntity } from '../identity/entities/password-credential.entity';
import { SessionEntity } from '../identity/entities/session.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import {
  AUTH_ACCESS_TOKEN_TTL_SECONDS,
  AUTH_PASSWORD_ALGO,
  AUTH_REFRESH_TOKEN_TTL_DAYS
} from './auth.constants';
import { AuthAntiAbuseService } from './auth-anti-abuse.service';
import { AuthCommandParser, PasswordLoginCommand } from './auth-command.parser';
import { AuthEventMaterializationService } from './auth-event-materialization.service';
import {
  authLoginInvalid,
  authPasswordLoginInvalid,
  authPasswordPolicyInvalid,
  authPasswordResetOtpInvalid,
  authPasswordSetNotAllowed as authPasswordSetNotAllowedError,
  authUnavailable
} from './auth.errors';
import { AccessCarrierService } from './access-carrier.service';
import { AuthPresenter } from './auth.presenter';
import { CurrentSessionVerificationService } from './current-session-verification.service';
import { AuthOtpService } from './auth-otp.service';

@Injectable()
export class AuthPasswordService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepository: Repository<SessionEntity>,
    @InjectRepository(DeviceEntity)
    private readonly deviceRepository: Repository<DeviceEntity>,
    @InjectRepository(OrganizationMemberEntity)
    private readonly membershipRepository: Repository<OrganizationMemberEntity>,
    @InjectRepository(PasswordCredentialEntity)
    private readonly passwordCredentialRepository: Repository<PasswordCredentialEntity>,
    private readonly dataSource: DataSource,
    private readonly parser: AuthCommandParser,
    private readonly antiAbuse: AuthAntiAbuseService,
    private readonly otpService: AuthOtpService,
    private readonly accessCarrierService: AccessCarrierService,
    private readonly config: RuntimeConfigService,
    private readonly presenter: AuthPresenter,
    private readonly verifier: CurrentSessionVerificationService,
    private readonly events: AuthEventMaterializationService
  ) {}

  async login(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.parser.parsePasswordLogin(payload);
    await this.antiAbuse.assertLoginAllowed(
      {
        mobile: command.mobile,
        deviceId: command.deviceId ?? ''
      },
      context
    );

    try {
      return await this.dataSource.transaction(async (manager) => {
        const userRepository = manager.getRepository(UserEntity);
        const sessionRepository = manager.getRepository(SessionEntity);
        const deviceRepository = manager.getRepository(DeviceEntity);
        const membershipRepository = manager.getRepository(OrganizationMemberEntity);
        const credentialRepository = manager.getRepository(PasswordCredentialEntity);

        const user = await this.findActiveUser(command.mobile, userRepository);
        const credential = await credentialRepository.findOneBy({ userId: user.id });
        if (!credential) {
          throw authPasswordLoginInvalid('The current password is unavailable or invalid.');
        }

        const passwordMatched = await this.matchPassword(command.password, credential.passwordHash);
        if (!passwordMatched) {
          throw authPasswordLoginInvalid('The current password is unavailable or invalid.');
        }

        const refreshToken = this.generateRefreshToken();
        const refreshTokenHash = this.hashRefreshToken(refreshToken);
        const sessionExpiresAt = this.buildSessionExpiresAt();
        const agreedAt = new Date();
        const agreementVersion = this.config.authUserAgreementVersion;
        const privacyVersion = this.config.authPrivacyPolicyVersion;
        const bootstrap = await this.resolveBootstrapState(user.id, membershipRepository);
        const accessExpiresAt = this.buildAccessExpiresAt(sessionExpiresAt);
        const organizationId = bootstrap.organizationId;

        await this.recordPasswordLoginUserHeartbeat(user, context, userRepository);
        await this.upsertDevice(command, user.id, deviceRepository);

        const session = sessionRepository.create({
          id: randomUUID(),
          userId: user.id,
          refreshTokenHash,
          organizationId,
          deviceId: command.deviceId,
          deviceName: command.deviceName,
          authMode: 'password_login',
          issueReason: null,
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

        await this.events.recordPasswordLoginSuccess(
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
            organizationId
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
      await this.recordPasswordLoginFailureIfNeeded(command.mobile, context, error, command.deviceId);
      throw error;
    }
  }

  async set(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.parser.parsePasswordSet(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.verifier);

    return this.dataSource.transaction(async (manager) => {
      const userRepository = manager.getRepository(UserEntity);
      const sessionRepository = manager.getRepository(SessionEntity);
      const credentialRepository = manager.getRepository(PasswordCredentialEntity);
      const user = await this.findActiveUserById(currentSession.userId, userRepository);
      const currentSessionEntity = await sessionRepository.findOneBy({
        id: currentSession.sessionId,
        userId: currentSession.userId,
        status: 'valid'
      });
      if (!currentSessionEntity || currentSessionEntity.authMode !== 'otp_login') {
        throw authPasswordSetNotAllowedError(
          'Current account password can only be set from an OTP login session.'
        );
      }

      const normalizedPassword = this.normalizePassword(command.newPassword);
      await this.validatePasswordPolicy(normalizedPassword, user.mobile);

      const existing = await credentialRepository.findOneBy({ userId: user.id });
      if (existing) {
        await this.events.recordPasswordSetFailure(
          {
            actorUserId: user.id,
            targetUserId: user.id,
            mobile: user.mobile,
            sessionId: currentSession.sessionId,
            deviceId: currentSessionEntity.deviceId,
            ip: this.nullable(context.remoteIp),
            failureReason: 'AUTH_PASSWORD_SET_NOT_ALLOWED'
          },
          context,
          manager
        );
        throw authPasswordSetNotAllowedError('Current account has already set a password.');
      }

      const now = new Date();
      const credential = credentialRepository.create({
        userId: user.id,
        passwordHash: await this.hashPassword(normalizedPassword),
        passwordAlgo: AUTH_PASSWORD_ALGO,
        passwordSetAt: now,
        passwordUpdatedAt: now
      });
      await credentialRepository.save(credential);

      await this.events.recordPasswordSet(
        {
          actorUserId: user.id,
          targetUserId: user.id,
          mobile: user.mobile,
          sessionId: currentSession.sessionId,
          deviceId: currentSessionEntity.deviceId,
          ip: this.nullable(context.remoteIp)
        },
        context,
        manager
      );
      return this.presenter.toActionAck(context.traceId);
    });
  }

  async reset(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.parser.parsePasswordReset(payload);

    try {
      await this.otpService.consumeResetOtp(command.mobile, command.otpCode);
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : typeof error === 'string'
            ? error
            : 'Current OTP is invalid or unavailable.';
      const mapped = authPasswordResetOtpInvalid(message);
      await this.recordPasswordResetFailure(command.mobile, context, null, mapped, null);
      throw mapped;
    }

    return this.dataSource.transaction(async (manager) => {
      const userRepository = manager.getRepository(UserEntity);
      const credentialRepository = manager.getRepository(PasswordCredentialEntity);
      const user = await userRepository.findOneBy({ mobile: command.mobile });
      if (!user || user.status !== 'active') {
        const error = authPasswordResetOtpInvalid('Current password reset target is unavailable.');
        await this.recordPasswordResetFailure(command.mobile, context, null, error, null);
        throw error;
      }

      const normalizedPassword = this.normalizePassword(command.newPassword);
      await this.validatePasswordPolicy(normalizedPassword, user.mobile);

      const existing = await credentialRepository.findOneBy({ userId: user.id });
      const now = new Date();
      if (existing) {
        const passwordReused = await this.matchPassword(normalizedPassword, existing.passwordHash);
        if (passwordReused) {
          const error = authPasswordPolicyInvalid(
            'Current password policy does not allow reusing existing password.'
          );
          await this.recordPasswordResetFailure(command.mobile, context, existing.userId, error, null);
          throw error;
        }

        existing.passwordHash = await this.hashPassword(normalizedPassword);
        existing.passwordAlgo = AUTH_PASSWORD_ALGO;
        existing.passwordUpdatedAt = now;
        await credentialRepository.save(existing);
      } else {
        const created = credentialRepository.create({
          userId: user.id,
          passwordHash: await this.hashPassword(normalizedPassword),
          passwordAlgo: AUTH_PASSWORD_ALGO,
          passwordSetAt: now,
          passwordUpdatedAt: now
        });
        await credentialRepository.save(created);
      }

      await this.events.recordPasswordResetSuccess(
        {
          actorUserId: user.id,
          targetUserId: user.id,
          mobile: user.mobile,
          deviceId: null,
          ip: this.nullable(context.remoteIp)
        },
        context,
        manager
      );

      return this.presenter.toActionAck(context.traceId);
    });
  }

  private async findActiveUser(mobile: string, repository: Repository<UserEntity>) {
    const user = await repository.findOneBy({ mobile });
    if (!user || user.status !== 'active') {
      throw authPasswordLoginInvalid('The current password is unavailable or invalid.');
    }
    return user;
  }

  private async findActiveUserById(userId: string, repository: Repository<UserEntity>) {
    const user = await repository.findOneBy({ id: userId });
    if (!user || user.status !== 'active') {
      throw authLoginInvalid('Current actor is unavailable for password set.');
    }
    return user;
  }

  private async recordPasswordLoginFailureIfNeeded(
    mobile: string,
    context: RequestContext,
    error: unknown,
    deviceId: string | null
  ) {
    const code = this.readErrorCode(error);
    if (code !== 'AUTH_PASSWORD_LOGIN_INVALID') {
      return;
    }
    await this.events.recordPasswordLoginFailure(
      {
        mobile,
        deviceId,
        ip: this.nullable(context.remoteIp),
        failureReason: code
      },
      context
    );
  }

  private async recordPasswordResetFailure(
    mobile: string,
    context: RequestContext,
    targetUserId: string | null,
    error: unknown,
    deviceId: string | null
  ) {
    await this.events.recordPasswordResetFailure(
      {
        mobile,
        deviceId,
        ip: this.nullable(context.remoteIp),
        targetUserId,
        failureReason: this.readErrorCode(error)
      },
      context
    );
  }

  private async upsertDevice(
    command: PasswordLoginCommand,
    userId: string,
    repository: Repository<DeviceEntity>
  ) {
    const existingByFingerprint = await repository.findOneBy({
      userId,
      deviceFingerprint: command.deviceId
    });
    const existing = existingByFingerprint ?? (await repository.findOneBy({ id: command.deviceId ?? '' }));
    const now = new Date();
    const device =
      existing ??
      repository.create({
        id: command.deviceId ?? randomUUID(),
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
  ): Promise<{ shellBootstrapState: 'authenticated' | 'no_organization'; organizationId: string | null }> {
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

  private async recordPasswordLoginUserHeartbeat(
    user: UserEntity,
    context: RequestContext,
    repository: Repository<UserEntity>
  ) {
    user.status = 'active';
    user.mobileVerifiedAt = new Date();
    user.lastLoginAt = new Date();
    user.lastLoginIp = this.nullable(context.remoteIp);
    await repository.save(user);
  }

  private async validatePasswordPolicy(password: string, mobile: string) {
    if (password.length < 8) {
      throw authPasswordPolicyInvalid('Password must be at least 8 characters.');
    }
    if (!/[A-Za-z]/.test(password) || !/[0-9]/.test(password)) {
      throw authPasswordPolicyInvalid('Password must contain at least one letter and one number.');
    }
    if (password === mobile) {
      throw authPasswordPolicyInvalid('Password cannot be the same as your mobile number.');
    }
  }

  private normalizePassword(password: string) {
    const normalized = password.trim();
    if (!normalized) {
      throw authPasswordPolicyInvalid('Password is required.');
    }
    return normalized;
  }

  private async hashPassword(password: string) {
    return argon2Hash(password, {
      type: argon2id,
      salt: randomBytes(16),
      secret: this.readPasswordPepper(),
      timeCost: 3,
      memoryCost: 65536,
      parallelism: 1
    });
  }

  private async matchPassword(password: string, stored: string) {
    try {
      return await argon2Verify(stored, password, {
        secret: this.readPasswordPepper()
      });
    } catch {
      return false;
    }
  }

  private generateRefreshToken() {
    return `srt1_${randomBytes(32).toString('base64url')}`;
  }

  private hashRefreshToken(refreshToken: string) {
    const pepper = this.config.sessionRefreshTokenPepper.trim();
    if (!pepper) {
      throw authUnavailable('Current auth runtime is missing refresh-token hashing material.');
    }
    return createHash('sha256').update(`${pepper}:${refreshToken}`).digest('hex');
  }

  private buildAccessExpiresAt(sessionExpiresAt: Date) {
    return new Date(
      Math.min(sessionExpiresAt.getTime(), Date.now() + AUTH_ACCESS_TOKEN_TTL_SECONDS * 1000)
    );
  }

  private buildSessionExpiresAt() {
    return new Date(Date.now() + AUTH_REFRESH_TOKEN_TTL_DAYS * 24 * 60 * 60 * 1000);
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

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readPasswordPepper() {
    const pepper = this.config.authPasswordPepper.trim();
    if (!pepper) {
      throw authUnavailable('Current auth runtime is missing password secret material.');
    }
    return Buffer.from(pepper, 'utf8');
  }
}
