import { Body, Controller, Get, Headers, HttpCode, Param, Patch, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { OrganizationWriteService } from '../organization/organization-write.service';
import { ProfileCertificationWriteService } from './profile-certification-write.service';
import { ProfilePersonalWriteService } from './profile-personal.write.service';
import { ProfileOrganizationMembersQueryService } from './profile-organization-members.query.service';
import { ProfileOrganizationMembersWriteService } from './profile-organization-members.write.service';
import { ProfileBlockService } from './profile-block.service';
import { ProfileQueryService } from './profile-query.service';
import { ProfileSafetyQueryService } from './profile-safety.query.service';
import { ProfileSafetyWriteService } from './profile-safety.write.service';
import { ProfileSecurityQueryService } from './profile-security.query.service';
import { ProfileSecurityWriteService } from './profile-security.write.service';

@Controller('server/profile')
export class ProfileController {
  constructor(
    private readonly queryService: ProfileQueryService,
    private readonly certificationWriteService: ProfileCertificationWriteService,
    private readonly personalWriteService: ProfilePersonalWriteService,
    private readonly safetyWriteService: ProfileSafetyWriteService,
    private readonly safetyQueryService: ProfileSafetyQueryService,
    private readonly organizationWriteService: OrganizationWriteService,
    private readonly organizationMembersQueryService: ProfileOrganizationMembersQueryService,
    private readonly organizationMembersWriteService: ProfileOrganizationMembersWriteService,
    private readonly securityQueryService: ProfileSecurityQueryService,
    private readonly securityWriteService: ProfileSecurityWriteService,
    private readonly blockService: ProfileBlockService
  ) {}

  @Get('index')
  getProfileIndex(@Headers() headers: HeaderBag) {
    return this.queryService.getProfileIndex(resolveRequestContext(headers));
  }

  @Get('organization/mine')
  getOrganizations(@Headers() headers: HeaderBag) {
    return this.queryService.getOrganizations(resolveRequestContext(headers));
  }

  @Post('personal/nickname')
  @HttpCode(200)
  updatePersonalNickname(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.safetyWriteService.updateNickname(body, resolveRequestContext(headers));
  }

  @Post('personal/avatar')
  @HttpCode(200)
  updatePersonalAvatar(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.safetyWriteService.updateAvatar(body, resolveRequestContext(headers));
  }

  @Post('personal/intro')
  @HttpCode(200)
  updatePersonalIntro(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.safetyWriteService.updateIntro(body, resolveRequestContext(headers));
  }

  @Get('personal/safety')
  getPersonalSafetyState(@Headers() headers: HeaderBag) {
    return this.safetyQueryService.getCurrentSafetyState(resolveRequestContext(headers));
  }

  @Post('block')
  @HttpCode(200)
  blockUser(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.blockService.block(body, resolveRequestContext(headers));
  }

  @Post('unblock')
  @HttpCode(200)
  unblockUser(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.blockService.unblock(body, resolveRequestContext(headers));
  }

  @Get('block/status')
  getBlockStatus(@Query('targetUserId') targetUserId: string | undefined, @Headers() headers: HeaderBag) {
    return this.blockService.getStatus(targetUserId, resolveRequestContext(headers));
  }

  @Post('personal/safety/submissions/:submissionId/approve')
  @HttpCode(200)
  approvePersonalSafetySubmission(
    @Param('submissionId') submissionId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.safetyWriteService.approveSubmission(
      submissionId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Post('personal/safety/submissions/:submissionId/reject')
  @HttpCode(200)
  rejectPersonalSafetySubmission(
    @Param('submissionId') submissionId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.safetyWriteService.rejectSubmission(
      submissionId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Get('organization/members')
  getOrganizationMembers(@Headers() headers: HeaderBag) {
    return this.organizationMembersQueryService.getMembers(resolveRequestContext(headers));
  }

  @Post('organization/create')
  createOrganization(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.organizationWriteService.create(body, resolveRequestContext(headers));
  }

  @Post('organization/join-by-code')
  joinOrganizationByCode(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.organizationWriteService.joinByCode(body, resolveRequestContext(headers));
  }

  @Post('organization/switch')
  switchOrganization(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.organizationWriteService.switch(body, resolveRequestContext(headers));
  }

  @Patch('organization/members/:memberId/role')
  patchOrganizationMemberRole(
    @Param('memberId') memberId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.organizationMembersWriteService.patchRole(
      memberId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Patch('organization/members/:memberId/disable')
  patchOrganizationMemberDisable(
    @Param('memberId') memberId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.organizationMembersWriteService.disable(
      memberId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Get('certification/current')
  getCurrentCertification(@Headers() headers: HeaderBag) {
    return this.queryService.getCurrentCertification(resolveRequestContext(headers));
  }

  @Post('certification/submit')
  submitCertification(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.certificationWriteService.submit(body, resolveRequestContext(headers));
  }

  @Post('certification/resubmit')
  resubmitCertification(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.certificationWriteService.resubmit(body, resolveRequestContext(headers));
  }

  @Get('security/devices')
  getSecurityDevices(@Headers() headers: HeaderBag) {
    return this.securityQueryService.getDevices(resolveRequestContext(headers));
  }

  @Post('security/devices/:deviceId/revoke')
  @HttpCode(200)
  revokeSecurityDevice(
    @Param('deviceId') deviceId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.securityWriteService.revokeDevice(deviceId, body, resolveRequestContext(headers));
  }
}
