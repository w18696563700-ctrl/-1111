import { Controller, Get, Headers, Param, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProfileBlockService } from './profile-block.service';
import { ProfileCreditConstraintsService } from './profile-credit-constraints.service';
import { ProfileGovernanceAppealsService } from './profile-governance-appeals.service';
import { ProfileGovernanceStatusService } from './profile-governance-status.service';
import { ProfilePaymentBillingStatusService } from './profile-payment-billing-status.service';
import { ProfileOrganizationCreditScoringService } from './profile-organization-credit-scoring.service';
import { ProfileMembershipService } from './profile-membership.service';
import { ProfileMembersService } from './profile-members.service';
import { ProfileReadService } from './profile-read.service';
import { ProfileSafetyService } from './profile-safety.service';
import { ProfileSecurityService } from './profile-security.service';

@Controller('api/app/profile')
export class AppProfileReadController {
  constructor(
    private readonly profileReadService: ProfileReadService,
    private readonly profileBlockService: ProfileBlockService,
    private readonly profileCreditConstraintsService: ProfileCreditConstraintsService,
    private readonly profileOrganizationCreditScoringService: ProfileOrganizationCreditScoringService,
    private readonly profilePaymentBillingStatusService: ProfilePaymentBillingStatusService,
    private readonly profileMembershipService: ProfileMembershipService,
    private readonly profileMembersService: ProfileMembersService,
    private readonly profileSafetyService: ProfileSafetyService,
    private readonly profileSecurityService: ProfileSecurityService,
    private readonly profileGovernanceAppealsService: ProfileGovernanceAppealsService,
    private readonly profileGovernanceStatusService: ProfileGovernanceStatusService,
  ) {}

  @Get('index')
  getProfileIndex(@Headers() headers: IncomingHttpHeaders) {
    return this.profileReadService.getProfileIndex(headers);
  }

  @Get('organization/mine')
  getOrganizations(@Headers() headers: IncomingHttpHeaders) {
    return this.profileReadService.getOrganizations(headers);
  }

  @Get('block/status')
  getBlockStatus(
    @Query() query: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileBlockService.getStatus(query, headers);
  }

  @Get('credit-and-constraints/status')
  getCreditAndConstraintsStatus(@Headers() headers: IncomingHttpHeaders) {
    return this.profileCreditConstraintsService.getStatus(headers);
  }

  @Get('credit-and-constraints/explanation')
  getCreditAndConstraintsExplanation(@Headers() headers: IncomingHttpHeaders) {
    return this.profileCreditConstraintsService.getExplanation(headers);
  }

  @Get('credit-and-constraints/handoff')
  getCreditAndConstraintsHandoff(@Headers() headers: IncomingHttpHeaders) {
    return this.profileCreditConstraintsService.getHandoff(headers);
  }

  @Get('organization-credit-scoring/status')
  getOrganizationCreditScoringStatus(@Headers() headers: IncomingHttpHeaders) {
    return this.profileOrganizationCreditScoringService.getStatus(headers);
  }

  @Get('organization-credit-scoring/explanation')
  getOrganizationCreditScoringExplanation(@Headers() headers: IncomingHttpHeaders) {
    return this.profileOrganizationCreditScoringService.getExplanation(headers);
  }

  @Get('organization-credit-scoring/handoff')
  getOrganizationCreditScoringHandoff(@Headers() headers: IncomingHttpHeaders) {
    return this.profileOrganizationCreditScoringService.getHandoff(headers);
  }

  @Get('payment-and-billing-status/status')
  getPaymentAndBillingStatus(@Headers() headers: IncomingHttpHeaders) {
    return this.profilePaymentBillingStatusService.getStatus(headers);
  }

  @Get('payment-and-billing-status/explanation')
  getPaymentAndBillingExplanation(@Headers() headers: IncomingHttpHeaders) {
    return this.profilePaymentBillingStatusService.getExplanation(headers);
  }

  @Get('payment-and-billing-status/handoff')
  getPaymentAndBillingHandoff(@Headers() headers: IncomingHttpHeaders) {
    return this.profilePaymentBillingStatusService.getHandoff(headers);
  }

  @Get('membership/current')
  getMembershipCurrent(@Headers() headers: IncomingHttpHeaders) {
    return this.profileMembershipService.getCurrent(headers);
  }

  @Get('membership/explanation')
  getMembershipExplanation(@Headers() headers: IncomingHttpHeaders) {
    return this.profileMembershipService.getExplanation(headers);
  }

  @Get('membership/quota')
  getMembershipQuota(@Headers() headers: IncomingHttpHeaders) {
    return this.profileMembershipService.getQuota(headers);
  }

  @Get('membership/upgrade-guide')
  getMembershipUpgradeGuide(@Headers() headers: IncomingHttpHeaders) {
    return this.profileMembershipService.getUpgradeGuide(headers);
  }

  @Get('personal/safety')
  getPersonalSafetyStatus(@Headers() headers: IncomingHttpHeaders) {
    return this.profileSafetyService.getSafetyStatus(headers);
  }

  @Get('organization/members')
  getOrganizationMembers(@Headers() headers: IncomingHttpHeaders) {
    return this.profileMembersService.getOrganizationMembers(headers);
  }

  @Get('certification/current')
  getCurrentCertification(@Headers() headers: IncomingHttpHeaders) {
    return this.profileReadService.getCurrentCertification(headers);
  }

  @Get('governance/status')
  getGovernanceStatus(@Headers() headers: IncomingHttpHeaders) {
    return this.profileGovernanceStatusService.getStatus(headers);
  }

  @Get('governance/appeals')
  getGovernanceAppeals(
    @Headers() headers: IncomingHttpHeaders,
    @Query() query: Record<string, unknown>,
  ) {
    return this.profileGovernanceAppealsService.getAppeals(headers, query);
  }

  @Get('governance/appeals/:appealCaseId')
  getGovernanceAppealDetail(
    @Headers() headers: IncomingHttpHeaders,
    @Param('appealCaseId') appealCaseId: string,
  ) {
    return this.profileGovernanceAppealsService.getAppealDetail(headers, appealCaseId);
  }

  @Get('security/devices')
  getSecurityDevices(@Headers() headers: IncomingHttpHeaders) {
    return this.profileSecurityService.getSecurityDevices(headers);
  }
}
