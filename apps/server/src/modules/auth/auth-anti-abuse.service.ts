import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Like, MoreThan, Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { LoginOtpCodeEntity } from '../identity/entities/login-otp-code.entity';
import { AUTH_LOGIN_SCENE } from './auth.constants';
import { AuthEventMaterializationService } from './auth-event-materialization.service';
import { authRateLimited, authUnavailable } from './auth.errors';

const OTP_SEND_WINDOW_SECONDS = 900;
const OTP_SEND_MAX_PER_MOBILE = 5;
const OTP_SEND_MAX_PER_DEVICE = 8;
const OTP_SEND_MAX_PER_IP = 10;

const LOGIN_WINDOW_SECONDS = 900;
const LOGIN_MAX_PER_MOBILE = 8;
const LOGIN_MAX_PER_DEVICE = 10;
const LOGIN_MAX_PER_IP = 12;
type OtpSendAccessMode = 'public' | 'isolated_whitelist' | 'closed';

@Injectable()
export class AuthAntiAbuseService {
  constructor(
    @InjectRepository(LoginOtpCodeEntity)
    private readonly otpRepository: Repository<LoginOtpCodeEntity>,
    @InjectRepository(IdentityAuditLogEntity)
    private readonly auditRepository: Repository<IdentityAuditLogEntity>,
    private readonly config: RuntimeConfigService,
    private readonly events: AuthEventMaterializationService
  ) {}

  isOtpSendEnabledForMobile(mobile: string) {
    return this.resolveOtpSendAccessMode(mobile) !== 'closed';
  }

  resolveOtpSendAccessMode(mobile: string): OtpSendAccessMode {
    if (this.config.authPublicOtpSendEnabled) {
      return 'public';
    }
    if (!this.config.allowsIsolatedAuthWhitelist) {
      return 'closed';
    }
    return this.isWhitelistedMobile(mobile) ? 'isolated_whitelist' : 'closed';
  }

  async assertOtpSendAllowed(
    input: {
      mobile: string;
      scene: string;
      deviceId: string | null;
    },
    context: RequestContext
  ) {
    if (this.resolveOtpSendAccessMode(input.mobile) === 'closed') {
      throw authUnavailable('The current public auth send capability is disabled.');
    }

    const cutoff = this.buildCutoff(OTP_SEND_WINDOW_SECONDS);
    await this.assertOtpSendRateLimit(
      'mobile',
      OTP_SEND_MAX_PER_MOBILE,
      OTP_SEND_WINDOW_SECONDS,
      await this.otpRepository.count({
        where: {
          mobile: input.mobile,
          scene: input.scene,
          createdAt: MoreThan(cutoff)
        }
      }),
      input,
      context
    );

    if (input.deviceId) {
      await this.assertOtpSendRateLimit(
        'device',
        OTP_SEND_MAX_PER_DEVICE,
        OTP_SEND_WINDOW_SECONDS,
        await this.otpRepository.count({
          where: {
            sendDeviceId: input.deviceId,
            scene: input.scene,
            createdAt: MoreThan(cutoff)
          }
        }),
        input,
        context
      );
    }

    const remoteIp = this.readRemoteIp(context);
    if (remoteIp) {
      await this.assertOtpSendRateLimit(
        'ip',
        OTP_SEND_MAX_PER_IP,
        OTP_SEND_WINDOW_SECONDS,
        await this.otpRepository.count({
          where: {
            sendIp: remoteIp,
            scene: input.scene,
            createdAt: MoreThan(cutoff)
          }
        }),
        input,
        context
      );
    }
  }

  async assertLoginAllowed(
    input: {
      mobile: string;
      deviceId: string;
    },
    context: RequestContext
  ) {
    const cutoff = this.buildCutoff(LOGIN_WINDOW_SECONDS);
    const actions = In(['login_success', 'login_failure']);

    await this.assertLoginRateLimit(
      'mobile',
      LOGIN_MAX_PER_MOBILE,
      LOGIN_WINDOW_SECONDS,
      await this.auditRepository.count({
        where: {
          action: actions,
          objectType: 'auth_login',
          objectId: input.mobile,
          occurredAt: MoreThan(cutoff)
        }
      }),
      input,
      context
    );

    await this.assertLoginRateLimit(
      'device',
      LOGIN_MAX_PER_DEVICE,
      LOGIN_WINDOW_SECONDS,
      await this.auditRepository.count({
        where: {
          action: actions,
          objectType: 'auth_login',
          objectNo: input.deviceId,
          occurredAt: MoreThan(cutoff)
        }
      }),
      input,
      context
    );

    const remoteIp = this.readRemoteIp(context);
    if (remoteIp) {
      await this.assertLoginRateLimit(
        'ip',
        LOGIN_MAX_PER_IP,
        LOGIN_WINDOW_SECONDS,
        await this.auditRepository.count({
          where: {
            action: actions,
            objectType: 'auth_login',
            reason: Like(`%ip=${remoteIp}%`),
            occurredAt: MoreThan(cutoff)
          }
        }),
        input,
        context
      );
    }
  }

  private async assertOtpSendRateLimit(
    dimension: 'mobile' | 'device' | 'ip',
    threshold: number,
    windowSeconds: number,
    count: number,
    input: {
      mobile: string;
      scene: string;
      deviceId: string | null;
    },
    context: RequestContext
  ) {
    if (count < threshold) {
      return;
    }
    await this.events.recordOtpRateLimitBreach(
      {
        mobile: input.mobile,
        deviceId: input.deviceId,
        ip: this.readRemoteIp(context),
        scene: input.scene,
        dimension,
        threshold,
        windowSeconds,
        route: 'otp_send'
      },
      context
    );
    throw authRateLimited(
      `The current auth OTP ${dimension} scope has exceeded the controlled send rate limit.`
    );
  }

  private async assertLoginRateLimit(
    dimension: 'mobile' | 'device' | 'ip',
    threshold: number,
    windowSeconds: number,
    count: number,
    input: {
      mobile: string;
      deviceId: string;
    },
    context: RequestContext
  ) {
    if (count < threshold) {
      return;
    }
    await this.events.recordOtpRateLimitBreach(
      {
        mobile: input.mobile,
        deviceId: input.deviceId,
        ip: this.readRemoteIp(context),
        scene: AUTH_LOGIN_SCENE,
        dimension,
        threshold,
        windowSeconds,
        route: 'otp_login'
      },
      context
    );
    throw authRateLimited(
      `The current auth login ${dimension} scope has exceeded the controlled rate limit.`
    );
  }

  private isWhitelistedMobile(mobile: string) {
    const normalizedMobile = mobile.trim();
    if (!normalizedMobile) {
      return false;
    }
    const whitelist = new Set(this.config.otpTestWhitelistMobiles);
    const directWhitelistMobile = this.config.authDevLoginWhitelistMobile.trim();
    return (
      (this.config.otpTestWhitelistEnabled && whitelist.has(normalizedMobile)) ||
      (this.config.authDevLoginWhitelistEnabled &&
        directWhitelistMobile === normalizedMobile)
    );
  }

  private buildCutoff(windowSeconds: number) {
    return new Date(Date.now() - windowSeconds * 1000);
  }

  private readRemoteIp(context: RequestContext) {
    const normalized = context.remoteIp.trim();
    return normalized ? normalized : null;
  }
}
