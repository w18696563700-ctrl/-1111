import { Body, Controller, Headers, HttpCode, Param, Patch, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProfileBlockService } from './profile-block.service';
import { ProfileCommandService } from './profile-command.service';
import { ProfileMembersService } from './profile-members.service';
import { ProfileSafetyService } from './profile-safety.service';
import { ProfileSecurityService } from './profile-security.service';

@Controller('bff/profile')
export class ProfileCommandController {
  constructor(
    private readonly profileCommandService: ProfileCommandService,
    private readonly profileBlockService: ProfileBlockService,
    private readonly profileMembersService: ProfileMembersService,
    private readonly profileSafetyService: ProfileSafetyService,
    private readonly profileSecurityService: ProfileSecurityService,
  ) {}

  @Post('organization/create')
  createOrganization(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.createOrganization(body, headers);
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

  @Post('organization/join-by-code')
  joinOrganizationByCode(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.joinOrganizationByCode(body, headers);
  }

  @Post('organization/switch')
  switchOrganization(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.switchOrganization(body, headers);
  }

  @Post('certification/submit')
  submitCertification(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.submitCertification(body, headers);
  }

  @Post('certification/resubmit')
  @HttpCode(200)
  resubmitCertification(@Body() body: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.profileCommandService.resubmitCertification(body, headers);
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
