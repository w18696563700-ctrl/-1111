import { Body, Controller, Get, Headers, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { OrganizationReviewQueryService } from './organization-review-query.service';
import { OrganizationReviewWriteService } from './organization-review-write.service';

@Controller('server/admin/reviews/organizations')
export class OrganizationReviewController {
  constructor(
    private readonly queryService: OrganizationReviewQueryService,
    private readonly writeService: OrganizationReviewWriteService
  ) {}

  @Get()
  list(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.queryService.list(query, resolveRequestContext(headers));
  }

  @Get(':organizationId')
  detail(@Param('organizationId') organizationId: string, @Headers() headers: HeaderBag) {
    return this.queryService.detail(organizationId, resolveRequestContext(headers));
  }

  @Post(':organizationId/approve')
  approve(
    @Param('organizationId') organizationId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.approve(organizationId, body, resolveRequestContext(headers));
  }

  @Post(':organizationId/reject')
  reject(
    @Param('organizationId') organizationId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.reject(organizationId, body, resolveRequestContext(headers));
  }
}
