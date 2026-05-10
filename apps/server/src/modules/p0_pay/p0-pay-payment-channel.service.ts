import { Injectable } from '@nestjs/common';
import { createHash, createHmac, createSign, createVerify, timingSafeEqual } from 'crypto';
import { P0_PAY_CALLBACK_SECRET_ENV } from './p0-pay.state';
import { P0PayPaymentChannel } from './p0-pay.types';

type ChannelActionInput = {
  paymentOrderId: string;
  merchantOrderNo: string;
  amount: string | number;
  currency: string;
  channel: P0PayPaymentChannel;
  clientPlatform: string;
};

@Injectable()
export class P0PayPaymentChannelService {
  buildChannelAction(input: ChannelActionInput) {
    if (input.channel === 'alipay') {
      return this.buildAlipayAppPayAction(input);
    }

    return {
      channelActionType: 'web_redirect' as const,
      channelPayload: {
        paymentOrderId: input.paymentOrderId,
        merchantOrderNo: input.merchantOrderNo,
        amount: input.amount,
        currency: input.currency,
        channel: input.channel,
        clientPlatform: input.clientPlatform,
        accountBindingRequired: false
      },
      callbackAwaiting: true
    };
  }

  hashPayload(payload: unknown) {
    return createHash('sha256').update(this.stableJson(payload), 'utf8').digest('hex');
  }

  verifyCallback(payload: unknown, signature: string, channel?: P0PayPaymentChannel) {
    if (channel === 'alipay') {
      return this.verifyAlipayCallback(payload, signature);
    }

    const secret = process.env[P0_PAY_CALLBACK_SECRET_ENV]?.trim() ?? '';
    if (!secret) {
      return { verified: false, reasonCode: 'callback_secret_missing' };
    }
    const expected = this.signPayload(payload, secret);
    const normalized = signature.trim();
    if (!normalized) {
      return { verified: false, reasonCode: 'callback_signature_missing' };
    }
    if (!this.safeEqual(expected, normalized)) {
      return { verified: false, reasonCode: 'callback_signature_invalid' };
    }
    return { verified: true, reasonCode: '' };
  }

  signPayload(payload: unknown, secret = process.env[P0_PAY_CALLBACK_SECRET_ENV]?.trim() ?? '') {
    return `sha256=${createHmac('sha256', secret).update(this.stableJson(payload), 'utf8').digest('hex')}`;
  }

  canSignControlledCallback() {
    return Boolean(process.env[P0_PAY_CALLBACK_SECRET_ENV]?.trim());
  }

  stableJson(value: unknown): string {
    return JSON.stringify(this.sortValue(value));
  }

