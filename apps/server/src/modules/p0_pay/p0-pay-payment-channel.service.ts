import { Injectable } from '@nestjs/common';
import { createHash, createHmac, timingSafeEqual } from 'crypto';
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

  verifyCallback(payload: unknown, signature: string) {
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
}
