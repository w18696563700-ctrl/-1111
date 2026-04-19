import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { GovernanceAppealService } from './governance-appeal.service';

@Controller('server/admin/governance/appeals')
export class GovernanceAppealAdminController {
  constructor(private readonly appealService: GovernanceAppealService) {}

  @Get()
  list(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.appealService.list(query, resolveRequestContext(headers));
  }

  @Get(':appealCaseId')
  detail(@Param('appealCaseId') appealCaseId: string, @Headers() headers: HeaderBag) {
    return this.appealService.detail(appealCaseId, resolveRequestContext(headers));
  }

  @Post(':appealCaseId/decide')
  @HttpCode(200)
  decide(
    @Param('appealCaseId') appealCaseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.appealService.decide(appealCaseId, body, resolveRequestContext(headers));
  }
}
