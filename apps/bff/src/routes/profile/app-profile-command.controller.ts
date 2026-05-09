import { Body, Controller, Headers, HttpCode, Param, Patch, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { rcFeatureDisabled } from '../../core/rc/rc-feature-disabled';
import { ProfileBlockService } from './profile-block.service';
import { ProfileCommandService } from './profile-command.service';
import { ProfileMembershipPurchaseService } from './profile-membership-purchase.service';
import { ProfileMembersService } from './profile-members.service';
import { ProfileOrganizationLeaveService } from './profile-organization-leave.service';
import { ProfileSafetyService } from './profile-safety.service';
import { ProfileSecurityService } from './profile-security.service';

@Controller('api/app/profile')
export class AppProfileCommandController {
  constructor(
    private readonly profileCommandService: ProfileCommandService,
    private readonly profileBlockService: ProfileBlockService,
    private readonly profileMembershipPurchaseService: ProfileMembershipPurchaseService,
    private readonly profileMembersService: ProfileMembersService,
    private readonly profileOrganizationLeaveService: ProfileOrganizationLeaveService,
    private readonly profileSafetyService: ProfileSafetyService,
    private readonly profileSecurityService: ProfileSecurityService,
  ) {}

  @Post('organization/create')
  createOrganization(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.createOrganization(body, headers);
  }

  @Patch('organization/current')
  @HttpCode(200)
  patchCurrentOrganization(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.updateCurrentOrganization(body, headers);
  }

  @Post('block')
  @HttpCode(200)
  block(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileBlockService.block(body, headers);
  }

  @Post('unblock')
  @HttpCode(200)
  unblock(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileBlockService.unblock(body, headers);
  }

  @Post('membership/orders')
  @HttpCode(201)
  createMembershipOrder(
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('membership_purchase_order');
    return this.profileMembershipPurchaseService.createOrder(body, headers);
  }

  @Post('membership/orders/:membershipOrderId/pay-init')
  @HttpCode(202)
  initMembershipOrderPayment(
    @Param('membershipOrderId') membershipOrderId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('membership_purchase_payment');
    return this.profileMembershipPurchaseService.payInit(membershipOrderId, body, headers);
  }

  @Post('organization/join-by-code')
  joinOrganizationByCode(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.joinOrganizationByCode(body, headers);
  }

  @Post('organization/switch')
  switchOrganization(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.switchOrganization(body, headers);
  }

  @Post('organization/current/leave')
  @HttpCode(200)
  leaveCurrentOrganization(
    @Body() body: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileOrganizationLeaveService.leaveCurrentOrganization(body, headers);
  }

  @Post('certification/submit')
  submitCertification(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.submitCertification(body, headers);
  }

  @Post('certification/license/ocr')
  @HttpCode(200)
  recognizeCertificationLicense(
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileCommandService.recognizeCertificationLicense(body, headers);
  }

  @Post('certification/personal/id-card/ocr')
  @HttpCode(200)
  recognizePersonalCertificationIdCard(
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileCommandService.recognizePersonalCertificationIdCard(body, headers);
  }

  @Post('certification/personal/submit')
  @HttpCode(200)
  submitPersonalCertification(
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileCommandService.submitPersonalCertification(body, headers);
  }

  @Post('certification/resubmit')
  @HttpCode(200)
  resubmitCertification(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.resubmitCertification(body, headers);
  }

  @Post('certification/revalidate')
  @HttpCode(200)
  revalidateCertification(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.revalidateCertification(body, headers);
  }

  @Post('personal/nickname')
  @HttpCode(200)
  updatePersonalNickname(
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileSafetyService.submitNickname(body as { nickname: string }, headers);
  }

  @Post('personal/avatar')
  @HttpCode(200)
  updatePersonalAvatar(
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileSafetyService.submitAvatar(body as { fileAssetId: string }, headers);
  }

  @Post('personal/bio')
  @HttpCode(200)
  updatePersonalBio(
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileSafetyService.submitBio(body as { bio: string }, headers);
  }

  @Patch('organization/members/:memberId/role')
  @HttpCode(200)
  patchOrganizationMemberRole(
    @Param('memberId') memberId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileMembersService.patchOrganizationMemberRole(memberId, body, headers);
  }

  @Patch('organization/members/:memberId/disable')
  @HttpCode(200)
  disableOrganizationMember(
    @Param('memberId') memberId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileMembersService.disableOrganizationMember(memberId, body, headers);
  }

  @Post('security/devices/:deviceId/revoke')
  @HttpCode(200)
  revokeSecurityDevice(
    @Param('deviceId') deviceId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.profileSecurityService.revokeSecurityDevice(deviceId, body, headers);
  }
}