  private sortValue(value: unknown): unknown {
    if (Array.isArray(value)) {
      return value.map((item) => this.sortValue(item));
    }
    if (!value || typeof value !== 'object') {
      return value;
    }
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .filter(([key]) => key !== 'signature')
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, item]) => [key, this.sortValue(item)])
    );
  }

  private safeEqual(left: string, right: string) {
    const leftBuffer = Buffer.from(left);
    const rightBuffer = Buffer.from(right);
    return leftBuffer.length === rightBuffer.length && timingSafeEqual(leftBuffer, rightBuffer);
  }

  private buildAlipayAppPayAction(input: ChannelActionInput) {
    const config = this.readAlipayConfig();
    if (!config.enabled) {
      return this.alipayUnavailable('alipay_app_pay_disabled', input);
    }
    if (!config.appId || !config.privateKey || !config.notifyUrl) {
      return this.alipayUnavailable('alipay_runtime_config_missing', input);
    }

    const timestamp = this.alipayTimestamp(new Date());
    const bizContent = {
      subject: this.alipaySubject(input),
      out_trade_no: input.merchantOrderNo,
      total_amount: this.normalizeAmount(input.amount),
      product_code: 'QUICK_MSECURITY_PAY',
      body: `paymentOrderId=${input.paymentOrderId}; channel=${input.channel}`,
      timeout_express: '30m'
    };
    const unsignedParams: Record<string, string> = {
      app_id: config.appId,
      method: 'alipay.trade.app.pay',
      format: 'JSON',
      charset: 'utf-8',
      sign_type: 'RSA2',
      timestamp,
      version: '1.0',
      notify_url: config.notifyUrl,
      biz_content: JSON.stringify(bizContent)
    };
    const signContent = this.alipaySignContent(unsignedParams);
    const sign = createSign('RSA-SHA256').update(signContent, 'utf8').sign(config.privateKey, 'base64');
    const orderString = this.alipayEncodeParams({ ...unsignedParams, sign });

    return {
      channelActionType: 'sdk_payload' as const,
      channelPayload: {
        provider: 'alipay',
        sdk: 'alipay_app_pay',
        orderString,
        paymentOrderId: input.paymentOrderId,
        merchantOrderNo: input.merchantOrderNo,
        amount: this.normalizeAmount(input.amount),
        currency: input.currency,
        clientPlatform: input.clientPlatform,
        callbackAwaiting: true
      },
      callbackAwaiting: true
    };
  }

  private alipayUnavailable(reasonCode: string, input: ChannelActionInput) {
    return {
      channelActionType: 'unavailable' as const,
      channelPayload: {
        provider: 'alipay',
        reasonCode,
        paymentOrderId: input.paymentOrderId,
        merchantOrderNo: input.merchantOrderNo,
        amount: this.normalizeAmount(input.amount),
        currency: input.currency,
        clientPlatform: input.clientPlatform,
        callbackAwaiting: true
      },
      callbackAwaiting: true
    };
  }

  private verifyAlipayCallback(payload: unknown, signature: string) {
    const payloadRecord = this.asAlipayPayload(payload);
    const config = this.readAlipayConfig();
    if (!config.publicKey) {
      return { verified: false, reasonCode: 'alipay_public_key_missing' };
    }
    const sign = this.alipayPayloadString(payloadRecord.sign) || signature.trim();
    if (!sign) {
      return { verified: false, reasonCode: 'alipay_signature_missing' };
    }
    const signType = this.alipayPayloadString(payloadRecord.sign_type) || 'RSA2';
    if (signType !== 'RSA2') {
      return { verified: false, reasonCode: 'alipay_signature_type_unsupported' };
    }
    const appId = this.alipayPayloadString(payloadRecord.app_id);
    if (config.appId && appId && appId !== config.appId) {
      return { verified: false, reasonCode: 'alipay_app_id_mismatch' };
    }
    const content = this.alipaySignContent(payloadRecord, ['sign', 'sign_type']);
    const verified = createVerify('RSA-SHA256').update(content, 'utf8').verify(config.publicKey, sign, 'base64');
    return verified
      ? { verified: true, reasonCode: '' }
      : { verified: false, reasonCode: 'alipay_signature_invalid' };
  }

  private readAlipayConfig() {
    const privateKey = this.readPemEnv([
      'P0_PAY_ALIPAY_APP_PRIVATE_KEY',
      'ALIPAY_APP_PRIVATE_KEY',
      'ALIPAY_PRIVATE_KEY'
    ], 'PRIVATE KEY');
    const publicKey = this.readPemEnv([
      'P0_PAY_ALIPAY_PUBLIC_KEY',
      'ALIPAY_PUBLIC_KEY'
    ], 'PUBLIC KEY');
    return {
      enabled: (process.env.P0_PAY_ALIPAY_APP_PAY_ENABLED ?? '').trim().toLowerCase() === 'true',
      gatewayUrl: (process.env.P0_PAY_ALIPAY_GATEWAY_URL ?? 'https://openapi.alipay.com/gateway.do').trim(),
      appId: (process.env.P0_PAY_ALIPAY_APP_ID ?? process.env.ALIPAY_APP_ID ?? '').trim(),
      privateKey,
      publicKey,
      notifyUrl: (process.env.P0_PAY_ALIPAY_NOTIFY_URL ?? process.env.ALIPAY_NOTIFY_URL ?? '').trim()
    };
  }

  private readPemEnv(names: string[], label: 'PRIVATE KEY' | 'PUBLIC KEY') {
    const direct = names.map((name) => process.env[name]).find((value) => typeof value === 'string' && value.trim());
    const base64 = names
      .map((name) => process.env[`${name}_BASE64`])
      .find((value) => typeof value === 'string' && value.trim());
    const raw = direct?.trim() || (base64 ? Buffer.from(base64.trim(), 'base64').toString('utf8').trim() : '');
    if (!raw) {
      return '';
    }
    const normalized = raw.replace(/\\n/g, '\n');
    if (normalized.includes('-----BEGIN')) {
      return normalized;
    }
    return `-----BEGIN ${label}-----\n${normalized}\n-----END ${label}-----`;
  }

  private alipaySubject(input: ChannelActionInput) {
    if (input.merchantOrderNo.startsWith('P0PAY_DEP')) {
      return '展览定制之家项目真实性诚意金';
    }
    if (input.merchantOrderNo.startsWith('P0PAY_AUTH')) {
      return '展览定制之家平台服务费预授权';
    }
    if (input.merchantOrderNo.startsWith('P0PAY_CHG')) {
      return '展览定制之家平台服务费';
    }
    if (input.merchantOrderNo.startsWith('MEM_PAY')) {
      return '展览定制之家会员直购';
    }
    return '展览定制之家平台支付订单';
  }

  private normalizeAmount(value: string | number) {
    const numeric = Number(value);
    return Number.isFinite(numeric) ? numeric.toFixed(2) : String(value);
  }

  private alipayTimestamp(value: Date) {
    const pad = (item: number) => String(item).padStart(2, '0');
    return `${value.getFullYear()}-${pad(value.getMonth() + 1)}-${pad(value.getDate())} ${pad(value.getHours())}:${pad(value.getMinutes())}:${pad(value.getSeconds())}`;
  }

  private alipaySignContent(params: Record<string, unknown>, excludedKeys: string[] = []) {
    const excluded = new Set(excludedKeys);
    return Object.keys(params)
      .filter((key) => !excluded.has(key))
      .filter((key) => params[key] !== undefined && params[key] !== null && `${params[key]}` !== '')
      .sort()
      .map((key) => `${key}=${this.alipayPayloadString(params[key])}`)
      .join('&');
  }

  private alipayEncodeParams(params: Record<string, string>) {
    return Object.keys(params)
      .sort()
      .map((key) => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
      .join('&');
  }

  private asAlipayPayload(payload: unknown) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      return {};
    }
    return payload as Record<string, unknown>;
  }

  private alipayPayloadString(value: unknown) {
    if (value === null || value === undefined) {
      return '';
    }
    return String(value);
  }
}
