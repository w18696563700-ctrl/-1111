import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ExhibitionReportCaseService } from './exhibition-report-case.service';

@Controller('server/admin/exhibition/report-cases')
export class ExhibitionReportCaseAdminController {
  constructor(private readonly reportCaseService: ExhibitionReportCaseService) {}

  @Get()
  list(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.reportCaseService.list(query, resolveRequestContext(headers));
  }

  @Get(':reportCaseId')
  detail(@Param('reportCaseId') reportCaseId: string, @Headers() headers: HeaderBag) {
    return this.reportCaseService.detail(reportCaseId, resolveRequestContext(headers));
  }

  @Post(':reportCaseId/request-explanation')
  @HttpCode(200)
  requestExplanation(
    @Param('reportCaseId') reportCaseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.reportCaseService.requestExplanation(
      reportCaseId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Post(':reportCaseId/decide')
  @HttpCode(200)
  decide(
    @Param('reportCaseId') reportCaseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.reportCaseService.decide(reportCaseId, body, resolveRequestContext(headers));
  }

  @Post(':reportCaseId/escalate')
  @HttpCode(200)
  escalate(
    @Param('reportCaseId') reportCaseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.reportCaseService.escalate(reportCaseId, body, resolveRequestContext(headers));
  }
}
