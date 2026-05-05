import { Injectable } from '@nestjs/common';
import { createSign } from 'crypto';
import { readFileSync } from 'fs';
import { connect } from 'http2';
import { AppNotificationEntity } from './entities/app-notification.entity';
import { DevicePushTokenEntity } from './entities/device-push-token.entity';

export type PushDeliveryAttemptStatus =
  | 'success'
  | 'provider_credentials_unavailable'
  | 'provider_rejected'
  | 'token_invalid'
  | 'network_error'
  | 'unknown_error';

export type PushDeliveryResult = {
  provider: string;
  attemptStatus: PushDeliveryAttemptStatus;
  errorCode: string | null;
  errorMessage: string | null;
};

type ApnsConfig = {
  keyId: string;
  teamId: string;
  bundleId: string;
  environment: 'development' | 'production';
  authKeyPath: string;
};

const REQUIRED_APNS_ENV_KEYS = [
  'APNS_KEY_ID',
  'APNS_TEAM_ID',
  'APNS_BUNDLE_ID',
  'APNS_ENV',
  'APNS_AUTH_KEY_PATH'
];

@Injectable()
export class ApnsPushProviderAdapter {
  async deliver(
    token: DevicePushTokenEntity,
    notification: AppNotificationEntity
  ): Promise<PushDeliveryResult> {
    if (token.provider !== 'apns') {
      return this.credentialsUnavailable(token.provider, 'Provider adapter is not configured for this token provider.');
    }
    const config = this.readConfig();
    if (!config) {
      return this.credentialsUnavailable('apns', 'APNs credentials are not configured.');
    }
    const jwt = this.createJwt(config);
    if (!jwt) {
      return this.credentialsUnavailable('apns', 'APNs auth key is unavailable.');
    }
    return this.sendApnsRequest(token.deviceToken, notification, config, jwt);
  }

  private readConfig(): ApnsConfig | null {
    const values = {
      keyId: this.readEnv('APNS_KEY_ID'),
      teamId: this.readEnv('APNS_TEAM_ID'),
      bundleId: this.readEnv('APNS_BUNDLE_ID'),
      environment: this.readEnv('APNS_ENV'),
      authKeyPath: this.readEnv('APNS_AUTH_KEY_PATH')
    };
    if (
      !values.keyId ||
      !values.teamId ||
      !values.bundleId ||
      !values.environment ||
      !values.authKeyPath
    ) {
      return null;
    }
    return {
      keyId: values.keyId,
      teamId: values.teamId,
      bundleId: values.bundleId,
      environment: values.environment === 'production' ? 'production' : 'development',
      authKeyPath: values.authKeyPath
    };
  }

  private createJwt(config: ApnsConfig): string | null {
    let authKey: string;
    try {
      authKey = readFileSync(config.authKeyPath, 'utf8');
    } catch {
      return null;
    }
    const header = this.base64UrlJson({ alg: 'ES256', kid: config.keyId });
    const claims = this.base64UrlJson({
      iss: config.teamId,
      iat: Math.floor(Date.now() / 1000)
    });
    const signingInput = `${header}.${claims}`;
    try {
      const signer = createSign('SHA256');
      signer.update(signingInput);
      signer.end();
      const signature = signer
        .sign({ key: authKey, dsaEncoding: 'ieee-p1363' })
        .toString('base64url');
      return `${signingInput}.${signature}`;
    } catch {
      return null;
    }
  }

