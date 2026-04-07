import { Body, Controller, Get, Headers, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { EnterpriseHubAdminService } from './enterprise-hub-admin.service';

@Controller('server/admin/exhibition/enterprise-hub')
export class EnterpriseHubAdminController {
  constructor(private readonly adminService: EnterpriseHubAdminService) {}

  @Get('applications')
  listApplications(@Query() query: Record<string, unknown>) {
    return this.adminService.listApplications(query);
  }

  @Get('applications/:applicationId')
  getApplicationDetail(@Param('applicationId') applicationId: string) {
    return this.adminService.getApplicationDetail(applicationId);
  }

  @Post('applications/:applicationId/review')
  reviewApplication(
    @Param('applicationId') applicationId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.adminService.reviewApplication(applicationId, body, resolveRequestContext(headers));
  }

  @Post('enterprises/:enterpriseId/publish')
  publishListing(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.adminService.publishListing(enterpriseId, body, resolveRequestContext(headers));
  }

  @Post('enterprises/:enterpriseId/offline')
  offlineListing(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.adminService.offlineListing(enterpriseId, body, resolveRequestContext(headers));
  }

  @Post('enterprises/:enterpriseId/freeze')
  freezeListing(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.adminService.freezeListing(enterpriseId, body, resolveRequestContext(headers));
  }

  @Get('recommendation-slots')
  listRecommendationSlots(@Query() query: Record<string, unknown>) {
    return this.adminService.listRecommendationSlots(query);
  }

  @Post('recommendation-slots')
  createRecommendationSlot(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.adminService.createRecommendationSlot(body, resolveRequestContext(headers));
  }
}
