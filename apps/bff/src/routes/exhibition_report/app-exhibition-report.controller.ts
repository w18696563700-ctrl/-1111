import { Body, Controller, Headers, HttpCode, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ExhibitionReportService } from './exhibition-report.service';

@Controller('api/app/exhibition/report')
export class AppExhibitionReportController {
  constructor(private readonly exhibitionReportService: ExhibitionReportService) {}

  @Post('submit')
  @HttpCode(200)
  submit(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.exhibitionReportService.submit(payload, headers);
  }
}
