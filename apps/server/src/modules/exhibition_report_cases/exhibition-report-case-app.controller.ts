import { Body, Controller, Headers, HttpCode, Post } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ExhibitionReportCaseService } from './exhibition-report-case.service';

@Controller('server/exhibition/report')
export class ExhibitionReportCaseAppController {
  constructor(private readonly reportCaseService: ExhibitionReportCaseService) {}

  @Post('submit')
  @HttpCode(200)
  submit(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.reportCaseService.submit(body, resolveRequestContext(headers));
  }
}
