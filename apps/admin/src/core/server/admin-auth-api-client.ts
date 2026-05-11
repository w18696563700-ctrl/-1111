import { adminJsonRequest } from './admin-api-runtime';

export type AdminSessionCarrierIssueInput = {
  mobile: string;
  password: string;
  consentAccepted: true;
  deviceId?: string;
  deviceName?: string;
  osType?: string;
  appVersion?: string;
};

export type AdminSessionCarrierIssueResponse = {
  adminSessionCarrier: string;
  expiresInSeconds: number;
  roleKey: 'platform_reviewer' | 'platform_super_admin';
  platformOrganizationId: string;
  nextPath: '/audit';
  issuer: 'server_auth';
};

export function issueAdminSessionCarrier(input: AdminSessionCarrierIssueInput) {
  return adminJsonRequest<AdminSessionCarrierIssueResponse>('/auth/session-carrier/issue', {
    method: 'POST',
    body: input,
  });
}
