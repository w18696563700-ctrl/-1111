import { Injectable, Logger } from '@nestjs/common';
import SmsClient, { SendSmsRequest } from '@alicloud/dysmsapi20170525';
import { $OpenApiUtil } from '@alicloud/openapi-core';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { authOtpSendLimitReached, authUnavailable } from './auth.errors';

@Injectable()
export class AuthOtpSmsDeliveryService {
  private readonly logger = new Logger(AuthOtpSmsDeliveryService.name);
  private client: SmsClient | null = null;

  constructor(private readonly config: RuntimeConfigService) {}

  async sendLoginOtp(input: { mobile: string; otpCode: string; traceId: string }) {
    const client = this.getClient();
    const response = await client.sendSms(
      new SendSmsRequest({
        phoneNumbers: input.mobile,
        signName: this.config.aliyunSmsSignName,
        templateCode: this.config.aliyunSmsTemplateCode,
        templateParam: JSON.stringify({ code: input.otpCode }),
        outId: input.traceId
      })
    );
    const body = response.body;
    if (body?.code === 'isv.BUSINESS_LIMIT_CONTROL') {
      this.logger.warn(
        `Aliyun SMS send rate-limited traceId=${input.traceId} mobile=${this.maskMobile(input.mobile)} requestId=${body.requestId ?? '-'} code=${body.code} message=${body.message ?? '-'}`
      );
      throw authOtpSendLimitReached('The current mobile has reached the upstream OTP send limit.', {
        providerCode: body.code,
        providerMessage: body.message ?? null,
        providerRequestId: body.requestId ?? null
      });
    }
    if (body?.code !== 'OK') {
      this.logger.error(
        `Aliyun SMS send rejected traceId=${input.traceId} mobile=${this.maskMobile(input.mobile)} requestId=${body?.requestId ?? '-'} code=${body?.code ?? '-'} message=${body?.message ?? '-'}`
      );
      throw authUnavailable('Current auth OTP send capability is unavailable.');
    }
    this.logger.log(
      `Aliyun SMS send accepted traceId=${input.traceId} mobile=${this.maskMobile(input.mobile)} requestId=${body.requestId ?? '-'} bizId=${body.bizId ?? '-'}`
    );
  }

  private getClient() {
    if (this.client) {
      return this.client;
    }
    this.ensureConfig();
    const config = new $OpenApiUtil.Config({
      accessKeyId: this.config.aliyunSmsAccessKeyId,
      accessKeySecret: this.config.aliyunSmsAccessKeySecret,
      regionId: this.config.aliyunSmsRegionId,
      connectTimeout: this.config.aliyunSmsConnectTimeoutMs,
      readTimeout: this.config.aliyunSmsReadTimeoutMs
    });
    if (this.config.aliyunSmsEndpoint.trim()) {
      config.endpoint = this.config.aliyunSmsEndpoint;
    }
    this.client = new SmsClient(config);
    return this.client;
  }

  private ensureConfig() {
    if (
      !this.config.aliyunSmsAccessKeyId.trim() ||
      !this.config.aliyunSmsAccessKeySecret.trim() ||
      !this.config.aliyunSmsSignName.trim() ||
      !this.config.aliyunSmsTemplateCode.trim()
    ) {
      throw authUnavailable('Current auth runtime is missing OTP send provider material.');
    }
  }

  private maskMobile(mobile: string) {
    const normalized = mobile.trim();
    if (normalized.length < 7) {
      return normalized;
    }
    return `${normalized.slice(0, 3)}****${normalized.slice(-4)}`;
  }
}
