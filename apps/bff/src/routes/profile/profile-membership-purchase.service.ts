import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  MembershipOrderCreateViewModel,
  MembershipOrderResultViewModel,
  MembershipPayInitViewModel,
  MembershipPurchaseOffersViewModel,
  readMembershipOrderCreateViewModel,
  readMembershipOrderResultViewModel,
  readMembershipPayInitViewModel,
  readMembershipPurchaseOffersViewModel,
} from './profile-membership-purchase.read-model';
import { ProfileMembershipPurchaseErrorService } from './profile-membership-purchase-error.service';

@Injectable()
export class ProfileMembershipPurchaseService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ProfileMembershipPurchaseErrorService,
  ) {}

  async getPurchaseOffers(headers: IncomingHttpHeaders): Promise<MembershipPurchaseOffersViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/membership/purchase-offers',
        { headers: this.authContext.buildReadOnlyForwardHeaders(headers) },
      );
      return readMembershipPurchaseOffersViewModel(this.requireRecord(result));
    } catch (error) {
      throw this.errors.normalizePurchaseOffersError(error);
    }
  }

  async createOrder(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<MembershipOrderCreateViewModel> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/membership/orders',
        body,
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return readMembershipOrderCreateViewModel(this.requireRecord(result));
    } catch (error) {
      throw this.errors.normalizeOrderCreateError(error);
    }
  }

  async payInit(
    membershipOrderId: string,
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<MembershipPayInitViewModel> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/profile/membership/orders/${encodeURIComponent(membershipOrderId)}/pay-init`,
        body,
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return readMembershipPayInitViewModel(this.requireRecord(result));
    } catch (error) {
      throw this.errors.normalizePayInitError(error);
    }
  }

  async getOrder(
    membershipOrderId: string,
    headers: IncomingHttpHeaders,
  ): Promise<MembershipOrderResultViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/profile/membership/orders/${encodeURIComponent(membershipOrderId)}`,
        { headers: this.authContext.buildReadOnlyForwardHeaders(headers) },
      );
      return readMembershipOrderResultViewModel(this.requireRecord(result));
    } catch (error) {
      throw this.errors.normalizeOrderResultError(error);
    }
  }

  private requireRecord(value: unknown): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error('Membership purchase response must be an object.');
  }
}