  private sendApnsRequest(
    deviceToken: string,
    notification: AppNotificationEntity,
    config: ApnsConfig,
    jwt: string
  ): Promise<PushDeliveryResult> {
    const host =
      config.environment === 'production'
        ? 'https://api.push.apple.com'
        : 'https://api.sandbox.push.apple.com';
    const payload = this.toApnsPayload(notification);
    return new Promise((resolve) => {
      let settled = false;
      let statusCode = 0;
      let body = '';
      const settle = (result: PushDeliveryResult) => {
        if (settled) {
          return;
        }
        settled = true;
        resolve(result);
      };
      const client = connect(host);
      client.on('error', () =>
        settle(this.failure('network_error', 'APNS_NETWORK_ERROR', 'APNs network request failed.'))
      );
      const request = client.request({
        ':method': 'POST',
        ':path': `/3/device/${deviceToken}`,
        authorization: `bearer ${jwt}`,
        'apns-topic': config.bundleId,
        'apns-push-type': 'alert',
        'apns-priority': '10',
        'content-type': 'application/json'
      });
      request.setEncoding('utf8');
      request.setTimeout(10000, () => {
        request.close();
        client.close();
        settle(this.failure('network_error', 'APNS_TIMEOUT', 'APNs request timed out.'));
      });
      request.on('response', (headers) => {
        statusCode = Number(headers[':status'] ?? 0);
      });
      request.on('data', (chunk) => {
        body += chunk;
      });
      request.on('error', () => {
        client.close();
        settle(this.failure('network_error', 'APNS_NETWORK_ERROR', 'APNs network request failed.'));
      });
      request.on('end', () => {
        client.close();
        settle(this.mapApnsResponse(statusCode, body));
      });
      request.end(JSON.stringify(payload));
    });
  }

  private mapApnsResponse(statusCode: number, body: string): PushDeliveryResult {
    if (statusCode === 200) {
      return {
        provider: 'apns',
        attemptStatus: 'success',
        errorCode: null,
        errorMessage: null
      };
    }
    const reason = this.extractApnsReason(body);
    if (statusCode === 400 || statusCode === 410) {
      if (
        reason === 'BadDeviceToken' ||
        reason === 'Unregistered' ||
        reason === 'DeviceTokenNotForTopic'
      ) {
        return this.failure('token_invalid', reason, 'APNs rejected this device token.');
      }
      return this.failure('provider_rejected', reason ?? 'APNS_BAD_REQUEST', 'APNs rejected this push request.');
    }
    if (statusCode === 403 || statusCode === 429) {
      return this.failure('provider_rejected', reason ?? 'APNS_PROVIDER_REJECTED', 'APNs rejected provider credentials or throttled the request.');
    }
    if (statusCode >= 500) {
      return this.failure('network_error', reason ?? 'APNS_PROVIDER_UNAVAILABLE', 'APNs provider is temporarily unavailable.');
    }
    return this.failure('unknown_error', reason ?? 'APNS_UNKNOWN_ERROR', 'APNs returned an unknown result.');
  }

  private toApnsPayload(notification: AppNotificationEntity) {
    const payload: Record<string, unknown> = {
      aps: {
        alert: {
          title: notification.title,
          body: notification.body ?? notification.title
        },
        sound: 'default'
      },
      notificationId: notification.id,
      source: notification.source
    };
    if (notification.routeTarget && Object.keys(notification.routeTarget).length > 0) {
      payload.routeTarget = notification.routeTarget;
    }
    return payload;
  }

  private extractApnsReason(body: string): string | null {
    if (!body.trim()) {
      return null;
    }
    try {
      const parsed = JSON.parse(body) as { reason?: unknown };
      return typeof parsed.reason === 'string' && parsed.reason.trim() ? parsed.reason.trim() : null;
    } catch {
      return null;
    }
  }

  private credentialsUnavailable(provider: string, message: string): PushDeliveryResult {
    return {
      provider,
      attemptStatus: 'provider_credentials_unavailable',
      errorCode: 'provider_credentials_unavailable',
      errorMessage: `${message} Required environment keys: ${REQUIRED_APNS_ENV_KEYS.join(', ')}.`
    };
  }

  private failure(
    attemptStatus: PushDeliveryAttemptStatus,
    errorCode: string,
    errorMessage: string
  ): PushDeliveryResult {
    return {
      provider: 'apns',
      attemptStatus,
      errorCode,
      errorMessage
    };
  }

  private base64UrlJson(value: Record<string, unknown>) {
    return Buffer.from(JSON.stringify(value)).toString('base64url');
  }

  private readEnv(name: string) {
    return process.env[name]?.trim() ?? '';
  }
}
