import { createHash, randomInt, randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { RequestContext } from '../../shared/request-context';
import { LoginOtpCodeEntity } from '../identity/entities/login-otp-code.entity';
import { AUTH_LOGIN_SCENE, AUTH_OTP_COOLDOWN_SECONDS, AUTH_OTP_TTL_SECONDS } from './auth.constants';
import { AuthAntiAbuseService } from './auth-anti-abuse.service';
import { AuthCommandParser } from './auth-command.parser';
import { AuthEventMaterializationService } from './auth-event-materialization.service';
import { authLoginInvalid, authRateLimited, authUnavailable } from './auth.errors';
import { AuthPresenter } from './auth.presenter';

@Injectable()
export class AuthOtpService {
  constructor(
    @InjectRepository(LoginOtpCodeEntity)
    private readonly otpRepository: Repository<LoginOtpCodeEntity>,
    private readonly parser: AuthCommandParser,
    private readonly presenter: AuthPresenter,
    private readonly config: RuntimeConfigService,
    private readonly antiAbuse: AuthAntiAbuseService,
    private readonly events: AuthEventMaterializationService
  ) {}

  async send(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.parser.parseOtpSend(payload);
    await this.antiAbuse.assertOtpSendAllowed(command, context);
    await this.assertCooldown(command.mobile, command.scene);

    const otpCode = this.resolveOtpCode();
    const entity = this.otpRepository.create({
      id: randomUUID(),
      mobile: command.mobile,
      otpCodeHash: this.hashOtp(command.mobile, command.scene, otpCode),
      scene: command.scene,
      expiresAt: new Date(Date.now() + AUTH_OTP_TTL_SECONDS * 1000),
      consumedAt: null,
      sendIp: context.remoteIp || null,
      sendDeviceId: command.deviceId
    });
    await this.otpRepository.save(entity);
    await this.events.recordOtpSendAttempt(
      {
        mobile: command.mobile,
        scene: command.scene,
        deviceId: command.deviceId,
        ip: this.nullable(context.remoteIp)
      },
      context
    );

    return this.presenter.toOtpSendAccepted(context.traceId);
  }

  async consumeLoginOtp(mobile: string, otpCode: string) {
    if (this.matchesDirectWhitelist(mobile, otpCode)) {
      return;
    }

    const record = await this.otpRepository.findOne({
      where: {
        mobile,
        scene: AUTH_LOGIN_SCENE,
        consumedAt: IsNull()
      },
      order: { createdAt: 'DESC' }
    });
    if (!record) {
      throw authLoginInvalid('The current OTP is invalid or unavailable.');
    }
    if (record.expiresAt.getTime() <= Date.now()) {
      throw authLoginInvalid('The current OTP is invalid or unavailable.');
    }
    if (record.otpCodeHash !== this.hashOtp(mobile, AUTH_LOGIN_SCENE, otpCode)) {
      throw authLoginInvalid('The current OTP is invalid or unavailable.');
    }

    record.consumedAt = new Date();
    await this.otpRepository.save(record);
  }

  private async assertCooldown(mobile: string, scene: string) {
    const latest = await this.otpRepository.findOne({
      where: { mobile, scene },
      order: { createdAt: 'DESC' }
    });
    if (!latest) {
      return;
    }
    if (latest.createdAt.getTime() > Date.now() - AUTH_OTP_COOLDOWN_SECONDS * 1000) {
      throw authRateLimited('The current mobile has requested OTP too frequently.');
    }
  }

  private matchesDirectWhitelist(mobile: string, otpCode: string) {
    return (
      this.config.authDevLoginWhitelistEnabled &&
      mobile === this.config.authDevLoginWhitelistMobile.trim() &&
      otpCode === this.config.authDevLoginWhitelistCode.trim()
    );
  }

  private resolveOtpCode() {
    if (this.config.authDevOtpEnabled && this.config.authDevOtpCode.trim()) {
      return this.config.authDevOtpCode.trim();
    }
    if (this.config.authDevLoginWhitelistEnabled && this.config.authDevLoginWhitelistCode.trim()) {
      return this.config.authDevLoginWhitelistCode.trim();
    }
    return `${randomInt(0, 1_000_000)}`.padStart(6, '0');
  }

  private hashOtp(mobile: string, scene: string, otpCode: string) {
    const signingSecret = this.config.sessionSigningSecret.trim();
    if (!signingSecret) {
      throw authUnavailable('Current auth runtime is missing OTP verification material.');
    }
    return createHash('sha256')
      .update([mobile, scene, otpCode, signingSecret].join(':'))
      .digest('hex');
  }

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}
