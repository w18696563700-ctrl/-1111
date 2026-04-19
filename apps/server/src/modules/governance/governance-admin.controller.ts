import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { GovernancePenaltyService } from './governance-penalty.service';

@Controller('server/admin/governance/penalties')
export class GovernanceAdminController {
  constructor(private readonly penaltyService: GovernancePenaltyService) {}

  @Get()
  list(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.penaltyService.list(query, resolveRequestContext(headers));
  }

  @Get(':penaltyId')
  detail(@Param('penaltyId') penaltyId: string, @Headers() headers: HeaderBag) {
    return this.penaltyService.detail(penaltyId, resolveRequestContext(headers));
  }

  @Post()
  @HttpCode(200)
  apply(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.penaltyService.apply(body, resolveRequestContext(headers));
  }
}
