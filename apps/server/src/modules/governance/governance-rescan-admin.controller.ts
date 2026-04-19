import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { GovernanceRescanJobService } from './governance-rescan-job.service';

@Controller('server/admin/governance/rescan-jobs')
export class GovernanceRescanAdminController {
  constructor(private readonly rescanJobService: GovernanceRescanJobService) {}

  @Post()
  @HttpCode(200)
  create(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.rescanJobService.create(body, resolveRequestContext(headers));
  }

  @Get()
  list(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.rescanJobService.list(query, resolveRequestContext(headers));
  }

  @Get(':rescanJobId')
  detail(@Param('rescanJobId') rescanJobId: string, @Headers() headers: HeaderBag) {
    return this.rescanJobService.detail(rescanJobId, resolveRequestContext(headers));
  }
}
