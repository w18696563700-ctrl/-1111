import { Body, Controller, Get, Headers, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { EnterpriseHubApplicationReviewAdminQueryService } from './enterprise-hub-application-review-admin.query.service';
import { EnterpriseHubApplicationReviewAdminWriteService } from './enterprise-hub-application-review-admin.write.service';
import { EnterpriseHubAdminService } from './enterprise-hub-admin.service';
import { EnterpriseHubPublishedChangeAdminService } from './enterprise-hub-published-change-admin.service';

@Controller('server/admin/exhibition/enterprise-hub')
export class EnterpriseHubAdminController {
  constructor(
    private readonly applicationReviewQueryService: EnterpriseHubApplicationReviewAdminQueryService,
    private readonly applicationReviewWriteService: EnterpriseHubApplicationReviewAdminWriteService,
    private readonly adminService: EnterpriseHubAdminService,
    private readonly publishedChangeAdminService: EnterpriseHubPublishedChangeAdminService,
  ) {}

  @Get('applications')
  listApplications(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.applicationReviewQueryService.listApplications(
      query,
      resolveRequestContext(headers),
    );
  }

  @Get('applications/:applicationId')
  getApplicationDetail(
    @Param('applicationId') applicationId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.applicationReviewQueryService.getApplicationDetail(
      applicationId,
      resolveRequestContext(headers),
    );
  }

  @Post('applications/:applicationId/review')
  reviewApplication(
    @Param('applicationId') applicationId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.applicationReviewWriteService.reviewApplication(
      applicationId,
      body,
      resolveRequestContext(headers),
    );
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
  listRecommendationSlots(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.adminService.listRecommendationSlots(query, resolveRequestContext(headers));
  }

  @Post('recommendation-slots')
  createRecommendationSlot(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.adminService.createRecommendationSlot(body, resolveRequestContext(headers));
  }

  @Get('change-requests')
  listChangeRequests(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.publishedChangeAdminService.listChangeRequests(
      query,
      resolveRequestContext(headers),
    );
  }

  @Get('change-requests/:changeRequestId')
  getChangeRequestDetail(
    @Param('changeRequestId') changeRequestId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAdminService.getChangeRequestDetail(
      changeRequestId,
      resolveRequestContext(headers),
    );
  }

  @Post('change-requests/:changeRequestId/review')
  reviewChangeRequest(
    @Param('changeRequestId') changeRequestId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAdminService.reviewChangeRequest(
      changeRequestId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Post('change-requests/:changeRequestId/apply')
  applyChangeRequest(
    @Param('changeRequestId') changeRequestId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAdminService.applyChangeRequest(
      changeRequestId,
      resolveRequestContext(headers),
    );
  }
}
