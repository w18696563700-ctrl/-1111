export const SECURITY_DEVICE_TRUST_STATUS_VALUES = [
  'unknown',
  'trusted',
  'untrusted',
  'revoked',
] as const;

export type SecurityDeviceTrustStatus = (typeof SECURITY_DEVICE_TRUST_STATUS_VALUES)[number];

export type SecurityDeviceItemViewModel = {
  deviceId: string;
  deviceName: string | null;
  osType: string | null;
  appVersion: string | null;
  currentDevice: boolean;
  trustStatus: SecurityDeviceTrustStatus;
  lastSeenAt: string | null;
  revokedAt: string | null;
};

export type SecurityDevicesViewModel = {
  items: SecurityDeviceItemViewModel[];
};

export type ActionAckViewModel = {
  ok: true;
  traceId: string;
};

const SECURITY_DEVICE_TRUST_STATUS_SET = new Set<string>(SECURITY_DEVICE_TRUST_STATUS_VALUES);

export function readSecurityDeviceTrustStatus(
  value: unknown,
  message: string,
): SecurityDeviceTrustStatus {
  if (typeof value !== 'string') {
    throw new Error(message);
  }

  const normalized = value.trim();
  if (SECURITY_DEVICE_TRUST_STATUS_SET.has(normalized)) {
    return normalized as SecurityDeviceTrustStatus;
  }

  throw new Error(message);
}
